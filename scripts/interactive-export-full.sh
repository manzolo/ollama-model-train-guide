#!/bin/bash
# Interactive full model export (weights included) with model selection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

check_ollama_running

echo "📦 Export a model WITH its weights (tar archive)"
echo ""
echo "📦 Available models:"
echo ""
echo "💡 Tip: the archive includes the model weights (can be several GB)."
echo "   For a lightweight recipe-only export, use 'make save-model' instead."
echo ""

MODEL_NAME=""
pick_model MODEL_NAME "Select a model" "Enter custom name" "Enter model name: " " ⭐ [likely custom]"

bash "$SCRIPT_DIR/export-model-full.sh" "$MODEL_NAME"
