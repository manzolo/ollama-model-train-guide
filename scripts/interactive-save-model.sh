#!/bin/bash
# Interactive model saving with model selection

set -e

# Check if Ollama service is running
if ! docker compose ps | grep -qE "ollama.*(Up|running)"; then
    echo "❌ Error: Ollama service is not running"
    echo "Please start it with: docker compose up -d"
    exit 1
fi

echo "💾 Save a model for deployment"
echo ""
echo "📦 Available models:"
echo ""
echo "💡 Tip: Base models (llama3.2, mistral, etc.) are from Ollama library"
echo "   Custom models are the ones you created with 'make create-model'"
echo ""

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
        echo "  [$INDEX] $MODEL_NAME ($MODEL_SIZE) ⭐ [likely custom]"
    else
        echo "  [$INDEX] $MODEL_NAME ($MODEL_SIZE)"
    fi
    ((INDEX++))
done < <(docker compose exec ollama ollama list)

if [ ${#MODELS[@]} -eq 0 ]; then
    echo "  No models found"
    echo ""
    echo "Pull a base model first:"
    echo "  make pull-base"
    exit 1
fi

echo ""
echo "  [0] Enter custom name"
echo ""
read -p "Select a model [0-$((INDEX-1))]: " SELECTION

# Validate input
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 0 ] || [ "$SELECTION" -ge "$INDEX" ]; then
    echo "❌ Invalid selection"
    exit 1
fi

if [ "$SELECTION" -eq 0 ]; then
    read -p "Enter model name: " MODEL_NAME
else
    MODEL_NAME="${MODELS[$((SELECTION-1))]}"
fi

# Save the model
bash scripts/save-model.sh "$MODEL_NAME"
