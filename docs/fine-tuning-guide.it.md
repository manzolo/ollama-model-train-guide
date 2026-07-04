# Guida al Fine-Tuning per Ollama

Guida all'integrazione con Ollama di modelli sottoposti a fine-tuning esternamente. **Questo è il riferimento canonico sul fine-tuning** per il progetto — altri documenti ([Guida alla Personalizzazione](./customization-guide.md), [Esempio di Addestramento con Dataset](./dataset-training-example.md), [Utilizzo Avanzato](./advanced-usage.md)) rimandano qui per il workflow completo.

## Panoramica

Ollama di per sé non offre funzionalità di fine-tuning dei modelli. Tuttavia, puoi eseguire il fine-tuning dei modelli utilizzando strumenti esterni e poi importarli in Ollama per l'inferenza.

**Prima del fine-tuning**: la maggior parte dei casi d'uso si risolve più rapidamente con un system prompt o con esempi MESSAGE few-shot — vedi la [Guida alla Personalizzazione](./customization-guide.md). Per un esempio concreto e completo di questo intero workflow (dataset → addestramento → GGUF → Ollama), vedi l'[Esempio di Addestramento con Dataset](./dataset-training-example.md).

## Workflow del Fine-Tuning

```
┌─────────────────┐
│ Choose Base     │
│ Model           │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Prepare         │
│ Training Data   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Fine-Tune with  │
│ External Tools  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Export to GGUF  │
│ or LoRA Adapter │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Import into     │
│ Ollama          │
└─────────────────┘
```

## Passo 1: Prepara i Dati di Addestramento

### Formato dei Dati

La maggior parte degli strumenti di fine-tuning si aspetta dati in formato JSON o JSONL:

```json
[
  {
    "instruction": "What is the capital of France?",
    "output": "The capital of France is Paris."
  },
  {
    "instruction": "Explain photosynthesis",
    "output": "Photosynthesis is the process by which plants..."
  }
]
```

Oppure, per dataset conversazionali:

```json
[
  {
    "messages": [
      {"role": "user", "content": "Hello!"},
      {"role": "assistant", "content": "Hi! How can I help you?"}
    ]
  }
]
```

### Consigli sulla Qualità dei Dati

1. **Coerenza**: Usa formattazione e stile coerenti
2. **Diversità**: Includi esempi variegati che coprano i tuoi casi d'uso
3. **Qualità più che Quantità**: 50 esempi di alta qualità > 500 mediocri
4. **Bilanciamento**: Mantieni una rappresentazione bilanciata tra le categorie

### Esempio di Struttura del Dataset

Salva in `./data/training/my-dataset.jsonl`:

```jsonl
{"instruction": "Convert 100°F to Celsius", "output": "100°F is equal to 37.78°C"}
{"instruction": "What is 50 km in miles?", "output": "50 kilometers is approximately 31.07 miles"}
```

## Passo 2: Fine-Tuning con Strumenti Esterni

### Opzione A: Unsloth (Consigliato per LoRA)

**Vantaggi**: Veloce, efficiente, supporta molti modelli

1. **Prepara l'ambiente**:
   ```bash
   pip install unsloth
   ```

2. **Crea lo script di addestramento** (`train.py`):
   ```python
   from unsloth import FastLanguageModel
   import torch
   
   # Load model
   model, tokenizer = FastLanguageModel.from_pretrained(
       model_name="unsloth/llama-3-8b-bnb-4bit",
       max_seq_length=2048,
       dtype=None,
       load_in_4bit=True,
   )
   
   # Add LoRA adapters
   model = FastLanguageModel.get_peft_model(
       model,
       r=16,
       target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
       lora_alpha=16,
       lora_dropout=0,
       bias="none",
   )
   
   # Load dataset
   from datasets import load_dataset
   dataset = load_dataset("json", data_files="data.jsonl")
   
   # Train
   from transformers import TrainingArguments
   from trl import SFTTrainer
   
   trainer = SFTTrainer(
       model=model,
       train_dataset=dataset["train"],
       args=TrainingArguments(
           per_device_train_batch_size=2,
           gradient_accumulation_steps=4,
           warmup_steps=10,
           max_steps=100,
           learning_rate=2e-4,
           fp16=not torch.cuda.is_bf16_supported(),
           bf16=torch.cuda.is_bf16_supported(),
           logging_steps=1,
           output_dir="outputs",
       ),
   )
   
   trainer.train()
   
   # Save LoRA adapter
   model.save_pretrained("lora_adapter")
   ```

3. **Avvia l'addestramento**:
   ```bash
   python train.py
   ```

### Opzione B: Hugging Face Transformers

**Vantaggi**: Standard di settore, documentazione estesa

1. **Installa le dipendenze**:
   ```bash
   pip install transformers datasets peft accelerate
   ```

2. **Esempio di script di addestramento**:
   ```python
   from transformers import (
       AutoModelForCausalLM,
       AutoTokenizer,
       TrainingArguments,
       Trainer,
   )
   from peft import LoraConfig, get_peft_model
   from datasets import load_dataset
   
   # Load model and tokenizer
   model_name = "meta-llama/Llama-2-7b-hf"
   model = AutoModelForCausalLM.from_pretrained(model_name)
   tokenizer = AutoTokenizer.from_pretrained(model_name)
   
   # Configure LoRA
   lora_config = LoraConfig(
       r=8,
       lora_alpha=32,
       target_modules=["q_proj", "v_proj"],
       lora_dropout=0.05,
       bias="none",
       task_type="CAUSAL_LM"
   )
   
   model = get_peft_model(model, lora_config)
   
   # Load and prepare dataset
   dataset = load_dataset("json", data_files="data.jsonl")
   
   # Train
   training_args = TrainingArguments(
       output_dir="./results",
       num_train_epochs=3,
       per_device_train_batch_size=4,
       save_steps=100,
       save_total_limit=2,
   )
   
   trainer = Trainer(
       model=model,
       args=training_args,
       train_dataset=dataset["train"],
   )
   
   trainer.train()
   model.save_pretrained("./finetuned_model")
   ```

### Opzione C: Google Colab (GPU Gratuita)

Per gli utenti senza GPU locale:

1. Apri [Google Colab](https://colab.research.google.com/)
2. Abilita la GPU: Runtime > Change runtime type > GPU
3. Usa Unsloth o Transformers come sopra
4. Scarica il modello/adattatore sottoposto a fine-tuning

## Passo 3: Esporta in Formato GGUF

### Usare llama.cpp

1. **Installa llama.cpp**:
   ```bash
   git clone https://github.com/ggerganov/llama.cpp
   cd llama.cpp
   make
   ```

2. **Converti il modello in GGUF**:
   ```bash
   python convert.py /path/to/your/model \
       --outtype f16 \
       --outfile model.gguf
   ```

3. **Opzionalmente quantizza** (riduci la dimensione):
   ```bash
   ./quantize model.gguf model-q4_0.gguf q4_0
   ```

### Opzioni di Quantizzazione

- **f16**: Precisione piena (più grande, qualità migliore)
- **q8_0**: Quantizzazione a 8 bit (buon equilibrio)
- **q4_0**: Quantizzazione a 4 bit (più piccolo, più veloce)
- **q4_K_M**: 4 bit con miglioramenti di qualità

## Passo 4: Importa in Ollama

### Metodo 1: Importa il Modello GGUF Completo

1. **Copia il GGUF nella directory data**:
   ```bash
   cp model.gguf ./data/gguf/
   ```

2. **Importa usando lo script**:
   ```bash
   bash scripts/import-model.sh my-finetuned-model ./data/gguf/model.gguf
   ```

3. **Testa il modello**:
   ```bash
   docker compose exec ollama ollama run my-finetuned-model "Test prompt"
   ```

### Metodo 2: Usa un Adattatore LoRA

Se disponi solo di un adattatore LoRA:

1. **Copia l'adattatore nella directory data**:
   ```bash
   cp lora_adapter/* ./data/adapters/my-adapter/
   ```

2. **Crea il Modelfile**:
   ```dockerfile
   FROM llama3.2:3b
   ADAPTER /data/adapters/my-adapter/adapter_model.bin
   
   PARAMETER temperature 0.7
   PARAMETER num_ctx 4096
   ```

3. **Crea il modello**:
   ```bash
   bash scripts/create-custom-model.sh my-custom-model ./models/custom/my-adapter-model
   ```

## Esempio: Workflow Completo di Fine-Tuning

### 1. Prepara i Dati

`./data/training/tech-support.jsonl`:
```jsonl
{"instruction": "How do I reset my password?", "output": "To reset your password: 1. Click 'Forgot Password' 2. Enter your email 3. Check your inbox for reset link"}
{"instruction": "My account is locked", "output": "If your account is locked, please contact support@example.com with your username"}
```

### 2. Fine-Tuning con Unsloth (Colab)

```python
# In Google Colab
!pip install unsloth

from unsloth import FastLanguageModel
from datasets import load_dataset

# Load model
model, tokenizer = FastLanguageModel.from_pretrained(
    "unsloth/llama-3-8b-bnb-4bit",
    max_seq_length=2048,
    load_in_4bit=True,
)

# Add LoRA
model = FastLanguageModel.get_peft_model(model, r=16)

# Load data
dataset = load_dataset("json", data_files="tech-support.jsonl")

# Train
from trl import SFTTrainer
from transformers import TrainingArguments

trainer = SFTTrainer(
    model=model,
    train_dataset=dataset["train"],
    max_seq_length=2048,
)

trainer.train()

# Save
model.save_pretrained_merged("tech_support_model", tokenizer)
```

### 3. Converti in GGUF

```bash
# Download from Colab
# Then convert
python llama.cpp/convert.py tech_support_model --outfile tech-support.gguf
./llama.cpp/quantize tech-support.gguf tech-support-q4.gguf q4_0
```

### 4. Importa in Ollama

```bash
cp tech-support-q4.gguf ./data/gguf/
bash scripts/import-model.sh tech-support ./data/gguf/tech-support-q4.gguf
```

### 5. Testa

```bash
docker compose exec ollama ollama run tech-support "How do I reset my password?"
```

## Best Practice

### Dati di Addestramento

- **Minimo**: 50-100 esempi di alta qualità
- **Ideale**: 1.000-10.000 esempi
- **Coerenza del formato**: Fai corrispondere lo stile input/output all'uso previsto
- **Suddivisione per la validazione**: Tieni da parte il 10-20% per la validazione

### Parametri LoRA

- **r (rank)**: 8-32 (più alto = più capacità, più lento)
- **alpha**: Solitamente 2×r (16-64)
- **dropout**: 0.05-0.1
- **Target modules**: q_proj, v_proj come minimo

### Iperparametri di Addestramento

- **Learning rate**: da 1e-4 a 5e-4
- **Batch size**: Inizia in piccolo (1-4), aumenta se possibile
- **Epoche**: 3-5 solitamente sufficienti
- **Gradient accumulation**: Usalo se la memoria della GPU è limitata

## Risoluzione dei Problemi

### Out of Memory Durante l'Addestramento

- Riduci il batch size
- Abilita il gradient checkpointing
- Usa una variante di modello più piccola
- Aumenta gli step di gradient accumulation

### Problemi di Qualità del Modello

- Controlla la qualità e la coerenza dei dati
- Aumenta gli esempi di addestramento
- Regola il learning rate
- Addestra per più epoche
- Prova diversi rank LoRA

### La Conversione in GGUF Fallisce

- Assicurati che il formato del modello sia supportato
- Verifica la compatibilità della versione di llama.cpp
- Verifica che i file del modello siano completi

## Risorse

- [Documentazione di Unsloth](https://github.com/unslothai/unsloth)
- [Hugging Face PEFT](https://huggingface.co/docs/peft)
- [Guida GGUF di llama.cpp](https://github.com/ggerganov/llama.cpp)
- [Paper su LoRA](https://arxiv.org/abs/2106.09685)
