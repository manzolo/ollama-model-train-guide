#!/bin/bash
# Interactive model deployment with saved Modelfile selection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

SAVED_DIR="./models/saved"

if [ ! -d "$SAVED_DIR" ]; then
    echo "❌ No saved models directory found at: $SAVED_DIR"
    exit 1
fi

echo "🚀 Deploy a saved model"
echo ""
echo "💾 Available saved models:"
echo ""

MODELFILE_PATH=""
pick_saved_modelfile MODELFILE_PATH "$SAVED_DIR"

# Get model name (optional)
echo ""
read -r -p "Enter model name (press Enter to use filename): " MODEL_NAME || MODEL_NAME=""

# Deploy the model
if [ -z "$MODEL_NAME" ]; then
    bash "$SCRIPT_DIR/deploy-model.sh" "$MODELFILE_PATH"
else
    bash "$SCRIPT_DIR/deploy-model.sh" "$MODELFILE_PATH" "$MODEL_NAME"
fi
