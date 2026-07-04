#!/bin/bash
# Deploy a saved model to the current Ollama instance

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Display usage
usage() {
    echo "Usage: $0 <modelfile-path> [model-name]"
    echo ""
    echo "Deploys a saved Modelfile to the current Ollama instance"
    echo ""
    echo "Arguments:"
    echo "  modelfile-path  - Path to the Modelfile"
    echo "  model-name      - (Optional) Name for the deployed model"
    echo ""
    echo "Examples:"
    echo "  $0 ./models/saved/my-chatbot.Modelfile"
    echo "  $0 ./models/saved/my-chatbot.Modelfile my-new-chatbot"
    exit 1
}

# Check arguments
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    usage
fi

MODELFILE_PATH=$1

# Extract model name from filename if not provided
if [ -z "${2:-}" ]; then
    FILENAME=$(basename "$MODELFILE_PATH")
    MODEL_NAME="${FILENAME%.Modelfile}"
    MODEL_NAME="${MODEL_NAME//_/\/}"
else
    MODEL_NAME=$2
fi

check_ollama_running

# Check if Modelfile exists
if [ ! -f "$MODELFILE_PATH" ]; then
    echo "❌ Error: Modelfile not found at: $MODELFILE_PATH"
    exit 1
fi

# Copy Modelfile to a location accessible by container
TEMP_DIR="./models/custom/temp-deploy"
mkdir -p "$TEMP_DIR"
trap 'rm -rf "$TEMP_DIR"' EXIT
cp "$MODELFILE_PATH" "$TEMP_DIR/Modelfile"

CONTAINER_PATH="/models/custom/temp-deploy/Modelfile"

echo "🚀 Deploying model: $MODEL_NAME"
echo "From: $MODELFILE_PATH"
echo ""

# Create the model
docker compose exec ollama ollama create "$MODEL_NAME" -f "$CONTAINER_PATH"

echo ""
echo "✅ Model deployed successfully!"
echo ""
echo "Test your model with:"
echo "  docker compose exec ollama ollama run $MODEL_NAME"
