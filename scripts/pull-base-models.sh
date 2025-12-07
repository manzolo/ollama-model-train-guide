#!/bin/bash
# Pull common base models for Ollama

set -e

echo "🚀 Pulling common base models for Ollama..."
echo ""

# Array of common models to pull
MODELS=(
    "llama3.2:1b"
    "llama3.2:3b"
    "mistral:7b"
    "phi3:mini"
)

# Function to pull a model
pull_model() {
    local model=$1
    echo "📥 Pulling model: $model"
    docker compose exec ollama ollama pull "$model"
    echo "✅ Successfully pulled: $model"
    echo ""
}

# Check if Ollama service is running
if ! docker compose ps | grep -qE "ollama.*(Up|running)"; then
    echo "❌ Error: Ollama service is not running"
    echo "Please start it with: docker compose up -d"
    exit 1
fi

# Pull each model
for model in "${MODELS[@]}"; do
    pull_model "$model"
done

echo "✨ All models pulled successfully!"
echo ""
echo "Available models:"
docker compose exec ollama ollama list
