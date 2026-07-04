# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker Compose-based environment for creating, customizing, and managing Ollama language models. The project focuses on model customization through Modelfiles (similar to Dockerfiles) rather than fine-tuning from scratch.

## Core Architecture

### Services (docker-compose.yml)
- **ollama**: `ollama/ollama:${OLLAMA_IMAGE_TAG:-latest}`
  - Persistent storage via Docker volume `ollama_data` at `/root/.ollama`
  - Bind mounts: `./models` → `/models` (Modelfiles), `./data` → `/data` (GGUF files, adapters, training datasets)
  - API exposed on `localhost:${OLLAMA_PORT:-11434}`
- **chat**: Flask web app (built from `./chat`), under Compose profile `chat`
  - Serves the chat UI (`/`), spreadsheet converter (`/converter`), and Modelfile wizard (`/wizard`) on `localhost:${CHAT_PORT:-8080}`
  - The Makefile always enables the profile (`docker compose --profile chat`); plain `docker compose up` respects `COMPOSE_PROFILES` from `.env`
- **GPU**: `docker-compose.gpu.yml` is an override adding the NVIDIA runtime; start with `make up-gpu` (requires NVIDIA Container Toolkit). No editing of `docker-compose.yml` needed.

### Environment Configuration (.env)
Created by `make setup` from `.env.example`. Variables are interpolated by Docker Compose (e.g. `"${OLLAMA_PORT:-11434}:11434"`):
- `OLLAMA_PORT` (default 11434): host port for the Ollama API
- `CHAT_PORT` (default 8080): host port for the chat web UI
- `COMPOSE_PROFILES` (default `chat`): profiles started by plain `docker compose up`; set empty to run Ollama only
- `OLLAMA_ORIGINS` (default `*`): CORS origins allowed to call the API
- `OLLAMA_IMAGE_TAG` (default `latest`): pin a specific Ollama version (e.g. `0.30.10`) for reproducibility

After changing `.env`, run `make down && make up` to apply.

### Modelfile System
Modelfiles define custom models by extending base models with:
- **FROM**: Base model (from Ollama library or local GGUF file)
- **PARAMETER**: Runtime parameters (temperature, context window, sampling, etc.)
- **SYSTEM**: System prompt defining model behavior and persona
- **ADAPTER**: Optional LoRA/QLoRA adapters
- **MESSAGE**: Few-shot examples
- **TEMPLATE**: Custom prompt formatting

Key directories:
- `models/examples/`: Pre-configured templates (chatbot, code-assistant, translator, creative-writer, personal-assistant, **techcorp-support**)
- `models/custom/`: User-created Modelfiles
- `data/gguf/`: External GGUF model files
- `data/adapters/`: Fine-tuned LoRA adapters
- `data/training/`: Training datasets (includes `techcorp-support.jsonl` example)

## Common Commands

### Environment Management
```bash
make preflight      # Check system requirements before setup
make setup          # Initial setup (creates .env, directories)
make up             # Start all services (Ollama + chat web UI)
make up-core        # Start Ollama only (no chat web UI)
make up-gpu         # Start with NVIDIA GPU support (docker-compose.gpu.yml override)
make down           # Stop services
make restart        # Restart services
make logs           # View container logs
make shell          # Access container shell
```

### Model Operations
```bash
# Pull base models
make pull-base      # Downloads common models (llama3.2:1b, mistral:7b, etc.)

# Create custom model from Modelfile (interactive selection)
make create-model   # Shows numbered list of available Modelfiles
# Or specify directly:
bash scripts/create-custom-model.sh <model-name> <modelfile-path>
# Example: bash scripts/create-custom-model.sh my-bot ./models/examples/chatbot/Modelfile

# List all models
make list-models
# Or: docker compose exec ollama ollama list

# Chat with a model (interactive selection)
make chat       # Shows numbered list of models, then starts chat

# Or run model directly
docker compose exec ollama ollama run <model-name>

# Export model's Modelfile (for version control/sharing)
bash scripts/export-model.sh <model-name> <output-path>

# Import external GGUF model
bash scripts/import-model.sh <model-name> <gguf-file-path>

# Save model for deployment to another Ollama instance (interactive)
make save-model     # Shows numbered list of available models
# Or: bash scripts/save-model.sh <model-name> [output-directory]

# Deploy saved model to current instance (interactive)
make deploy-model   # Shows numbered list of saved Modelfiles
# Or: bash scripts/deploy-model.sh <modelfile-path> [model-name]

# Backup all custom models
make backup-models
# Or: bash scripts/backup-models.sh [output-directory]
```

### API Usage
```bash
# Generate response
curl http://localhost:11434/api/generate -d '{
  "model": "my-model",
  "prompt": "Your prompt here",
  "stream": false
}'

# List available models
curl http://localhost:11434/api/tags
```

### Testing
```bash
make quick-test     # Quick end-to-end test (create, chat, delete)
make test          # Run validation tests
```

## Development Workflow

### Creating a Custom Model

1. **Create Modelfile** in `models/custom/<model-name>/Modelfile`:
   ```dockerfile
   FROM llama3.2:1b

   PARAMETER temperature 0.7
   PARAMETER num_ctx 4096
   PARAMETER top_p 0.9

   SYSTEM """
   You are a specialized assistant for [use case].
   [Define behavior, constraints, personality]
   """
   ```

2. **Build the model**:
   ```bash
   bash scripts/create-custom-model.sh my-model ./models/custom/my-model/Modelfile
   ```

3. **Test iteratively**:
   ```bash
   docker compose exec ollama ollama run my-model "Test prompt"
   ```

4. **Export for version control**:
   ```bash
   bash scripts/export-model.sh my-model ./models/custom/my-model/Modelfile-exported
   ```

### Working with External Models

For fine-tuned models from Unsloth, Hugging Face, or custom training:

1. Export model to GGUF format (using llama.cpp or similar tools)
2. Place GGUF file in `./data/gguf/`
3. Import: `bash scripts/import-model.sh my-finetuned ./data/gguf/model.gguf`

### LoRA Adapters

To use LoRA adapters:
1. Place adapter file in `./data/adapters/`
2. Reference in Modelfile:
   ```dockerfile
   FROM llama3.2:1b
   ADAPTER /data/adapters/my-adapter.bin
   ```

### Deploying Models to Self-Hosted Instances

To deploy custom models to another self-hosted Ollama instance:

1. **Save the model** on the source instance:
   ```bash
   make save-model
   # Or: bash scripts/save-model.sh my-chatbot
   # Saves to: ./models/saved/my-chatbot.Modelfile
   ```

2. **Transfer the Modelfile** to the target instance:
   ```bash
   scp ./models/saved/my-chatbot.Modelfile user@target-server:/path/to/ollama-project/models/saved/
   ```

3. **Deploy on the target instance**:
   ```bash
   make deploy-model
   # Or: bash scripts/deploy-model.sh ./models/saved/my-chatbot.Modelfile
   ```

4. **Backup all models** regularly:
   ```bash
   make backup-models
   # Creates timestamped backup in ./backups/models/YYYYMMDD_HHMMSS/
   ```

## Interactive Model Selection

Interactive numbered menus are built directly into the `scripts/interactive-*.sh` scripts (`interactive-create-model.sh`, `interactive-chat.sh`, `interactive-save-model.sh`, `interactive-deploy-model.sh`, `interactive-publish-model.sh`), which share helper functions from `scripts/lib/common.sh`.

These scripts back `make create-model`, `make chat`, `make save-model`, `make deploy-model`, and `make publish-model`, so no manual path entry is required.

All selection menus include option `[0]` to manually enter a custom path/name.

## Important Implementation Details

### Script Paths
- All scripts use Docker Compose commands: `docker compose exec ollama ollama <command>`
- Modelfile paths inside container are relative to bind mounts:
  - `./models/custom/foo` → `/models/custom/foo`
  - `./data/gguf/bar.gguf` → `/data/gguf/bar.gguf`

### Service State Check
Scripts verify Ollama is running with:
```bash
docker compose ps | grep -qE "ollama.*(Up|running)"
```

### Model Parameters
- **temperature** (0.0-2.0): Lower = deterministic, higher = creative
  - Code/factual: 0.2-0.4
  - Chat: 0.6-0.8
  - Creative writing: 0.9-1.2
- **num_ctx**: Context window in tokens (2048 default, 4096-8192 for longer context)
- **top_k** (1-100): Token selection pool size
- **top_p** (0.0-1.0): Nucleus sampling threshold
- **repeat_penalty** (0.0-2.0): Repetition control (1.1-1.2 recommended)

### GPU Support
Optional NVIDIA GPU acceleration via the `docker-compose.gpu.yml` override file. Start with `make up-gpu` (equivalent to `docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d`). Requires NVIDIA drivers and the NVIDIA Container Toolkit on the host.

### License
The project is released under the MIT License (see `LICENSE`).

## Troubleshooting

### Service Not Starting
```bash
docker ps                    # Check Docker daemon
make logs                    # View error logs
make restart                 # Restart service
```

### Modelfile Creation Fails
- Verify base model exists: `docker compose exec ollama ollama list`
- Check Modelfile syntax (case-insensitive, FROM required)
- Ensure paths are correct relative to container mounts

### Disk Space Issues
Models can be large (1GB-30GB+). Check available space:
```bash
df -h
docker system df             # Docker resource usage
```

## API Endpoints Reference

- `GET /api/tags` - List models
- `POST /api/generate` - Generate completion
- `POST /api/chat` - Chat completion
- `POST /api/pull` - Pull model from library
- `POST /api/create` - Create model from Modelfile
- `POST /api/show` - Show model info
- `DELETE /api/delete` - Delete model

See docs/api-usage.md for detailed API documentation.

## Continuous Integration

The project includes GitHub Actions workflows for automated testing:

- **`.github/workflows/test.yml`**: End-to-end testing (creates model, tests chat, cleans up)
- **`.github/workflows/validate.yml`**: Configuration and structure validation
- **`.github/workflows/test-dataset-example.yml`**: Tests the TechCorp customer support dataset example

All workflows run on push and pull requests to main/master branches.

To run the same tests locally:
```bash
make quick-test                          # End-to-end test
make test                                # Validation tests
bash scripts/test-techcorp-example.sh    # Dataset example test
```

## Dataset Training Example

The project includes a complete example of dataset-based model training:

**TechCorp Customer Support Bot** (`models/examples/techcorp-support/`)
- Demonstrates few-shot learning with MESSAGE examples
- Uses a 10-example Q&A dataset (`data/training/techcorp-support.jsonl`)
- Shows how to create specialized models without fine-tuning
- Temperature: 0.3 (factual, consistent responses)

**Spreadsheet to JSONL Converter**: web UI at `http://localhost:8080/converter`
- Convert CSV or Excel files to JSONL training format
- Column mapping with data preview before converting
- Download the result or save it directly to `data/training/`

**Modelfile Wizard**: web UI at `http://localhost:8080/wizard`
- Guided 6-step Modelfile creation (use case, base model, personality, rules, examples)
- Generates the Modelfile via `POST /api/wizard/generate`, saves it to `models/custom/<name>/`, and creates the model

See `docs/chat-ui.md` for the complete web UI guide.

**Complete guide**: `docs/dataset-training-example.md` covers:
- Preparing JSONL datasets
- Fine-tuning with Unsloth or Hugging Face Transformers
- Converting to GGUF format
- When to use few-shot learning vs fine-tuning
- Using Google Colab for free GPU training
