#!/bin/bash
# Create a custom Ollama model from a Modelfile

set -e

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

# Check if Ollama service is running
if ! docker compose ps | grep -qE "ollama.*(Up|running)"; then
    echo "❌ Error: Ollama service is not running"
    echo "Please start it with: docker compose up -d"
    exit 1
fi

# Check if Modelfile exists
if [ ! -f "$MODELFILE_PATH" ]; then
    echo "❌ Error: Modelfile not found at: $MODELFILE_PATH"
    exit 1
fi

# Get the Modelfile path relative to container
CONTAINER_PATH="/$(echo "$MODELFILE_PATH" | sed 's|^\./||')"

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
