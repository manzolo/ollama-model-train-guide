#!/bin/bash
# Pull common base models for Ollama

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

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

check_ollama_running

# Pull each model
for model in "${MODELS[@]}"; do
    pull_model "$model"
done

echo "✨ All models pulled successfully!"
echo ""
echo "Available models:"
docker compose exec ollama ollama list
