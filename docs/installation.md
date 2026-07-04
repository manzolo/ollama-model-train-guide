# Installation Guide

## Quick Start (60 seconds)

```bash
# Clone and enter directory
git clone https://github.com/manzolo/ollama-model-train-guide.git
cd ollama-model-train-guide

# Check requirements, then setup and start services
make preflight
make setup && make up

# Pull a base model and test
docker compose exec ollama ollama pull llama3.2:1b
docker compose exec ollama ollama run llama3.2:1b "Hello!"
```

**Access the Web UI**: Open `http://localhost:8080` in your browser.

---

## Prerequisites

Before you begin, ensure your system meets these requirements:

- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **Disk Space**: At least 10GB for base models (more for larger models)
- **RAM**: Minimum 8GB (16GB recommended)
- **Optional**: NVIDIA GPU with Container Toolkit for GPU acceleration

### Check Your System

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker compose version

# Check available disk space
df -h

# Check available RAM
free -h
```

## Detailed Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/manzolo/ollama-model-train-guide.git
cd ollama-model-train-guide
```

### 2. Check System Requirements (Optional)

```bash
make preflight
```

This verifies Docker, Docker Compose, free disk space, and RAM before you start.

### 3. Run Initial Setup

This creates the `.env` file (from `.env.example`) and necessary directories:

```bash
make setup
```

### 4. Start Services

Start both Ollama and the Chat UI:

```bash
make up
```

This will start two services:
- **Ollama API**: Available at `http://localhost:11434`
- **Chat Web UI**: Available at `http://localhost:8080` (chat, converter, and Modelfile wizard)

To start Ollama **without** the web UI:

```bash
make up-core
```

To start with **NVIDIA GPU acceleration** (see [GPU Support](#gpu-support-optional)):

```bash
make up-gpu
```

### 5. Pull Base Models

Download common base models to get started:

```bash
make pull-base
```

This downloads:
- `llama3.2:1b` (small, fast)
- `llama3.2:3b` (balanced)
- `mistral:7b` (high quality)
- `phi3:mini` (compact)

Alternatively, pull models via the Web UI:
1. Open `http://localhost:8080`
2. Click "Manage Models"
3. Enter model name (e.g., `llama3.2:1b`)
4. Click "Pull" and watch real-time progress

### 6. Verify Installation

Check that everything is working:

```bash
# List available models
make list-models

# Run quick test
make quick-test

# Check service status
docker compose ps
```

You should see both `ollama` and `ollama-chat` services running.

## GPU Support (Optional)

To enable NVIDIA GPU acceleration for faster inference:

### 1. Install NVIDIA Container Toolkit

**Ubuntu/Debian**:
```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
    sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

**Fedora/RHEL/CentOS**:
```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | \
    sudo tee /etc/yum.repos.d/nvidia-docker.repo

sudo yum install -y nvidia-container-toolkit
sudo systemctl restart docker
```

### 2. Start with the GPU Override

GPU support is provided by a separate Compose override file, `docker-compose.gpu.yml` — there is nothing to uncomment or edit in `docker-compose.yml`:

```bash
make up-gpu

# Equivalent to:
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
```

The override reserves all available NVIDIA GPUs for the Ollama service:

```yaml
# docker-compose.gpu.yml
services:
  ollama:
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
```

### 3. Verify GPU Detection

Check that the GPU is available inside the container:

```bash
docker compose exec ollama nvidia-smi
```

You should see your GPU listed with memory usage and driver information.

### Performance Benefits

With GPU acceleration:
- **Inference Speed**: 5-10x faster for large models
- **Context Processing**: Significantly faster for long prompts
- **Concurrent Users**: Better performance with multiple requests

## Environment Configuration

The `.env` file (created by `make setup` from `.env.example`) contains the configuration options. These values are interpolated directly into `docker-compose.yml` (e.g. the Ollama port mapping is `"${OLLAMA_PORT:-11434}:11434"`):

```bash
# Host port for the Ollama API
OLLAMA_PORT=11434

# Host port for the Chat web UI
CHAT_PORT=8080

# Compose profiles started by default with `docker compose up`.
# Set to empty (COMPOSE_PROFILES=) to run Ollama only, without the chat web UI.
COMPOSE_PROFILES=chat

# Which origins may call the Ollama API (CORS). "*" is fine for local use.
OLLAMA_ORIGINS=*

# Pin a specific Ollama version instead of "latest" for reproducible setups,
# e.g. OLLAMA_IMAGE_TAG=0.30.10
OLLAMA_IMAGE_TAG=latest
```

After editing `.env`, recreate the containers for the changes to take effect:

```bash
make down && make up
```

## Directory Structure

After setup, your project will have this structure:

```
ollama-model-train-guide/
├── .env                    # Environment variables (ports, profiles, image tag)
├── docker-compose.yml      # Service configuration
├── docker-compose.gpu.yml  # NVIDIA GPU override (make up-gpu)
├── models/
│   ├── examples/          # Pre-configured Modelfiles
│   ├── custom/            # Your custom Modelfiles
│   └── saved/             # Exported models
├── data/
│   ├── gguf/             # External GGUF files
│   ├── adapters/         # LoRA adapters
│   └── training/         # Training datasets
└── chat/                  # Web UI application
```

## Next Steps

- [Usage Guide](./usage.md) - Learn how to work with models
- [Chat UI Guide](./chat-ui.md) - Use the web interface
- [Creating Custom Models](./modelfile-reference.md) - Customize your models
- [Examples](./examples.md) - Pre-configured templates

## Troubleshooting Installation

### Docker daemon not running

```bash
# Start Docker service
sudo systemctl start docker

# Enable Docker at boot
sudo systemctl enable docker
```

### Permission denied errors

Add your user to the docker group:

```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

### Port already in use

If port 11434 or 8080 is already in use, edit `.env` to use different ports:

```bash
OLLAMA_PORT=11435
CHAT_PORT=8081
```

Then recreate the containers:

```bash
make down && make up
```

### Insufficient disk space

Check and clean up Docker resources:

```bash
# Check disk usage
docker system df

# Clean up unused resources
docker system prune -a

# Remove old images
docker image prune -a
```

For more troubleshooting help, see [Troubleshooting Guide](./troubleshooting.md).
