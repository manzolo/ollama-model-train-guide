# Complete Dataset Training Example

This guide shows you how to train a model with your own dataset and use it in Ollama.

## Example: Training a Customer Support Bot

Let's create a customer support bot for a fictional company "TechCorp" using a custom dataset.

---

## Step 1: Prepare Your Dataset

Create a training dataset in JSONL format with your Q&A pairs.

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

## Step 2: Choose Your Training Method

### Option A: Using Unsloth (Recommended - Fast & Easy)

**Best for**: Quick fine-tuning with LoRA adapters

#### 1. Install Unsloth

```bash
pip install "unsloth[colab-new] @ git+https://github.com/unslothai/unsloth.git"
pip install --no-deps "xformers<0.0.27" "trl<0.9.0" peft accelerate bitsandbytes
```

#### 2. Create Training Script

**File**: `train_techcorp.py`

```python
from unsloth import FastLanguageModel
from datasets import load_dataset
from trl import SFTTrainer
from transformers import TrainingArguments
import torch

# Configuration
max_seq_length = 2048
model_name = "unsloth/llama-3.2-1b-bnb-4bit"

# Load model
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name=model_name,
    max_seq_length=max_seq_length,
    dtype=None,
    load_in_4bit=True,
)

# Add LoRA adapters
model = FastLanguageModel.get_peft_model(
    model,
    r=16,  # LoRA rank
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                    "gate_proj", "up_proj", "down_proj"],
    lora_alpha=16,
    lora_dropout=0,
    bias="none",
    use_gradient_checkpointing="unsloth",
    random_state=3407,
)

# Load your dataset
dataset = load_dataset("json", data_files="data/training/techcorp-support.jsonl", split="train")

# Format function for the dataset
def formatting_prompts_func(examples):
    instructions = examples["instruction"]
    outputs = examples["output"]
    texts = []
    for instruction, output in zip(instructions, outputs):
        text = f"""Below is an instruction that describes a task. Write a response that appropriately completes the request.

### Instruction:
{instruction}

### Response:
{output}"""
        texts.append(text)
    return {"text": texts}

dataset = dataset.map(formatting_prompts_func, batched=True)

# Training arguments
trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=dataset,
    dataset_text_field="text",
    max_seq_length=max_seq_length,
    dataset_num_proc=2,
    packing=False,
    args=TrainingArguments(
        per_device_train_batch_size=2,
        gradient_accumulation_steps=4,
        warmup_steps=5,
        max_steps=60,  # Increase for better results
        learning_rate=2e-4,
        fp16=not torch.cuda.is_bf16_supported(),
        bf16=torch.cuda.is_bf16_supported(),
        logging_steps=1,
        optim="adamw_8bit",
        weight_decay=0.01,
        lr_scheduler_type="linear",
        seed=3407,
        output_dir="outputs",
    ),
)

# Train!
trainer.train()

# Save the model
model.save_pretrained("techcorp-support-lora")
tokenizer.save_pretrained("techcorp-support-lora")

print("✅ Training complete! Model saved to techcorp-support-lora/")
```

#### 3. Run Training

```bash
# If you have a GPU
python train_techcorp.py

# Or use Google Colab (free GPU)
# Upload the script and dataset to Colab and run there
```

#### 4. Export to GGUF

```bash
# Install llama.cpp
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
make

# Convert to GGUF
python convert.py ../techcorp-support-lora --outtype f16 --outfile ../techcorp-support.gguf

# Quantize (optional, makes it smaller)
./quantize ../techcorp-support.gguf ../techcorp-support-q4.gguf q4_0
```

---

### Option B: Using Hugging Face Transformers

**Best for**: More control over training process

#### Training Script

**File**: `train_hf.py`

```python
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    TrainingArguments,
    Trainer,
    DataCollatorForLanguageModeling
)
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
from datasets import load_dataset
import torch

# Load model and tokenizer
model_name = "meta-llama/Llama-2-7b-hf"  # or any compatible model
tokenizer = AutoTokenizer.from_pretrained(model_name)
tokenizer.pad_token = tokenizer.eos_token

model = AutoModelForCausalLM.from_pretrained(
    model_name,
    load_in_8bit=True,
    device_map="auto",
    torch_dtype=torch.float16
)

# Prepare for training
model = prepare_model_for_kbit_training(model)

# LoRA configuration
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
dataset = load_dataset("json", data_files="data/training/techcorp-support.jsonl", split="train")

def tokenize_function(examples):
    prompts = [f"Question: {inst}\nAnswer: {out}" 
               for inst, out in zip(examples["instruction"], examples["output"])]
    return tokenizer(prompts, truncation=True, max_length=512)

tokenized_dataset = dataset.map(tokenize_function, batched=True, remove_columns=dataset.column_names)

# Training
training_args = TrainingArguments(
    output_dir="./results",
    num_train_epochs=3,
    per_device_train_batch_size=4,
    save_steps=100,
    save_total_limit=2,
    learning_rate=2e-4,
    logging_steps=10,
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_dataset,
    data_collator=DataCollatorForLanguageModeling(tokenizer, mlm=False),
)

trainer.train()
model.save_pretrained("./techcorp-model")
```

---

## Step 3: Import into Ollama

Once you have your GGUF file:

```bash
# Copy to data directory
cp techcorp-support-q4.gguf ./data/gguf/

# Import using the script
bash scripts/import-model.sh techcorp-support ./data/gguf/techcorp-support-q4.gguf
```

---

## Step 4: Test Your Model

```bash
# Interactive test
docker compose exec ollama ollama run techcorp-support

# Try these questions:
# - "How do I reset my password?"
# - "What are your business hours?"
# - "Where are you located?"
```

---

## Alternative: Quick Method with Few-Shot Learning

If you don't want to do full fine-tuning, you can use the MESSAGE approach in a Modelfile:

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

Create the model:

```bash
bash scripts/create-custom-model.sh techcorp-support ./models/custom/techcorp-support/Modelfile
```

---

## Comparison: Fine-Tuning vs Few-Shot

| Aspect | Fine-Tuning | Few-Shot (Modelfile) |
|--------|-------------|---------------------|
| **Setup Time** | Hours to days | Minutes |
| **Hardware** | GPU required | None |
| **Dataset Size** | 100+ examples | 5-20 examples |
| **Quality** | Better for complex tasks | Good for simple Q&A |
| **Cost** | GPU costs | Free |
| **Flexibility** | Can learn new patterns | Limited to examples |

**Recommendation**: 
- **Start with Few-Shot** (Modelfile approach) for quick prototyping
- **Move to Fine-Tuning** if you need better quality or have 100+ examples

---

## Best Practices

### 1. Dataset Quality

```jsonl
# ❌ Bad - Too vague
{"instruction": "help", "output": "what do you need"}

# ✅ Good - Specific and detailed
{"instruction": "How do I reset my password?", "output": "To reset your password: 1. Go to login page 2. Click 'Forgot Password' 3. Enter your email 4. Check your inbox for the reset link 5. Follow the link and create a new password"}
```

### 2. Dataset Size

- **Minimum**: 50 examples
- **Good**: 100-500 examples
- **Ideal**: 1,000+ examples

### 3. Data Diversity

Cover different:
- Question phrasings
- Topics
- Response lengths
- Edge cases

### 4. Validation Split

```python
# Split your data
from sklearn.model_selection import train_test_split

train_data, val_data = train_test_split(dataset, test_size=0.2, random_state=42)
```

---

## Using Google Colab (Free GPU)

1. Go to [Google Colab](https://colab.research.google.com/)
2. Create new notebook
3. Enable GPU: Runtime → Change runtime type → GPU
4. Upload your dataset
5. Run the training script
6. Download the resulting GGUF file
7. Import into Ollama

**Colab Notebook Template**:

```python
# Install dependencies
!pip install "unsloth[colab-new] @ git+https://github.com/unslothai/unsloth.git"

# Upload your dataset
from google.colab import files
uploaded = files.upload()  # Upload techcorp-support.jsonl

# Run training (use the script from Option A above)
# ...

# Download the result
from google.colab import files
files.download('techcorp-support.gguf')
```

---

## Next Steps

1. **Start small**: Create 10-20 examples and use the Modelfile approach
2. **Test thoroughly**: Verify responses match your expectations
3. **Iterate**: Add more examples for cases where it fails
4. **Scale up**: If Modelfile approach isn't enough, move to fine-tuning
5. **Monitor**: Track which questions work well and which don't

---

## Resources

- [Unsloth Documentation](https://github.com/unslothai/unsloth)
- [Hugging Face PEFT Guide](https://huggingface.co/docs/peft)
- [Dataset Preparation Guide](../docs/fine-tuning-guide.md)
- [Ollama Modelfile Reference](../docs/modelfile-reference.md)
