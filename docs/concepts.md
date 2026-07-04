# Essential Concepts - Quick Reference

**New to Ollama and language models?** This page explains everything you need to know in simple terms.

---

## 🎯 The Basics (Start Here)

### What is Ollama?
A tool that lets you run AI language models (like ChatGPT) **locally on your computer**. No internet required, no API costs, complete privacy.

### What is a Model?
Think of it as a "brain" that can understand and generate text. Different models have different capabilities:
- **Small models** (1B-3B): Fast, use less memory, good for simple tasks
- **Medium models** (7B-13B): Balanced quality and speed
- **Large models** (30B+): Best quality, but slow and memory-hungry

**The "B" stands for "billions of parameters"** - more parameters = smarter but slower.

### What is a Modelfile?
Like a recipe card for creating a custom model. It defines:
- Which base model to use
- How the model should behave (personality, rules)
- Settings that control output quality

**Think of it like Dockerfile** - text file with instructions.

---

## 🔧 Core Concepts

### Base Model
A pre-trained model from the Ollama library (e.g., `llama3.2:1b`, `mistral:7b`).

**You build custom models ON TOP of base models** - you don't train from scratch.

**Where do they come from?**
- Download from [Ollama Library](https://ollama.com/library)
- Use `make pull-base` to get common ones
- Or pull via Web UI

### Choosing a Base Model (2026)

This project deliberately targets **lightweight models** — everything in the guides and examples uses `llama3.2:1b`, which remains a great, fast default for learning and prototyping. The model landscape keeps evolving, though, and these modern lightweight alternatives are worth trying with a simple `ollama pull`:

| Model | Approx. size | Approx. RAM needed | Notes |
|-------|-------------|--------------------|-------|
| `llama3.2:1b` | ~1.3 GB | ~4 GB | Project default; fast, well documented |
| `qwen3:0.6b` | ~0.5 GB | ~2 GB | Tiny but surprisingly strong; optional thinking mode |
| `qwen3:1.7b` | ~1.4 GB | ~4 GB | Small and strong; optional thinking mode |
| `gemma3:1b` | ~815 MB | ~4 GB | Compact Google model |
| `gemma3:4b` | ~3.3 GB | ~8 GB | Multimodal (images), 128K context |
| `phi4-mini` | ~2.5 GB | ~8 GB | Compact and efficient Microsoft model |
| `llama3.2:3b` | ~2 GB | ~8 GB | Balanced quality and speed |
| `mistral:7b` | ~4.1 GB | ~8-16 GB | Higher quality, slower |

**Heavier options for capable machines:**

| Model | Approx. size | Approx. RAM needed | Notes |
|-------|-------------|--------------------|-------|
| `qwen3:8b` | ~5 GB | ~16 GB | Strong general-purpose model |
| `gpt-oss:20b` | ~13 GB | ~16 GB | OpenAI's open-weight model |

RAM figures are rough guidelines for CPU inference; a GPU with enough VRAM makes everything much faster. Any of these can replace `llama3.2:1b` in the `FROM` line of a Modelfile.

### What's New in Ollama (2026)

This guide focuses on **running models locally** — that is all you need for everything covered here. But Ollama itself has grown, and these features exist if you outgrow local:

- **Cloud models**: Offload big models to Ollama's cloud while keeping the exact same API and CLI — useful when a model doesn't fit your hardware.
- **`ollama launch`**: Bootstraps coding tools/agents preconfigured to use your local models.
- **Web search API**: Lets models augment answers with web results.
- **Improved scheduling**: Better multi-GPU support and memory management for larger setups.

### System Prompt
Instructions that define your model's behavior and personality.

**Example:**
```
SYSTEM """
You are a helpful customer support agent for ACME Corp.
Be friendly, professional, and concise.
Always ask clarifying questions if unsure.
"""
```

**This is the easiest way to customize a model!**

### Parameters
Settings that control how the model generates text.

**The 3 most important:**
- **temperature** (0.0-2.0): Creativity dial
  - `0.3` = Predictable, factual (for code, support)
  - `0.7` = Balanced (for chat)
  - `1.2` = Creative, varied (for stories)

- **num_ctx** (tokens): How much conversation history the model remembers
  - `2048` = Short conversations
  - `4096` = Standard (recommended)
  - `8192` = Long, complex discussions

- **top_p** (0.0-1.0): Output variety control
  - `0.9` = Good default for most uses

**Don't worry about the other parameters yet** - these defaults work great:
```
PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
```

---

## 🎓 Customization Methods

### Method 1: System Prompt Only (Easiest)
**When to use:** You want to change personality or add rules

**Example:** Make a customer support bot, translator, or code assistant

**How:** Edit the `SYSTEM` section in a Modelfile

**Time required:** 5 minutes

---

### Method 2: Few-Shot Learning with MESSAGE Examples
**When to use:** You have 5-50 example Q&A pairs

**Example:** Train a support bot with common customer questions

**How:** Add `MESSAGE` blocks to your Modelfile
```
MESSAGE user "What are your hours?"
MESSAGE assistant "We're open Mon-Fri, 9am-6pm EST."
```

**Time required:** 15-30 minutes

---

### Method 3: Fine-Tuning (Advanced)
**When to use:** You have 100+ examples and need deep specialization

**Example:** Medical diagnosis bot, legal document analyzer

**How:** Train with external tools (Unsloth, Hugging Face), export to GGUF, import to Ollama — see the [Fine-Tuning Guide](./fine-tuning-guide.md)

**Time required:** Hours to days (requires GPU)

**⚠️ Most users don't need this!** Try Method 1 or 2 first.

---

## Decision Tree: Which Method Should I Use?

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

## 🗂️ File Formats Explained

### GGUF Files
Compressed model files that work with Ollama.

**When you'll see them:**
- Downloading models from Hugging Face
- Importing externally trained models
- Using custom fine-tuned models

**What to do:** Place in `./data/gguf/` and use `bash scripts/import-model.sh`

### JSONL Files
Training data format - one JSON object per line.

**Example:**
```json
{"role": "user", "content": "What is your return policy?"}
{"role": "assistant", "content": "We offer 30-day returns with receipt."}
```

**When you'll use:** Preparing training datasets

**Tool available:** Spreadsheet to JSONL converter in Web UI

### Modelfile
Text file with instructions for creating a model (like Dockerfile).

**Structure:**
```
FROM llama3.2:1b
PARAMETER temperature 0.7
SYSTEM """Your instructions here"""
MESSAGE user "example question"
MESSAGE assistant "example answer"
```

---

## 🔌 Ports and Services

After running `make up`, you get:

- **Port 11434**: Ollama API (for programmatic access)
- **Port 8080**: Web UI — chat (`/`), spreadsheet converter (`/converter`), and Modelfile wizard (`/wizard`)

Both host ports are configurable via `OLLAMA_PORT` and `CHAT_PORT` in `.env` (then `make down && make up`).

**Just open http://localhost:8080** - that's all you need!

---

## 🐳 Docker Concepts (Quick Primer)

### Container
A lightweight virtual machine running Ollama. **Your models live inside this container.**

### Volume
Persistent storage. **`ollama_data` volume** stores your models even when container stops.

**Important:**
- `make down` = Stop container (models are safe ✅)
- `make clean` = Delete container AND volume (models are deleted ❌)

### Bind Mount
Link between your computer and the container.

**Why it matters:**
- `./models/` on your computer → `/models/` in container
- `./data/` on your computer → `/data/` in container

**This is how you add files to Ollama!**

---

## 🚀 Advanced Concepts (You Can Skip These Initially)

### LoRA Adapters
Small files that modify base model behavior without full retraining.

**When you'll need:** Fine-tuning with limited resources

**How to use:** Reference in Modelfile with `ADAPTER /data/adapters/my-adapter.bin`

### Quantization
Reducing model precision to save memory (8-bit, 4-bit).

**When you'll need:** Running large models on limited RAM

**Ollama does this automatically** - you don't need to worry about it.

### Context Window
How many tokens (words/parts of words) the model can process at once.

**Controlled by:** `num_ctx` parameter

**Default:** 2048 tokens (~1500 words)

### Token
Atomic unit of text (not always a full word).

**Example:** "Hello world" = 2 tokens, "Anthropic" = 1 token, "ChatGPT" = 2 tokens

**Why it matters:** Model pricing, context limits, response length

### Template
Advanced prompt formatting using Go template syntax.

**When you'll need:** Custom chat formats for specific models

**⚠️ Skip unless you have specific requirements**

---

## 📖 Quick Glossary

| Term | Simple Definition |
|------|-------------------|
| **Inference** | Running a model to generate text |
| **Prompt** | The input text you give to the model |
| **System Prompt** | Instructions that define model behavior |
| **Temperature** | Creativity setting (0=boring, 2=chaotic) |
| **Context** | How much history the model remembers |
| **Base Model** | Pre-trained model from Ollama library |
| **Custom Model** | Your modified version of a base model |
| **Modelfile** | Recipe for creating a custom model |
| **GGUF** | Model file format for Ollama |
| **LoRA** | Efficient fine-tuning method |
| **Few-Shot** | Learning from a few examples |
| **Fine-Tuning** | Training model on custom dataset |
| **Quantization** | Compressing model to use less memory |

---

## 🎯 What You Actually Need to Know (TL;DR)

**To get started (5 minutes):**
1. What is Ollama (runs AI models locally)
2. How to pull a base model
3. How to chat via Web UI

**To create custom models (15 minutes):**
1. What is a Modelfile
2. How to write a system prompt
3. Temperature parameter (0.3 = factual, 0.7 = balanced, 1.2 = creative)

**To train with your data (30 minutes):**
1. What is few-shot learning
2. How to add MESSAGE examples
3. JSONL format basics

**Everything else can wait!** Start simple and learn as you go.

---

## 🔗 Next Steps

- **Beginner?** Start with [Chat UI Guide](./chat-ui.md) - use pre-made models
- **Ready to customize?** See [Example Modelfiles](./examples.md) - copy and modify
- **Have training data?** Read [Dataset Training Example](./dataset-training-example.md)
- **Need reference?** Check [Modelfile Reference](./modelfile-reference.md) - complete syntax

---

**Still confused?** That's normal! Start with the Web UI, play with pre-made models, and concepts will click into place. 🎉
