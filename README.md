# Ollama Model Training Guide

A comprehensive Docker Compose project for training, customizing, and managing Ollama models. This guide provides everything you need to work with Ollama models in a containerized environment, from basic customization to advanced model management.

## 📋 Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Usage Guide](#usage-guide)
- [Example Modelfiles](#example-modelfiles)
- [Advanced Topics](#advanced-topics)
- [Troubleshooting](#troubleshooting)
- [GPU Support](#gpu-support)

## ✨ Features

- **Docker Compose Setup**: Easy-to-use containerized Ollama environment
- **Example Modelfiles**: Pre-configured templates for common use cases
- **Helper Scripts**: Convenient automation for common tasks
- **Model Customization**: Adjust parameters, prompts, and behavior
- **Import/Export**: Share and version control your custom models
- **GPU Support**: Optional NVIDIA GPU acceleration
- **Persistent Storage**: Models survive container restarts

## 🔧 Prerequisites

- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **Disk Space**: At least 10GB for base models
- **RAM**: Minimum 8GB (16GB recommended)
- **Optional**: NVIDIA GPU with Container Toolkit for GPU acceleration

## 🚀 Quick Start

1. **Clone or navigate to the project directory**:
   ```bash
   cd ollama-model-train-guide
   ```

2. **Run initial setup**:
   ```bash
   make setup
   ```
   This creates the `.env` file and necessary directories.

3. **Start Ollama**:
   ```bash
   make up
   ```
   Ollama will be available at `http://localhost:11434`

4. **Pull base models**:
   ```bash
   make pull-base
   ```
   This downloads common models like `llama3.2:1b`, `mistral:7b`, etc.

5. **Create your first custom model**:
   ```bash
   bash scripts/create-custom-model.sh my-chatbot ./models/examples/chatbot/Modelfile
   ```

6. **Test the model**:
   ```bash
   docker compose exec ollama ollama run my-chatbot "Tell me a joke"
   ```

## 📁 Project Structure

```
ollama-model-train-guide/
├── docker-compose.yml          # Docker Compose configuration
├── .env.example                # Environment variables template
├── Makefile                    # Convenient make commands
├── models/
│   ├── examples/              # Example Modelfiles
│   │   ├── chatbot/
│   │   ├── code-assistant/
│   │   ├── translator/
│   │   └── creative-writer/
│   └── custom/                # Your custom Modelfiles
├── scripts/
│   ├── pull-base-models.sh    # Download base models
│   ├── create-custom-model.sh # Create models from Modelfiles
│   ├── list-models.sh         # List available models
│   ├── export-model.sh        # Export model configurations
│   ├── import-model.sh        # Import GGUF models
│   └── test.sh                # Validation tests
├── data/
│   ├── gguf/                  # External GGUF model files
│   ├── adapters/              # LoRA adapter files
│   └── training/              # Training dataset documentation
└── docs/                      # Additional documentation
```

## 📖 Usage Guide

### Managing the Environment

**Start Ollama**:
```bash
make up
```

**Stop Ollama**:
```bash
make down
```

**View logs**:
```bash
make logs
```

**Access container shell**:
```bash
make shell
```

### Working with Models

**List all models**:
```bash
make list-models
# Or directly:
docker compose exec ollama ollama list
```

**Pull a specific model**:
```bash
docker compose exec ollama ollama pull llama3.2:3b
```

**Create a custom model**:
```bash
bash scripts/create-custom-model.sh <model-name> <modelfile-path>

# Example:
bash scripts/create-custom-model.sh my-assistant ./models/examples/code-assistant/Modelfile
```

**Run a model interactively**:
```bash
docker compose exec ollama ollama run my-assistant
```

**Use model via API**:
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "my-assistant",
  "prompt": "Write a Python function to calculate factorial",
  "stream": false
}'
```

### Exporting and Sharing Models

**Export a model's Modelfile**:
```bash
bash scripts/export-model.sh my-chatbot ./my-chatbot-modelfile
```

This creates a file you can:
- Edit to create variations
- Share with others
- Version control in Git
- Use to recreate the model

**Import an external GGUF model**:
```bash
# 1. Place your GGUF file in ./data/gguf/
# 2. Import it:
bash scripts/import-model.sh my-custom-model ./data/gguf/model.gguf
```

## 📝 Example Modelfiles

The project includes four pre-configured example Modelfiles:

### 1. Chatbot (`models/examples/chatbot/Modelfile`)
- **Purpose**: General conversational AI assistant
- **Temperature**: 0.7 (balanced)
- **Context**: 4096 tokens
- **Use case**: Customer service, Q&A, general chat

### 2. Code Assistant (`models/examples/code-assistant/Modelfile`)
- **Purpose**: Programming help and code generation
- **Temperature**: 0.3 (deterministic)
- **Context**: 8192 tokens
- **Use case**: Code writing, debugging, explanations

### 3. Translator (`models/examples/translator/Modelfile`)
- **Purpose**: Language translation
- **Temperature**: 0.5 (moderate)
- **Context**: 4096 tokens
- **Use case**: Text translation, localization

### 4. Creative Writer (`models/examples/creative-writer/Modelfile`)
- **Purpose**: Creative content generation
- **Temperature**: 1.2 (high creativity)
- **Context**: 8192 tokens
- **Use case**: Story writing, content creation

## 🎓 Advanced Topics

### Creating Custom Modelfiles

Create a new file `./models/custom/my-model/Modelfile`:

```dockerfile
# Base model
FROM llama3.2:1b

# Adjust parameters
PARAMETER temperature 0.8
PARAMETER num_ctx 4096
PARAMETER top_p 0.9

# Define behavior
SYSTEM """
You are a specialized assistant for [your use case].
[Define specific behavior, constraints, and personality]
"""
```

Then create the model:
```bash
bash scripts/create-custom-model.sh my-model ./models/custom/my-model/Modelfile
```

### Using LoRA Adapters

If you have a fine-tuned LoRA adapter:

1. Place the adapter in `./data/adapters/`
2. Create a Modelfile:
   ```dockerfile
   FROM llama3.2:1b
   ADAPTER /data/adapters/my-adapter.bin
   ```
3. Create the model as usual

### Model Parameters Reference

Key Modelfile parameters:

- **temperature** (0.0-2.0): Controls randomness
  - Lower (0.1-0.5): More focused, deterministic
  - Medium (0.6-0.9): Balanced
  - Higher (1.0-2.0): More creative, varied

- **num_ctx** (512-32768): Context window size in tokens

- **top_k** (1-100): Limits next token selection to top K

- **top_p** (0.0-1.0): Cumulative probability threshold

- **repeat_penalty** (0.0-2.0): Penalizes repetition

See [`docs/modelfile-reference.md`](./docs/modelfile-reference.md) for complete documentation.

### Integrating Fine-Tuned Models

For models fine-tuned externally (e.g., with Unsloth, Hugging Face):

1. Export your model to GGUF format
2. Place the GGUF file in `./data/gguf/`
3. Import using:
   ```bash
   bash scripts/import-model.sh my-finetuned-model ./data/gguf/model.gguf
   ```

See [`docs/fine-tuning-guide.md`](./docs/fine-tuning-guide.md) for detailed instructions.

## 🔍 Troubleshooting

### Ollama service won't start

**Check Docker is running**:
```bash
docker ps
```

**Check logs**:
```bash
make logs
```

**Restart services**:
```bash
make restart
```

### Model downloads fail

**Check disk space**:
```bash
df -h
```

**Check internet connection** and Docker network:
```bash
docker compose exec ollama ping -c 3 ollama.com
```

### Custom model creation fails

**Verify Modelfile syntax**:
```bash
docker compose exec ollama ollama create test -f /models/your-modelfile --dry-run
```

**Check base model exists**:
```bash
docker compose exec ollama ollama list
```

### API not accessible

**Verify port mapping**:
```bash
docker compose ps
netstat -an | grep 11434
```

**Test API directly**:
```bash
curl http://localhost:11434/api/tags
```

## 🎮 GPU Support

To enable NVIDIA GPU support:

1. **Install NVIDIA Container Toolkit**:
   ```bash
   # Ubuntu/Debian
   distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
   curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
   curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
       sudo tee /etc/apt/sources.list.d/nvidia-docker.list
   sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
   sudo systemctl restart docker
   ```

2. **Uncomment GPU configuration** in `docker-compose.yml`:
   ```yaml
   deploy:
     resources:
       reservations:
         devices:
           - driver: nvidia
             count: 1
             capabilities: [gpu]
   ```

3. **Restart services**:
   ```bash
   make restart
   ```

4. **Verify GPU is detected**:
   ```bash
   docker compose exec ollama nvidia-smi
   ```

## 📚 Additional Resources

- [Ollama Official Documentation](https://ollama.com/docs)
- [Modelfile Specification](https://github.com/ollama/ollama/blob/main/docs/modelfile.md)
- [Available Models](https://ollama.com/library)
- [Ollama API Reference](https://github.com/ollama/ollama/blob/main/docs/api.md)

## 🧪 Testing

Run validation tests:
```bash
make test
```

This will verify:
- Docker Compose configuration
- Service health
- Directory structure
- Example Modelfiles
- Model operations (optional)

## 🧹 Cleanup

**Remove all containers and volumes** (this deletes all models):
```bash
make clean
```

## 📄 License

This project is provided as-is for educational and development purposes.

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Add more example Modelfiles
- Improve documentation
- Report issues
- Suggest enhancements
