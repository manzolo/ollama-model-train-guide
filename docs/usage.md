# Usage Guide

Complete guide to managing your Ollama environment and working with models.

## Managing the Environment

### Starting and Stopping Services

**Start all services** (Ollama + Chat UI):
```bash
make up
```

**Stop all services**:
```bash
make down
```

**Restart services** (after configuration changes):
```bash
make restart
```

**Check service status**:
```bash
docker compose ps
```

### Monitoring and Logs

**View real-time logs**:
```bash
make logs

# Or for specific service
docker compose logs -f ollama
docker compose logs -f chat
```

**Access container shell**:
```bash
make shell

# Or directly
docker compose exec ollama bash
```

### Cleanup

**Remove all containers and volumes** (deletes all models):
```bash
make clean
```

**Partial cleanup** (keep volumes):
```bash
make down
```

## Working with Models

### Listing Models

**List all installed models**:
```bash
make list-models

# Or directly
docker compose exec ollama ollama list
```

This shows:
- Model names
- Size on disk
- Model ID
- Last modified date

### Pulling Models

**Via Web UI** (Recommended):
1. Open `http://localhost:8080`
2. Click "Manage Models"
3. Enter model name (e.g., `llama3.2`, `mistral:7b`, `phi3:mini`)
4. Click "Pull Model"
5. Watch real-time progress with download speed and ETA

**Via CLI**:
```bash
# Pull common base models
make pull-base

# Pull specific model
docker compose exec ollama ollama pull <model-name>

# Examples:
docker compose exec ollama ollama pull llama3.2:1b
docker compose exec ollama ollama pull mistral:7b
docker compose exec ollama ollama pull codellama:13b
```

**Available models**: See [Ollama Library](https://ollama.com/library) for all models.

### Creating Custom Models

Custom models are defined using Modelfiles (similar to Dockerfiles).

**Interactive creation** (with menu selection):
```bash
make create-model
```

This will:
1. Show a numbered list of available Modelfiles
2. Let you select one
3. Ask for a model name
4. Create the model

**Direct creation**:
```bash
bash scripts/create-custom-model.sh <model-name> <modelfile-path>

# Examples:
bash scripts/create-custom-model.sh my-chatbot ./models/examples/chatbot/Modelfile
bash scripts/create-custom-model.sh code-helper ./models/custom/code-assistant/Modelfile
```

**Creating your own Modelfile**:

Create a file at `./models/custom/my-model/Modelfile`:

```dockerfile
# Base model (must be pulled first)
FROM llama3.2:1b

# Model parameters
PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1

# System prompt (defines behavior)
SYSTEM """
You are a helpful assistant specialized in [your use case].
[Define specific behavior, constraints, and personality here]
"""

# Optional: Few-shot examples
MESSAGE user "Example question?"
MESSAGE assistant "Example answer."
```

Then create the model:
```bash
bash scripts/create-custom-model.sh my-model ./models/custom/my-model/Modelfile
```

See [Modelfile Reference](./modelfile-reference.md) for complete syntax.

### Chatting with Models

**Interactive chat** (via CLI):
```bash
make chat
# Select from a numbered list of models
```

Or directly:
```bash
docker compose exec ollama ollama run <model-name>

# Examples:
docker compose exec ollama ollama run llama3.2:1b
docker compose exec ollama ollama run my-chatbot
```

**Single prompt** (non-interactive):
```bash
docker compose exec ollama ollama run <model-name> "Your prompt here"

# Example:
docker compose exec ollama ollama run llama3.2:1b "Write a haiku about Docker"
```

**Via Web UI**:
1. Open `http://localhost:8080`
2. Select model from dropdown
3. Start chatting!

See [Chat UI Guide](./chat-ui.md) for web interface features.

### Using the API

**Generate completion**:
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:1b",
  "prompt": "Why is the sky blue?",
  "stream": false
}'
```

**Chat completion** (with conversation history):
```bash
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2:1b",
  "messages": [
    {"role": "user", "content": "Hello!"},
    {"role": "assistant", "content": "Hi! How can I help?"},
    {"role": "user", "content": "What is Docker?"}
  ],
  "stream": false
}'
```

**List models**:
```bash
curl http://localhost:11434/api/tags
```

**Show model info**:
```bash
curl http://localhost:11434/api/show -d '{
  "name": "llama3.2:1b"
}'
```

See [API Usage Guide](./api-usage.md) for complete API documentation.

## Saving and Deploying Models

### Export Model Configuration

**Save a model for deployment** (interactive):
```bash
make save-model
```

Or directly:
```bash
bash scripts/save-model.sh <model-name> [output-directory]

# Examples:
bash scripts/save-model.sh my-chatbot
bash scripts/save-model.sh my-chatbot ./custom-output
```

This saves the Modelfile to `./models/saved/<model-name>.Modelfile`

**Export model's Modelfile**:
```bash
bash scripts/export-model.sh <model-name> <output-path>

# Example:
bash scripts/export-model.sh my-chatbot ./my-chatbot-v1.Modelfile
```

### Deploy to Another Instance

**Transfer Modelfile to target server**:
```bash
scp ./models/saved/my-chatbot.Modelfile user@server:/path/to/ollama-project/models/saved/
```

**Deploy on target instance** (interactive):
```bash
make deploy-model
```

Or directly:
```bash
bash scripts/deploy-model.sh <modelfile-path> [model-name]

# Example:
bash scripts/deploy-model.sh ./models/saved/my-chatbot.Modelfile my-chatbot
```

### Backup All Models

**Create timestamped backup**:
```bash
make backup-models

# Or directly:
bash scripts/backup-models.sh [output-directory]
```

This creates a backup in `./backups/models/YYYYMMDD_HHMMSS/` containing all your custom models' Modelfiles.

## Importing External Models

### Import GGUF Files

If you have a GGUF model file (from Hugging Face, fine-tuning, etc.):

1. **Place GGUF file in data directory**:
   ```bash
   cp /path/to/model.gguf ./data/gguf/
   ```

2. **Import the model**:
   ```bash
   bash scripts/import-model.sh <model-name> ./data/gguf/model.gguf

   # Example:
   bash scripts/import-model.sh my-custom-model ./data/gguf/my-model.gguf
   ```

3. **Use the model**:
   ```bash
   docker compose exec ollama ollama run my-custom-model
   ```

### Using LoRA Adapters

If you have a LoRA adapter file:

1. **Place adapter in data directory**:
   ```bash
   cp /path/to/adapter.bin ./data/adapters/
   ```

2. **Create Modelfile** at `./models/custom/adapted-model/Modelfile`:
   ```dockerfile
   FROM llama3.2:1b
   ADAPTER /data/adapters/my-adapter.bin

   PARAMETER temperature 0.7

   SYSTEM """
   You are a specialized assistant.
   """
   ```

3. **Create the model**:
   ```bash
   bash scripts/create-custom-model.sh adapted-model ./models/custom/adapted-model/Modelfile
   ```

## Model Parameters

Key parameters you can adjust in Modelfiles:

### Temperature (0.0 - 2.0)
Controls randomness and creativity:
- **0.1-0.3**: Deterministic, factual (code, technical docs)
- **0.6-0.8**: Balanced, conversational (chat, general Q&A)
- **0.9-1.5**: Creative, varied (story writing, brainstorming)
- **1.6-2.0**: Highly random (experimental)

### Context Window (num_ctx)
Number of tokens the model can "remember":
- **2048**: Default, suitable for short conversations
- **4096**: Standard for most uses
- **8192**: Long conversations, large documents
- **16384+**: Very long context (requires more RAM)

### Top P (0.0 - 1.0)
Nucleus sampling threshold:
- **0.9**: Recommended for most uses
- Lower values = more focused, deterministic
- Higher values = more diverse outputs

### Top K (1 - 100)
Limits token selection pool:
- **40**: Default, good balance
- Lower values = more focused
- Higher values = more diverse

### Repeat Penalty (0.0 - 2.0)
Reduces repetition:
- **1.0**: No penalty
- **1.1-1.2**: Recommended for most uses
- Higher values = stronger anti-repetition

Example Modelfile with tuned parameters:

```dockerfile
FROM mistral:7b

PARAMETER temperature 0.4
PARAMETER num_ctx 8192
PARAMETER top_p 0.9
PARAMETER top_k 40
PARAMETER repeat_penalty 1.15

SYSTEM """
You are a technical documentation assistant.
Provide clear, accurate, well-structured responses.
"""
```

See [Modelfile Reference](./modelfile-reference.md) for all available parameters.

## Advanced Operations

### Testing Models

**Quick end-to-end test**:
```bash
make quick-test
```

This automatically:
1. Creates a test model
2. Sends a test prompt
3. Displays the response
4. Deletes the test model

**Validation tests**:
```bash
make test
```

Validates:
- Docker Compose configuration
- Service health
- Directory structure
- Example Modelfiles

### Interactive Model Selection

Helper scripts provide numbered menus:

- **`scripts/select-modelfile.sh`**: Lists Modelfiles for creation
- **`scripts/select-model.sh`**: Lists installed models
- **`scripts/select-saved-model.sh`**: Lists saved Modelfiles

These are used by `make create-model`, `make save-model`, and `make deploy-model`.

All menus include option `[0]` to manually enter a custom path.

### Delete Models

```bash
docker compose exec ollama ollama rm <model-name>

# Example:
docker compose exec ollama ollama rm old-model
```

**Warning**: This permanently deletes the model. Make sure to export/save it first if needed.

## Performance Tips

### Model Size vs Performance

- **1B-3B models**: Fast, low RAM, suitable for simple tasks
- **7B-13B models**: Balanced quality and speed
- **30B+ models**: High quality, slow, requires significant RAM/VRAM

### GPU Acceleration

Enable GPU support for:
- 5-10x faster inference
- Ability to run larger models
- Better concurrent user handling

See [Installation Guide - GPU Support](./installation.md#gpu-support-optional).

### Disk Space Management

Models can be large. Check usage:

```bash
# Check Docker disk usage
docker system df

# Check volume size
docker volume inspect ollama_data

# List model sizes
docker compose exec ollama ollama list
```

Clean up unused models:
```bash
docker compose exec ollama ollama rm <unused-model>
```

## Next Steps

- [Chat UI Guide](./chat-ui.md) - Use the web interface
- [Examples](./examples.md) - Pre-configured model templates
- [Advanced Usage](./advanced-usage.md) - Fine-tuning and customization
- [Troubleshooting](./troubleshooting.md) - Common issues and solutions
