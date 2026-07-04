#!/bin/bash
# Create a custom Ollama model from a Modelfile

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Display usage
usage() {
    echo "Usage: $0 <model-name> <modelfile-path>"
    echo ""
    echo "Examples:"
    echo "  $0 my-chatbot ./models/examples/chatbot/Modelfile"
    echo "  $0 my-assistant ./models/custom/my-modelfile"
    exit 1
}

# Check arguments
if [ $# -ne 2 ]; then
    usage
fi

MODEL_NAME=$1
MODELFILE_PATH=$2

check_ollama_running

# Check if Modelfile exists
if [ ! -f "$MODELFILE_PATH" ]; then
    echo "❌ Error: Modelfile not found at: $MODELFILE_PATH"
    exit 1
fi

# Get the Modelfile path relative to container
CONTAINER_PATH="/${MODELFILE_PATH#./}"

echo "🔨 Creating custom model: $MODEL_NAME"
echo "📄 Using Modelfile: $MODELFILE_PATH"
echo ""

# Create the model
docker compose exec ollama ollama create "$MODEL_NAME" -f "$CONTAINER_PATH"

echo ""
echo "✅ Model created successfully!"
echo ""
echo "💬 Test your model with:"
echo "  make chat"
echo ""
echo "Or run it directly:"
echo "  docker compose exec ollama ollama run $MODEL_NAME"
echo ""
echo "Or via API:"
echo "  curl http://localhost:11434/api/generate -d '{\"model\":\"$MODEL_NAME\",\"prompt\":\"Hello\"}'"
