#!/bin/bash
# Interactive chat with model selection

set -e

# Check if Ollama service is running
if ! docker compose ps | grep -qE "ollama.*(Up|running)"; then
    echo "❌ Error: Ollama service is not running"
    echo "Please start it with: docker compose up -d"
    exit 1
fi

echo "💬 Chat with a model"
echo ""
echo "📦 Available models:"
echo ""

# Get list of all models
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

    # Highlight custom models
    if [[ ! "$MODEL_NAME" =~ : ]]; then
        echo "  [$INDEX] $MODEL_NAME ($MODEL_SIZE) ⭐"
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
echo "  [0] Cancel"
echo ""
read -p "Select a model to chat with [0-$((INDEX-1))]: " SELECTION

# Validate input
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 0 ] || [ "$SELECTION" -ge "$INDEX" ]; then
    echo "❌ Invalid selection"
    exit 1
fi

if [ "$SELECTION" -eq 0 ]; then
    echo "Cancelled"
    exit 0
fi

MODEL_NAME="${MODELS[$((SELECTION-1))]}"

echo ""
echo "🚀 Starting chat with: $MODEL_NAME"
echo ""
echo "💡 Tips:"
echo "   - Type your messages and press Enter"
echo "   - Use /bye to exit the chat"
echo "   - Use Ctrl+D to exit"
echo ""
echo "───────────────────────────────────────────────────────"
echo ""

# Start interactive chat
docker compose exec -it ollama ollama run "$MODEL_NAME"

echo ""
echo "👋 Chat ended"
