#!/bin/bash
# Export a model WITH its weights (manifest + blobs) to a portable tar archive.
#
# Unlike save-model.sh (Modelfile recipe only), the resulting archive contains
# everything needed to run the model on another instance, with no re-download
# of the base model — useful for air-gapped or slow-connection targets.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

OLLAMA_MODELS_DIR="/root/.ollama/models"

usage() {
    echo "Usage: $0 <model-name> [output-directory]"
    echo ""
    echo "Exports a model INCLUDING its weights to a tar archive"
    echo ""
    echo "Arguments:"
    echo "  model-name        - Name of the model to export (e.g. my-bot, llama3.2:1b)"
    echo "  output-directory  - (Optional) Directory for the archive (default: ./backups/full)"
    echo ""
    echo "Examples:"
    echo "  $0 my-chatbot"
    echo "  $0 llama3.2:1b ./exports"
    echo ""
    echo "Note: archives include model weights and can be several GB in size."
    echo "For a lightweight recipe-only export, use: make save-model"
    exit 1
}

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    usage
fi

MODEL_NAME=$1
OUTPUT_DIR=${2:-./backups/full}

# The name is interpolated into container-side paths: allow only the
# characters valid in Ollama model references.
if ! [[ "$MODEL_NAME" =~ ^[A-Za-z0-9._/:-]+$ ]]; then
    echo "❌ Error: Invalid model name: $MODEL_NAME"
    exit 1
fi

check_ollama_running

if ! model_exists "$MODEL_NAME"; then
    echo "❌ Error: Model '$MODEL_NAME' not found"
    echo ""
    echo "Available models:"
    docker compose exec ollama ollama list
    exit 1
fi

# Split name:tag (tag defaults to latest, as Ollama does)
TAG="latest"
NAME="$MODEL_NAME"
if [[ "$MODEL_NAME" == *:* ]]; then
    TAG="${MODEL_NAME##*:}"
    NAME="${MODEL_NAME%:*}"
fi

# Map the model reference to its manifest path:
#   name            -> manifests/registry.ollama.ai/library/name/tag
#   user/name       -> manifests/registry.ollama.ai/user/name/tag
#   host/user/name  -> manifests/host/user/name/tag
case "$NAME" in
    */*/*) MANIFEST_REL="manifests/$NAME/$TAG" ;;
    */*)   MANIFEST_REL="manifests/registry.ollama.ai/$NAME/$TAG" ;;
    *)     MANIFEST_REL="manifests/registry.ollama.ai/library/$NAME/$TAG" ;;
esac

if ! docker compose exec -T ollama test -f "$OLLAMA_MODELS_DIR/$MANIFEST_REL"; then
    echo "❌ Error: Manifest not found for '$MODEL_NAME' at $MANIFEST_REL"
    exit 1
fi

# Collect the digests referenced by the manifest (config + all layers)
mapfile -t DIGESTS < <(docker compose exec -T ollama \
    sh -c "grep -oE 'sha256:[a-f0-9]{64}' '$OLLAMA_MODELS_DIR/$MANIFEST_REL' | sort -u")

if [ ${#DIGESTS[@]} -eq 0 ]; then
    echo "❌ Error: No blobs referenced by manifest $MANIFEST_REL"
    exit 1
fi

FILES=("$MANIFEST_REL")
for digest in "${DIGESTS[@]}"; do
    FILES+=("blobs/${digest/:/-}")
done

mkdir -p "$OUTPUT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$OUTPUT_DIR/${MODEL_NAME//[:\/]/-}-$TIMESTAMP.tar"

echo "📦 Exporting model: $MODEL_NAME"
echo "  Manifest: $MANIFEST_REL"
echo "  Blobs:    ${#DIGESTS[@]}"
echo "  Output:   $OUTPUT_FILE"
echo ""
echo "⏳ Creating archive (weights included, this can take a while)..."

docker compose exec -T ollama \
    tar -cf - -C "$OLLAMA_MODELS_DIR" "${FILES[@]}" > "$OUTPUT_FILE"

if [ ! -s "$OUTPUT_FILE" ]; then
    echo "❌ Failed to create archive"
    rm -f "$OUTPUT_FILE"
    exit 1
fi

echo "✅ Model exported successfully!"
echo ""
ls -lh "$OUTPUT_FILE"
echo ""
echo "To import on another instance of this project:"
echo "  1. Copy the archive to the target machine"
echo "  2. Run: make import-full"
echo ""
echo "Or use the import script directly:"
echo "  bash scripts/import-model-full.sh $OUTPUT_FILE"
echo ""
echo "⚠️  Source and target should run similar Ollama versions"
echo "   (pin OLLAMA_IMAGE_TAG in .env for reproducible setups)."
