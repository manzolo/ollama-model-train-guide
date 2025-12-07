#!/bin/bash
# Save a model for deployment to another Ollama instance

set -e

# Display usage
usage() {
    echo "Usage: $0 <model-name> [output-directory]"
    echo ""
    echo "Saves a model's Modelfile for deployment to another Ollama instance"
    echo ""
    echo "Arguments:"
    echo "  model-name        - Name of the model to save"
    echo "  output-directory  - (Optional) Directory to save files (default: ./models/saved)"
    echo ""
    echo "Examples:"
    echo "  $0 my-chatbot"
    echo "  $0 my-assistant ./backups/models"
    exit 1
}

# Check arguments
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    usage
fi

MODEL_NAME=$1
OUTPUT_DIR=${2:-./models/saved}

# Check if Ollama service is running
if ! docker compose ps | grep -qE "ollama.*(Up|running)"; then
    echo "❌ Error: Ollama service is not running"
    echo "Please start it with: docker compose up -d"
    exit 1
fi

# Check if model exists
if ! docker compose exec ollama ollama list | grep -q "^$MODEL_NAME"; then
    echo "❌ Error: Model '$MODEL_NAME' not found"
    echo ""
    echo "Available models:"
    docker compose exec ollama ollama list
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="$OUTPUT_DIR/${MODEL_NAME//\//_}.Modelfile"

echo "💾 Saving model: $MODEL_NAME"
echo "Output: $OUTPUT_FILE"
echo ""

# Show model info first
echo "Model details:"
docker compose exec ollama ollama show "$MODEL_NAME" 2>/dev/null | head -10 || echo "  (Unable to show details)"
echo ""

# Export the Modelfile
docker compose exec ollama ollama show "$MODEL_NAME" --modelfile > "$OUTPUT_FILE"

if [ ! -s "$OUTPUT_FILE" ]; then
    echo "❌ Failed to save model or model is empty"
    echo ""
    echo "This might be a base model from Ollama library."
    echo "Only custom models you created can be saved for deployment."
    rm -f "$OUTPUT_FILE"
    exit 1
fi

echo "✅ Model saved successfully!"
echo ""
echo "📄 Saved Modelfile content preview:"
head -5 "$OUTPUT_FILE"
echo "..."
echo ""
echo "To deploy this model on another Ollama instance:"
echo "  1. Copy the Modelfile to the target instance"
echo "  2. Run: make deploy-model"
echo ""
echo "Or use the deploy script directly:"
echo "  bash scripts/deploy-model.sh $OUTPUT_FILE $MODEL_NAME"
