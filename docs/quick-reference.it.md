# Guida di Riferimento Rapido

## Selezione Interattiva del Modello

Tutti i comandi make relativi ai modelli ora offrono menu di selezione interattivi. Non c'è bisogno di ricordare o digitare percorsi lunghi!

### Chatta con un Modello

```bash
make chat
```

**Cosa succede:**
1. Mostra un elenco numerato di tutti i modelli disponibili
2. Selezioni con quale modello chattare
3. Avvia una sessione di chat interattiva
4. Digita i messaggi e ricevi le risposte
5. Usa `/bye` o `Ctrl+D` per uscire

**Esempio di output:**
```
💬 Chat with a model

📦 Available models:

  [1] llama3.2:1b (1.3 GB)
  [2] mistral:7b (4.1 GB)
  [3] my-chatbot (1.3 GB) ⭐
  [4] my-code-helper (1.3 GB) ⭐

  [0] Cancel

Select a model to chat with [0-4]: 3

🚀 Starting chat with: my-chatbot

💡 Tips:
   - Type your messages and press Enter
   - Use /bye to exit the chat
   - Use Ctrl+D to exit

───────────────────────────────────────────────────────

>>> Hello! How are you?
I'm doing great, thanks for asking! How can I help you today?

>>> Tell me a joke
Why don't scientists trust atoms? Because they make up everything!

>>> /bye
👋 Chat ended
```

### Crea un Modello Personalizzato

```bash
make create-model
```

**Cosa succede:**
1. Mostra un elenco numerato di tutti i Modelfile in `models/examples/` e `models/custom/`
2. Selezioni per numero
3. Inserisci un nome per il tuo nuovo modello
4. Il modello viene creato

**Esempio di output:**
```
🔨 Create a custom model

📁 Available Modelfiles:

  [1] examples/chatbot/Modelfile
  [2] examples/code-assistant/Modelfile
  [3] examples/creative-writer/Modelfile
  [4] examples/personal-assistant/Modelfile
  [5] examples/translator/Modelfile
  [6] custom/my-custom-bot/Modelfile

  [0] Enter custom path

Select a Modelfile [0-6]: 2
Enter name for the new model: my-code-helper
```

### Salva un Modello per il Deployment

```bash
make save-model
```

**Cosa succede:**
1. Mostra un elenco numerato di tutti i modelli nella tua istanza Ollama
2. Selezioni quale modello salvare
3. Salva il Modelfile in `models/saved/`

**Esempio di output:**
```
💾 Save a model for deployment

📦 Available models:

  [1] llama3.2:1b
  [2] mistral:7b
  [3] my-chatbot
  [4] my-code-helper
  [5] production-assistant

  [0] Enter custom name

Select a model [0-5]: 3

💾 Saving model: my-chatbot
Output: ./models/saved/my-chatbot.Modelfile

✅ Model saved successfully!
```

### Esegui il Deployment di un Modello Salvato

```bash
make deploy-model
```

**Cosa succede:**
1. Mostra un elenco numerato dei Modelfile salvati in `models/saved/`
2. Selezioni quale distribuire
3. Facoltativamente lo rinomini durante il deployment
4. Il modello viene creato nella tua istanza Ollama

**Esempio di output:**
```
🚀 Deploy a saved model

💾 Available saved models:

  [1] my-chatbot.Modelfile
  [2] production-bot.Modelfile
  [3] team-assistant.Modelfile

  [0] Enter custom path

Select a saved model [0-3]: 1
Enter model name (press Enter to use filename):

🚀 Deploying model: my-chatbot
✅ Model deployed successfully!
```

## Uso Diretto degli Script

Se preferisci gli argomenti da riga di comando, puoi comunque usare gli script direttamente:

```bash
# Create model (specify path)
bash scripts/create-custom-model.sh my-bot ./models/examples/chatbot/Modelfile

# Save model (specify name)
bash scripts/save-model.sh my-chatbot

# Deploy model (specify path)
bash scripts/deploy-model.sh ./models/saved/my-chatbot.Modelfile

# Or deploy with custom name
bash scripts/deploy-model.sh ./models/saved/my-chatbot.Modelfile renamed-bot
```

## Riepilogo dei Comandi

| Attività | Comando | Interattivo? |
|------|---------|--------------|
| Verifica i requisiti | `make preflight` | No |
| Avvia tutti i servizi (Ollama + Chat UI) | `make up` | No |
| Avvia solo Ollama (senza web UI) | `make up-core` | No |
| Avvia con GPU NVIDIA | `make up-gpu` | No |
| Ferma i servizi | `make down` | No |
| Visualizza i log | `make logs` | No |
| Accesso alla shell | `make shell` | No |
| Scarica i modelli base | `make pull-base` | No |
| Elenca i modelli | `make list-models` | No |
| **Crea un modello personalizzato** | `make create-model` | **Sì - seleziona il Modelfile** |
| **Chatta con un modello** | `make chat` | **Sì - seleziona il modello** |
| **Salva un modello** | `make save-model` | **Sì - seleziona il modello** |
| **Esegui il deployment di un modello** | `make deploy-model` | **Sì - seleziona il file salvato** |
| **Pubblica un modello su un registry** | `make publish-model` | **Sì - seleziona il modello** |
| **Esporta modello + pesi (tar)** | `make export-full` | **Sì - seleziona il modello** |
| **Importa archivio completo del modello** | `make import-full` | **Sì - seleziona l'archivio** |
| Backup di tutti i modelli | `make backup-models` | No |
| Test rapido | `make quick-test` | Sì - conferma |
| Test di validazione | `make test` | No |
| Pulizia | `make clean` | Sì - conferma |

## Scegliere un Modello Base (2026)

Gli esempi del progetto usano di default il leggero `llama3.2:1b` — continua a usarlo per l'apprendimento e l'iterazione rapida. Alternative leggere moderne che vale la pena provare con `ollama pull`:

| Modello | Dimensione approx. | RAM approx. necessaria | Note |
|-------|-------------|--------------------|-------|
| `llama3.2:1b` | ~1.3 GB | ~4 GB | Default del progetto |
| `qwen3:0.6b` / `qwen3:1.7b` | ~0.5 / ~1.4 GB | ~2 / ~4 GB | Piccolo, potente; modalità thinking opzionale |
| `gemma3:1b` | ~815 MB | ~4 GB | Molto compatto |
| `gemma3:4b` | ~3.3 GB | ~8 GB | Multimodale, contesto 128K |
| `phi4-mini` | ~2.5 GB | ~8 GB | Compatto ed efficiente |
| `qwen3:8b` | ~5 GB | ~16 GB | Più pesante, per macchine capaci |
| `gpt-oss:20b` | ~13 GB | ~16 GB | Più pesante, per macchine capaci |

Consulta [Concetti Essenziali - Scegliere un Modello Base](./concepts.md#scegliere-un-modello-base-2026) per i dettagli.

## Struttura delle Directory

```
models/
├── examples/          # Pre-configured example Modelfiles
│   ├── chatbot/
│   │   └── Modelfile
│   ├── code-assistant/
│   │   └── Modelfile
│   └── ...
├── custom/            # Your custom Modelfiles
│   └── my-bot/
│       └── Modelfile
└── saved/             # Saved models ready for deployment
    ├── my-chatbot.Modelfile
    └── production-bot.Modelfile
```

## Suggerimenti

1. L'**opzione [0]** in qualsiasi menu di selezione ti permette di inserire un percorso/nome personalizzato
2. I modelli salvati sono memorizzati in `models/saved/` per impostazione predefinita
3. I backup includono timestamp: `backups/models/YYYYMMDD_HHMMSS/`
4. Puoi comunque usare gli script direttamente con i percorsi se preferisci
5. Tutti i comandi interattivi possono essere annullati con Ctrl+C

## Workflow Comuni

### Test Rapido di un Modello di Esempio

```bash
make up                 # Start Ollama
make pull-base          # Get base models
make create-model       # Select example, name it
make chat               # Select your model and start chatting!
```

### Deployment in Produzione

```bash
# On dev server:
make save-model         # Select your model

# Transfer file:
scp ./models/saved/my-model.Modelfile user@prod:/opt/ollama/models/saved/

# On prod server:
make deploy-model       # Select the transferred file
```

### Backup Regolare

```bash
make backup-models      # Backs up all custom models
# Files saved to: ./backups/models/YYYYMMDD_HHMMSS/
```

### Test Rapido

Testa il workflow completo:

```bash
make quick-test
```

**Cosa succede:**
1. Chiede conferma
2. Crea un modello di test temporaneo
3. Invia un prompt di test: "Hello! Can you introduce yourself in one sentence?"
4. Mostra la risposta
5. Elimina il modello di test
6. Mostra un riepilogo di successo

**Esempio di output:**
```
🧪 Quick Model Test

This will:
  1. Create a test model from an example
  2. Send a test prompt to it
  3. Delete the test model

Continue? (y/N): y

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 Step 1/3: Creating test model 'test-chatbot-1701234567'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Test Details:
  Base Model: llama3.2:1b
  Modelfile:  ./models/examples/chatbot/Modelfile
  Test Model: test-chatbot-1701234567

🔨 Creating custom model: test-chatbot-1701234567
✅ Model created successfully!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💬 Step 2/3: Testing model with a prompt
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sending test prompt: 'Hello! Can you introduce yourself in one sentence?'

Response:
─────────────────────────────────────────────────────
I'm a helpful AI assistant designed to provide accurate and
clear answers to your questions.
─────────────────────────────────────────────────────

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🗑️  Step 3/3: Cleaning up test model
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

deleted 'test-chatbot-1701234567'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Quick test completed successfully!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary:
  ✓ Model creation works (base: llama3.2:1b)
  ✓ Model responds to prompts
  ✓ Model cleanup works

You can now create your own models with:
  make create-model
```

**Nota:** l'output viene automaticamente ripulito per la leggibilità (codici di escape ANSI rimossi).
