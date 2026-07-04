#!/bin/bash
# Interactive model creation with Modelfile selection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

echo "🔨 Create a custom model"
echo ""
echo "📁 Available Modelfiles:"
echo ""

MODELFILE_PATH=""
pick_modelfile MODELFILE_PATH

# Get model name
echo ""
read -r -p "Enter name for the new model: " MODEL_NAME || MODEL_NAME=""

if [ -z "$MODEL_NAME" ]; then
    echo "❌ Model name cannot be empty"
    exit 1
fi

# Create the model
bash "$SCRIPT_DIR/create-custom-model.sh" "$MODEL_NAME" "$MODELFILE_PATH"

# Ask if user wants to chat now
echo ""
read -r -p "Would you like to chat with $MODEL_NAME now? (y/N): " CHAT_NOW || CHAT_NOW=""

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
