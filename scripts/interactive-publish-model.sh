#!/bin/bash
# Interactive model publishing wizard

set -e

# Check if Ollama service is running
if ! docker compose ps | grep -qE "ollama.*(Up|running)"; then
    echo "❌ Error: Ollama service is not running"
    echo "Please start it with: docker compose up -d"
    exit 1
fi

echo "🌍 Publish a model to an external registry"
echo ""
echo "Select a local custom model to publish:"
echo ""

# Get list of all models with size info
MODELS=()
INDEX=1

while IFS= read -r line; do
    # Skip empty lines and header
    [ -z "$line" ] && continue
    [[ "$line" =~ ^NAME ]] && continue

    MODEL_NAME=$(echo "$line" | awk '{print $1}')
    MODEL_SIZE=$(echo "$line" | awk '{print $2}')
    [ -z "$MODEL_NAME" ] && continue

    # Filter out models that look like base models (heuristic: contain ':')
    # Or just list everything but highlight custom ones?
    # Let's list everything but prioritize ones without '/' if possible, or just all.
    # Actually, for publishing, you might want to publish a derivative of a base model.

    MODELS+=("$MODEL_NAME")
    echo "  [$INDEX] $MODEL_NAME ($MODEL_SIZE)"
    ((INDEX++))
done < <(docker compose exec ollama ollama list)

if [ ${#MODELS[@]} -eq 0 ]; then
    echo "  No models found"
    exit 1
fi

echo ""
echo "  [0] Enter custom name manually"
echo ""
read -p "Select a model [0-$((INDEX-1))]: " SELECTION

# Validate input
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 0 ] || [ "$SELECTION" -ge "$INDEX" ]; then
    echo "❌ Invalid selection"
    exit 1
fi

if [ "$SELECTION" -eq 0 ]; then
    read -p "Enter local model name: " LOCAL_MODEL
else
    LOCAL_MODEL="${MODELS[$((SELECTION-1))]}"
fi

echo ""
echo "Where are you publishing to?"
echo "  [1] Ollama.com (Default)"
echo "  [2] Private/Other Registry"
read -p "Select destination [1-2]: " DEST_TYPE
DEST_TYPE=${DEST_TYPE:-1}

TARGET_TAG=""

if [ "$DEST_TYPE" -eq 1 ]; then
    # Ollama.com
    echo ""
    echo "To publish to Ollama.com, you need a namespace (your username)."
    read -p "Enter your Ollama.com username (namespace): " NAMESPACE
    
    if [ -z "$NAMESPACE" ]; then
        echo "❌ Username is required"
        exit 1
    fi

    # Default model name is the local name, stripping any previous tag/namespace if present
    # Simple basename approach:
    # If local is "my-model", default is "my-model"
    # If local is "library/llama3", default is "llama3" (user probably renamed it locally)
    
    # We'll just ask the user for the name, suggesting the current basename
    DEFAULT_NAME=$(basename "${LOCAL_MODEL%%:*}")
    
    read -p "Enter target model name [default: $DEFAULT_NAME]: " TARGET_NAME
    TARGET_NAME=${TARGET_NAME:-$DEFAULT_NAME}

    read -p "Enter tag (version) [default: latest]: " TAG
    TAG=${TAG:-latest}

    TARGET_TAG="$NAMESPACE/$TARGET_NAME:$TAG"

else
    # Private Registry
    echo ""
    echo "Enter the full registry path (e.g. registry.example.com/team/model:v1)"
    read -p "Target Tag: " TARGET_TAG
    
    if [ -z "$TARGET_TAG" ]; then
        echo "❌ Target tag is required"
        exit 1
    fi
fi

echo ""
echo "Summary:"
echo "  Local Source: $LOCAL_MODEL"
echo "  Publish To:   $TARGET_TAG"
echo ""
read -p "Proceed with publish? (y/N): " CONFIRM

if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    bash scripts/publish-model.sh "$LOCAL_MODEL" "$TARGET_TAG"
else
    echo "❌ Publish cancelled"
    exit 0
fi
