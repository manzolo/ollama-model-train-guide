# Guida alla Web UI di Chat

La Ollama Model Training Guide include una moderna interfaccia web per interagire con i tuoi modelli, gestirli e convertire i dati di addestramento.

## Accesso alla Web UI

Avvia i servizi:
```bash
make up
```

Poi apri il browser all'indirizzo: **http://localhost:8080**

La UI viene avviata automaticamente insieme a Ollama e si connette all'API su `http://ollama:11434`. Il servizio di chat gira sotto il profilo Compose `chat`; usa `make up-core` (oppure imposta `COMPOSE_PROFILES=` in `.env`) per eseguire Ollama senza di esso.

L'applicazione web ha tre pagine:

| Pagina | URL | Scopo |
|------|-----|---------|
| **Chat** | http://localhost:8080 | Chatta con i modelli, scarica/gestisci i modelli, modifica i Modelfile |
| **Converter** | http://localhost:8080/converter | Converti fogli di calcolo Excel/CSV in dati di addestramento JSONL |
| **Wizard** | http://localhost:8080/wizard | Creazione guidata passo-passo di un Modelfile |

## Panoramica delle Funzionalità

La Chat UI offre:
- **Chat interattiva**: dialoga con i tuoi modelli in una moderna interfaccia di chat
- **Selezione del modello**: passa facilmente tra i modelli installati
- **Gestione dei modelli**: scarica modelli dalla libreria Ollama con avanzamento in tempo reale
- **Convertitore di fogli di calcolo**: converti file Excel/CSV nel formato di addestramento JSONL
- **Modelfile Wizard**: crea un modello personalizzato in 6 passi guidati, senza sintassi richiesta
- **Menu a tendina di selezione del modello**: menu a tendina migliorato con stile moderno e ricerca

## Interfaccia di Chat

### Avviare una Conversazione

1. **Seleziona un modello**: clicca sul menu a tendina di selezione del modello in alto
2. **Scegli tra i modelli disponibili**: tutti i modelli installati appaiono nell'elenco
3. **Inizia a digitare**: inserisci il tuo messaggio nella casella di input
4. **Invia**: premi Invio o clicca su Invia

### Selettore del Modello

Il selettore del modello migliorato offre:
- **Stile moderno**: aspetto pulito e professionale con stile personalizzato
- **Stati interattivi**: effetti di hover e focus per una migliore UX
- **Freccia personalizzata**: freccia del menu a tendina con stile dedicato
- **Design responsive**: funziona su desktop e mobile

Per cambiare modello durante la conversazione:
1. Clicca sul menu a tendina del modello
2. Seleziona un modello diverso
3. Continua a chattare (il contesto della conversazione precedente potrebbe andare perso)

### Funzionalità della Chat

- **Risposte in streaming**: guarda la risposta del modello mentre viene generata
- **Cronologia dei messaggi**: scorri i messaggi precedenti
- **Copia delle risposte**: copia le risposte del modello negli appunti
- **Pulisci chat**: avvia una nuova conversazione

## Gestione dei Modelli

### Scaricare i Modelli

Clicca sul pulsante **"Manage Models"** per accedere allo scaricamento dei modelli:

1. **Inserisci il nome del modello**: digita il nome del modello (es. `llama3.2`, `mistral:7b`)
2. **Clicca su "Pull Model"**: avvia il download
3. **Osserva l'avanzamento**: la barra di avanzamento in tempo reale mostra:
   - Velocità di download
   - Percentuale completata
   - Tempo stimato rimanente
   - Stato corrente (download, verifica, ecc.)

**Modelli popolari da provare**:
- `llama3.2:1b` - Veloce, leggero (1.3GB)
- `llama3.2:3b` - Qualità bilanciata (2GB)
- `mistral:7b` - Alta qualità (4.1GB)
- `phi3:mini` - Compatto e veloce (2.3GB)
- `codellama:7b` - Generazione di codice (3.8GB)

Sfoglia tutti i modelli su [Ollama Library](https://ollama.com/library).

### Visualizzare i Modelli Installati

Il menu a tendina di selezione del modello mostra automaticamente tutti i modelli installati. I modelli vengono recuperati dall'API di Ollama e aggiornati quando:
- Ricarichi la pagina
- Scarichi un nuovo modello
- Elimini un modello (tramite CLI)

## Convertitore da Foglio di Calcolo a JSONL

Il convertitore ti aiuta a preparare dataset di addestramento a partire da fogli di calcolo.

### Accesso al Convertitore

Due modi per accedere:

1. **Tramite la barra laterale**: clicca su "Converter" nella barra laterale della Chat UI
2. **URL diretto**: vai su `http://localhost:8080/converter`

### Convertire i File

#### Passo 1: Carica il tuo File

**Formati supportati**:
- Excel: `.xlsx`, `.xls`
- CSV: `.csv`

**Metodi di caricamento**:
- **Trascina e rilascia**: trascina il file sull'area di caricamento
- **Clicca per sfogliare**: clicca sull'area di caricamento e seleziona un file

#### Passo 2: Configura le Colonne

Il convertitore:
- **Rileva automaticamente** i nomi di colonna che contengono "question", "query", "prompt", "answer", "response"
- Mostra un'anteprima dei tuoi dati
- Ti permette di selezionare manualmente le colonne se il rilevamento automatico fallisce

**Mappatura delle colonne**:
- **Colonna Domanda/Prompt**: contiene le domande o i prompt dell'utente
- **Colonna Risposta/Response**: contiene le risposte dell'assistente

Esempio di struttura del foglio di calcolo:

| Question | Answer |
|----------|--------|
| How do I reset my password? | Click "Forgot Password" on the login page... |
| What are your business hours? | We're open Monday-Friday, 9am-5pm EST. |

#### Passo 3: Anteprima

Rivedi l'anteprima per assicurarti che:
- Le colonne siano mappate correttamente
- I dati appaiano corretti
- Non ci siano voci mancanti o malformate

#### Passo 4: Converti e Salva

1. **Clicca su "Convert"**
2. **Salva il file**: il file JSONL viene salvato automaticamente in `./data/training/`
3. **Usalo nell'addestramento**: fai riferimento al file nel tuo Modelfile

### Formato di Output

Il convertitore crea il formato JSONL (JSON Lines):

```jsonl
{"role": "user", "content": "How do I reset my password?"}
{"role": "assistant", "content": "Click 'Forgot Password' on the login page..."}
{"role": "user", "content": "What are your business hours?"}
{"role": "assistant", "content": "We're open Monday-Friday, 9am-5pm EST."}
```

### Usare i Dati Convertiti

Dopo la conversione, usa i dati in un Modelfile:

```dockerfile
FROM llama3.2:1b

PARAMETER temperature 0.3

SYSTEM """
You are a customer support assistant.
"""

# Load examples from converted data
MESSAGE user "How do I reset my password?"
MESSAGE assistant "Click 'Forgot Password' on the login page and follow the instructions sent to your email."

MESSAGE user "What are your business hours?"
MESSAGE assistant "We're open Monday-Friday, 9am-5pm EST."
```

Consulta l'[Esempio di Addestramento su Dataset](./dataset-training-example.md) per la guida completa.

## Modelfile Wizard

Il wizard ti guida nella creazione di un modello personalizzato senza scrivere a mano alcuna sintassi Modelfile.

### Accesso al Wizard

Vai su `http://localhost:8080/wizard` (oppure usa il link dalla Chat UI).

### I 6 Passi

1. **Caso d'uso**: scegli cosa farà il tuo modello — Chatbot, Assistente al Codice, Supporto Clienti, Scrittura Creativa, Traduttore o Estrazione Dati. Ogni caso d'uso applica un preset di parametri collaudato (temperature, `num_ctx`, `top_p` e `repeat_penalty` dove rilevante), corrispondente ai preset nella [Guida ai Parametri](./parameter-guide.md). Ad esempio, "Scrittura Creativa" imposta temperature 1.2 con un contesto di 8192 token, mentre "Estrazione Dati" imposta temperature 0.1.

2. **Modello base**: scegli il modello base da un menu a tendina (`llama3.2:1b` è il punto di partenza consigliato; sono offerti anche `llama3.2:3b`, `mistral:7b` e `phi3:mini`). Puoi modificare il Modelfile generato in seguito per usare qualsiasi altro modello che hai scaricato.

3. **Personalità**: scrivi il system prompt che descrive come il modello dovrebbe comportarsi e rispondere. Sii specifico — "spiega passo-passo" funziona meglio di "sii utile".

4. **Regole (opzionale)**: aggiungi vincoli individuali come "Mantieni le risposte entro 3 frasi" o "Usa la formattazione markdown". Questi vengono aggiunti al system prompt come elenco di regole.

5. **Esempi (opzionale)**: aggiungi coppie di esempio domanda/risposta. Queste diventano esempi few-shot `MESSAGE user` / `MESSAGE assistant` nel Modelfile; 3-5 esempi di qualità sono di solito sufficienti.

6. **Risultato**: il wizard genera il Modelfile (tramite l'endpoint `POST /api/wizard/generate` dell'app) e lo mostra per la revisione. Inserisci un nome per il modello (lettere minuscole, numeri e trattini) e clicca su **Save & Create Model**:
   - Il Modelfile viene salvato in `models/custom/<name>/Modelfile`
   - Il modello viene costruito immediatamente nell'istanza Ollama
   - Puoi poi selezionarlo nel menu a tendina della chat o eseguirlo con `make chat`

### Suggerimenti

- Il modello base che scegli deve essere scaricato prima (tramite "Manage Models" o `docker compose exec ollama ollama pull <model>`), altrimenti la creazione del modello fallisce.
- Il Modelfile generato è un normale file sotto `models/custom/` — puoi modificarlo in seguito e ricreare il modello, oppure versionarlo in Git.
- Per capire cosa fa ogni parametro generato, consulta la [Guida ai Parametri](./parameter-guide.md).

## Configurazione della Web UI

### Configurazione della Porta

La porta predefinita è `8080`. Per cambiarla:

1. Modifica `.env` (il valore viene interpolato nel file compose come `${CHAT_PORT:-8080}:8080`):
   ```bash
   CHAT_PORT=8081
   ```

2. Ricrea i container (necessario per le modifiche alla porta):
   ```bash
   make down && make up
   ```

3. Accedi alla nuova porta: `http://localhost:8081`

### Connessione all'API

La Chat UI si connette all'API di Ollama su `http://ollama:11434` per impostazione predefinita (rete Docker interna).

Se hai bisogno di connetterti a un'istanza Ollama esterna, modifica `docker-compose.yml`:

```yaml
chat:
  environment:
    - OLLAMA_API=http://external-ollama-host:11434
```

## Risoluzione dei Problemi

### La Chat UI non si carica

**Verifica che i servizi siano in esecuzione**:
```bash
docker compose ps
```

Sia `ollama` che `ollama-chat` dovrebbero essere "Up".

**Controlla i log**:
```bash
docker compose logs chat
```

**Riavvia i servizi**:
```bash
make restart
```

### I modelli non appaiono nel menu a tendina

**Verifica che Ollama sia in esecuzione**:
```bash
docker compose exec ollama ollama list
```

**Controlla la connessione all'API**:
```bash
curl http://localhost:11434/api/tags
```

Se questo fallisce, controlla `docker-compose.yml` per l'URL API corretto.

### Lo scaricamento del modello fallisce

**Controlla la connessione a internet**:
```bash
docker compose exec ollama ping -c 3 ollama.com
```

**Controlla lo spazio su disco**:
```bash
df -h
docker system df
```

**Prova tramite CLI**:
```bash
docker compose exec ollama ollama pull llama3.2:1b
```

### Il caricamento nel convertitore fallisce

**Controlla i permessi del file**:
```bash
ls -la ./data/training/
```

La directory deve essere scrivibile dal container Docker.

**Controlla la dimensione del file**:
File molto grandi potrebbero andare in timeout. Prova a suddividerli in file più piccoli.

**Controlla il formato del file**:
- Assicurati che i file Excel siano `.xlsx` o `.xls`
- Assicurati che i file CSV siano formattati correttamente

### Problemi di stile

**Svuota la cache del browser**:
- Premi `Ctrl+Shift+R` (Windows/Linux)
- Premi `Cmd+Shift+R` (Mac)

**Prova un browser diverso**:
La UI è testata su Chrome, Firefox e Safari.

## Uso Avanzato

### Personalizzare la UI

Il codice della Chat UI si trova in `./chat/`:

```
chat/
├── app.py              # Flask application (chat, converter, wizard)
├── templates/          # HTML templates
│   ├── chat.html      # Chat interface
│   ├── converter.html # Converter interface
│   └── wizard.html    # Modelfile wizard
├── Dockerfile          # Container configuration
└── requirements.txt    # Python dependencies
```

Per personalizzare:
1. Modifica i file in `./chat/`
2. Ricostruisci il container:
   ```bash
   docker compose build chat
   docker compose up -d
   ```

### Usare l'API Direttamente

La Chat UI usa l'API di Ollama. Puoi chiamarla direttamente:

**Genera una risposta**:
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:1b",
  "prompt": "Hello!",
  "stream": true
}'
```

**Chatta con contesto**:
```bash
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2:1b",
  "messages": [
    {"role": "user", "content": "What is Docker?"}
  ],
  "stream": true
}'
```

Consulta la [Guida all'Uso dell'API](./api-usage.md) per la documentazione completa dell'API.

## Scorciatoie da Tastiera

- **Enter**: invia il messaggio
- **Shift+Enter**: nuova riga nel messaggio
- **Esc**: pulisci l'input (quando è a fuoco)
- **Ctrl+L**: pulisci la cronologia della chat (prossimamente)

## Prossimi Passi

- [Guida all'Uso](./usage.md) - Impara i comandi CLI e la gestione dei modelli
- [Esempi](./examples.md) - Template di modello preconfigurati
- [Esempio di Addestramento su Dataset](./dataset-training-example.md) - Addestra con i tuoi dati
- [Uso dell'API](./api-usage.md) - Accesso programmatico ai modelli
