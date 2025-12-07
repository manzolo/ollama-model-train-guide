#!/bin/bash
# Helper script to select an existing model interactively

set -e

# Check if Ollama service is running
if ! docker compose ps | grep -qE "ollama.*(Up|running)"; then
    echo "❌ Error: Ollama service is not running" >&2
    echo "Please start it with: docker compose up -d" >&2
    exit 1
fi

echo "📦 Available models:" >&2
echo "" >&2
echo "💡 Tip: Base models (llama3.2, mistral, etc.) are from Ollama library" >&2
echo "   Custom models are the ones you created with 'make create-model'" >&2
echo "" >&2

# Get list of all models with size info
MODELS=()
INDEX=1

while IFS= read -r line; do
    # Skip empty lines and header
    [ -z "$line" ] && continue
    [[ "$line" =~ ^NAME ]] && continue

    MODEL_NAME=$(echo "$line" | awk '{print $1}')
    MODEL_SIZE=$(echo "$line" | awk '{print $2}')
    [ -z "$MODEL_NAME" ] && continue

    MODELS+=("$MODEL_NAME")

    # Try to identify if it's likely a custom model (doesn't contain ':' usually means custom)
    if [[ ! "$MODEL_NAME" =~ : ]]; then
        echo "  [$INDEX] $MODEL_NAME ($MODEL_SIZE) ⭐ [likely custom]" >&2
    else
        echo "  [$INDEX] $MODEL_NAME ($MODEL_SIZE)" >&2
    fi
    ((INDEX++))
done < <(docker compose exec ollama ollama list)

if [ ${#MODELS[@]} -eq 0 ]; then
    echo "  No models found" >&2
    echo "" >&2
    echo "Pull a base model first:" >&2
    echo "  make pull-base" >&2
    exit 1
fi

echo "" >&2
echo "  [0] Enter custom name" >&2
echo "" >&2
read -p "Select a model [0-$((INDEX-1))]: " SELECTION

# Validate input
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 0 ] || [ "$SELECTION" -ge "$INDEX" ]; then
    echo "❌ Invalid selection" >&2
    exit 1
fi

if [ "$SELECTION" -eq 0 ]; then
    read -p "Enter model name: " CUSTOM_NAME
    echo "$CUSTOM_NAME"
else
    SELECTED_MODEL="${MODELS[$((SELECTION-1))]}"
    echo "$SELECTED_MODEL"
fi
