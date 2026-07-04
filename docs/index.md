# Ollama Model Training Guide

A Docker Compose environment for creating, customizing, and managing [Ollama](https://ollama.com) language models — no GPU cluster required. Customize models with Modelfiles (like Dockerfiles, but for LLMs), experiment through a web UI, and deploy your creations to other instances.

## Quickstart

```bash
make preflight      # check system requirements
make setup          # create .env and directories
make up             # start Ollama + web UI
make create-model   # build your first custom model (interactive)
```

Then open:

- **Chat UI** — <http://localhost:8080>
- **Modelfile Wizard** — <http://localhost:8080/wizard>
- **Spreadsheet → JSONL Converter** — <http://localhost:8080/converter>
- **Ollama API** — <http://localhost:11434>

## Where to go next

| If you want to... | Read |
|---|---|
| Understand models, Modelfiles, and parameters | [Concepts](concepts.md) |
| Install and configure the environment | [Installation](installation.md) |
| Look up a command quickly | [Quick Reference](quick-reference.md) |
| Create a model without touching a terminal | [Web UI](chat-ui.md) |
| Pick between prompting, few-shot, and fine-tuning | [Choosing a Method](customization-guide.md) |
| Train on your own Q&A dataset | [Dataset Training Example](dataset-training-example.md) |
| Fix something that broke | [Troubleshooting](troubleshooting.md) |

The full source, issue tracker, and README live on [GitHub](https://github.com/manzolo/ollama-model-train-guide).
