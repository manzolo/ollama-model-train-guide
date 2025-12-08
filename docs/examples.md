# Example Modelfiles

The project includes pre-configured Modelfile templates for common use cases. These examples demonstrate best practices and different parameter configurations.

## Quick Reference

| Example | Base Model | Temperature | Context | Use Case |
|---------|------------|-------------|---------|----------|
| [Chatbot](#1-chatbot) | llama3.2:1b | 0.7 | 4096 | General conversation |
| [Code Assistant](#2-code-assistant) | llama3.2:1b | 0.3 | 8192 | Programming help |
| [Translator](#3-translator) | llama3.2:1b | 0.5 | 4096 | Language translation |
| [Creative Writer](#4-creative-writer) | llama3.2:1b | 1.2 | 8192 | Content creation |
| [Personal Assistant](#5-personal-assistant) | llama3.2:1b | 0.6 | 4096 | Task management |
| [TechCorp Support](#6-techcorp-support) | llama3.2:1b | 0.3 | 4096 | Customer support |

## Using Examples

### Quick Start

Create a model from any example:

```bash
# Interactive selection
make create-model

# Or directly
bash scripts/create-custom-model.sh <model-name> ./models/examples/<example>/Modelfile

# Example:
bash scripts/create-custom-model.sh my-chatbot ./models/examples/chatbot/Modelfile
```

Test the model:
```bash
make chat
# Select your newly created model
```

---

## 1. Chatbot

**Location**: `models/examples/chatbot/Modelfile`

### Purpose
General-purpose conversational AI for customer service, Q&A, and casual chat.

### Configuration

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

### Best For
- Customer support
- General Q&A
- Interactive help systems
- Educational chatbots

### Example Usage

```bash
bash scripts/create-custom-model.sh friendly-bot ./models/examples/chatbot/Modelfile
docker compose exec ollama ollama run friendly-bot "How can I track my order?"
```

### Parameter Notes
- **Temperature 0.7**: Balanced between consistency and variety
- **Context 4096**: Handles medium-length conversations
- **Top P 0.9**: Good diversity without being random

---

## 2. Code Assistant

**Location**: `models/examples/code-assistant/Modelfile`

### Purpose
Programming help, code generation, debugging, and technical explanations.

### Configuration

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

### Best For
- Code generation
- Debugging help
- Code review
- Technical documentation
- Algorithm explanations

### Example Usage

```bash
bash scripts/create-custom-model.sh code-helper ./models/examples/code-assistant/Modelfile
docker compose exec ollama ollama run code-helper "Write a Python function to validate email addresses"
```

### Parameter Notes
- **Temperature 0.3**: Deterministic, consistent code generation
- **Context 8192**: Can handle large code files
- **Repeat Penalty 1.15**: Prevents repetitive code patterns

---

## 3. Translator

**Location**: `models/examples/translator/Modelfile`

### Purpose
Language translation and localization.

### Configuration

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

### Best For
- Text translation
- Localization
- Language learning
- Multilingual content creation

### Example Usage

```bash
bash scripts/create-custom-model.sh translator ./models/examples/translator/Modelfile
docker compose exec ollama ollama run translator "Translate to Spanish: Hello, how are you today?"
```

### Parameter Notes
- **Temperature 0.5**: Moderate creativity for natural phrasing
- **Context 4096**: Handles paragraphs and documents
- **Top P 0.9**: Balanced translation variety

---

## 4. Creative Writer

**Location**: `models/examples/creative-writer/Modelfile`

### Purpose
Creative content generation, storytelling, and ideation.

### Configuration

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

### Best For
- Story writing
- Content creation
- Brainstorming ideas
- Marketing copy
- Poetry and creative text

### Example Usage

```bash
bash scripts/create-custom-model.sh creative ./models/examples/creative-writer/Modelfile
docker compose exec ollama ollama run creative "Write a short story about a robot learning to paint"
```

### Parameter Notes
- **Temperature 1.2**: High creativity and variety
- **Context 8192**: Long-form content generation
- **Top P 0.95**: Wide vocabulary range
- **Repeat Penalty 1.2**: Avoids repetitive phrasing

---

## 5. Personal Assistant

**Location**: `models/examples/personal-assistant/Modelfile`

### Purpose
Task management, scheduling, reminders, and personal productivity.

### Configuration

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

### Best For
- To-do list management
- Calendar assistance
- Email drafting
- Meeting scheduling
- Personal organization

### Example Usage

```bash
bash scripts/create-custom-model.sh assistant ./models/examples/personal-assistant/Modelfile
docker compose exec ollama ollama run assistant "Help me plan my day. I have a meeting at 2pm and need to finish a report."
```

### Parameter Notes
- **Temperature 0.6**: Consistent but not rigid
- **Context 4096**: Tracks tasks and conversations
- **Top P 0.9**: Natural conversational flow

---

## 6. TechCorp Support

**Location**: `models/examples/techcorp-support/Modelfile`

### Purpose
Demonstrates few-shot learning with dataset examples for specialized customer support.

### Configuration

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

The model uses examples from `data/training/techcorp-support.jsonl` (10 Q&A pairs).

### Best For
- Company-specific support bots
- FAQ automation
- Consistent branded responses
- Knowledge base queries

### Example Usage

```bash
bash scripts/create-custom-model.sh support-bot ./models/examples/techcorp-support/Modelfile
docker compose exec ollama ollama run support-bot "How do I reset my password?"
```

### Parameter Notes
- **Temperature 0.3**: Factual, consistent responses
- **Few-shot Learning**: MESSAGE examples train the model
- **Context 4096**: Handles support conversations

### Learn More
See [Dataset Training Example](./dataset-training-example.md) for complete guide on creating custom support bots.

---

## Customizing Examples

All examples can be customized for your needs:

### 1. Copy the Example

```bash
cp -r ./models/examples/chatbot ./models/custom/my-chatbot
```

### 2. Edit the Modelfile

```bash
nano ./models/custom/my-chatbot/Modelfile
```

Modify:
- **Base model**: Change `FROM` line to use different model
- **Parameters**: Adjust temperature, context, etc.
- **System prompt**: Customize behavior and personality
- **Examples**: Add MESSAGE pairs for few-shot learning

### 3. Create Your Model

```bash
bash scripts/create-custom-model.sh my-chatbot ./models/custom/my-chatbot/Modelfile
```

## Parameter Tuning Guide

### Temperature Selection

```
0.1-0.3  → Factual, deterministic (code, docs, support)
0.4-0.6  → Balanced, consistent (assistants, education)
0.7-0.9  → Conversational, varied (chat, discussion)
1.0-1.5  → Creative, diverse (writing, brainstorming)
1.6-2.0  → Highly random (experimental)
```

### Context Window Selection

```
2048     → Short conversations, simple tasks
4096     → Standard conversations, documents
8192     → Long conversations, large code files
16384+   → Very long context (requires more RAM)
```

### Top P Selection

```
0.7-0.8  → Focused, consistent output
0.9      → Recommended default
0.95-1.0 → Maximum diversity
```

### Repeat Penalty Selection

```
1.0      → No penalty
1.1-1.2  → Standard anti-repetition
1.3-1.5  → Strong anti-repetition (can affect quality)
```

## Testing Your Custom Model

### Quick Test

```bash
docker compose exec ollama ollama run <model-name> "Test prompt"
```

### Interactive Test

```bash
make chat
# Select your model
```

### API Test

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "your-model",
  "prompt": "Test prompt",
  "stream": false
}'
```

### Comprehensive Test

Use the quick-test script:
```bash
make quick-test
```

## Next Steps

- [Modelfile Reference](./modelfile-reference.md) - Complete syntax guide
- [Dataset Training Example](./dataset-training-example.md) - Train with custom data
- [Advanced Usage](./advanced-usage.md) - Fine-tuning and LoRA adapters
- [API Usage](./api-usage.md) - Integrate models into applications
