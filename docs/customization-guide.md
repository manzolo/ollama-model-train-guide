# Model Customization Guide - Which Method Should I Use?

**Confused about how to customize your model?** This guide helps you choose the right approach.

---

## 🎯 Quick Decision Tree

```
START: What do you want to do?

┌─ Change personality or behavior
│  └─→ METHOD 1: System Prompt ✅ (5 minutes)
│
├─ Add specific knowledge or examples
│  │
│  ├─ I have < 50 examples
│  │  └─→ METHOD 2: Few-Shot Learning ✅ (30 minutes)
│  │
│  └─ I have 100+ examples and need deep specialization
│     └─→ METHOD 3: Fine-Tuning ⚠️ (hours/days, requires GPU)
│
└─ Just want to chat with existing models
   └─→ NO CUSTOMIZATION NEEDED ✅ (Use web UI)
```

---

## 📊 Comparison Table

| Method | Time | Difficulty | When to Use | Cost |
|--------|------|------------|-------------|------|
| **System Prompt** | 5 min | ⭐ Easy | Change behavior, add rules | Free |
| **Few-Shot** | 30 min | ⭐⭐ Medium | Add 5-50 examples | Free |
| **Fine-Tuning** | Hours+ | ⭐⭐⭐⭐ Hard | 100+ examples, deep specialization | GPU time |

**90% of users only need Methods 1 or 2!**

---

## 🔧 Method 1: System Prompt (Easiest)

### When to Use
- Change model personality (formal, casual, technical, etc.)
- Add specific rules or constraints
- Define role (customer support, tutor, assistant)
- Set output format (JSON, markdown, etc.)

### What You Need
- No training data required
- Just clear instructions

### Time Required
- 5-15 minutes

### Example Use Cases
✅ Make a chatbot more professional
✅ Create a code assistant that explains step-by-step
✅ Build a translator with specific style
✅ Design a creative writer that uses certain themes

### How to Do It

**Step 1:** Create a Modelfile
```bash
mkdir -p ./models/custom/my-assistant
nano ./models/custom/my-assistant/Modelfile
```

**Step 2:** Define behavior with SYSTEM prompt
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

**Step 3:** Create the model
```bash
bash scripts/create-custom-model.sh my-assistant ./models/custom/my-assistant/Modelfile
```

**Step 4:** Test it
```bash
make chat
# Select "my-assistant" and start chatting
```

### Pros
✅ Fastest method
✅ No training data needed
✅ Easy to iterate and improve
✅ Works immediately

### Cons
❌ Limited knowledge beyond base model
❌ Can't add complex specialized knowledge
❌ May not follow instructions perfectly every time

---

## 📚 Method 2: Few-Shot Learning (Recommended)

### When to Use
- You have 5-50 example interactions
- Want model to respond in a specific way
- Need consistent tone/format
- Teaching specific domain knowledge

### What You Need
- Question/answer pairs
- Examples of ideal responses
- JSONL file (optional, can use converter)

### Time Required
- 30 minutes to 2 hours

### Example Use Cases
✅ Customer support with FAQs
✅ Product documentation Q&A
✅ Style-specific content generation
✅ Domain-specific terminology

### How to Do It

**Step 1:** Prepare your examples

Option A: Manual (for small datasets)
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

Option B: Using a JSONL file
```bash
# Use the Web UI converter
# 1. Go to http://localhost:8080/converter
# 2. Upload your Excel/CSV with questions and answers
# 3. Download the JSONL file
# 4. Save to ./data/training/my-data.jsonl
```

Then reference in Modelfile:
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

**Step 2:** Create the model
```bash
bash scripts/create-custom-model.sh support-bot ./models/custom/support-bot/Modelfile
```

**Step 3:** Test with real questions
```bash
docker compose exec ollama ollama run support-bot "How can I track my order?"
```

### Pros
✅ More consistent than System Prompt alone
✅ Teaches specific knowledge
✅ Still fast and easy
✅ No GPU required

### Cons
❌ Limited to ~50 examples (Modelfile size)
❌ Doesn't deeply "learn" patterns
❌ May not generalize well beyond examples

### Tips
- Start with 5-10 examples, test, then add more
- Include edge cases and common variations
- Make examples diverse (different question styles)
- Test after adding each batch

---

## 🚀 Method 3: Fine-Tuning (Advanced)

### When to Use
- You have 100+ training examples
- Need deep domain specialization (medical, legal, technical)
- Want model to learn complex patterns
- Require consistent structured outputs

### What You Need
- Large dataset (100-10,000+ examples)
- GPU access (local or cloud)
- Technical skills (Python, ML frameworks)
- Time for training and evaluation

### Time Required
- Setup: 1-2 hours
- Training: 30 minutes to 8+ hours (depends on size)
- Evaluation: 1-2 hours

### Example Use Cases
✅ Medical diagnosis assistant
✅ Legal document analyzer
✅ Code generation for specific framework
✅ Technical troubleshooting expert

### High-Level Process

**Step 1:** Prepare dataset
```bash
# Create JSONL with many examples
# Format:
# {"messages": [{"role": "user", "content": "..."}, {"role": "assistant", "content": "..."}]}
```

**Step 2:** Choose training platform
- **Unsloth** (easiest, recommended) - [See guide](./dataset-training-example.md)
- **Hugging Face Transformers**
- **Google Colab** (free GPU)

**Step 3:** Train the model
```python
# Use Unsloth or similar library
# Train with LoRA/QLoRA for efficiency
# See docs/dataset-training-example.md for complete guide
```

**Step 4:** Export to GGUF
```bash
# Convert trained model to GGUF format
# Place in ./data/gguf/my-model.gguf
```

**Step 5:** Import to Ollama
```bash
bash scripts/import-model.sh my-finetuned ./data/gguf/my-model.gguf
```

### Pros
✅ Deep learning of patterns
✅ Can handle complex domain knowledge
✅ Better generalization
✅ Consistent structured outputs

### Cons
❌ Time-consuming
❌ Requires GPU
❌ Technical complexity
❌ Risk of overfitting
❌ Expensive (GPU time/cloud costs)

### Important Notes
⚠️ **Try Method 2 first!** Few-shot learning often works surprisingly well.
⚠️ **More data ≠ better** - Quality matters more than quantity.
⚠️ **Start small** - Fine-tune on 100 examples, evaluate, then scale up.

---

## 🎓 Progressive Learning Path

### Week 1: Start Simple
1. Use existing models from Ollama library
2. Test with Web UI
3. Understand basic prompting

### Week 2: System Prompts
1. Create first custom Modelfile
2. Experiment with SYSTEM prompts
3. Adjust parameters (temperature, etc.)

### Week 3: Few-Shot Learning
1. Collect 10-20 example Q&As
2. Add MESSAGE blocks to Modelfile
3. Test and refine

### Week 4+: Advanced (Optional)
1. Consider fine-tuning for specialized needs
2. Explore LoRA adapters
3. Deploy to production

---

## 📖 Real-World Examples

### Example 1: Personal Assistant (System Prompt)
**Goal:** Friendly helper that keeps responses concise

**Method:** System Prompt
**Time:** 5 minutes

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

### Example 2: FAQ Bot (Few-Shot)
**Goal:** Answer common questions about a product

**Method:** Few-Shot Learning
**Time:** 30 minutes
**Data:** 20 Q&A pairs from support tickets

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

### Example 3: Medical Coding Assistant (Fine-Tuning)
**Goal:** Convert medical notes to billing codes

**Method:** Fine-Tuning
**Time:** 8 hours
**Data:** 5,000 labeled examples

**Reason for fine-tuning:**
- Requires learning complex ICD-10 code patterns
- Needs high accuracy (billing consequences)
- Large labeled dataset available
- Structured output format

---

## 🤔 Still Not Sure?

### Ask Yourself:

**Q: Do I just want to change how it talks?**
→ Use **System Prompt**

**Q: Do I have specific examples of ideal responses?**
→ Use **Few-Shot Learning** (if < 50 examples)
→ Use **Fine-Tuning** (if 100+ examples)

**Q: Is it mission-critical with regulatory requirements?**
→ Consider **Fine-Tuning** (after thorough testing)

**Q: Am I on a tight deadline?**
→ Use **System Prompt** or **Few-Shot Learning**

**Q: Do I have a GPU and ML expertise?**
→ Consider **Fine-Tuning** (but try simpler methods first!)

---

## 🚦 Traffic Light Guide

| 🟢 Start Here | 🟡 Next Step | 🔴 Advanced |
|---------------|--------------|-------------|
| System Prompt | Few-Shot Learning | Fine-Tuning |
| 5 minutes | 30 minutes | Hours/Days |
| No data needed | 5-50 examples | 100+ examples |
| Easy iteration | Medium complexity | High complexity |
| **Use for 80% of cases** | **Use for 15% of cases** | **Use for 5% of cases** |

---

## 📚 Additional Resources

- [Essential Concepts](./concepts.md) - Learn the basics
- [Parameter Guide](./parameter-guide.md) - Optimize your settings
- [Example Modelfiles](./examples.md) - Ready-to-use templates
- [Dataset Training Example](./dataset-training-example.md) - Complete fine-tuning guide

---

**Remember: Start simple, test, iterate!** Most users achieve their goals with just a well-crafted system prompt. Don't overcomplicate! 🎯
