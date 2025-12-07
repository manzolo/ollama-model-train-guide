.PHONY: help setup up down restart logs shell pull-base create-model list-models chat save-model deploy-model backup-models test quick-test clean

# Default target
help:
	@echo "Ollama Model Training Guide - Available Commands:"
	@echo ""
	@echo "  make setup        - Initial setup (copy .env.example to .env)"
	@echo "  make up           - Start Ollama service"
	@echo "  make down         - Stop Ollama service"
	@echo "  make restart      - Restart Ollama service"
	@echo "  make logs         - View Ollama logs"
	@echo "  make shell        - Access Ollama container shell"
	@echo "  make pull-base    - Pull common base models"
	@echo "  make create-model - Create a custom model (interactive)"
	@echo "  make list-models  - List all available models"
	@echo "  make chat         - Chat with a model (interactive)"
	@echo "  make save-model   - Save a model for deployment (interactive)"
	@echo "  make deploy-model - Deploy a saved model (interactive)"
	@echo "  make backup-models- Backup all custom models"
	@echo "  make test         - Run validation tests"
	@echo "  make quick-test   - Quick test: create, chat, and delete a model"
	@echo "  make clean        - Stop services and remove volumes"
	@echo ""

setup:
	@echo "🔧 Setting up environment..."
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "✅ Created .env file from .env.example"; \
	else \
		echo "⚠️  .env file already exists, skipping"; \
	fi
	@mkdir -p data/gguf data/adapters data/training models/custom models/saved
	@touch data/gguf/.gitkeep data/adapters/.gitkeep data/training/.gitkeep models/custom/.gitkeep models/saved/.gitkeep
	@chmod +x scripts/*.sh
	@echo "✅ Setup complete!"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Run 'make up' to start Ollama"
	@echo "  2. Run 'make pull-base' to download base models"

up:
	@echo "🚀 Starting Ollama service..."
	@docker compose up -d
	@echo "✅ Ollama is running on http://localhost:11434"

down:
	@echo "🛑 Stopping Ollama service..."
	@docker compose down

restart:
	@echo "🔄 Restarting Ollama service..."
	@docker compose restart

logs:
	@docker compose logs -f ollama

shell:
	@echo "🐚 Accessing Ollama container shell..."
	@docker compose exec ollama /bin/bash

pull-base:
	@bash scripts/pull-base-models.sh

create-model:
	@bash scripts/interactive-create-model.sh

list-models:
	@bash scripts/list-models.sh

chat:
	@bash scripts/interactive-chat.sh

save-model:
	@bash scripts/interactive-save-model.sh

deploy-model:
	@bash scripts/interactive-deploy-model.sh

backup-models:
	@bash scripts/backup-models.sh

test:
	@bash scripts/test.sh

quick-test:
	@bash scripts/quick-test.sh

clean:
	@echo "🧹 Cleaning up..."
	@echo "⚠️  This will remove all Docker volumes and models!"
	@read -p "Are you sure? (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		docker compose down -v; \
		echo "✅ Cleanup complete"; \
	else \
		echo "❌ Cleanup cancelled"; \
	fi
