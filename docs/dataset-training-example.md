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

## Step 2: Fine-Tune the Model (External Tools)

Ollama doesn't train models itself — you fine-tune with external tools, export to GGUF, and import the result. The two recommended options are:

- **Unsloth** (fast and easy, LoRA-based) — works well on a single GPU or Google Colab's free GPU tier
- **Hugging Face Transformers + PEFT** — industry standard, more control over the training loop

In short, with Unsloth you load a 4-bit base model (e.g. `unsloth/llama-3.2-1b-bnb-4bit`), attach LoRA adapters, format the `techcorp-support.jsonl` examples into instruction/response prompts, train for a small number of steps, then convert the merged model to GGUF with llama.cpp:

```bash
python llama.cpp/convert.py techcorp-support-lora --outtype f16 --outfile techcorp-support.gguf
./llama.cpp/quantize techcorp-support.gguf techcorp-support-q4.gguf q4_0
```

**📖 The complete training scripts (Unsloth and Hugging Face), LoRA hyperparameters, quantization options, and troubleshooting live in the [Fine-Tuning Guide](./fine-tuning-guide.md)** — the canonical deep-dive for this workflow.

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

# Run training (use the Unsloth script from the Fine-Tuning Guide)
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

- [Fine-Tuning Guide](./fine-tuning-guide.md) - Canonical deep-dive with full training scripts
- [Unsloth Documentation](https://github.com/unslothai/unsloth)
- [Hugging Face PEFT Guide](https://huggingface.co/docs/peft)
- [Ollama Modelfile Reference](./modelfile-reference.md)
