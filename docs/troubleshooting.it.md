# Guida alla risoluzione dei problemi

Problemi comuni e soluzioni per la Ollama Model Training Guide.

## Indice

- [Problemi del servizio](#problemi-del-servizio)
- [Problemi dei modelli](#problemi-dei-modelli)
- [Problemi di rete e API](#problemi-di-rete-e-api)
- [Problemi di prestazioni](#problemi-di-prestazioni)
- [Problemi di spazio su disco](#problemi-di-spazio-su-disco)
- [Problemi della Chat UI](#problemi-della-chat-ui)
- [Problemi del convertitore](#problemi-del-convertitore)
- [Problemi con la GPU](#problemi-con-la-gpu)

---

## Problemi del servizio

### Il servizio Ollama non si avvia

**Sintomi**: `docker compose up` fallisce o il servizio termina immediatamente

**Verifica che Docker sia in esecuzione**:
```bash
docker ps
# If this fails, Docker daemon is not running
```

**Soluzione**:
```bash
# Ubuntu/Debian
sudo systemctl start docker
sudo systemctl enable docker

# Check status
sudo systemctl status docker
```

**Controlla i log**:
```bash
make logs
# Or:
docker compose logs ollama
```

Cerca messaggi di errore che indichino:
- Conflitti di porta
- Problemi di mount dei volumi
- Problemi di permessi

**Riavvia i servizi**:
```bash
make restart
```

### La Chat UI non si avvia

**Controlla entrambi i servizi**:
```bash
docker compose ps
```

Sia `ollama` che `ollama-chat` dovrebbero essere "Up".

**Controlla i log della Chat**:
```bash
docker compose logs chat
```

**Ricostruisci il container della Chat**:
```bash
docker compose build chat
docker compose up -d
```

### Il container termina immediatamente

**Verifica la presenza di conflitti di porta**:
```bash
# Check if port 11434 is already in use
netstat -an | grep 11434

# Check if port 8080 is already in use
netstat -an | grep 8080
```

**Soluzione**: Modifica le porte host nel file `.env` (questi valori vengono interpolati nel file compose come `${OLLAMA_PORT:-11434}:11434` e `${CHAT_PORT:-8080}:8080`):
```bash
OLLAMA_PORT=11435
CHAT_PORT=8081
```

Poi ricrea i container (un semplice riavvio non è sufficiente per le modifiche alle porte):
```bash
make down && make up
```

### Errori di permesso negato

**Aggiungi l'utente al gruppo docker**:
```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

**Correggi i permessi dei volumi**:
```bash
# Check volume ownership
docker volume inspect ollama_data

# If needed, fix permissions
docker compose down
docker volume rm ollama_data
make up
```

---

## Problemi dei modelli

### La creazione del modello fallisce

**Sintomi**: `bash scripts/create-custom-model.sh` fallisce con un errore

**Verifica che il modello base esista**:
```bash
docker compose exec ollama ollama list
```

Se il modello base manca, scaricalo:
```bash
docker compose exec ollama ollama pull llama3.2:1b
```

**Convalida la sintassi del Modelfile**:
```bash
# Check Modelfile exists
cat ./models/custom/my-model/Modelfile

# Verify FROM line uses correct model name
grep "FROM" ./models/custom/my-model/Modelfile
```

**Errori di sintassi comuni**:
- Riga `FROM` mancante
- Nome del modello base errato
- Righe PARAMETER malformate
- Virgolette mancanti nel prompt SYSTEM

**Testa il Modelfile manualmente**:
```bash
docker compose exec ollama ollama create test -f /models/examples/chatbot/Modelfile
```

### Il download dei modelli fallisce o va in timeout

**Verifica la connessione a internet**:
```bash
docker compose exec ollama ping -c 3 ollama.com
```

**Controlla la rete Docker**:
```bash
docker network ls
docker network inspect ollama-model-train-guide_default
```

**Riprova con un timeout più ampio**:
```bash
# Some models are large (>10GB) and may take time
docker compose exec ollama ollama pull mistral:7b
# Wait patiently...
```

**Controlla lo spazio su disco** (vedi [Problemi di spazio su disco](#problemi-di-spazio-su-disco))

### Le risposte del modello sono di scarsa qualità

**Regola la temperature**:
- Troppo alta (>1.5): Casuale, incoerente
- Troppo bassa (<0.1): Ripetitiva, rigida

**Aumenta la finestra di contesto**:
```dockerfile
PARAMETER num_ctx 8192
# Instead of 2048
```

**Usa un modello base migliore**:
- Passa da un modello da 1B a uno da 3B o 7B
- Prova famiglie di modelli diverse (Mistral, CodeLlama, ecc.)

**Aggiungi esempi few-shot**:
```dockerfile
MESSAGE user "Example question?"
MESSAGE assistant "Example high-quality answer."
```

### Il modello esaurisce la memoria

**Sintomi**: Il servizio va in crash, errori "out of memory"

**Usa un modello più piccolo**:
- `llama3.2:1b` invece di `mistral:7b`
- Versioni quantizzate (se disponibili)

**Riduci la finestra di contesto**:
```dockerfile
PARAMETER num_ctx 2048
# Instead of 8192
```

**Aumenta la RAM di sistema** o abilita l'accelerazione GPU

**Controlla i limiti delle risorse Docker**:
```bash
docker stats
```

---

## Problemi di rete e API

### API non accessibile

**Verifica che il servizio sia in esecuzione**:
```bash
docker compose ps
```

**Verifica la mappatura delle porte**:
```bash
netstat -an | grep 11434
```

**Testa direttamente l'API**:
```bash
curl http://localhost:11434/api/tags
```

Se fallisce:
```bash
# Check firewall
sudo ufw status

# Try from within container
docker compose exec ollama curl http://localhost:11434/api/tags
```

### L'API restituisce errori

**"model not found"**:
```bash
# List available models
docker compose exec ollama ollama list

# Pull missing model
docker compose exec ollama ollama pull <model-name>
```

**Timeout di connessione**:
```bash
# Check if Ollama is responsive
docker compose logs ollama

# Restart if needed
make restart
```

**Rate limiting o risposte lente**:
- Riduci le richieste concorrenti
- Abilita l'accelerazione GPU
- Usa modelli più piccoli

### Impossibile connettersi da un host esterno

**Ollama è associato a 0.0.0.0** per impostazione predefinita in `docker-compose.yml`.

**Controlla le regole del firewall**:
```bash
sudo ufw allow 11434/tcp
sudo ufw allow 8080/tcp
```

**Verifica la rete Docker**:
```bash
docker compose exec ollama env | grep OLLAMA_HOST
# Should show: OLLAMA_HOST=0.0.0.0
```

---

## Problemi di prestazioni

### Risposte del modello lente

**Abilita l'accelerazione GPU**:
Vedi [Guida all'installazione - Supporto GPU](./installation.md#supporto-gpu-opzionale)

**Usa modelli più piccoli**:
- `llama3.2:1b` (il più veloce)
- `phi3:mini` (veloce e di buona qualità)
- `llama3.2:3b` (bilanciato)

**Riduci la finestra di contesto**:
```dockerfile
PARAMETER num_ctx 2048
```

**Controlla le risorse di sistema**:
```bash
docker stats
htop  # or top
```

Cerca:
- Utilizzo elevato della CPU
- Pressione sulla memoria
- Colli di bottiglia dell'I/O su disco

**Potenzia l'hardware**:
- Aggiungi più RAM (consigliati 16GB+)
- Usa un SSD invece di un HDD
- Aggiungi l'accelerazione GPU

### Utilizzo elevato della memoria

**Controlla il consumo di memoria**:
```bash
docker stats ollama
```

**Soluzioni**:
- Usa modelli più piccoli (1B-3B invece di 7B+)
- Riduci la finestra di contesto
- Limita le richieste concorrenti
- Abilita la GPU per scaricare la memoria della CPU

### La Chat UI è lenta

**Controlla il tempo di risposta dell'API**:
```bash
time curl http://localhost:11434/api/generate -d '{"model":"llama3.2:1b","prompt":"Hi","stream":false}'
```

Se l'API è lenta, vedi i problemi di prestazioni dei modelli sopra.

**Controlla la console del browser** per eventuali errori JavaScript:
- Apri i DevTools (F12)
- Controlla la scheda Console per gli errori
- Controlla la scheda Network per le richieste lente

---

## Problemi di spazio su disco

### Spazio insufficiente per i modelli

**Controlla lo spazio disponibile**:
```bash
df -h
docker system df
```

**Controlla le dimensioni dei modelli**:
```bash
docker compose exec ollama ollama list
```

**Pulisci le risorse Docker**:
```bash
# Remove unused images
docker image prune -a

# Remove unused volumes (CAUTION: may delete models)
docker volume prune

# Full cleanup
docker system prune -a --volumes
```

**Elimina i modelli inutilizzati**:
```bash
docker compose exec ollama ollama rm <unused-model>
```

**Sposta la directory dei dati di Docker**:
```bash
# Stop Docker
sudo systemctl stop docker

# Edit daemon.json
sudo nano /etc/docker/daemon.json
# Add: {"data-root": "/new/path"}

# Move data
sudo mv /var/lib/docker /new/path/

# Start Docker
sudo systemctl start docker
```

### Il volume è pieno

**Controlla le dimensioni del volume**:
```bash
docker volume inspect ollama_data
```

**Ricrea il volume con più spazio**:
```bash
# Backup models first!
make backup-models

# Remove old volume
docker compose down
docker volume rm ollama_data

# Start fresh
make up
make pull-base
```

---

## Problemi della Chat UI

### I modelli non compaiono nel menu a tendina

**Verifica che l'API di Ollama sia accessibile**:
```bash
curl http://localhost:11434/api/tags
```

**Controlla i log della Chat UI**:
```bash
docker compose logs chat
```

**Riavvia la Chat UI**:
```bash
docker compose restart chat
```

**Svuota la cache del browser**:
- Premi `Ctrl+Shift+R` (Windows/Linux)
- Premi `Cmd+Shift+R` (Mac)

### Il download del modello non mostra progressi

**Verifica se il modello si sta effettivamente scaricando**:
```bash
docker compose logs -f ollama
```

**Prova a scaricarlo tramite CLI**:
```bash
docker compose exec ollama ollama pull llama3.2:1b
```

**Controlla la velocità di rete**:
```bash
# Test download speed
docker compose exec ollama curl -o /dev/null http://speedtest.example.com/file
```

### Le risposte della chat vengono troncate

**Aumenta la finestra di contesto** nel Modelfile del modello:
```dockerfile
PARAMETER num_ctx 8192
```

**Verifica la presenza di timeout dell'API** nei log della Chat UI:
```bash
docker compose logs chat | grep timeout
```

---

## Problemi del convertitore

### Il caricamento del file fallisce

**Controlla la dimensione del file**:
File molto grandi (>50MB) possono andare in timeout. Prova a suddividerli in file più piccoli.

**Controlla il formato del file**:
- Assicurati che sia `.xlsx`, `.xls` o `.csv`
- Assicurati che il file non sia corrotto

**Controlla i permessi**:
```bash
ls -la ./data/training/
```

La directory deve essere scrivibile.

**Controlla i log**:
```bash
docker compose logs chat | grep converter
```

### La conversione produce un file vuoto

**Controlla la mappatura delle colonne**:
- Assicurati che siano selezionate le colonne corrette
- Visualizza l'anteprima dei dati prima di convertire
- Verifica che i dati di origine abbiano contenuto

**Controlla il file di output**:
```bash
cat ./data/training/output.jsonl
```

**Conversione manuale**:
Prova direttamente l'API del convertitore:
```bash
curl -X POST http://localhost:8080/api/converter/convert \
  -F "file=@input.csv" \
  -F "instruction_col=question" \
  -F "output_col=answer" \
  -o output.jsonl
```

### Il rilevamento automatico fallisce

**Specifica manualmente le colonne** nell'interfaccia:
- Seleziona la colonna "Question" dal menu a tendina
- Seleziona la colonna "Answer" dal menu a tendina
- Visualizza l'anteprima per verificare

**Controlla i nomi delle colonne** nel file di origine:
- Usa nomi chiari come "question", "answer"
- Evita caratteri speciali
- Usa la prima riga come intestazioni

---

## Problemi con la GPU

### GPU non rilevata

**Controlla il driver NVIDIA**:
```bash
nvidia-smi
```

Se fallisce, installa o aggiorna i driver NVIDIA.

**Controlla l'NVIDIA Container Toolkit**:
```bash
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi
```

**Assicurati di aver avviato con l'override per la GPU**:
Il supporto GPU proviene dall'override `docker-compose.gpu.yml`, non da `docker-compose.yml`:
```bash
make up-gpu
# Equivalent to:
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
```

**Riavvia Docker**:
```bash
sudo systemctl restart docker
make up-gpu
```

### La GPU non viene utilizzata

**Verifica che Ollama stia rilevando la GPU**:
```bash
docker compose exec ollama nvidia-smi
```

**Controlla durante l'inferenza**:
```bash
# In one terminal
watch -n 1 nvidia-smi

# In another terminal
docker compose exec ollama ollama run llama3.2:1b "Long prompt here..."
```

L'utilizzo della GPU dovrebbe aumentare durante la generazione.

**Assicurati che il modello entri nella VRAM**:
- Controlla la memoria della GPU con `nvidia-smi`
- Usa modelli più piccoli se necessario
- Monitora l'utilizzo della VRAM

### Memoria GPU esaurita

**Usa modelli più piccoli**:
- Prova le versioni quantizzate
- Usa modelli da 1B-3B invece di 7B+

**Riduci la dimensione del batch** (per l'uso via API):
Abbassa le richieste concorrenti per ridurre l'utilizzo della VRAM.

**Controlla altri processi che usano la GPU**:
```bash
nvidia-smi
# Look for other processes using GPU
```

---

## Ottenere ulteriore aiuto

### Controlla i log

**Tutti i servizi**:
```bash
make logs
```

**Un servizio specifico**:
```bash
docker compose logs ollama
docker compose logs chat
```

**Segui i log in tempo reale**:
```bash
docker compose logs -f
```

### Esegui i test

**Test rapido**:
```bash
make quick-test
```

**Test di validazione**:
```bash
make test
```

**Esempio del dataset TechCorp**:
```bash
bash scripts/test-techcorp-example.sh
```

### Raccogli informazioni di debug

```bash
# System info
uname -a
docker --version
docker compose version

# Service status
docker compose ps
docker compose logs --tail=50

# Resource usage
docker stats --no-stream
df -h

# Network
netstat -an | grep -E "11434|8080"

# Models
docker compose exec ollama ollama list
```

### Risorse della community

- [Documentazione di Ollama](https://ollama.com/docs)
- [Issue GitHub di Ollama](https://github.com/ollama/ollama/issues)
- [Documentazione di Docker](https://docs.docker.com)
- [Issue GitHub del progetto](https://github.com/manzolo/ollama-model-train-guide/issues)

### Ancora bloccato?

1. **Cerca tra le issue esistenti** su GitHub
2. **Crea una nuova issue** con:
   - Descrizione del problema
   - Messaggi di errore
   - Output dei log
   - Informazioni di sistema
   - Passaggi per riprodurre il problema

---

## Manutenzione preventiva

### Pulizia regolare

```bash
# Weekly: Clean up Docker resources
docker system prune

# Monthly: Review and delete unused models
docker compose exec ollama ollama list
docker compose exec ollama ollama rm <unused-model>

# Quarterly: Backup custom models
make backup-models
```

### Monitora lo spazio su disco

```bash
# Check before pulling large models
df -h
docker system df
```

### Mantieni i servizi aggiornati

```bash
# Pull latest Ollama image
docker compose pull

# Rebuild Chat UI with updates
docker compose build chat

# Restart services
make restart
```

### Strategia di backup

```bash
# Backup custom Modelfiles
make backup-models

# Export important models
bash scripts/export-model.sh my-important-model ./backups/my-model.Modelfile

# Backup training data
cp -r ./data/training ./backups/training-$(date +%Y%m%d)
```
