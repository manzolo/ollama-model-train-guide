# Guida alla personalizzazione dei modelli - Quale metodo dovrei usare?

**Hai dubbi su come personalizzare il tuo modello?** Questa guida ti aiuta a scegliere l'approccio giusto.

---

## 🎯 Albero decisionale rapido

**In breve:** cambiare il comportamento → **System Prompt** (5 min). Hai < 50 esempi di domande/risposte → **Few-Shot Learning** (30 min). Hai 100+ esempi e serve una specializzazione approfondita → **Fine-Tuning** (ore/giorni, GPU).

Per l'albero decisionale completo passo passo, consulta [Concetti essenziali - Albero decisionale](./concepts.md#albero-decisionale-quale-metodo-dovrei-usare).

---

## 📊 Tabella comparativa

| Metodo | Tempo | Difficoltà | Quando usarlo | Costo |
|--------|------|------------|-------------|------|
| **System Prompt** | 5 min | ⭐ Facile | Cambiare comportamento, aggiungere regole | Gratuito |
| **Few-Shot** | 30 min | ⭐⭐ Medio | Aggiungere 5-50 esempi | Gratuito |
| **Fine-Tuning** | Ore+ | ⭐⭐⭐⭐ Difficile | 100+ esempi, specializzazione approfondita | Tempo GPU |

**Al 90% degli utenti servono solo i Metodi 1 o 2!**

---

## 🔧 Metodo 1: System Prompt (il più semplice)

### Quando usarlo
- Cambiare la personalità del modello (formale, informale, tecnica, ecc.)
- Aggiungere regole o vincoli specifici
- Definire un ruolo (supporto clienti, tutor, assistente)
- Impostare il formato dell'output (JSON, markdown, ecc.)

### Cosa ti serve
- Nessun dato di addestramento richiesto
- Solo istruzioni chiare

### Tempo richiesto
- 5-15 minuti

### Esempi di casi d'uso
✅ Rendere un chatbot più professionale
✅ Creare un assistente di codice che spiega passo passo
✅ Costruire un traduttore con uno stile specifico
✅ Progettare uno scrittore creativo che usa determinati temi

### Come farlo

**Passo 1:** crea un Modelfile
```bash
mkdir -p ./models/custom/my-assistant
nano ./models/custom/my-assistant/Modelfile
```

**Passo 2:** definisci il comportamento con il prompt SYSTEM
```dockerfile
FROM llama3.2:1b

PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_p 0.9

SYSTEM """
You are a helpful programming tutor.

Your role:
- Explain concepts in simple terms
- Provide code examples
- Ask clarifying questions if the request is unclear
- Break down complex topics into steps

Style:
- Use clear, beginner-friendly language
- Include emojis for readability
- Always test code before suggesting it
- Admit when you're unsure
"""
```

**Passo 3:** crea il modello
```bash
bash scripts/create-custom-model.sh my-assistant ./models/custom/my-assistant/Modelfile
```

**Passo 4:** provalo
```bash
make chat
# Seleziona "my-assistant" e inizia a chattare
```

### Pro
✅ Il metodo più veloce
✅ Nessun dato di addestramento necessario
✅ Facile da iterare e migliorare
✅ Funziona immediatamente

### Contro
❌ Conoscenza limitata a quella del modello base
❌ Non può aggiungere conoscenze specialistiche complesse
❌ Potrebbe non seguire le istruzioni perfettamente ogni volta

---

## 📚 Metodo 2: Few-Shot Learning (consigliato)

### Quando usarlo
- Hai 5-50 interazioni di esempio
- Vuoi che il modello risponda in un modo specifico
- Serve un tono/formato coerente
- Vuoi insegnare conoscenze di un dominio specifico

### Cosa ti serve
- Coppie domanda/risposta
- Esempi di risposte ideali
- Un file JSONL (opzionale, puoi usare il convertitore)

### Tempo richiesto
- Da 30 minuti a 2 ore

### Esempi di casi d'uso
✅ Supporto clienti con FAQ
✅ Domande e risposte sulla documentazione di prodotto
✅ Generazione di contenuti con uno stile specifico
✅ Terminologia specifica di un dominio

### Come farlo

**Passo 1:** prepara i tuoi esempi

Opzione A: manuale (per dataset piccoli)
```dockerfile
FROM llama3.2:1b

PARAMETER temperature 0.3
PARAMETER num_ctx 4096

SYSTEM """
You are TechCorp's customer support assistant.
Be helpful, professional, and concise.
"""

MESSAGE user "What are your business hours?"
MESSAGE assistant "We're open Monday-Friday, 9am-6pm EST. Weekend support is available via email."

MESSAGE user "How do I reset my password?"
MESSAGE assistant "To reset your password: 1) Click 'Forgot Password' on the login page. 2) Enter your email. 3) Check your inbox for a reset link. 4) Create a new password. If you don't receive the email within 5 minutes, check your spam folder."

MESSAGE user "What's your return policy?"
MESSAGE assistant "We offer a 30-day money-back guarantee. Items must be unused and in original packaging. Simply contact support to initiate a return and we'll email you a prepaid shipping label."
```

Opzione B: usare un file JSONL
```bash
# Use the Web UI converter
# 1. Go to http://localhost:8080/converter
# 2. Upload your Excel/CSV with questions and answers
# 3. Download the JSONL file
# 4. Save to ./data/training/my-data.jsonl
```

Poi fai riferimento ad esso nel Modelfile:
```dockerfile
FROM llama3.2:1b

PARAMETER temperature 0.3
PARAMETER num_ctx 4096

SYSTEM """
You are a customer support assistant.
"""

# Load examples from JSONL (if using external data)
# Note: Currently requires manual MESSAGE blocks
# Future: We may support direct JSONL import
```

**Passo 2:** crea il modello
```bash
bash scripts/create-custom-model.sh support-bot ./models/custom/support-bot/Modelfile
```

**Passo 3:** prova con domande reali
```bash
docker compose exec ollama ollama run support-bot "How can I track my order?"
```

### Pro
✅ Più coerente del solo System Prompt
✅ Insegna conoscenze specifiche
✅ Comunque veloce e semplice
✅ Non richiede GPU

### Contro
❌ Limitato a circa 50 esempi (dimensione del Modelfile)
❌ Non "apprende" in profondità i pattern
❌ Potrebbe non generalizzare bene oltre gli esempi

### Consigli
- Inizia con 5-10 esempi, prova, poi aggiungine altri
- Includi casi limite e variazioni comuni
- Rendi gli esempi diversificati (diversi stili di domanda)
- Prova dopo aver aggiunto ogni gruppo

---

## 🚀 Metodo 3: Fine-Tuning (avanzato)

### Quando usarlo
- Hai 100+ esempi di addestramento
- Serve una specializzazione approfondita in un dominio (medico, legale, tecnico)
- Vuoi che il modello apprenda pattern complessi
- Servono output strutturati e coerenti

### Cosa ti serve
- Un dataset ampio (100-10.000+ esempi)
- Accesso a una GPU (locale o cloud)
- Competenze tecniche (Python, framework ML)
- Tempo per l'addestramento e la valutazione

### Tempo richiesto
- Configurazione: 1-2 ore
- Addestramento: da 30 minuti a 8+ ore (dipende dalla dimensione)
- Valutazione: 1-2 ore

### Esempi di casi d'uso
✅ Assistente per diagnosi mediche
✅ Analizzatore di documenti legali
✅ Generazione di codice per un framework specifico
✅ Esperto di troubleshooting tecnico

### Processo ad alto livello

Ollama di per sé non esegue il fine-tuning dei modelli — l'addestramento avviene con strumenti esterni e poi si importa il risultato:

1. **Prepara un dataset JSONL** (100+ esempi)
2. **Addestra esternamente** con Unsloth o Hugging Face Transformers (localmente o sulla GPU gratuita di Google Colab), tipicamente con LoRA/QLoRA
3. **Esporta in formato GGUF** con llama.cpp
4. **Importa in Ollama**: `bash scripts/import-model.sh my-finetuned ./data/gguf/my-model.gguf`

**📖 Guida completa passo passo con gli script di addestramento: [Guida al Fine-Tuning](./fine-tuning-guide.md)** (approfondimento canonico). Per un esempio concreto svolto, consulta l'[Esempio di addestramento su dataset](./dataset-training-example.md).

### Pro
✅ Apprendimento approfondito dei pattern
✅ Può gestire conoscenze di dominio complesse
✅ Migliore generalizzazione
✅ Output strutturati e coerenti

### Contro
❌ Richiede molto tempo
❌ Richiede una GPU
❌ Complessità tecnica
❌ Rischio di overfitting
❌ Costoso (tempo GPU/costi cloud)

### Note importanti
⚠️ **Prova prima il Metodo 2!** Il few-shot learning spesso funziona sorprendentemente bene.
⚠️ **Più dati ≠ meglio** - La qualità conta più della quantità.
⚠️ **Inizia in piccolo** - Fai fine-tuning su 100 esempi, valuta, poi aumenta la scala.

---

## 🎓 Percorso di apprendimento progressivo

### Settimana 1: inizia semplice
1. Usa i modelli esistenti dalla libreria Ollama
2. Prova con la Web UI
3. Comprendi i fondamenti del prompting

### Settimana 2: System Prompt
1. Crea il tuo primo Modelfile personalizzato
2. Sperimenta con i prompt SYSTEM
3. Regola i parametri (temperature, ecc.)

### Settimana 3: Few-Shot Learning
1. Raccogli 10-20 domande/risposte di esempio
2. Aggiungi blocchi MESSAGE al Modelfile
3. Prova e affina

### Settimana 4+: avanzato (opzionale)
1. Valuta il fine-tuning per esigenze specialistiche
2. Esplora gli adapter LoRA
3. Distribuisci in produzione

---

## 📖 Esempi reali

### Esempio 1: assistente personale (System Prompt)
**Obiettivo:** un aiutante cordiale che mantiene le risposte concise

**Metodo:** System Prompt
**Tempo:** 5 minuti

```dockerfile
FROM llama3.2:1b
PARAMETER temperature 0.7
PARAMETER num_ctx 4096

SYSTEM """
You are a helpful personal assistant.
Keep responses under 3 sentences unless asked for details.
Be friendly and use a conversational tone.
"""
```

### Esempio 2: bot per le FAQ (Few-Shot)
**Obiettivo:** rispondere a domande comuni su un prodotto

**Metodo:** Few-Shot Learning
**Tempo:** 30 minuti
**Dati:** 20 coppie di domande/risposte dai ticket di supporto

```dockerfile
FROM llama3.2:1b
PARAMETER temperature 0.3
PARAMETER num_ctx 4096

SYSTEM """
You are a support bot for WidgetPro 3000.
Answer questions based on the manual.
"""

MESSAGE user "How do I charge the battery?"
MESSAGE assistant "Connect the USB-C cable to the charging port on the bottom. A red light indicates charging; green means fully charged (takes ~2 hours)."

# ... 19 more examples ...
```

### Esempio 3: assistente per la codifica medica (Fine-Tuning)
**Obiettivo:** convertire note mediche in codici di fatturazione

**Metodo:** Fine-Tuning
**Tempo:** 8 ore
**Dati:** 5.000 esempi etichettati

**Motivo del fine-tuning:**
- Richiede l'apprendimento di pattern complessi di codici ICD-10
- Necessita di alta precisione (conseguenze di fatturazione)
- È disponibile un ampio dataset etichettato
- Formato di output strutturato

---

## 🤔 Ancora indeciso?

### Chiediti:

**D: Voglio solo cambiare il modo in cui parla?**
→ Usa il **System Prompt**

**D: Ho esempi specifici di risposte ideali?**
→ Usa il **Few-Shot Learning** (se < 50 esempi)
→ Usa il **Fine-Tuning** (se 100+ esempi)

**D: È mission-critical con requisiti normativi?**
→ Considera il **Fine-Tuning** (dopo test approfonditi)

**D: Ho una scadenza stretta?**
→ Usa il **System Prompt** o il **Few-Shot Learning**

**D: Ho una GPU e competenze di ML?**
→ Considera il **Fine-Tuning** (ma prova prima i metodi più semplici!)

---

## 🚦 Guida a semaforo

| 🟢 Inizia da qui | 🟡 Passo successivo | 🔴 Avanzato |
|---------------|--------------|-------------|
| System Prompt | Few-Shot Learning | Fine-Tuning |
| 5 minuti | 30 minuti | Ore/Giorni |
| Nessun dato necessario | 5-50 esempi | 100+ esempi |
| Iterazione facile | Complessità media | Complessità alta |
| **Usalo per l'80% dei casi** | **Usalo per il 15% dei casi** | **Usalo per il 5% dei casi** |

---

## 📚 Risorse aggiuntive

- [Concetti essenziali](./concepts.md) - Impara le basi
- [Guida ai parametri](./parameter-guide.md) - Ottimizza le tue impostazioni
- [Modelfile di esempio](./examples.md) - Template pronti all'uso
- [Guida al Fine-Tuning](./fine-tuning-guide.md) - Approfondimento completo sul fine-tuning
- [Esempio di addestramento su dataset](./dataset-training-example.md) - Esempio svolto con un dataset

---

**Ricorda: inizia semplice, prova, itera!** La maggior parte degli utenti raggiunge i propri obiettivi con un semplice system prompt ben congegnato. Non complicare le cose! 🎯
