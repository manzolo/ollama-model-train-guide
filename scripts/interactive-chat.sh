#!/bin/bash
# Interactive chat with model selection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

check_ollama_running

echo "💬 Chat with a model"
echo ""
echo "📦 Available models:"
echo ""

MODEL_NAME=""
pick_model MODEL_NAME "Select a model to chat with" "Cancel" "" " ⭐"

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
