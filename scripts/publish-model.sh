#!/bin/bash
# Push a model to an external registry (Ollama.com or private)

set -e

# Display usage
usage() {
    echo "Usage: $0 <local-model-name> <target-model-name>"
    echo ""
    echo "Pushes a local model to an external registry"
    echo ""
    echo "Arguments:"
    echo "  local-model-name   - Name of the local model to push"
    echo "  target-model-name  - Full tag for the destination (e.g. username/model:tag)"
    echo ""
    echo "Examples:"
    echo "  $0 my-model manzolo/my-model:latest"
    echo "  $0 my-model registry.example.com/team/model:v1"
    exit 1
}

# Check arguments
if [ $# -lt 2 ]; then
    usage
fi

LOCAL_MODEL=$1
TARGET_MODEL=$2

# Check if Ollama service is running
if ! docker compose ps | grep -qE "ollama.*(Up|running)"; then
    echo "❌ Error: Ollama service is not running"
    echo "Please start it with: docker compose up -d"
    exit 1
fi

# Check if local model exists
if ! docker compose exec ollama ollama list | grep -q "^$LOCAL_MODEL"; then
    echo "❌ Error: Local model '$LOCAL_MODEL' not found"
    echo ""
    echo "Available models:"
    docker compose exec ollama ollama list
    exit 1
fi

echo "🚀 Publishing model..."
echo "  Local:  $LOCAL_MODEL"
echo "  Target: $TARGET_MODEL"
echo ""

# Tag the model
echo "🏷️  Tagging model as '$TARGET_MODEL'..."
docker compose exec ollama ollama cp "$LOCAL_MODEL" "$TARGET_MODEL"

# Push the model
echo "⬆️  Pushing model to registry..."
echo "   (This may take a while depending on model size and upload speed)"
echo ""

if docker compose exec ollama ollama push "$TARGET_MODEL"; then
    echo ""
    echo "✅ Model published successfully!"
    echo "   $TARGET_MODEL"
else
    echo ""
    echo "❌ Failed to push model."
    echo ""
    echo "Possible reasons:"
    echo "  1. You are not logged in. Run 'docker compose exec ollama ollama list' to check keys,"
    echo "     adding your public key to https://ollama.com/settings/keys"
    echo "  2. Network connectivity issues."
    echo "  3. Permission denied on the registry namespace."
    exit 1
fi
