# Ollama Model Training Guide

[![Documentation](https://img.shields.io/badge/docs-manzolo.github.io-teal?logo=materialformkdocs)](https://manzolo.github.io/ollama-model-train-guide/)
[![Test](https://github.com/manzolo/ollama-model-train-guide/actions/workflows/test.yml/badge.svg)](https://github.com/manzolo/ollama-model-train-guide/actions/workflows/test.yml)
[![Validate](https://github.com/manzolo/ollama-model-train-guide/actions/workflows/validate.yml/badge.svg)](https://github.com/manzolo/ollama-model-train-guide/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

🌐 **English** | [Italiano](./README.it.md)

A comprehensive Docker Compose project for creating, customizing, and managing Ollama models. Everything you need to work with lightweight local language models in a containerized environment, from basic customization to advanced model management.

<a href="https://www.buymeacoffee.com/manzolo">
  <img src=".github/blue-button.png" alt="Buy Me A Coffee" width="200">
</a>

## ✨ Features

- **Docker Compose Setup**: Easy-to-use containerized Ollama environment
- **🌐 Chat Web UI**: Modern web interface at `http://localhost:8080`
- **🧙 Modelfile Wizard**: Guided model creation at `http://localhost:8080/wizard`
- **📊 Spreadsheet Converter**: Convert Excel/CSV to JSONL training format
- **🔄 Model Pulling UI**: Pull models from Ollama library with real-time progress
- **📝 Example Modelfiles**: Pre-configured templates for common use cases
- **🛠️ Helper Scripts**: Convenient automation for common tasks
- **🎨 Model Customization**: Adjust parameters, prompts, and behavior
- **💾 Import/Export**: Share and version control your custom models
- **⚡ GPU Support**: Optional NVIDIA GPU acceleration via `make up-gpu`
- **💿 Persistent Storage**: Models survive container restarts

## 🚀 Quick Start

**New to Ollama?** Read [Essential Concepts](./docs/concepts.md) first (5 min read).

```bash
git clone https://github.com/manzolo/ollama-model-train-guide.git
cd ollama-model-train-guide

make preflight      # 1. Check system requirements
make setup          # 2. Create .env and directories
make up             # 3. Start Ollama + Chat UI
make create-model   # 4. Create your first custom model (interactive)
```

Then pull a base model and start chatting:

```bash
docker compose exec ollama ollama pull llama3.2:1b
open http://localhost:8080
```

That's it! 🎉

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/b4703c8f-8d34-4846-894d-699cb503efe9" />

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/ae737805-8df6-4d56-90e6-652dd4620844" />

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/51214062-044f-4f67-86e8-87a4cffe98a8" />

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/8f4d08f9-1740-4266-a04e-b28cf6b3b365" />

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/cd00f10a-cf6c-4504-a07f-7784c3e2bdd6" />

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/195a95de-8235-4145-b3df-8dd547e43d72" />

## 📖 Documentation

Also browsable as a website at **<https://manzolo.github.io/ollama-model-train-guide/>** (built with MkDocs from `docs/`).

Suggested reading order: start with **Concepts**, then follow the table top to bottom. Reference docs can be read as needed.

| # | Document | What it covers |
|---|----------|----------------|
| 1 | [Essential Concepts](./docs/concepts.md) ⭐ | Models, Modelfiles, parameters, choosing a base model, which method to use — **start here** |
| 2 | [Installation Guide](./docs/installation.md) | Prerequisites, setup, `.env` configuration, GPU support |
| 3 | [Chat Web UI](./docs/chat-ui.md) | Web interface: chat, model management, converter, Modelfile wizard |
| 4 | [Customization Guide](./docs/customization-guide.md) | System prompt vs few-shot vs fine-tuning — pick the right method |
| 5 | [Parameter Guide](./docs/parameter-guide.md) | Copy-paste parameter presets and tuning advice (canonical reference) |
| 6 | [Example Modelfiles](./docs/examples.md) | Pre-configured templates: chatbot, code assistant, translator, support bot |
| 7 | [Usage Guide](./docs/usage.md) | Day-to-day CLI commands and model operations |
| 8 | [Quick Reference](./docs/quick-reference.md) | Command cheat sheet and interactive menus |
| 9 | [Personal Model Guide](./docs/personal-model-guide.md) | Build a personalized assistant that knows your own information |
| 10 | [Dataset Training Example](./docs/dataset-training-example.md) | End-to-end example: build a support bot from a Q&A dataset |
| 11 | [Fine-Tuning Guide](./docs/fine-tuning-guide.md) | Deep-dive: fine-tune externally (Unsloth/HF), export GGUF, import into Ollama |
| 12 | [Modelfile Reference](./docs/modelfile-reference.md) | Complete Modelfile syntax reference |
| 13 | [API Usage Guide](./docs/api-usage.md) | Ollama REST API documentation |
| 14 | [Deployment Guide](./docs/deployment-guide.md) | Save, transfer, and deploy models between instances |
| 15 | [Advanced Usage](./docs/advanced-usage.md) | Templates, LoRA adapters, performance, monitoring, security |
| 16 | [Troubleshooting](./docs/troubleshooting.md) | Common issues and solutions |

## 🌐 Web UI

`make up` starts a Flask web app alongside Ollama with three pages:

- **Chat**: http://localhost:8080 — chat with any installed model, pull new models with real-time progress, create/edit Modelfiles
- **Converter**: http://localhost:8080/converter — convert Excel/CSV spreadsheets to JSONL training data
- **Wizard**: http://localhost:8080/wizard — guided 6-step Modelfile creation: pick a use case, base model, personality, rules, and examples, then create the model in one click

See the [Chat UI Guide](./docs/chat-ui.md) for details. To run Ollama without the web UI, use `make up-core`.

## 📁 Project Structure

```
ollama-model-train-guide/
├── docker-compose.yml      # Services: Ollama + Chat UI (profile "chat")
├── docker-compose.gpu.yml  # NVIDIA GPU override (make up-gpu)
├── .env                    # Ports, profiles, Ollama image tag
├── Makefile                # Convenient commands
├── LICENSE                 # MIT license
├── chat/                   # Web UI application
│   ├── app.py             # Flask app (chat + converter + wizard)
│   └── templates/         # HTML templates
├── models/
│   ├── examples/          # Pre-configured Modelfiles
│   ├── custom/            # Your custom Modelfiles
│   └── saved/             # Exported models
├── data/
│   ├── gguf/             # External GGUF files
│   ├── adapters/         # LoRA adapters
│   └── training/         # Training datasets
├── scripts/              # Helper scripts (shared library in scripts/lib/)
└── docs/                 # Documentation
```

## 🎯 Common Commands

### Environment Management

```bash
make preflight          # Check system requirements
make setup              # Initial setup (creates .env)
make up                 # Start services (Ollama + Chat UI)
make up-core            # Start Ollama only (no web UI)
make up-gpu             # Start with NVIDIA GPU support
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
make publish-model      # Publish model to external registry (interactive)
make backup-models      # Backup all custom models
make export-full        # Export model WITH weights to tar (interactive)
make import-full        # Import a full model archive (interactive)
```

### Testing

```bash
make quick-test         # Quick end-to-end test
make test               # Run validation tests
```

## 🌟 Popular Use Cases

### 1. Chat with Models

Open http://localhost:8080, select a model, and start chatting — or use `make chat` from the CLI. See the [Chat UI Guide](./docs/chat-ui.md).

### 2. Create Custom Models

- **Wizard** (easiest): open http://localhost:8080/wizard and follow the steps
- **Interactive CLI**: `make create-model` and pick a template
- **From scratch**: write a Modelfile in `./models/custom/my-model/` and run `bash scripts/create-custom-model.sh my-model ./models/custom/my-model/Modelfile`

See [Example Modelfiles](./docs/examples.md) and the [Modelfile Reference](./docs/modelfile-reference.md).

### 3. Pull Models with UI

Open http://localhost:8080, click "Manage Models", enter a name (e.g. `llama3.2:1b`), and watch real-time progress. Browse models at the [Ollama Library](https://ollama.com/library).

### 4. Convert Spreadsheets to Training Data

Open http://localhost:8080/converter, upload an Excel/CSV file, map the question/answer columns, and download or save the JSONL. See [Chat UI Guide - Converter](./docs/chat-ui.md#spreadsheet-to-jsonl-converter).

### 5. Train with Your Own Data

Prepare a JSONL dataset (or use the converter), add MESSAGE examples to a Modelfile, create the model, and iterate. See the [Dataset Training Example](./docs/dataset-training-example.md) and, for real fine-tuning, the [Fine-Tuning Guide](./docs/fine-tuning-guide.md).

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

# 4. Use in Web UI: open http://localhost:8080 and select "my-bot"
```

## 🧪 Testing

```bash
make quick-test                          # Quick end-to-end test
make test                                # Validation tests
bash scripts/test-techcorp-example.sh    # Test TechCorp dataset example
```

GitHub Actions automatically run tests on every push. See [.github/workflows/README.md](.github/workflows/README.md) for CI/CD details.

## 🚨 Troubleshooting

Having issues? Check the [Troubleshooting Guide](./docs/troubleshooting.md) for solutions to service startup problems, model creation errors, API connection issues, performance problems, disk space, and GPU configuration.

## 🎮 GPU Support

Enable NVIDIA GPU acceleration for 5-10x faster inference:

```bash
# 1. Install the NVIDIA Container Toolkit (see installation guide)
# 2. Start with the GPU override
make up-gpu
```

This layers `docker-compose.gpu.yml` on top of the base compose file — no editing of `docker-compose.yml` required. See [Installation Guide - GPU Support](./docs/installation.md#gpu-support-optional).

## 📚 Additional Resources

- [Ollama Official Documentation](https://ollama.com/docs)
- [Modelfile Specification](https://github.com/ollama/ollama/blob/main/docs/modelfile.md)
- [Available Models](https://ollama.com/library)
- [Ollama API Reference](https://github.com/ollama/ollama/blob/main/docs/api.md)

## 🤝 Contributing

Contributions are welcome! Add example Modelfiles, improve documentation, report issues, or suggest enhancements. All pull requests are automatically tested via GitHub Actions.

## 🧹 Cleanup

**Remove all containers and volumes** (deletes all models):
```bash
make clean
```

## 📄 License

This project is released under the MIT License — see [LICENSE](./LICENSE).

---

**Get started now**: `make preflight && make setup && make up` then open http://localhost:8080

---

## 🧠 Local AI Lab

[![Local AI Lab](https://img.shields.io/badge/🧠_Local_AI_Lab-member-6e40c9?style=for-the-badge)](https://github.com/manzolo/local-ai-lab)

This project is part of **[manzolo's Local AI Lab](https://github.com/manzolo/local-ai-lab)** — a family of self-hosted AI projects (LLM, voice, vision & documents) that share the same conventions and can be wired together through the shared `local-ai-net` Docker network.

Explore the whole family: [`topic:local-ai`](https://github.com/search?q=user%3Amanzolo+topic%3Alocal-ai&type=repositories)
