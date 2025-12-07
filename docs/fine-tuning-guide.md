# Fine-Tuning Guide for Ollama

Guide for integrating externally fine-tuned models with Ollama.

## Overview

Ollama itself doesn't provide model fine-tuning capabilities. However, you can fine-tune models using external tools and then import them into Ollama for inference.

## Fine-Tuning Workflow

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

## Step 1: Prepare Training Data

### Data Format

Most fine-tuning tools expect data in JSON or JSONL format:

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

Or for conversational datasets:

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

### Data Quality Tips

1. **Consistency**: Use consistent formatting and style
2. **Diversity**: Include varied examples covering your use cases
3. **Quality over Quantity**: 50 high-quality examples > 500 mediocre ones
4. **Balance**: Maintain balanced representation across categories

### Example Dataset Structure

Save in `./data/training/my-dataset.jsonl`:

```jsonl
{"instruction": "Convert 100°F to Celsius", "output": "100°F is equal to 37.78°C"}
{"instruction": "What is 50 km in miles?", "output": "50 kilometers is approximately 31.07 miles"}
```

## Step 2: Fine-Tuning with External Tools

### Option A: Unsloth (Recommended for LoRA)

**Advantages**: Fast, efficient, supports many models

1. **Setup environment**:
   ```bash
   pip install unsloth
   ```

2. **Create training script** (`train.py`):
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

3. **Run training**:
   ```bash
   python train.py
   ```

### Option B: Hugging Face Transformers

**Advantages**: Industry standard, extensive documentation

1. **Install dependencies**:
   ```bash
   pip install transformers datasets peft accelerate
   ```

2. **Training script example**:
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

### Option C: Google Colab (Free GPU)

For users without local GPU:

1. Open [Google Colab](https://colab.research.google.com/)
2. Enable GPU: Runtime > Change runtime type > GPU
3. Use Unsloth or Transformers as above
4. Download the fine-tuned model/adapter

## Step 3: Export to GGUF Format

### Using llama.cpp

1. **Install llama.cpp**:
   ```bash
   git clone https://github.com/ggerganov/llama.cpp
   cd llama.cpp
   make
   ```

2. **Convert model to GGUF**:
   ```bash
   python convert.py /path/to/your/model \
       --outtype f16 \
       --outfile model.gguf
   ```

3. **Optionally quantize** (reduce size):
   ```bash
   ./quantize model.gguf model-q4_0.gguf q4_0
   ```

### Quantization Options

- **f16**: Full precision (largest, best quality)
- **q8_0**: 8-bit quantization (good balance)
- **q4_0**: 4-bit quantization (smaller, faster)
- **q4_K_M**: 4-bit with quality improvements

## Step 4: Import into Ollama

### Method 1: Import Full GGUF Model

1. **Copy GGUF to data directory**:
   ```bash
   cp model.gguf ./data/gguf/
   ```

2. **Import using script**:
   ```bash
   bash scripts/import-model.sh my-finetuned-model ./data/gguf/model.gguf
   ```

3. **Test the model**:
   ```bash
   docker compose exec ollama ollama run my-finetuned-model "Test prompt"
   ```

### Method 2: Use LoRA Adapter

If you only have a LoRA adapter:

1. **Copy adapter to data directory**:
   ```bash
   cp lora_adapter/* ./data/adapters/my-adapter/
   ```

2. **Create Modelfile**:
   ```dockerfile
   FROM llama3.2:3b
   ADAPTER /data/adapters/my-adapter/adapter_model.bin
   
   PARAMETER temperature 0.7
   PARAMETER num_ctx 4096
   ```

3. **Create model**:
   ```bash
   bash scripts/create-custom-model.sh my-custom-model ./models/custom/my-adapter-model
   ```

## Example: Complete Fine-Tuning Workflow

### 1. Prepare Data

`./data/training/tech-support.jsonl`:
```jsonl
{"instruction": "How do I reset my password?", "output": "To reset your password: 1. Click 'Forgot Password' 2. Enter your email 3. Check your inbox for reset link"}
{"instruction": "My account is locked", "output": "If your account is locked, please contact support@example.com with your username"}
```

### 2. Fine-Tune with Unsloth (Colab)

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

### 3. Convert to GGUF

```bash
# Download from Colab
# Then convert
python llama.cpp/convert.py tech_support_model --outfile tech-support.gguf
./llama.cpp/quantize tech-support.gguf tech-support-q4.gguf q4_0
```

### 4. Import to Ollama

```bash
cp tech-support-q4.gguf ./data/gguf/
bash scripts/import-model.sh tech-support ./data/gguf/tech-support-q4.gguf
```

### 5. Test

```bash
docker compose exec ollama ollama run tech-support "How do I reset my password?"
```

## Best Practices

### Training Data

- **Minimum**: 50-100 high-quality examples
- **Ideal**: 1,000-10,000 examples
- **Format consistency**: Match input/output style to intended use
- **Validation split**: Keep 10-20% for validation

### LoRA Parameters

- **r (rank)**: 8-32 (higher = more capacity, slower)
- **alpha**: Usually 2×r (16-64)
- **dropout**: 0.05-0.1
- **Target modules**: q_proj, v_proj minimum

### Training Hyperparameters

- **Learning rate**: 1e-4 to 5e-4
- **Batch size**: Start small (1-4), increase if possible
- **Epochs**: 3-5 typically sufficient
- **Gradient accumulation**: Use if GPU memory limited

## Troubleshooting

### Out of Memory During Training

- Reduce batch size
- Enable gradient checkpointing
- Use smaller model variant
- Increase gradient accumulation steps

### Model Quality Issues

- Check data quality and consistency
- Increase training examples
- Adjust learning rate
- Train for more epochs
- Try different LoRA ranks

### GGUF Conversion Fails

- Ensure model format is supported
- Check llama.cpp version compatibility
- Verify model files are complete

## Resources

- [Unsloth Documentation](https://github.com/unslothai/unsloth)
- [Hugging Face PEFT](https://huggingface.co/docs/peft)
- [llama.cpp GGUF Guide](https://github.com/ggerganov/llama.cpp)
- [LoRA Paper](https://arxiv.org/abs/2106.09685)
