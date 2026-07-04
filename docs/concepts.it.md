# Concetti essenziali - Riferimento rapido

**Nuovo a Ollama e ai modelli linguistici?** Questa pagina spiega tutto ciò che devi sapere in termini semplici.

---

## 🎯 Le basi (inizia da qui)

### Cos'è Ollama?
Uno strumento che ti permette di eseguire modelli linguistici di IA (come ChatGPT) **localmente sul tuo computer**. Nessuna connessione internet richiesta, nessun costo di API, privacy completa.

### Cos'è un modello?
Pensalo come un "cervello" in grado di comprendere e generare testo. Modelli diversi hanno capacità diverse:
- **Modelli piccoli** (1B-3B): Veloci, usano meno memoria, adatti a compiti semplici
- **Modelli medi** (7B-13B): Qualità e velocità bilanciate
- **Modelli grandi** (30B+): Migliore qualità, ma lenti e avidi di memoria

**La "B" sta per "miliardi di parametri"** - più parametri = più intelligente ma più lento.

### Cos'è un Modelfile?
Come una scheda ricetta per creare un modello personalizzato. Definisce:
- Quale modello base usare
- Come deve comportarsi il modello (personalità, regole)
- Le impostazioni che controllano la qualità dell'output

**Pensalo come un Dockerfile** - un file di testo con istruzioni.

---

## 🔧 Concetti fondamentali

### Modello base
Un modello pre-addestrato dalla libreria di Ollama (ad esempio `llama3.2:1b`, `mistral:7b`).

**Costruisci modelli personalizzati SOPRA i modelli base** - non addestri da zero.

**Da dove provengono?**
- Scaricali dalla [Libreria di Ollama](https://ollama.com/library)
- Usa `make pull-base` per ottenere i più comuni
- Oppure scaricali tramite la Web UI

### Scegliere un modello base (2026)

Questo progetto punta deliberatamente sui **modelli leggeri** — tutto ciò che è presente nelle guide e negli esempi usa `llama3.2:1b`, che resta un'ottima scelta di default, veloce, per imparare e prototipare. Il panorama dei modelli continua però a evolversi, e queste moderne alternative leggere meritano di essere provate con un semplice `ollama pull`:

| Modello | Dimensione approx. | RAM approx. necessaria | Note |
|-------|-------------|--------------------|-------|
| `llama3.2:1b` | ~1.3 GB | ~4 GB | Default del progetto; veloce, ben documentato |
| `qwen3:0.6b` | ~0.5 GB | ~2 GB | Minuscolo ma sorprendentemente valido; modalità thinking opzionale |
| `qwen3:1.7b` | ~1.4 GB | ~4 GB | Piccolo e valido; modalità thinking opzionale |
| `gemma3:1b` | ~815 MB | ~4 GB | Modello Google compatto |
| `gemma3:4b` | ~3.3 GB | ~8 GB | Multimodale (immagini), contesto da 128K |
| `phi4-mini` | ~2.5 GB | ~8 GB | Modello Microsoft compatto ed efficiente |
| `llama3.2:3b` | ~2 GB | ~8 GB | Qualità e velocità bilanciate |
| `mistral:7b` | ~4.1 GB | ~8-16 GB | Qualità superiore, più lento |

**Opzioni più pesanti per macchine performanti:**

| Modello | Dimensione approx. | RAM approx. necessaria | Note |
|-------|-------------|--------------------|-------|
| `qwen3:8b` | ~5 GB | ~16 GB | Solido modello general-purpose |
| `gpt-oss:20b` | ~13 GB | ~16 GB | Modello open-weight di OpenAI |

I valori di RAM sono indicazioni approssimative per l'inferenza su CPU; una GPU con VRAM sufficiente rende tutto molto più veloce. Ognuno di questi può sostituire `llama3.2:1b` nella riga `FROM` di un Modelfile.

### Novità in Ollama (2026)

Questa guida si concentra sull'**esecuzione dei modelli in locale** — è tutto ciò che serve per quanto trattato qui. Ma Ollama stesso è cresciuto, e queste funzionalità esistono se il locale non ti basta più:

- **Modelli cloud**: Scarica il lavoro dei modelli grandi sul cloud di Ollama mantenendo esattamente le stesse API e CLI — utile quando un modello non entra nel tuo hardware.
- **`ollama launch`**: Configura in automatico strumenti/agenti di coding preimpostati per usare i tuoi modelli locali.
- **API di ricerca web**: Permette ai modelli di arricchire le risposte con risultati dal web.
- **Scheduling migliorato**: Migliore supporto multi-GPU e gestione della memoria per configurazioni più grandi.

### System prompt
Istruzioni che definiscono il comportamento e la personalità del tuo modello.

**Esempio:**
```
SYSTEM """
You are a helpful customer support agent for ACME Corp.
Be friendly, professional, and concise.
Always ask clarifying questions if unsure.
"""
```

**Questo è il modo più semplice per personalizzare un modello!**

### Parametri
Impostazioni che controllano come il modello genera il testo.

**I 3 più importanti:**
- **temperature** (0.0-2.0): Manopola della creatività
  - `0.3` = Prevedibile, fattuale (per codice, supporto)
  - `0.7` = Bilanciato (per chat)
  - `1.2` = Creativo, vario (per storie)

- **num_ctx** (token): Quanta cronologia della conversazione il modello ricorda
  - `2048` = Conversazioni brevi
  - `4096` = Standard (consigliato)
  - `8192` = Discussioni lunghe e complesse

- **top_p** (0.0-1.0): Controllo della varietà dell'output
  - `0.9` = Buon valore di default per la maggior parte degli usi

**Non preoccuparti ancora degli altri parametri** - questi valori di default funzionano benissimo:
```
PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
```

---

## 🎓 Metodi di personalizzazione

### Metodo 1: Solo system prompt (il più semplice)
**Quando usarlo:** Vuoi cambiare la personalità o aggiungere regole

**Esempio:** Creare un bot di supporto clienti, un traduttore o un assistente di codice

**Come:** Modifica la sezione `SYSTEM` in un Modelfile

**Tempo richiesto:** 5 minuti

---

### Metodo 2: Few-shot learning con esempi MESSAGE
**Quando usarlo:** Hai da 5 a 50 coppie domanda/risposta di esempio

**Esempio:** Addestrare un bot di supporto con le domande più comuni dei clienti

**Come:** Aggiungi blocchi `MESSAGE` al tuo Modelfile
```
MESSAGE user "What are your hours?"
MESSAGE assistant "We're open Mon-Fri, 9am-6pm EST."
```

**Tempo richiesto:** 15-30 minuti

---

### Metodo 3: Fine-tuning (avanzato)
**Quando usarlo:** Hai più di 100 esempi e serve una specializzazione profonda

**Esempio:** Bot di diagnosi medica, analizzatore di documenti legali

**Come:** Addestra con strumenti esterni (Unsloth, Hugging Face), esporta in GGUF, importa in Ollama — vedi la [Guida al fine-tuning](./fine-tuning-guide.md)

**Tempo richiesto:** Da ore a giorni (richiede una GPU)

**⚠️ La maggior parte degli utenti non ne ha bisogno!** Prova prima il Metodo 1 o 2.

---

## Albero decisionale: quale metodo dovrei usare?

```
Do you just want to change the model's personality/behavior?
├─ YES → Use Method 1 (System Prompt)
└─ NO → Continue...

Do you have specific examples of how it should respond?
├─ NO → Use Method 1 (System Prompt with detailed instructions)
└─ YES → Continue...

Do you have less than 50 examples?
├─ YES → Use Method 2 (Few-Shot Learning)
└─ NO → Continue...

Do you have 100+ examples and need specialized knowledge?
├─ YES → Consider Method 3 (Fine-Tuning)
└─ NO → Use Method 2 (Few-Shot Learning)
```

---

## 🗂️ Formati di file spiegati

### File GGUF
File di modello compressi che funzionano con Ollama.

**Quando li vedrai:**
- Scaricando modelli da Hugging Face
- Importando modelli addestrati esternamente
- Usando modelli personalizzati sottoposti a fine-tuning

**Cosa fare:** Posizionali in `./data/gguf/` e usa `bash scripts/import-model.sh`

### File JSONL
Formato dei dati di addestramento - un oggetto JSON per riga.

**Esempio:**
```json
{"role": "user", "content": "What is your return policy?"}
{"role": "assistant", "content": "We offer 30-day returns with receipt."}
```

**Quando li userai:** Preparando i dataset di addestramento

**Strumento disponibile:** Convertitore da foglio di calcolo a JSONL nella Web UI

### Modelfile
File di testo con le istruzioni per creare un modello (come un Dockerfile).

**Struttura:**
```
FROM llama3.2:1b
PARAMETER temperature 0.7
SYSTEM """Your instructions here"""
MESSAGE user "example question"
MESSAGE assistant "example answer"
```

---

## 🔌 Porte e servizi

Dopo aver eseguito `make up`, ottieni:

- **Porta 11434**: API di Ollama (per l'accesso programmatico)
- **Porta 8080**: Web UI — chat (`/`), convertitore di fogli di calcolo (`/converter`) e wizard per Modelfile (`/wizard`)

Entrambe le porte host sono configurabili tramite `OLLAMA_PORT` e `CHAT_PORT` nel file `.env` (poi `make down && make up`).

**Basta aprire http://localhost:8080** - è tutto ciò che serve!

---

## 🐳 Concetti Docker (guida rapida)

### Container
Una macchina virtuale leggera che esegue Ollama. **I tuoi modelli vivono dentro questo container.**

### Volume
Storage persistente. **Il volume `ollama_data`** memorizza i tuoi modelli anche quando il container si ferma.

**Importante:**
- `make down` = Ferma il container (i modelli sono al sicuro ✅)
- `make clean` = Elimina il container E il volume (i modelli vengono cancellati ❌)

### Bind mount
Collegamento tra il tuo computer e il container.

**Perché è importante:**
- `./models/` sul tuo computer → `/models/` nel container
- `./data/` sul tuo computer → `/data/` nel container

**È così che aggiungi file a Ollama!**

---

## 🚀 Concetti avanzati (puoi saltarli all'inizio)

### Adapter LoRA
Piccoli file che modificano il comportamento del modello base senza un riaddestramento completo.

**Quando ti serviranno:** Fine-tuning con risorse limitate

**Come usarli:** Referenziali nel Modelfile con `ADAPTER /data/adapters/my-adapter.bin`

### Quantizzazione
Ridurre la precisione del modello per risparmiare memoria (8-bit, 4-bit).

**Quando ti servirà:** Eseguire modelli grandi con RAM limitata

**Ollama lo fa automaticamente** - non devi preoccupartene.

### Context window
Quanti token (parole/parti di parole) il modello può elaborare contemporaneamente.

**Controllata da:** Il parametro `num_ctx`

**Default:** 2048 token (~1500 parole)

### Token
Unità atomica di testo (non sempre una parola intera).

**Esempio:** "Hello world" = 2 token, "Anthropic" = 1 token, "ChatGPT" = 2 token

**Perché è importante:** Prezzo dei modelli, limiti di contesto, lunghezza delle risposte

### Template
Formattazione avanzata dei prompt usando la sintassi dei template di Go.

**Quando ti servirà:** Formati di chat personalizzati per modelli specifici

**⚠️ Saltalo a meno che tu non abbia requisiti specifici**

---

## 📖 Glossario rapido

| Termine | Definizione semplice |
|------|-------------------|
| **Inference** | Eseguire un modello per generare testo |
| **Prompt** | Il testo di input che dai al modello |
| **System Prompt** | Istruzioni che definiscono il comportamento del modello |
| **Temperature** | Impostazione della creatività (0=noioso, 2=caotico) |
| **Context** | Quanta cronologia il modello ricorda |
| **Base Model** | Modello pre-addestrato dalla libreria di Ollama |
| **Custom Model** | La tua versione modificata di un modello base |
| **Modelfile** | Ricetta per creare un modello personalizzato |
| **GGUF** | Formato di file di modello per Ollama |
| **LoRA** | Metodo efficiente di fine-tuning |
| **Few-Shot** | Apprendimento da pochi esempi |
| **Fine-Tuning** | Addestrare il modello su un dataset personalizzato |
| **Quantization** | Comprimere il modello per usare meno memoria |

---

## 🎯 Cosa devi davvero sapere (TL;DR)

**Per iniziare (5 minuti):**
1. Cos'è Ollama (esegue modelli di IA in locale)
2. Come scaricare un modello base
3. Come chattare tramite la Web UI

**Per creare modelli personalizzati (15 minuti):**
1. Cos'è un Modelfile
2. Come scrivere un system prompt
3. Il parametro temperature (0.3 = fattuale, 0.7 = bilanciato, 1.2 = creativo)

**Per addestrare con i tuoi dati (30 minuti):**
1. Cos'è il few-shot learning
2. Come aggiungere esempi MESSAGE
3. Le basi del formato JSONL

**Tutto il resto può aspettare!** Inizia in modo semplice e impara strada facendo.

---

## 🔗 Prossimi passi

- **Sei alle prime armi?** Inizia con la [Guida alla Chat UI](./chat-ui.md) - usa modelli già pronti
- **Pronto a personalizzare?** Vedi gli [Esempi di Modelfile](./examples.md) - copia e modifica
- **Hai dati di addestramento?** Leggi l'[Esempio di addestramento su dataset](./dataset-training-example.md)
- **Serve un riferimento?** Consulta il [Riferimento Modelfile](./modelfile-reference.md) - sintassi completa

---

**Ancora confuso?** È normale! Inizia con la Web UI, gioca con i modelli già pronti, e i concetti andranno al loro posto. 🎉
