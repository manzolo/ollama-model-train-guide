# Quick Reference Guide

## Interactive Model Selection

All model-related make commands now feature interactive selection menus. No need to remember or type long paths!

### Chat with a Model

```bash
make chat
```

**What happens:**
1. Shows numbered list of all available models
2. You select which model to chat with
3. Starts an interactive chat session
4. Type messages and get responses
5. Use `/bye` or `Ctrl+D` to exit

**Example output:**
```
💬 Chat with a model

📦 Available models:

  [1] llama3.2:1b (1.3 GB)
  [2] mistral:7b (4.1 GB)
  [3] my-chatbot (1.3 GB) ⭐
  [4] my-code-helper (1.3 GB) ⭐

  [0] Cancel

Select a model to chat with [0-4]: 3

🚀 Starting chat with: my-chatbot

💡 Tips:
   - Type your messages and press Enter
   - Use /bye to exit the chat
   - Use Ctrl+D to exit

───────────────────────────────────────────────────────

>>> Hello! How are you?
I'm doing great, thanks for asking! How can I help you today?

>>> Tell me a joke
Why don't scientists trust atoms? Because they make up everything!

>>> /bye
👋 Chat ended
```

### Create a Custom Model

```bash
make create-model
```

**What happens:**
1. Shows numbered list of all Modelfiles in `models/examples/` and `models/custom/`
2. You select by number
3. You enter a name for your new model
4. Model is created

**Example output:**
```
🔨 Create a custom model

📁 Available Modelfiles:

  [1] examples/chatbot/Modelfile
  [2] examples/code-assistant/Modelfile
  [3] examples/creative-writer/Modelfile
  [4] examples/personal-assistant/Modelfile
  [5] examples/translator/Modelfile
  [6] custom/my-custom-bot/Modelfile

  [0] Enter custom path

Select a Modelfile [0-6]: 2
Enter name for the new model: my-code-helper
```

### Save a Model for Deployment

```bash
make save-model
```

**What happens:**
1. Shows numbered list of all models in your Ollama instance
2. You select which model to save
3. Saves Modelfile to `models/saved/`

**Example output:**
```
💾 Save a model for deployment

📦 Available models:

  [1] llama3.2:1b
  [2] mistral:7b
  [3] my-chatbot
  [4] my-code-helper
  [5] production-assistant

  [0] Enter custom name

Select a model [0-5]: 3

💾 Saving model: my-chatbot
Output: ./models/saved/my-chatbot.Modelfile

✅ Model saved successfully!
```

### Deploy a Saved Model

```bash
make deploy-model
```

**What happens:**
1. Shows numbered list of saved Modelfiles in `models/saved/`
2. You select which one to deploy
3. Optionally rename it during deployment
4. Model is created in your Ollama instance

**Example output:**
```
🚀 Deploy a saved model

💾 Available saved models:

  [1] my-chatbot.Modelfile
  [2] production-bot.Modelfile
  [3] team-assistant.Modelfile

  [0] Enter custom path

Select a saved model [0-3]: 1
Enter model name (press Enter to use filename):

🚀 Deploying model: my-chatbot
✅ Model deployed successfully!
```

## Direct Script Usage

If you prefer command-line arguments, you can still use the scripts directly:

```bash
# Create model (specify path)
bash scripts/create-custom-model.sh my-bot ./models/examples/chatbot/Modelfile

# Save model (specify name)
bash scripts/save-model.sh my-chatbot

# Deploy model (specify path)
bash scripts/deploy-model.sh ./models/saved/my-chatbot.Modelfile

# Or deploy with custom name
bash scripts/deploy-model.sh ./models/saved/my-chatbot.Modelfile renamed-bot
```

## Cheat Sheet

| Task | Command | Interactive? |
|------|---------|--------------|
| Check requirements | `make preflight` | No |
| Start all services (Ollama + Chat UI) | `make up` | No |
| Start Ollama only (no web UI) | `make up-core` | No |
| Start with NVIDIA GPU | `make up-gpu` | No |
| Stop services | `make down` | No |
| View logs | `make logs` | No |
| Shell access | `make shell` | No |
| Pull base models | `make pull-base` | No |
| List models | `make list-models` | No |
| **Create custom model** | `make create-model` | **Yes - select Modelfile** |
| **Chat with model** | `make chat` | **Yes - select model** |
| **Save model** | `make save-model` | **Yes - select model** |
| **Deploy model** | `make deploy-model` | **Yes - select saved file** |
| **Publish model to registry** | `make publish-model` | **Yes - select model** |
| Backup all models | `make backup-models` | No |
| Quick test | `make quick-test` | Yes - confirmation |
| Validation tests | `make test` | No |
| Clean up | `make clean` | Yes - confirmation |

## Choosing a Base Model (2026)

The project's examples default to the lightweight `llama3.2:1b` — keep using it for learning and quick iteration. Modern lightweight alternatives worth trying with `ollama pull`:

| Model | Approx. size | Approx. RAM needed | Notes |
|-------|-------------|--------------------|-------|
| `llama3.2:1b` | ~1.3 GB | ~4 GB | Project default |
| `qwen3:0.6b` / `qwen3:1.7b` | ~0.5 / ~1.4 GB | ~2 / ~4 GB | Small, strong; optional thinking mode |
| `gemma3:1b` | ~815 MB | ~4 GB | Very compact |
| `gemma3:4b` | ~3.3 GB | ~8 GB | Multimodal, 128K context |
| `phi4-mini` | ~2.5 GB | ~8 GB | Compact and efficient |
| `qwen3:8b` | ~5 GB | ~16 GB | Heavier, for capable machines |
| `gpt-oss:20b` | ~13 GB | ~16 GB | Heavier, for capable machines |

See [Essential Concepts - Choosing a Base Model](./concepts.md#choosing-a-base-model-2026) for details.

## Directory Structure

```
models/
├── examples/          # Pre-configured example Modelfiles
│   ├── chatbot/
│   │   └── Modelfile
│   ├── code-assistant/
│   │   └── Modelfile
│   └── ...
├── custom/            # Your custom Modelfiles
│   └── my-bot/
│       └── Modelfile
└── saved/             # Saved models ready for deployment
    ├── my-chatbot.Modelfile
    └── production-bot.Modelfile
```

## Tips

1. **Option [0]** in any selection menu lets you enter a custom path/name
2. Saved models are stored in `models/saved/` by default
3. Backups include timestamps: `backups/models/YYYYMMDD_HHMMSS/`
4. You can still use scripts directly with paths if you prefer
5. All interactive commands can be cancelled with Ctrl+C

## Common Workflows

### Quick Test of Example Model

```bash
make up                 # Start Ollama
make pull-base          # Get base models
make create-model       # Select example, name it
make chat               # Select your model and start chatting!
```

### Deploy to Production

```bash
# On dev server:
make save-model         # Select your model

# Transfer file:
scp ./models/saved/my-model.Modelfile user@prod:/opt/ollama/models/saved/

# On prod server:
make deploy-model       # Select the transferred file
```

### Regular Backup

```bash
make backup-models      # Backs up all custom models
# Files saved to: ./backups/models/YYYYMMDD_HHMMSS/
```

### Quick Test

Test the complete workflow:

```bash
make quick-test
```

**What happens:**
1. Asks for confirmation
2. Creates a temporary test model
3. Sends a test prompt: "Hello! Can you introduce yourself in one sentence?"
4. Displays the response
5. Deletes the test model
6. Shows success summary

**Example output:**
```
🧪 Quick Model Test

This will:
  1. Create a test model from an example
  2. Send a test prompt to it
  3. Delete the test model

Continue? (y/N): y

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 Step 1/3: Creating test model 'test-chatbot-1701234567'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Test Details:
  Base Model: llama3.2:1b
  Modelfile:  ./models/examples/chatbot/Modelfile
  Test Model: test-chatbot-1701234567

🔨 Creating custom model: test-chatbot-1701234567
✅ Model created successfully!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💬 Step 2/3: Testing model with a prompt
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sending test prompt: 'Hello! Can you introduce yourself in one sentence?'

Response:
─────────────────────────────────────────────────────
I'm a helpful AI assistant designed to provide accurate and
clear answers to your questions.
─────────────────────────────────────────────────────

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🗑️  Step 3/3: Cleaning up test model
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

deleted 'test-chatbot-1701234567'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Quick test completed successfully!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary:
  ✓ Model creation works (base: llama3.2:1b)
  ✓ Model responds to prompts
  ✓ Model cleanup works

You can now create your own models with:
  make create-model
```

**Note:** Output is automatically cleaned for readability (ANSI escape codes removed).
