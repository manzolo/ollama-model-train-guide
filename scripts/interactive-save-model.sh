#!/bin/bash
# Interactive model saving with model selection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

check_ollama_running

echo "💾 Save a model for deployment"
echo ""
echo "📦 Available models:"
echo ""
echo "💡 Tip: Base models (llama3.2, mistral, etc.) are from Ollama library"
echo "   Custom models are the ones you created with 'make create-model'"
echo ""

MODEL_NAME=""
pick_model MODEL_NAME "Select a model" "Enter custom name" "Enter model name: " " ⭐ [likely custom]"

# Save the model
bash "$SCRIPT_DIR/save-model.sh" "$MODEL_NAME"
