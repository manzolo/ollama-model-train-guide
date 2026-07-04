# Esempio Completo di Addestramento con Dataset

Questa guida mostra come addestrare un modello con un tuo dataset e utilizzarlo in Ollama.

## Esempio: Addestrare un Bot di Supporto Clienti

Creiamo un bot di supporto clienti per un'azienda fittizia "TechCorp" utilizzando un dataset personalizzato.

---

## Passo 1: Prepara il Tuo Dataset

Crea un dataset di addestramento in formato JSONL con le tue coppie Q&A.

**File**: `data/training/techcorp-support.jsonl`

```jsonl
{"instruction": "How do I reset my password?", "output": "To reset your password: 1. Go to login page 2. Click 'Forgot Password' 3. Enter your email 4. Check your inbox for the reset link 5. Follow the link and create a new password"}
{"instruction": "What are your business hours?", "output": "TechCorp support is available Monday-Friday 9:00-18:00 CET. For urgent issues outside these hours, please email emergency@techcorp.com"}
{"instruction": "How do I contact sales?", "output": "You can contact our sales team at sales@techcorp.com or call +39 055 1234567 during business hours (Mon-Fri 9:00-18:00 CET)"}
{"instruction": "Where are you located?", "output": "TechCorp headquarters is located in Florence, Italy. We also have offices in Milan and Rome."}
{"instruction": "Do you offer refunds?", "output": "Yes, we offer a 30-day money-back guarantee on all products. Contact support@techcorp.com with your order number to initiate a refund."}
{"instruction": "How long does shipping take?", "output": "Standard shipping within Italy takes 2-3 business days. Express shipping is available for next-day delivery in major cities."}
{"instruction": "What payment methods do you accept?", "output": "We accept credit cards (Visa, Mastercard, American Express), PayPal, bank transfer, and Apple Pay."}
{"instruction": "How do I track my order?", "output": "You'll receive a tracking number via email once your order ships. Use this number on our website's tracking page or the courier's website."}
{"instruction": "Can I change my order after placing it?", "output": "Yes, you can modify your order within 2 hours of placing it. Contact support@techcorp.com with your order number and requested changes."}
{"instruction": "What's your return policy?", "output": "Items can be returned within 30 days of delivery in original condition. Return shipping is free for defective items, otherwise customer pays return shipping."}
```

---

## Passo 2: Esegui il Fine-Tuning del Modello (Strumenti Esterni)

Ollama non addestra i modelli da solo — esegui il fine-tuning con strumenti esterni, esporti in GGUF e importi il risultato. Le due opzioni consigliate sono:

- **Unsloth** (veloce e semplice, basato su LoRA) — funziona bene su una singola GPU o sul tier GPU gratuito di Google Colab
- **Hugging Face Transformers + PEFT** — standard di settore, maggior controllo sul ciclo di addestramento

In breve, con Unsloth carichi un modello base a 4 bit (ad es. `unsloth/llama-3.2-1b-bnb-4bit`), colleghi gli adattatori LoRA, formatti gli esempi di `techcorp-support.jsonl` in prompt istruzione/risposta, addestri per un piccolo numero di step, quindi converti il modello unito in GGUF con llama.cpp:

```bash
python llama.cpp/convert.py techcorp-support-lora --outtype f16 --outfile techcorp-support.gguf
./llama.cpp/quantize techcorp-support.gguf techcorp-support-q4.gguf q4_0
```

**📖 Gli script di addestramento completi (Unsloth e Hugging Face), gli iperparametri LoRA, le opzioni di quantizzazione e la risoluzione dei problemi si trovano nella [Guida al Fine-Tuning](./fine-tuning-guide.md)** — l'approfondimento canonico per questo workflow.

---

## Passo 3: Importa in Ollama

Una volta ottenuto il file GGUF:

```bash
# Copy to data directory
cp techcorp-support-q4.gguf ./data/gguf/

# Import using the script
bash scripts/import-model.sh techcorp-support ./data/gguf/techcorp-support-q4.gguf
```

---

## Passo 4: Testa il Tuo Modello

```bash
# Interactive test
docker compose exec ollama ollama run techcorp-support

# Try these questions:
# - "How do I reset my password?"
# - "What are your business hours?"
# - "Where are you located?"
```

---

## Alternativa: Metodo Rapido con Few-Shot Learning

Se non vuoi eseguire un fine-tuning completo, puoi utilizzare l'approccio MESSAGE in un Modelfile:

**File**: `models/custom/techcorp-support/Modelfile`

```dockerfile
FROM llama3.2:1b

PARAMETER temperature 0.3
PARAMETER num_ctx 4096

SYSTEM """
You are TechCorp's customer support assistant. Provide helpful, accurate information about TechCorp services.

COMPANY INFO:
- Location: Florence, Italy (offices in Milan, Rome)
- Business Hours: Mon-Fri 9:00-18:00 CET
- Support Email: support@techcorp.com
- Sales Email: sales@techcorp.com
- Sales Phone: +39 055 1234567
- Emergency Email: emergency@techcorp.com

POLICIES:
- 30-day money-back guarantee
- Free returns for defective items
- Standard shipping: 2-3 business days in Italy
- Express shipping: Next-day in major cities
- Payment: Credit cards, PayPal, bank transfer, Apple Pay
"""

# Training examples
MESSAGE user How do I reset my password?
MESSAGE assistant To reset your password: 1. Go to login page 2. Click 'Forgot Password' 3. Enter your email 4. Check your inbox for the reset link 5. Follow the link and create a new password

MESSAGE user What are your business hours?
MESSAGE assistant TechCorp support is available Monday-Friday 9:00-18:00 CET. For urgent issues outside these hours, please email emergency@techcorp.com

MESSAGE user How do I contact sales?
MESSAGE assistant You can contact our sales team at sales@techcorp.com or call +39 055 1234567 during business hours (Mon-Fri 9:00-18:00 CET)

MESSAGE user Where are you located?
MESSAGE assistant TechCorp headquarters is located in Florence, Italy. We also have offices in Milan and Rome.

MESSAGE user Do you offer refunds?
MESSAGE assistant Yes, we offer a 30-day money-back guarantee on all products. Contact support@techcorp.com with your order number to initiate a refund.
```

Crea il modello:

```bash
bash scripts/create-custom-model.sh techcorp-support ./models/custom/techcorp-support/Modelfile
```

---

## Confronto: Fine-Tuning vs Few-Shot

| Aspetto | Fine-Tuning | Few-Shot (Modelfile) |
|--------|-------------|---------------------|
| **Tempo di Setup** | Da ore a giorni | Minuti |
| **Hardware** | GPU richiesta | Nessuno |
| **Dimensione del Dataset** | 100+ esempi | 5-20 esempi |
| **Qualità** | Migliore per attività complesse | Buona per Q&A semplici |
| **Costo** | Costi della GPU | Gratuito |
| **Flessibilità** | Può apprendere nuovi pattern | Limitata agli esempi |

**Raccomandazione**: 
- **Inizia con il Few-Shot** (approccio Modelfile) per una prototipazione rapida
- **Passa al Fine-Tuning** se hai bisogno di una qualità migliore o disponi di 100+ esempi

---

## Best Practice

### 1. Qualità del Dataset

```jsonl
# ❌ Bad - Too vague
{"instruction": "help", "output": "what do you need"}

# ✅ Good - Specific and detailed
{"instruction": "How do I reset my password?", "output": "To reset your password: 1. Go to login page 2. Click 'Forgot Password' 3. Enter your email 4. Check your inbox for the reset link 5. Follow the link and create a new password"}
```

### 2. Dimensione del Dataset

- **Minimo**: 50 esempi
- **Buono**: 100-500 esempi
- **Ideale**: 1.000+ esempi

### 3. Diversità dei Dati

Copri diverse:
- Formulazioni delle domande
- Argomenti
- Lunghezze delle risposte
- Casi limite

### 4. Suddivisione per la Validazione

```python
# Split your data
from sklearn.model_selection import train_test_split

train_data, val_data = train_test_split(dataset, test_size=0.2, random_state=42)
```

---

## Usare Google Colab (GPU Gratuita)

1. Vai su [Google Colab](https://colab.research.google.com/)
2. Crea un nuovo notebook
3. Abilita la GPU: Runtime → Change runtime type → GPU
4. Carica il tuo dataset
5. Esegui lo script di addestramento
6. Scarica il file GGUF risultante
7. Importa in Ollama

**Template di Notebook Colab**:

```python
# Install dependencies
!pip install "unsloth[colab-new] @ git+https://github.com/unslothai/unsloth.git"

# Upload your dataset
from google.colab import files
uploaded = files.upload()  # Upload techcorp-support.jsonl

# Run training (use the Unsloth script from the Fine-Tuning Guide)
# ...

# Download the result
from google.colab import files
files.download('techcorp-support.gguf')
```

---

## Prossimi Passi

1. **Inizia in piccolo**: Crea 10-20 esempi e usa l'approccio Modelfile
2. **Testa a fondo**: Verifica che le risposte corrispondano alle tue aspettative
3. **Itera**: Aggiungi altri esempi per i casi in cui fallisce
4. **Scala**: Se l'approccio Modelfile non basta, passa al fine-tuning
5. **Monitora**: Tieni traccia di quali domande funzionano bene e quali no

---

## Risorse

- [Guida al Fine-Tuning](./fine-tuning-guide.md) - Approfondimento canonico con gli script di addestramento completi
- [Documentazione di Unsloth](https://github.com/unslothai/unsloth)
- [Guida a Hugging Face PEFT](https://huggingface.co/docs/peft)
- [Riferimento Modelfile di Ollama](./modelfile-reference.md)
