#!/bin/bash
# Import a model archive created by export-model-full.sh (manifest + blobs).
#
# The archive already contains the model weights, so nothing is downloaded:
# the model is available immediately after extraction.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

OLLAMA_MODELS_DIR="/root/.ollama/models"

usage() {
    echo "Usage: $0 <archive.tar>"
    echo ""
    echo "Imports a full model archive created by export-model-full.sh"
    echo ""
    echo "Examples:"
    echo "  $0 ./backups/full/my-chatbot-20260704_120000.tar"
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

TAR_FILE=$1

if [ ! -f "$TAR_FILE" ]; then
    echo "❌ Error: Archive not found: $TAR_FILE"
    exit 1
fi

check_ollama_running

# Sanity-check the archive: it must contain a manifest and only paths inside
# manifests/ or blobs/ (no absolute paths or traversal).
CONTENTS="$(tar -tf "$TAR_FILE")"
if ! grep -q "^manifests/" <<< "$CONTENTS"; then
    echo "❌ Error: Not a model archive (no manifests/ entry inside)"
    echo "Expected an archive created by: make export-full"
    exit 1
fi
if grep -qvE "^(manifests|blobs)/" <<< "$CONTENTS" || grep -q "\.\." <<< "$CONTENTS"; then
    echo "❌ Error: Archive contains unexpected paths, refusing to import"
    exit 1
fi

# Reconstruct the model name(s) from the manifest path(s):
#   manifests/registry.ollama.ai/library/name/tag -> name:tag
#   manifests/registry.ollama.ai/user/name/tag    -> user/name:tag
#   manifests/host/user/name/tag                  -> host/user/name:tag
MODELS="$(grep "^manifests/" <<< "$CONTENTS" | awk -F/ '
    NF >= 5 {
        name = ""
        for (i = 2; i < NF; i++) name = name (name == "" ? "" : "/") $i
        sub(/^registry\.ollama\.ai\/library\//, "", name)
        sub(/^registry\.ollama\.ai\//, "", name)
        print name ":" $NF
    }')"

BLOB_COUNT="$(grep -c "^blobs/" <<< "$CONTENTS" || true)"

echo "📥 Importing model archive: $TAR_FILE"
echo "  Models: "
while IFS= read -r model; do
    [ -z "$model" ] && continue
    echo "    - $model"
done <<< "$MODELS"
echo "  Blobs:  $BLOB_COUNT"
echo ""
echo "⏳ Extracting into the Ollama volume..."

docker compose exec -T ollama \
    tar -xf - -C "$OLLAMA_MODELS_DIR" < "$TAR_FILE"

echo ""
FAILED=0
while IFS= read -r model; do
    [ -z "$model" ] && continue
    if model_exists "$model"; then
        echo "✅ Model available: $model"
    else
        echo "❌ Model not visible after import: $model"
        FAILED=1
    fi
done <<< "$MODELS"

if [ "$FAILED" -ne 0 ]; then
    echo ""
    echo "The archive was extracted but Ollama does not list the model."
    echo "Check version compatibility between source and target instances."
    exit 1
fi

echo ""
echo "Test it with:"
while IFS= read -r model; do
    [ -z "$model" ] && continue
    echo "  docker compose exec ollama ollama run ${model%:latest}"
done <<< "$MODELS"
