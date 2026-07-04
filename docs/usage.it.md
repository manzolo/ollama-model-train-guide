# Guida all'utilizzo

Guida completa alla gestione del tuo ambiente Ollama e all'uso dei modelli.

## Gestione dell'ambiente

### Avvio e arresto dei servizi

**Avvia tutti i servizi** (Ollama + Chat UI):
```bash
make up
```

**Avvia solo Ollama** (senza interfaccia web di chat):
```bash
make up-core
```

**Avvia con accelerazione GPU NVIDIA** (usa l'override `docker-compose.gpu.yml`):
```bash
make up-gpu
```

**Arresta tutti i servizi**:
```bash
make down
```

**Riavvia i servizi**:
```bash
make restart
```

**Nota**: dopo aver modificato porte o altri valori in `.env`, usa `make down && make up` (un semplice riavvio non rilegge le mappature delle porte).

**Verifica lo stato dei servizi**:
```bash
docker compose ps
```

### Monitoraggio e log

**Visualizza i log in tempo reale**:
```bash
make logs

# Oppure per un servizio specifico
docker compose logs -f ollama
docker compose logs -f chat
```

**Accedi alla shell del container**:
```bash
make shell

# Oppure direttamente
docker compose exec ollama bash
```

### Pulizia

**Rimuovi tutti i container e volumi** (elimina tutti i modelli):
```bash
make clean
```

**Pulizia parziale** (mantieni i volumi):
```bash
make down
```

## Lavorare con i modelli

### Elencare i modelli

**Elenca tutti i modelli installati**:
```bash
make list-models

# Oppure direttamente
docker compose exec ollama ollama list
```

Questo mostra:
- Nomi dei modelli
- Dimensione su disco
- ID del modello
- Data dell'ultima modifica

### Scaricare i modelli

**Tramite Web UI** (consigliato):
1. Apri `http://localhost:8080`
2. Clicca su "Manage Models"
3. Inserisci il nome del modello (es. `llama3.2`, `mistral:7b`, `phi3:mini`)
4. Clicca su "Pull Model"
5. Osserva l'avanzamento in tempo reale con velocità di download ed ETA

**Tramite CLI**:
```bash
# Scarica i modelli base più comuni
make pull-base

# Scarica un modello specifico
docker compose exec ollama ollama pull <model-name>

# Esempi:
docker compose exec ollama ollama pull llama3.2:1b
docker compose exec ollama ollama pull mistral:7b
docker compose exec ollama ollama pull codellama:13b
```

**Modelli disponibili**: consulta la [Libreria Ollama](https://ollama.com/library) per tutti i modelli.

### Creare modelli personalizzati

I modelli personalizzati vengono definiti tramite i Modelfile (simili ai Dockerfile).

**Creazione interattiva** (con selezione a menu):
```bash
make create-model
```

Questo comando:
1. Mostra un elenco numerato dei Modelfile disponibili
2. Ti permette di selezionarne uno
3. Chiede un nome per il modello
4. Crea il modello

**Creazione diretta**:
```bash
bash scripts/create-custom-model.sh <model-name> <modelfile-path>

# Esempi:
bash scripts/create-custom-model.sh my-chatbot ./models/examples/chatbot/Modelfile
bash scripts/create-custom-model.sh code-helper ./models/custom/code-assistant/Modelfile
```

**Creare il tuo Modelfile**:

Crea un file in `./models/custom/my-model/Modelfile`:

```dockerfile
# Base model (must be pulled first)
FROM llama3.2:1b

# Model parameters
PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1

# System prompt (defines behavior)
SYSTEM """
You are a helpful assistant specialized in [your use case].
[Define specific behavior, constraints, and personality here]
"""

# Optional: Few-shot examples
MESSAGE user "Example question?"
MESSAGE assistant "Example answer."
```

Poi crea il modello:
```bash
bash scripts/create-custom-model.sh my-model ./models/custom/my-model/Modelfile
```

Consulta il [Riferimento Modelfile](./modelfile-reference.md) per la sintassi completa.

### Chattare con i modelli

**Chat interattiva** (tramite CLI):
```bash
make chat
# Seleziona da un elenco numerato di modelli
```

Oppure direttamente:
```bash
docker compose exec ollama ollama run <model-name>

# Esempi:
docker compose exec ollama ollama run llama3.2:1b
docker compose exec ollama ollama run my-chatbot
```

**Prompt singolo** (non interattivo):
```bash
docker compose exec ollama ollama run <model-name> "Your prompt here"

# Esempio:
docker compose exec ollama ollama run llama3.2:1b "Write a haiku about Docker"
```

**Tramite Web UI**:
1. Apri `http://localhost:8080`
2. Seleziona il modello dal menu a discesa
3. Inizia a chattare!

Consulta la [Guida alla Chat UI](./chat-ui.md) per le funzionalità dell'interfaccia web.

### Usare l'API

**Genera un completamento**:
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:1b",
  "prompt": "Why is the sky blue?",
  "stream": false
}'
```

**Completamento di chat** (con cronologia della conversazione):
```bash
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2:1b",
  "messages": [
    {"role": "user", "content": "Hello!"},
    {"role": "assistant", "content": "Hi! How can I help?"},
    {"role": "user", "content": "What is Docker?"}
  ],
  "stream": false
}'
```

**Elenca i modelli**:
```bash
curl http://localhost:11434/api/tags
```

**Mostra le informazioni del modello**:
```bash
curl http://localhost:11434/api/show -d '{
  "name": "llama3.2:1b"
}'
```

Consulta la [Guida all'uso dell'API](./api-usage.md) per la documentazione completa dell'API.

## Salvare e distribuire i modelli

### Esportare la configurazione del modello

**Salva un modello per il deployment** (interattivo):
```bash
make save-model
```

Oppure direttamente:
```bash
bash scripts/save-model.sh <model-name> [output-directory]

# Esempi:
bash scripts/save-model.sh my-chatbot
bash scripts/save-model.sh my-chatbot ./custom-output
```

Questo salva il Modelfile in `./models/saved/<model-name>.Modelfile`

**Esporta il Modelfile del modello**:
```bash
bash scripts/export-model.sh <model-name> <output-path>

# Esempio:
bash scripts/export-model.sh my-chatbot ./my-chatbot-v1.Modelfile
```

### Distribuire su un'altra istanza

**Trasferisci il Modelfile al server di destinazione**:
```bash
scp ./models/saved/my-chatbot.Modelfile user@server:/path/to/ollama-project/models/saved/
```

**Distribuisci sull'istanza di destinazione** (interattivo):
```bash
make deploy-model
```

Oppure direttamente:
```bash
bash scripts/deploy-model.sh <modelfile-path> [model-name]

# Esempio:
bash scripts/deploy-model.sh ./models/saved/my-chatbot.Modelfile my-chatbot
```

### Backup di tutti i modelli

**Crea un backup con timestamp**:
```bash
make backup-models

# Oppure direttamente:
bash scripts/backup-models.sh [output-directory]
```

Questo crea un backup in `./backups/models/YYYYMMDD_HHMMSS/` contenente i Modelfile di tutti i tuoi modelli personalizzati.

## Importare modelli esterni

### Importare file GGUF

Se disponi di un file di modello GGUF (da Hugging Face, fine-tuning, ecc.):

1. **Colloca il file GGUF nella directory data**:
   ```bash
   cp /path/to/model.gguf ./data/gguf/
   ```

2. **Importa il modello**:
   ```bash
   bash scripts/import-model.sh <model-name> ./data/gguf/model.gguf

   # Esempio:
   bash scripts/import-model.sh my-custom-model ./data/gguf/my-model.gguf
   ```

3. **Usa il modello**:
   ```bash
   docker compose exec ollama ollama run my-custom-model
   ```

### Usare gli adapter LoRA

Se disponi di un file di adapter LoRA:

1. **Colloca l'adapter nella directory data**:
   ```bash
   cp /path/to/adapter.bin ./data/adapters/
   ```

2. **Crea un Modelfile** in `./models/custom/adapted-model/Modelfile`:
   ```dockerfile
   FROM llama3.2:1b
   ADAPTER /data/adapters/my-adapter.bin

   PARAMETER temperature 0.7

   SYSTEM """
   You are a specialized assistant.
   """
   ```

3. **Crea il modello**:
   ```bash
   bash scripts/create-custom-model.sh adapted-model ./models/custom/adapted-model/Modelfile
   ```

## Parametri del modello

Panoramica rapida dei parametri che puoi regolare nei Modelfile:

| Parametro | Intervallo | Consigliato | Scopo |
|-----------|-------|-------------|---------|
| `temperature` | 0.0-2.0 | 0.7 (0.3 fattuale, 1.2 creativo) | Casualità / creatività |
| `num_ctx` | 512-32768 | 4096 | Finestra di contesto (token memorizzati) |
| `top_p` | 0.0-1.0 | 0.9 | Nucleus sampling / diversità dell'output |
| `top_k` | 1-100 | 40 | Dimensione del pool di selezione dei token |
| `repeat_penalty` | 0.0-2.0 | 1.1 | Controllo delle ripetizioni |

**La [Guida ai parametri](./parameter-guide.md) è il riferimento canonico** — contiene preset pronti da copiare e incollare per ogni caso d'uso (chatbot, codice, supporto, creativo, traduttore, estrazione dati) e consigli per la risoluzione dei problemi. Per l'elenco completo dei parametri e la sintassi, consulta il [Riferimento Modelfile](./modelfile-reference.md).

## Operazioni avanzate

### Testare i modelli

**Test end-to-end rapido**:
```bash
make quick-test
```

Questo esegue automaticamente:
1. Crea un modello di test
2. Invia un prompt di test
3. Mostra la risposta
4. Elimina il modello di test

**Test di validazione**:
```bash
make test
```

Valida:
- La configurazione di Docker Compose
- Lo stato di salute dei servizi
- La struttura delle directory
- I Modelfile di esempio

### Selezione interattiva dei modelli

I menu numerati interattivi sono forniti direttamente dagli script `scripts/interactive-*.sh`, che condividono funzioni di supporto da `scripts/lib/common.sh`:

- **`scripts/interactive-create-model.sh`**: seleziona un Modelfile e crea un modello (`make create-model`)
- **`scripts/interactive-chat.sh`**: seleziona un modello installato e chatta (`make chat`)
- **`scripts/interactive-save-model.sh`**: seleziona un modello da salvare (`make save-model`)
- **`scripts/interactive-deploy-model.sh`**: seleziona un Modelfile salvato da distribuire (`make deploy-model`)
- **`scripts/interactive-publish-model.sh`**: seleziona un modello da pubblicare su un registry (`make publish-model`)

Tutti i menu includono l'opzione `[0]` per inserire manualmente un percorso personalizzato.

### Eliminare i modelli

```bash
docker compose exec ollama ollama rm <model-name>

# Esempio:
docker compose exec ollama ollama rm old-model
```

**Attenzione**: questo elimina definitivamente il modello. Assicurati di esportarlo/salvarlo prima, se necessario.

## Consigli sulle prestazioni

### Dimensione del modello e prestazioni

- **Modelli 1B-3B**: veloci, poca RAM, adatti a task semplici
- **Modelli 7B-13B**: equilibrio tra qualità e velocità
- **Modelli 30B+**: alta qualità, lenti, richiedono molta RAM/VRAM

### Accelerazione GPU

Abilita il supporto GPU per:
- Inferenza 5-10 volte più veloce
- La possibilità di eseguire modelli più grandi
- Una migliore gestione di utenti concorrenti

Consulta la [Guida all'installazione - Supporto GPU](./installation.md#supporto-gpu-opzionale).

### Gestione dello spazio su disco

I modelli possono essere grandi. Controlla l'utilizzo:

```bash
# Controlla l'utilizzo del disco di Docker
docker system df

# Controlla la dimensione del volume
docker volume inspect ollama_data

# Elenca le dimensioni dei modelli
docker compose exec ollama ollama list
```

Elimina i modelli inutilizzati:
```bash
docker compose exec ollama ollama rm <unused-model>
```

## Prossimi passi

- [Guida alla Chat UI](./chat-ui.md) - Usa l'interfaccia web
- [Esempi](./examples.md) - Template di modelli preconfigurati
- [Utilizzo avanzato](./advanced-usage.md) - Fine-tuning e personalizzazione
- [Risoluzione dei problemi](./troubleshooting.md) - Problemi comuni e soluzioni
