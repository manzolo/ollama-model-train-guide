# Guida al deployment dei modelli

Questa guida spiega come salvare, distribuire e gestire i modelli su più istanze self-hosted di Ollama.

## Panoramica

Quando lavori con servizi Ollama self-hosted, spesso hai bisogno di:
- Distribuire modelli personalizzati sui server di produzione
- Condividere modelli tra ambienti di sviluppo e staging
- Fare il backup dei modelli per il disaster recovery
- Trasferire modelli tra i membri del team

Questo progetto include script e comandi make per semplificare questi flussi di lavoro.

## Avvio rapido

### Salvare un modello

Salva il Modelfile di un modello per il deployment:

```bash
# Interactive
make save-model

# Or specify directly
bash scripts/save-model.sh my-chatbot

# Save to custom location
bash scripts/save-model.sh my-chatbot ./backups/production
```

Questo crea un Modelfile in `./models/saved/my-chatbot.Modelfile` (o nella posizione specificata).

### Distribuire un modello

Distribuisci un Modelfile salvato all'istanza Ollama corrente:

```bash
# Interactive
make deploy-model

# Or specify directly
bash scripts/deploy-model.sh ./models/saved/my-chatbot.Modelfile

# Deploy with a different name
bash scripts/deploy-model.sh ./models/saved/my-chatbot.Modelfile production-chatbot
```

### Fare il backup di tutti i modelli

Crea un backup con timestamp di tutti i modelli personalizzati:

```bash
# Default location: ./backups/models/YYYYMMDD_HHMMSS/
make backup-models

# Or specify custom location
bash scripts/backup-models.sh /mnt/backup/ollama-models
```

### Export/import completo (pesi inclusi)

`make save-model` esporta solo la *ricetta* (Modelfile): l'istanza di destinazione deve
ri-scaricare il modello base dalla libreria di Ollama. Quando la destinazione è air-gapped
o su una connessione lenta, esporta invece il modello **con i suoi pesi**:

```bash
# Interactive
make export-full

# Or specify directly (default output: ./backups/full/)
bash scripts/export-model-full.sh my-chatbot
bash scripts/export-model-full.sh llama3.2:1b ./exports
```

Questo crea un archivio tar contenente il manifest del modello e tutti i suoi blob
(pesi, system prompt, parametri). Trasferiscilo sulla macchina di destinazione, poi:

```bash
# Interactive (lists archives in ./backups/full/)
make import-full

# Or specify directly
bash scripts/import-model-full.sh ./backups/full/my-chatbot-20260704_120000.tar
```

Il modello è disponibile immediatamente dopo l'import — non viene scaricato nulla.

**Note:**
- Gli archivi includono i pesi completi: aspettati **1-5 GB+** per modello. Per la condivisione
  quotidiana tra istanze connesse, `make save-model` resta l'opzione migliore.
- Il layout dell'archivio è il formato di storage interno di Ollama. Mantieni origine e destinazione
  su versioni di Ollama simili — fissa `OLLAMA_IMAGE_TAG` nel file `.env` su entrambi i lati.
- I blob sono content-addressed: importare un modello i cui blob di base esistono già
  sulla destinazione li sovrascrive semplicemente (nessuna duplicazione).

## Flussi di lavoro di deployment

### Flusso 1: Dallo sviluppo alla produzione

1. **Sul server di sviluppo**, crea e testa il tuo modello:
   ```bash
   # Create custom model
   bash scripts/create-custom-model.sh my-app-assistant ./models/custom/app-assistant/Modelfile

   # Test it
   docker compose exec ollama ollama run my-app-assistant "Test prompt"
   ```

2. **Salva il modello**:
   ```bash
   bash scripts/save-model.sh my-app-assistant
   # Creates: ./models/saved/my-app-assistant.Modelfile
   ```

3. **Trasferisci al server di produzione**:
   ```bash
   scp ./models/saved/my-app-assistant.Modelfile user@prod-server:/opt/ollama/models/saved/
   ```

4. **Sul server di produzione**, esegui il deployment:
   ```bash
   cd /opt/ollama
   bash scripts/deploy-model.sh ./models/saved/my-app-assistant.Modelfile
   ```

5. **Verifica il deployment**:
   ```bash
   docker compose exec ollama ollama list
   docker compose exec ollama ollama run my-app-assistant "Test prompt"
   ```

### Flusso 2: Collaborazione di team

Condividi i modelli tramite il version control:

1. **Lo sviluppatore A** crea un modello:
   ```bash
   bash scripts/create-custom-model.sh team-assistant ./models/custom/team/Modelfile
   bash scripts/save-model.sh team-assistant ./models/custom/team/
   ```

2. **Fai il commit nel repository**:
   ```bash
   git add models/custom/team/
   git commit -m "Add team assistant model"
   git push
   ```

3. **Lo sviluppatore B** fa il pull ed esegue il deployment:
   ```bash
   git pull
   bash scripts/deploy-model.sh ./models/custom/team/team-assistant.Modelfile
   ```

### Flusso 3: Disaster recovery

Backup regolari garantiscono la possibilità di recuperare da una perdita di dati:

1. **Pianifica backup regolari** (ad esempio un cron job giornaliero):
   ```bash
   # Add to crontab
   0 2 * * * cd /opt/ollama && bash scripts/backup-models.sh /mnt/backup/ollama
   ```

2. **Se si verifica un disastro**, ripristina dal backup:
   ```bash
   # List available backups
   ls -la /mnt/backup/ollama/

   # Deploy models from specific backup
   for modelfile in /mnt/backup/ollama/20240315_020000/*.Modelfile; do
       bash scripts/deploy-model.sh "$modelfile"
   done
   ```

### Flusso 4: Deployment multi-ambiente

Distribuisci lo stesso modello su dev, staging e prod:

1. **Crea un Modelfile master** nel version control:
   ```bash
   # models/production/customer-support/Modelfile
   FROM llama3.2:3b
   PARAMETER temperature 0.6
   SYSTEM """You are a helpful customer support assistant..."""
   ```

2. **Distribuisci su tutti gli ambienti**:
   ```bash
   # Development
   ssh dev-server "cd /opt/ollama && bash scripts/deploy-model.sh ./models/production/customer-support/Modelfile"

   # Staging
   ssh stage-server "cd /opt/ollama && bash scripts/deploy-model.sh ./models/production/customer-support/Modelfile"

   # Production
   ssh prod-server "cd /opt/ollama && bash scripts/deploy-model.sh ./models/production/customer-support/Modelfile"
   ```

## Cosa viene salvato/distribuito?

### Salvato nel Modelfile
- Riferimento al modello base (FROM)
- Tutti i parametri (temperature, num_ctx, ecc.)
- System prompt (SYSTEM)
- Template personalizzato (TEMPLATE, se definito)
- Esempi few-shot (MESSAGE, se definiti)
- Riferimenti agli adapter (ADAPTER, se definiti)

### NON salvato nel Modelfile
- **Pesi del modello base**: Il modello sottostante (ad esempio llama3.2:3b) deve essere disponibile sull'istanza di destinazione
- **File GGUF**: I file di modello esterni devono essere copiati separatamente
- **Adapter LoRA**: I file degli adapter devono essere trasferiti separatamente

## Note importanti

### Disponibilità del modello base

Quando distribuisci un Modelfile, l'istanza di destinazione deve avere accesso al modello base:

```dockerfile
FROM llama3.2:3b  # This model must exist on target instance
```

**Prima del deployment**, assicurati che il modello base sia disponibile:
```bash
# On target instance
docker compose exec ollama ollama pull llama3.2:3b
```

### Modelli GGUF esterni

Se il tuo modello usa un file GGUF locale:

```dockerfile
FROM /data/gguf/my-custom-model.gguf
```

Devi trasferire il file GGUF separatamente:
```bash
scp ./data/gguf/my-custom-model.gguf user@target:/opt/ollama/data/gguf/
```

### Adapter LoRA

Se il tuo modello usa gli adapter:

```dockerfile
FROM llama3.2:3b
ADAPTER /data/adapters/my-adapter.bin
```

Trasferisci il file dell'adapter:
```bash
scp ./data/adapters/my-adapter.bin user@target:/opt/ollama/data/adapters/
```

## Script di automazione

### Esempio di script di deployment automatizzato

Crea uno script per automatizzare il deployment:

```bash
#!/bin/bash
# deploy-to-production.sh

MODEL_NAME=$1
PROD_SERVER="user@prod-server"
PROD_PATH="/opt/ollama"

# Save model
bash scripts/save-model.sh "$MODEL_NAME"

# Transfer
scp "./models/saved/${MODEL_NAME}.Modelfile" "$PROD_SERVER:$PROD_PATH/models/saved/"

# Deploy remotely
ssh "$PROD_SERVER" "cd $PROD_PATH && bash scripts/deploy-model.sh ./models/saved/${MODEL_NAME}.Modelfile"

echo "✅ Deployed $MODEL_NAME to production"
```

### Esempio di script di backup automatizzato

```bash
#!/bin/bash
# backup-to-s3.sh

BACKUP_DIR="/tmp/ollama-backup"

# Create backup
bash scripts/backup-models.sh "$BACKUP_DIR"

# Upload to S3
LATEST_BACKUP=$(ls -t "$BACKUP_DIR" | head -1)
aws s3 sync "$BACKUP_DIR/$LATEST_BACKUP" "s3://my-bucket/ollama-backups/$LATEST_BACKUP/"

# Cleanup local backup
rm -rf "$BACKUP_DIR"

echo "✅ Backup uploaded to S3"
```

## Risoluzione dei problemi

### Modello non trovato dopo il deployment

**Problema**: Il modello distribuito non compare in `ollama list`

**Soluzioni**:
1. Verifica che il modello base esista: `docker compose exec ollama ollama pull <base-model>`
2. Controlla la sintassi del Modelfile: cerca errori nell'output del deployment
3. Verifica che il container abbia accesso ai file referenziati (GGUF, adapter)

### Comportamento diverso sull'istanza di destinazione

**Problema**: Il modello si comporta diversamente sulla destinazione rispetto all'origine

**Cause possibili**:
1. Versioni diverse del modello base
2. File degli adapter mancanti
3. Differenze hardware (CPU vs GPU)

**Soluzione**: Assicurati che i modelli base siano identici e che tutte le dipendenze siano presenti

### Lo script di backup salta alcuni modelli

**Problema**: Alcuni modelli non sono inclusi nei backup

**Motivo**: Lo script esporta solo i modelli personalizzati, non i modelli base dalla libreria di Ollama

**Soluzione**: Questo è il comportamento previsto. I modelli base dovrebbero essere scaricati dalla libreria di Ollama sulle istanze di destinazione

## Best practice

1. **Version control**: Mantieni i Modelfile in Git per tracciare le modifiche
2. **Convenzione di denominazione**: Usa nomi descrittivi (ad esempio `customer-support-v2`, `code-assistant-python`)
3. **Backup regolari**: Pianifica backup automatizzati per i modelli personalizzati
4. **Testa prima della produzione**: Testa sempre i deployment prima in staging
5. **Documenta le dipendenze**: Annota i modelli base e gli adapter nel README o nella documentazione
6. **Parità tra ambienti**: Usa le stesse versioni del modello base tra gli ambienti

## Vedi anche

- [Riferimento Modelfile](./modelfile-reference.md)
- [Guida al fine-tuning](./fine-tuning-guide.md)
- [Uso delle API](./api-usage.md)
