#!/bin/bash
# Import an external GGUF model into Ollama

set -e

# Display usage
usage() {
    echo "Usage: $0 <model-name> <gguf-file-path>"
    echo ""
    echo "The GGUF file should be placed in the ./data/gguf/ directory"
    echo ""
    echo "Examples:"
    echo "  $0 my-custom-model ./data/gguf/model.gguf"
    exit 1
}

# Check arguments
if [ $# -ne 2 ]; then
    usage
fi

MODEL_NAME=$1
GGUF_PATH=$2

# Check if Ollama service is running
if ! docker compose ps | grep -qE "ollama.*(Up|running)"; then
    echo "❌ Error: Ollama service is not running"
    echo "Please start it with: docker compose up -d"
    exit 1
fi

# Check if GGUF file exists
if [ ! -f "$GGUF_PATH" ]; then
    echo "❌ Error: GGUF file not found at: $GGUF_PATH"
    exit 1
fi

# Get the GGUF path relative to container
CONTAINER_PATH="/$(echo "$GGUF_PATH" | sed 's|^\./||')"

echo "📥 Importing GGUF model: $MODEL_NAME"
echo "📄 Using GGUF file: $GGUF_PATH"
echo ""

# Create a temporary Modelfile
TEMP_MODELFILE="/tmp/import-modelfile-$$"
cat > "$TEMP_MODELFILE" << EOF
FROM $CONTAINER_PATH

# Default parameters for imported model
PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_k 40
PARAMETER top_p 0.9
EOF

# Copy Modelfile to container accessible location
cp "$TEMP_MODELFILE" "./models/custom/temp-import-modelfile"

# Create the model
docker compose exec ollama ollama create "$MODEL_NAME" -f "/models/custom/temp-import-modelfile"

# Cleanup
rm -f "$TEMP_MODELFILE" "./models/custom/temp-import-modelfile"

echo ""
echo "✅ Model imported successfully!"
echo ""
echo "You can now customize it by exporting and editing the Modelfile:"
echo "  bash scripts/export-model.sh $MODEL_NAME"
echo ""
echo "Test your model with:"
echo "  docker compose exec ollama ollama run $MODEL_NAME"
