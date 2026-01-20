# Parameter Guide - Quick Defaults

**Don't overthink parameters!** Use these proven defaults and adjust only if needed.

---

## 🎯 The 3 Parameters You Actually Need

### 1. Temperature (Creativity)

Controls randomness in output. **This is the most important parameter.**

| Value | Behavior | Use Case |
|-------|----------|----------|
| **0.1-0.3** | Predictable, consistent, factual | Code generation, technical support, data extraction |
| **0.6-0.8** | Balanced, natural conversation | General chatbots, Q&A, tutoring |
| **1.0-1.5** | Creative, varied, surprising | Creative writing, brainstorming, storytelling |

**Default recommendation: 0.7**

### 2. Context Window (num_ctx)

How much conversation history the model remembers (in tokens).

| Value | Behavior | Use Case |
|-------|----------|----------|
| **2048** | 2-3 exchanges | Quick Q&A, simple tasks |
| **4096** | 5-10 exchanges | Normal conversations (recommended) |
| **8192** | Long discussions | Complex analysis, code review |

**Default recommendation: 4096**

### 3. Top-P (Nucleus Sampling)

Controls output diversity. Keep this simple.

| Value | Behavior |
|-------|----------|
| **0.9** | Good default for almost everything |
| **1.0** | Maximum diversity (use with low temperature) |

**Default recommendation: 0.9**

---

## 📋 Copy-Paste Templates

### General Chatbot (Most Common)
```
PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
```

### Code Assistant
```
PARAMETER temperature 0.3
PARAMETER num_ctx 8192
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1
```

### Customer Support Bot
```
PARAMETER temperature 0.3
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
```

### Creative Writer
```
PARAMETER temperature 1.2
PARAMETER num_ctx 8192
PARAMETER top_p 0.95
```

### Translator
```
PARAMETER temperature 0.2
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
```

### Data Extraction / Structured Output
```
PARAMETER temperature 0.1
PARAMETER num_ctx 2048
PARAMETER top_p 0.9
```

---

## 🔧 Optional Parameters (Advanced)

These are fine-tuning knobs. **Skip unless you have specific needs.**

### top_k (Token Selection Pool)
- **Default: 40**
- Higher = more diverse output
- Lower = more focused output
- Range: 1-100

```
PARAMETER top_k 40
```

### repeat_penalty (Repetition Control)
- **Default: 1.1**
- Higher = less repetition (can make output weird)
- Lower = more repetition (natural but redundant)
- Range: 0.5-2.0

```
PARAMETER repeat_penalty 1.1
```

### stop (Stop Sequences)
Stop generation when these strings appear.

```
PARAMETER stop "User:"
PARAMETER stop "###"
```

### num_predict (Max Response Length)
Maximum tokens in response.

```
PARAMETER num_predict 512
```

### seed (Reproducibility)
Set a seed for consistent outputs (useful for testing).

```
PARAMETER seed 42
```

---

## 🎨 Temperature Visual Guide

```
Temperature Scale:
0.0 ───────────────────────── 2.0
 │           │           │
Robotic   Natural   Chaotic
```

**Examples at different temperatures:**

**Question:** "What is 2+2?"

| Temp | Response |
|------|----------|
| 0.1  | "2+2 equals 4." |
| 0.7  | "The answer to 2+2 is 4. This is basic arithmetic." |
| 1.5  | "Well, if we're talking standard mathematics, 2+2 gives us 4, though in some abstract contexts..." |

**See the difference?** Lower = direct, higher = elaborate.

---

## 🧪 How to Experiment

### Step 1: Start with defaults
```
PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
```

### Step 2: Test your model
```bash
make chat
# Select your model and test with real prompts
```

### Step 3: Adjust ONE parameter at a time

**If output is too boring/repetitive:**
- Increase temperature by 0.2

**If output is too random/incoherent:**
- Decrease temperature by 0.2

**If model "forgets" earlier conversation:**
- Increase num_ctx to 8192

**If responses are too long:**
- Add `PARAMETER num_predict 256`

### Step 4: Re-create the model
```bash
# Edit your Modelfile with new parameters
bash scripts/create-custom-model.sh my-model ./models/custom/my-model/Modelfile
```

---

## 💡 Common Issues and Fixes

### "Model gives the same response every time"
**Problem:** Temperature too low
**Fix:** Increase to 0.7 or higher

### "Model output is nonsense/incoherent"
**Problem:** Temperature too high
**Fix:** Decrease to 0.7 or lower

### "Model forgets what I said earlier"
**Problem:** Context window too small
**Fix:** Increase num_ctx to 8192

### "Model repeats phrases constantly"
**Problem:** Repetition penalty too low
**Fix:** Set `repeat_penalty 1.2`

### "Responses are cut off mid-sentence"
**Problem:** Max response length too short
**Fix:** Add `PARAMETER num_predict 1024`

---

## 📊 Parameter Comparison Table

| Use Case | Temp | num_ctx | top_p | repeat_penalty |
|----------|------|---------|-------|----------------|
| **Chatbot** | 0.7 | 4096 | 0.9 | 1.1 |
| **Code** | 0.3 | 8192 | 0.9 | 1.1 |
| **Support** | 0.3 | 4096 | 0.9 | 1.0 |
| **Creative** | 1.2 | 8192 | 0.95 | 1.0 |
| **Translator** | 0.2 | 4096 | 0.9 | 1.0 |
| **Data Extract** | 0.1 | 2048 | 0.9 | 1.0 |

---

## 🚀 Quick Start Recommendations

**Just want to get started?** Use this:

```dockerfile
FROM llama3.2:1b

PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_p 0.9

SYSTEM """
Your instructions here...
"""
```

**This works for 80% of use cases!**

Adjust temperature after testing:
- Too predictable? → Raise to 0.9
- Too random? → Lower to 0.5

---

## 📖 Full Parameter Reference

For complete parameter documentation, see [Modelfile Reference](./modelfile-reference.md).

---

## 🎓 Learning Path

1. **Week 1:** Use defaults (temp 0.7, ctx 4096, top_p 0.9)
2. **Week 2:** Experiment with temperature only
3. **Week 3:** Try different context windows
4. **Week 4:** Explore advanced parameters

**Don't try to optimize everything at once!**

---

## 🔗 Next Steps

- **Apply these settings:** [Example Modelfiles](./examples.md)
- **Understand the concepts:** [Essential Concepts](./concepts.md)
- **Complete reference:** [Modelfile Reference](./modelfile-reference.md)

---

**Remember:** Good prompts matter more than perfect parameters! Spend your time improving your SYSTEM prompt, not endlessly tweaking numbers.
