# Modelfile di Esempio

Il progetto include template di Modelfile preconfigurati per i casi d'uso più comuni. Questi esempi illustrano le best practice e diverse configurazioni di parametri.

## Riferimento Rapido

| Esempio | Modello Base | Temperature | Contesto | Caso d'Uso |
|---------|------------|-------------|---------|----------|
| [Chatbot](#1-chatbot) | llama3.2:1b | 0.7 | 4096 | Conversazione generica |
| [Assistente di Codice](#2-assistente-di-codice) | llama3.2:1b | 0.3 | 8192 | Aiuto alla programmazione |
| [Traduttore](#3-traduttore) | llama3.2:1b | 0.5 | 4096 | Traduzione linguistica |
| [Scrittore Creativo](#4-scrittore-creativo) | llama3.2:1b | 1.2 | 8192 | Creazione di contenuti |
| [Assistente Personale](#5-assistente-personale) | llama3.2:1b | 0.6 | 4096 | Gestione delle attività |
| [Supporto TechCorp](#6-supporto-techcorp) | llama3.2:1b | 0.3 | 4096 | Supporto clienti |

## Utilizzare gli Esempi

### Avvio Rapido

Crea un modello a partire da qualsiasi esempio:

```bash
# Interactive selection
make create-model

# Or directly
bash scripts/create-custom-model.sh <model-name> ./models/examples/<example>/Modelfile

# Example:
bash scripts/create-custom-model.sh my-chatbot ./models/examples/chatbot/Modelfile
```

Testa il modello:
```bash
make chat
# Select your newly created model
```

---

## 1. Chatbot

**Posizione**: `models/examples/chatbot/Modelfile`

### Scopo
IA conversazionale generica per assistenza clienti, Q&A e chat informali.

### Configurazione

```dockerfile
FROM llama3.2:1b

PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1

SYSTEM """
You are a friendly and helpful AI assistant.
Provide clear, accurate, and concise responses.
Be conversational but professional.
"""
```

### Ideale Per
- Supporto clienti
- Q&A generico
- Sistemi di aiuto interattivi
- Chatbot didattici

### Esempio di Utilizzo

```bash
bash scripts/create-custom-model.sh friendly-bot ./models/examples/chatbot/Modelfile
docker compose exec ollama ollama run friendly-bot "How can I track my order?"
```

### Note sui Parametri
- **Temperature 0.7**: Equilibrio tra coerenza e varietà
- **Contesto 4096**: Gestisce conversazioni di lunghezza media
- **Top P 0.9**: Buona diversità senza risultare casuale

---

## 2. Assistente di Codice

**Posizione**: `models/examples/code-assistant/Modelfile`

### Scopo
Aiuto alla programmazione, generazione di codice, debugging e spiegazioni tecniche.

### Configurazione

```dockerfile
FROM llama3.2:1b

PARAMETER temperature 0.3
PARAMETER num_ctx 8192
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.15

SYSTEM """
You are an expert programming assistant.
- Provide clear, well-commented code
- Explain your reasoning
- Follow best practices and design patterns
- Suggest optimizations when relevant
"""
```

### Ideale Per
- Generazione di codice
- Aiuto al debugging
- Revisione del codice
- Documentazione tecnica
- Spiegazione di algoritmi

### Esempio di Utilizzo

```bash
bash scripts/create-custom-model.sh code-helper ./models/examples/code-assistant/Modelfile
docker compose exec ollama ollama run code-helper "Write a Python function to validate email addresses"
```

### Note sui Parametri
- **Temperature 0.3**: Generazione di codice deterministica e coerente
- **Contesto 8192**: Può gestire file di codice di grandi dimensioni
- **Repeat Penalty 1.15**: Evita pattern di codice ripetitivi

---

## 3. Traduttore

**Posizione**: `models/examples/translator/Modelfile`

### Scopo
Traduzione linguistica e localizzazione.

### Configurazione

```dockerfile
FROM llama3.2:1b

PARAMETER temperature 0.5
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1

SYSTEM """
You are a professional translator.
Translate text accurately while preserving:
- Meaning and intent
- Cultural context
- Tone and formality
- Idiomatic expressions

Provide natural-sounding translations in the target language.
"""
```

### Ideale Per
- Traduzione di testi
- Localizzazione
- Apprendimento delle lingue
- Creazione di contenuti multilingue

### Esempio di Utilizzo

```bash
bash scripts/create-custom-model.sh translator ./models/examples/translator/Modelfile
docker compose exec ollama ollama run translator "Translate to Spanish: Hello, how are you today?"
```

### Note sui Parametri
- **Temperature 0.5**: Creatività moderata per un fraseggio naturale
- **Contesto 4096**: Gestisce paragrafi e documenti
- **Top P 0.9**: Varietà di traduzione equilibrata

---

## 4. Scrittore Creativo

**Posizione**: `models/examples/creative-writer/Modelfile`

### Scopo
Generazione di contenuti creativi, narrativa e ideazione.

### Configurazione

```dockerfile
FROM llama3.2:1b

PARAMETER temperature 1.2
PARAMETER num_ctx 8192
PARAMETER top_p 0.95
PARAMETER repeat_penalty 1.2

SYSTEM """
You are a creative writing assistant.
Generate engaging, imaginative, and original content.
Use vivid descriptions, varied vocabulary, and interesting narratives.
Adapt your style to the genre and tone requested.
"""
```

### Ideale Per
- Scrittura di storie
- Creazione di contenuti
- Brainstorming di idee
- Testi di marketing
- Poesia e testi creativi

### Esempio di Utilizzo

```bash
bash scripts/create-custom-model.sh creative ./models/examples/creative-writer/Modelfile
docker compose exec ollama ollama run creative "Write a short story about a robot learning to paint"
```

### Note sui Parametri
- **Temperature 1.2**: Elevata creatività e varietà
- **Contesto 8192**: Generazione di contenuti di ampio respiro
- **Top P 0.95**: Ampia gamma di vocabolario
- **Repeat Penalty 1.2**: Evita fraseggi ripetitivi

---

## 5. Assistente Personale

**Posizione**: `models/examples/personal-assistant/Modelfile`

### Scopo
Gestione delle attività, pianificazione, promemoria e produttività personale.

### Configurazione

```dockerfile
FROM llama3.2:1b

PARAMETER temperature 0.6
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1

SYSTEM """
You are a personal assistant helping with:
- Task organization and prioritization
- Schedule management
- Reminders and follow-ups
- Information lookup
- Productivity tips

Be efficient, organized, and proactive.
"""
```

### Ideale Per
- Gestione delle liste di cose da fare
- Assistenza al calendario
- Redazione di email
- Pianificazione di riunioni
- Organizzazione personale

### Esempio di Utilizzo

```bash
bash scripts/create-custom-model.sh assistant ./models/examples/personal-assistant/Modelfile
docker compose exec ollama ollama run assistant "Help me plan my day. I have a meeting at 2pm and need to finish a report."
```

### Note sui Parametri
- **Temperature 0.6**: Coerente ma non rigido
- **Contesto 4096**: Tiene traccia di attività e conversazioni
- **Top P 0.9**: Flusso conversazionale naturale

---

## 6. Supporto TechCorp

**Posizione**: `models/examples/techcorp-support/Modelfile`

### Scopo
Dimostra il few-shot learning con esempi da dataset per un supporto clienti specializzato.

### Configurazione

```dockerfile
FROM llama3.2:1b

PARAMETER temperature 0.3
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1

SYSTEM """
You are a customer support agent for TechCorp.
Provide accurate, helpful, and professional responses.
"""

# Few-shot examples from dataset
MESSAGE user "How do I reset my password?"
MESSAGE assistant "Click 'Forgot Password' on the login page..."

MESSAGE user "What are your business hours?"
MESSAGE assistant "We're open Monday-Friday, 9am-5pm EST..."

# (additional examples...)
```

### Dataset

Il modello utilizza esempi da `data/training/techcorp-support.jsonl` (10 coppie Q&A).

### Ideale Per
- Bot di supporto specifici per l'azienda
- Automazione delle FAQ
- Risposte coerenti e brandizzate
- Query su knowledge base

### Esempio di Utilizzo

```bash
bash scripts/create-custom-model.sh support-bot ./models/examples/techcorp-support/Modelfile
docker compose exec ollama ollama run support-bot "How do I reset my password?"
```

### Note sui Parametri
- **Temperature 0.3**: Risposte fattuali e coerenti
- **Few-shot Learning**: Gli esempi MESSAGE addestrano il modello
- **Contesto 4096**: Gestisce le conversazioni di supporto

### Approfondimenti
Consulta l'[Esempio di Addestramento con Dataset](./dataset-training-example.md) per una guida completa alla creazione di bot di supporto personalizzati.

---

## Personalizzare gli Esempi

Tutti gli esempi possono essere personalizzati in base alle tue esigenze:

### 1. Copia l'Esempio

```bash
cp -r ./models/examples/chatbot ./models/custom/my-chatbot
```

### 2. Modifica il Modelfile

```bash
nano ./models/custom/my-chatbot/Modelfile
```

Modifica:
- **Modello base**: Cambia la riga `FROM` per usare un modello diverso
- **Parametri**: Regola temperature, contesto, ecc.
- **System prompt**: Personalizza comportamento e personalità
- **Esempi**: Aggiungi coppie MESSAGE per il few-shot learning

### 3. Crea il Tuo Modello

```bash
bash scripts/create-custom-model.sh my-chatbot ./models/custom/my-chatbot/Modelfile
```

## Ottimizzazione dei Parametri

Riferimento rapido per i valori utilizzati negli esempi qui sopra:

| Parametro | Fattuale/supporto | Chat equilibrata | Creativo |
|-----------|-----------------|---------------|----------|
| `temperature` | 0.2-0.3 | 0.6-0.8 | 1.0-1.2 |
| `num_ctx` | 4096 | 4096 | 8192 |
| `top_p` | 0.9 | 0.9 | 0.95 |
| `repeat_penalty` | 1.0-1.1 | 1.1 | 1.2 |

**Per consigli dettagliati sull'ottimizzazione, preset pronti da copiare e incollare e la risoluzione dei problemi, consulta la [Guida ai Parametri](./parameter-guide.md)** — il riferimento canonico sui parametri.

## Testare il Tuo Modello Personalizzato

### Test Rapido

```bash
docker compose exec ollama ollama run <model-name> "Test prompt"
```

### Test Interattivo

```bash
make chat
# Select your model
```

### Test via API

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "your-model",
  "prompt": "Test prompt",
  "stream": false
}'
```

### Test Completo

Usa lo script quick-test:
```bash
make quick-test
```

## Prossimi Passi

- [Guida ai Parametri](./parameter-guide.md) - Preset canonici dei parametri e ottimizzazione
- [Riferimento Modelfile](./modelfile-reference.md) - Guida completa alla sintassi
- [Esempio di Addestramento con Dataset](./dataset-training-example.md) - Addestra con dati personalizzati
- [Utilizzo Avanzato](./advanced-usage.md) - Template, adattatori LoRA e altro
- [Utilizzo delle API](./api-usage.md) - Integra i modelli nelle applicazioni
