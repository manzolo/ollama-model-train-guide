#!/bin/bash
# Export a model's Modelfile configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Display usage
usage() {
    echo "Usage: $0 <model-name> [output-file]"
    echo ""
    echo "Examples:"
    echo "  $0 my-chatbot"
    echo "  $0 my-chatbot ./exported-modelfile"
    exit 1
}

# Check arguments
if [ $# -lt 1 ]; then
    usage
fi

MODEL_NAME=$1
OUTPUT_FILE=${2:-"${MODEL_NAME}-modelfile"}

check_ollama_running

echo "📤 Exporting Modelfile for: $MODEL_NAME"
echo "💾 Saving to: $OUTPUT_FILE"
echo ""

# Export the Modelfile
docker compose exec ollama ollama show "$MODEL_NAME" --modelfile > "$OUTPUT_FILE"

echo "✅ Modelfile exported successfully!"
echo ""
echo "You can now:"
echo "  - Edit the Modelfile to customize it further"
echo "  - Share it with others"
echo "  - Use it to create a new model variant"
echo ""
echo "To create a new model from this Modelfile:"
echo "  bash scripts/create-custom-model.sh new-model-name $OUTPUT_FILE"
