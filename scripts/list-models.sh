#!/bin/bash
# List all available Ollama models

set -e

# Check if Ollama service is running
if ! docker compose ps | grep -qE "ollama.*(Up|running)"; then
    echo "❌ Error: Ollama service is not running"
    echo "Please start it with: docker compose up -d"
    exit 1
fi

echo "📋 Available Ollama models:"
echo ""

docker compose exec ollama ollama list
