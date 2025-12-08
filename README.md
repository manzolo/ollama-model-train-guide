# Ollama Model Training Guide

A comprehensive Docker Compose project for training, customizing, and managing Ollama models. This guide provides everything you need to work with Ollama models in a containerized environment, from basic customization to advanced model management.

<a href="https://www.buymeacoffee.com/manzolo">
  <img src=".github/blue-button.png" alt="Buy Me A Coffee" width="200">
</a>

## ✨ Features

- **Docker Compose Setup**: Easy-to-use containerized Ollama environment
- **🌐 Chat Web UI**: Modern web interface at `http://localhost:8080`
- **📊 Spreadsheet Converter**: Convert Excel/CSV to JSONL training format
- **🔄 Model Pulling UI**: Pull models from Ollama library with real-time progress
- **📝 Example Modelfiles**: Pre-configured templates for common use cases
- **🛠️ Helper Scripts**: Convenient automation for common tasks
- **🎨 Model Customization**: Adjust parameters, prompts, and behavior
- **💾 Import/Export**: Share and version control your custom models
- **⚡ GPU Support**: Optional NVIDIA GPU acceleration
- **💿 Persistent Storage**: Models survive container restarts

## 🚀 Quick Start (60 seconds)

```bash
# Clone and setup
git clone https://github.com/manzolo/ollama-model-train-guide.git
cd ollama-model-train-guide
make setup && make up

# Pull a base model
docker compose exec ollama ollama pull llama3.2:1b

# Access the Web UI
open http://localhost:8080
```

That's it! 🎉 Start chatting with your models or [learn more about installation](./docs/installation.md).
  
<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/b4703c8f-8d34-4846-894d-699cb503efe9" />

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/ae737805-8df6-4d56-90e6-652dd4620844" />

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/51214062-044f-4f67-86e8-87a4cffe98a8" />

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/8f4d08f9-1740-4266-a04e-b28cf6b3b365" />

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/cd00f10a-cf6c-4504-a07f-7784c3e2bdd6" />

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/195a95de-8235-4145-b3df-8dd547e43d72" />

## 📖 Documentation

### Getting Started

- **[Installation Guide](./docs/installation.md)** - Prerequisites, setup, and GPU support
- **[Usage Guide](./docs/usage.md)** - Managing environment and working with models
- **[Chat Web UI](./docs/chat-ui.md)** - Using the web interface, converter, and model management
- **[Troubleshooting](./docs/troubleshooting.md)** - Common issues and solutions

### Working with Models

- **[Example Modelfiles](./docs/examples.md)** - Pre-configured templates (chatbot, code assistant, translator, etc.)
- **[Modelfile Reference](./docs/modelfile-reference.md)** - Complete Modelfile syntax and parameters
- **[Dataset Training Example](./docs/dataset-training-example.md)** - Train models with custom datasets
- **[Advanced Usage](./docs/advanced-usage.md)** - Fine-tuning, LoRA adapters, and more

### API and Integration

- **[API Usage Guide](./docs/api-usage.md)** - REST API documentation
- **[Quick Reference](./docs/quick-reference.md)** - Command cheat sheet
- **[Deployment Guide](./docs/deployment-guide.md)** - Deploy to production

## 📁 Project Structure

```
ollama-model-train-guide/
├── docker-compose.yml      # Services: Ollama + Chat UI
├── .env                    # Environment configuration
├── Makefile                # Convenient commands
├── chat/                   # Web UI application
│   ├── app.py             # Flask app (chat + converter)
│   └── templates/         # HTML templates
├── models/
│   ├── examples/          # Pre-configured Modelfiles
│   │   ├── chatbot/
│   │   ├── code-assistant/
│   │   ├── translator/
│   │   ├── creative-writer/
│   │   ├── personal-assistant/
│   │   └── techcorp-support/
│   ├── custom/            # Your custom Modelfiles
│   └── saved/             # Exported models
├── data/
│   ├── gguf/             # External GGUF files
│   ├── adapters/         # LoRA adapters
│   └── training/         # Training datasets
├── scripts/              # Helper scripts
└── docs/                 # Documentation
```

## 🎯 Common Commands

### Environment Management

```bash
make setup              # Initial setup
make up                 # Start services (Ollama + Chat UI)
make down               # Stop services
make restart            # Restart all services
make logs               # View logs
```

### Model Operations

```bash
make pull-base          # Pull common base models
make create-model       # Create custom model (interactive)
make chat               # Chat with a model (interactive)
make list-models        # List all models
make save-model         # Save model for deployment (interactive)
make deploy-model       # Deploy saved model (interactive)
```

### Testing

```bash
make quick-test         # Quick end-to-end test
make test               # Run validation tests
```

### Access Points

- **Ollama API**: http://localhost:11434
- **Chat Web UI**: http://localhost:8080
- **Converter**: http://localhost:8080/converter (or via Chat sidebar)

## 🌟 Popular Use Cases

### 1. Chat with Models

**Via Web UI** (easiest):
1. Open http://localhost:8080
2. Select a model from dropdown
3. Start chatting!

**Via CLI**:
```bash
make chat
# Select your model and start chatting
```

See [Chat UI Guide](./docs/chat-ui.md) for features and tips.

### 2. Create Custom Models

**Interactive**:
```bash
make create-model
# Select from example templates
```

**From scratch**:
1. Create a Modelfile in `./models/custom/my-model/Modelfile`
2. Run: `bash scripts/create-custom-model.sh my-model ./models/custom/my-model/Modelfile`

See [Example Modelfiles](./docs/examples.md) for templates and [Modelfile Reference](./docs/modelfile-reference.md) for syntax.

### 3. Pull Models with UI

1. Open http://localhost:8080
2. Click "Manage Models"
3. Enter model name (e.g., `llama3.2:1b`, `mistral:7b`)
4. Click "Pull Model"
5. Watch real-time progress with download speed and ETA

See all available models at [Ollama Library](https://ollama.com/library).

### 4. Convert Spreadsheets to Training Data

1. Open http://localhost:8080/converter
2. Upload Excel (.xlsx, .xls) or CSV file
3. Map question/answer columns
4. Preview and convert to JSONL
5. Use in your Modelfiles

See [Chat UI Guide - Converter](./docs/chat-ui.md#spreadsheet-to-jsonl-converter) for details.

### 5. Train with Your Own Data

1. Prepare a JSONL dataset (or use the converter)
2. Create a Modelfile with MESSAGE examples
3. Create the model
4. Test and iterate

See [Dataset Training Example](./docs/dataset-training-example.md) for a complete guide using the TechCorp support bot example.

## 🔧 Example: Creating a Custom Chatbot

```bash
# 1. Create a Modelfile
mkdir -p ./models/custom/my-bot
cat > ./models/custom/my-bot/Modelfile << 'EOF'
FROM llama3.2:1b

PARAMETER temperature 0.7
PARAMETER num_ctx 4096

SYSTEM """
You are a friendly customer service assistant for ACME Corp.
Be helpful, professional, and concise.
"""

MESSAGE user "What are your hours?"
MESSAGE assistant "We're open Monday-Friday, 9am-6pm EST."
EOF

# 2. Create the model
bash scripts/create-custom-model.sh my-bot ./models/custom/my-bot/Modelfile

# 3. Test it
docker compose exec ollama ollama run my-bot "Hello!"

# 4. Use in Web UI
# Open http://localhost:8080 and select "my-bot" from dropdown
```

## 🎓 Learning Resources

### For Beginners
1. [Installation Guide](./docs/installation.md) - Get started
2. [Usage Guide](./docs/usage.md) - Learn basic commands
3. [Example Modelfiles](./docs/examples.md) - See pre-configured templates
4. [Chat UI Guide](./docs/chat-ui.md) - Use the web interface

### For Advanced Users
1. [Modelfile Reference](./docs/modelfile-reference.md) - Master Modelfile syntax
2. [Dataset Training Example](./docs/dataset-training-example.md) - Train with custom data
3. [Advanced Usage](./docs/advanced-usage.md) - Fine-tuning and LoRA adapters
4. [API Usage Guide](./docs/api-usage.md) - Integrate into applications

## 🧪 Testing

Run automated tests to verify everything works:

```bash
# Quick end-to-end test
make quick-test

# Validation tests
make test

# Test TechCorp dataset example
bash scripts/test-techcorp-example.sh
```

GitHub Actions automatically run tests on every push. See [.github/workflows/README.md](.github/workflows/README.md) for CI/CD details.

## 🚨 Troubleshooting

Having issues? Check the [Troubleshooting Guide](./docs/troubleshooting.md) for solutions to:
- Service startup problems
- Model creation errors
- API connection issues
- Performance problems
- Disk space issues
- GPU configuration

## 🎮 GPU Support

Enable NVIDIA GPU acceleration for 5-10x faster inference:

```bash
# 1. Install NVIDIA Container Toolkit
# (see installation guide for commands)

# 2. Uncomment GPU config in docker-compose.yml
# 3. Restart services
make restart
```

See [Installation Guide - GPU Support](./docs/installation.md#gpu-support-optional) for detailed instructions.

## 📚 Additional Resources

- [Ollama Official Documentation](https://ollama.com/docs)
- [Modelfile Specification](https://github.com/ollama/ollama/blob/main/docs/modelfile.md)
- [Available Models](https://ollama.com/library)
- [Ollama API Reference](https://github.com/ollama/ollama/blob/main/docs/api.md)

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Add more example Modelfiles
- Improve documentation
- Report issues
- Suggest enhancements

All pull requests are automatically tested via GitHub Actions.

## 🧹 Cleanup

**Remove all containers and volumes** (deletes all models):
```bash
make clean
```

## 📄 License

This project is provided as-is for educational and development purposes.

---

## Quick Links

| Documentation | Description |
|--------------|-------------|
| [Installation](./docs/installation.md) | Prerequisites, setup, GPU support |
| [Usage Guide](./docs/usage.md) | Commands and model operations |
| [Chat UI](./docs/chat-ui.md) | Web interface and converter |
| [Examples](./docs/examples.md) | Pre-configured templates |
| [Troubleshooting](./docs/troubleshooting.md) | Common issues and solutions |
| [Modelfile Reference](./docs/modelfile-reference.md) | Complete syntax guide |
| [Dataset Training](./docs/dataset-training-example.md) | Train with custom data |
| [Advanced Usage](./docs/advanced-usage.md) | Fine-tuning and adapters |
| [API Guide](./docs/api-usage.md) | REST API documentation |
| [Quick Reference](./docs/quick-reference.md) | Command cheat sheet |

---

**Get started now**: `make setup && make up` then open http://localhost:8080
