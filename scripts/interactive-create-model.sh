#!/bin/bash
# Interactive model creation with Modelfile selection

set -e

echo "🔨 Create a custom model"
echo ""
echo "📁 Available Modelfiles:"
echo ""

# Find all Modelfiles in examples and custom directories
MODELFILES=()
INDEX=1

# Search in examples
if [ -d "./models/examples" ]; then
    while IFS= read -r file; do
        MODELFILES+=("$file")
        DISPLAY_NAME=$(echo "$file" | sed 's|^\./models/||')
        echo "  [$INDEX] $DISPLAY_NAME"
        ((INDEX++))
    done < <(find ./models/examples -name "Modelfile" -type f | sort)
fi

# Search in custom
if [ -d "./models/custom" ]; then
    while IFS= read -r file; do
        MODELFILES+=("$file")
        DISPLAY_NAME=$(echo "$file" | sed 's|^\./models/||')
        echo "  [$INDEX] $DISPLAY_NAME"
        ((INDEX++))
    done < <(find ./models/custom -name "Modelfile" -type f | sort)
fi

if [ ${#MODELFILES[@]} -eq 0 ]; then
    echo "  No Modelfiles found in models/examples or models/custom"
    exit 1
fi

echo ""
echo "  [0] Enter custom path"
echo ""
read -p "Select a Modelfile [0-$((INDEX-1))]: " SELECTION

# Validate input
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 0 ] || [ "$SELECTION" -ge "$INDEX" ]; then
    echo "❌ Invalid selection"
    exit 1
fi

if [ "$SELECTION" -eq 0 ]; then
    read -p "Enter path to Modelfile: " MODELFILE_PATH
else
    MODELFILE_PATH="${MODELFILES[$((SELECTION-1))]}"
fi

# Get model name
echo ""
read -p "Enter name for the new model: " MODEL_NAME

if [ -z "$MODEL_NAME" ]; then
    echo "❌ Model name cannot be empty"
    exit 1
fi

# Create the model
bash scripts/create-custom-model.sh "$MODEL_NAME" "$MODELFILE_PATH"

# Ask if user wants to chat now
echo ""
read -p "Would you like to chat with $MODEL_NAME now? (y/N): " CHAT_NOW

if [ "$CHAT_NOW" = "y" ] || [ "$CHAT_NOW" = "Y" ]; then
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
    docker compose exec -it ollama ollama run "$MODEL_NAME"
    echo ""
    echo "👋 Chat ended"
fi
