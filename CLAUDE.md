# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker Compose-based environment for creating, customizing, and managing Ollama language models. The project focuses on model customization through Modelfiles (similar to Dockerfiles) rather than fine-tuning from scratch.

## Core Architecture

### Containerized Ollama Service
- Single Docker container running `ollama/ollama:latest`
- Persistent storage via Docker volume `ollama_data` at `/root/.ollama`
- Three bind mounts:
  - `./models` → `/models` (Modelfiles and custom model definitions)
  - `./data` → `/data` (GGUF files, LoRA adapters, training datasets)
  - Configuration via `.env` file
- API exposed on `localhost:11434`

### Modelfile System
Modelfiles define custom models by extending base models with:
- **FROM**: Base model (from Ollama library or local GGUF file)
- **PARAMETER**: Runtime parameters (temperature, context window, sampling, etc.)
- **SYSTEM**: System prompt defining model behavior and persona
- **ADAPTER**: Optional LoRA/QLoRA adapters
- **MESSAGE**: Few-shot examples
- **TEMPLATE**: Custom prompt formatting

Key directories:
- `models/examples/`: Pre-configured templates (chatbot, code-assistant, translator, creative-writer, personal-assistant)
- `models/custom/`: User-created Modelfiles
- `data/gguf/`: External GGUF model files
- `data/adapters/`: Fine-tuned LoRA adapters
- `data/training/`: Training dataset documentation

## Common Commands

### Environment Management
```bash
make setup          # Initial setup (creates .env, directories)
make up             # Start Ollama (docker compose up -d)
make down           # Stop Ollama
make restart        # Restart service
make logs           # View container logs
make shell          # Access container shell
```

### Model Operations
```bash
# Pull base models
make pull-base      # Downloads common models (llama3.2:1b, mistral:7b, etc.)

# Create custom model from Modelfile
bash scripts/create-custom-model.sh <model-name> <modelfile-path>
# Example: bash scripts/create-custom-model.sh my-bot ./models/examples/chatbot/Modelfile

# List all models
make list-models
# Or: docker compose exec ollama ollama list

# Run model interactively
docker compose exec ollama ollama run <model-name>

# Export model's Modelfile (for version control/sharing)
bash scripts/export-model.sh <model-name> <output-path>

# Import external GGUF model
bash scripts/import-model.sh <model-name> <gguf-file-path>
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
make test           # Run validation tests
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
Optional NVIDIA GPU acceleration via Docker Compose deploy configuration (commented out by default). Requires NVIDIA Container Toolkit installation.

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
