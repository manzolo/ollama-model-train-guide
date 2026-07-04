# Guida all'installazione

## Avvio rapido (60 secondi)

```bash
# Clone and enter directory
git clone https://github.com/manzolo/ollama-model-train-guide.git
cd ollama-model-train-guide

# Check requirements, then setup and start services
make preflight
make setup && make up

# Pull a base model and test
docker compose exec ollama ollama pull llama3.2:1b
docker compose exec ollama ollama run llama3.2:1b "Hello!"
```

**Accedi alla Web UI**: Apri `http://localhost:8080` nel tuo browser.

---

## Prerequisiti

Prima di iniziare, assicurati che il tuo sistema soddisfi questi requisiti:

- **Docker**: Versione 20.10 o superiore
- **Docker Compose**: Versione 2.0 o superiore
- **Spazio su disco**: Almeno 10GB per i modelli base (di più per modelli più grandi)
- **RAM**: Minimo 8GB (consigliati 16GB)
- **Opzionale**: GPU NVIDIA con Container Toolkit per l'accelerazione GPU

### Controlla il tuo sistema

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker compose version

# Check available disk space
df -h

# Check available RAM
free -h
```

## Passaggi dettagliati di installazione

### 1. Clona il repository

```bash
git clone https://github.com/manzolo/ollama-model-train-guide.git
cd ollama-model-train-guide
```

### 2. Controlla i requisiti di sistema (opzionale)

```bash
make preflight
```

Questo verifica Docker, Docker Compose, lo spazio libero su disco e la RAM prima di iniziare.

### 3. Esegui la configurazione iniziale

Questo crea il file `.env` (a partire da `.env.example`) e le directory necessarie:

```bash
make setup
```

### 4. Avvia i servizi

Avvia sia Ollama che la Chat UI:

```bash
make up
```

Questo avvia due servizi:
- **API Ollama**: Disponibile su `http://localhost:11434`
- **Chat Web UI**: Disponibile su `http://localhost:8080` (chat, convertitore e wizard per Modelfile)

Per avviare Ollama **senza** la web UI:

```bash
make up-core
```

Per avviare con l'**accelerazione GPU NVIDIA** (vedi [Supporto GPU](#supporto-gpu-opzionale)):

```bash
make up-gpu
```

### 5. Scarica i modelli base

Scarica i modelli base più comuni per iniziare:

```bash
make pull-base
```

Questo scarica:
- `llama3.2:1b` (piccolo, veloce)
- `llama3.2:3b` (bilanciato)
- `mistral:7b` (alta qualità)
- `phi3:mini` (compatto)

In alternativa, scarica i modelli tramite la Web UI:
1. Apri `http://localhost:8080`
2. Clicca su "Manage Models"
3. Inserisci il nome del modello (ad es. `llama3.2:1b`)
4. Clicca su "Pull" e osserva l'avanzamento in tempo reale

### 6. Verifica l'installazione

Controlla che tutto funzioni:

```bash
# List available models
make list-models

# Run quick test
make quick-test

# Check service status
docker compose ps
```

Dovresti vedere entrambi i servizi `ollama` e `ollama-chat` in esecuzione.

## Supporto GPU (opzionale)

Per abilitare l'accelerazione GPU NVIDIA e velocizzare l'inferenza:

### 1. Installa l'NVIDIA Container Toolkit

**Ubuntu/Debian**:
```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
    sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

**Fedora/RHEL/CentOS**:
```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | \
    sudo tee /etc/yum.repos.d/nvidia-docker.repo

sudo yum install -y nvidia-container-toolkit
sudo systemctl restart docker
```

### 2. Avvia con l'override per la GPU

Il supporto GPU è fornito da un file di override Compose separato, `docker-compose.gpu.yml` — non c'è nulla da decommentare o modificare in `docker-compose.yml`:

```bash
make up-gpu

# Equivalent to:
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
```

L'override riserva tutte le GPU NVIDIA disponibili al servizio Ollama:

```yaml
# docker-compose.gpu.yml
services:
  ollama:
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
```

### 3. Verifica il rilevamento della GPU

Controlla che la GPU sia disponibile all'interno del container:

```bash
docker compose exec ollama nvidia-smi
```

Dovresti vedere la tua GPU elencata con l'utilizzo della memoria e le informazioni sul driver.

### Vantaggi in termini di prestazioni

Con l'accelerazione GPU:
- **Velocità di inferenza**: 5-10 volte più veloce per i modelli grandi
- **Elaborazione del contesto**: Significativamente più veloce per prompt lunghi
- **Utenti concorrenti**: Migliori prestazioni con richieste multiple

## Configurazione dell'ambiente

Il file `.env` (creato da `make setup` a partire da `.env.example`) contiene le opzioni di configurazione. Questi valori vengono interpolati direttamente in `docker-compose.yml` (ad es. la mappatura della porta di Ollama è `"${OLLAMA_PORT:-11434}:11434"`):

```bash
# Host port for the Ollama API
OLLAMA_PORT=11434

# Host port for the Chat web UI
CHAT_PORT=8080

# Compose profiles started by default with `docker compose up`.
# Set to empty (COMPOSE_PROFILES=) to run Ollama only, without the chat web UI.
COMPOSE_PROFILES=chat

# Which origins may call the Ollama API (CORS). "*" is fine for local use.
OLLAMA_ORIGINS=*

# Pin a specific Ollama version instead of "latest" for reproducible setups,
# e.g. OLLAMA_IMAGE_TAG=0.30.10
OLLAMA_IMAGE_TAG=latest
```

Dopo aver modificato `.env`, ricrea i container affinché le modifiche abbiano effetto:

```bash
make down && make up
```

## Struttura delle directory

Dopo la configurazione, il tuo progetto avrà questa struttura:

```
ollama-model-train-guide/
├── .env                    # Environment variables (ports, profiles, image tag)
├── docker-compose.yml      # Service configuration
├── docker-compose.gpu.yml  # NVIDIA GPU override (make up-gpu)
├── models/
│   ├── examples/          # Pre-configured Modelfiles
│   ├── custom/            # Your custom Modelfiles
│   └── saved/             # Exported models
├── data/
│   ├── gguf/             # External GGUF files
│   ├── adapters/         # LoRA adapters
│   └── training/         # Training datasets
└── chat/                  # Web UI application
```

## Prossimi passi

- [Guida all'uso](./usage.md) - Impara a lavorare con i modelli
- [Guida alla Chat UI](./chat-ui.md) - Usa l'interfaccia web
- [Creare modelli personalizzati](./modelfile-reference.md) - Personalizza i tuoi modelli
- [Esempi](./examples.md) - Template preconfigurati

## Risoluzione dei problemi di installazione

### Il daemon Docker non è in esecuzione

```bash
# Start Docker service
sudo systemctl start docker

# Enable Docker at boot
sudo systemctl enable docker
```

### Errori di permesso negato

Aggiungi il tuo utente al gruppo docker:

```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

### Porta già in uso

Se la porta 11434 o 8080 è già in uso, modifica `.env` per usare porte diverse:

```bash
OLLAMA_PORT=11435
CHAT_PORT=8081
```

Poi ricrea i container:

```bash
make down && make up
```

### Spazio su disco insufficiente

Controlla e pulisci le risorse Docker:

```bash
# Check disk usage
docker system df

# Clean up unused resources
docker system prune -a

# Remove old images
docker image prune -a
```

Per ulteriore aiuto nella risoluzione dei problemi, vedi la [Guida alla risoluzione dei problemi](./troubleshooting.md).
