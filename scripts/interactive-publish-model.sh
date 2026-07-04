#!/bin/bash
# Interactive model publishing wizard

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

check_ollama_running

echo "🌍 Publish a model to an external registry"
echo ""
echo "Select a local custom model to publish:"
echo ""

LOCAL_MODEL=""
pick_model LOCAL_MODEL "Select a model" "Enter custom name manually" "Enter local model name: "

echo ""
echo "Where are you publishing to?"
echo "  [1] Ollama.com (Default)"
echo "  [2] Private/Other Registry"
read -r -p "Select destination [1-2]: " DEST_TYPE || DEST_TYPE=""
DEST_TYPE=${DEST_TYPE:-1}

TARGET_TAG=""

if [ "$DEST_TYPE" -eq 1 ]; then
    # Ollama.com
    echo ""
    echo "To publish to Ollama.com, you need a namespace (your username)."
    read -r -p "Enter your Ollama.com username (namespace): " NAMESPACE || NAMESPACE=""

    if [ -z "$NAMESPACE" ]; then
        echo "❌ Username is required"
        exit 1
    fi

    # Default target name is the local name without any tag/namespace,
    # suggested to the user as the default.
    DEFAULT_NAME=$(basename "${LOCAL_MODEL%%:*}")

    read -r -p "Enter target model name [default: $DEFAULT_NAME]: " TARGET_NAME || TARGET_NAME=""
    TARGET_NAME=${TARGET_NAME:-$DEFAULT_NAME}

    read -r -p "Enter tag (version) [default: latest]: " TAG || TAG=""
    TAG=${TAG:-latest}

    TARGET_TAG="$NAMESPACE/$TARGET_NAME:$TAG"

else
    # Private Registry
    echo ""
    echo "Enter the full registry path (e.g. registry.example.com/team/model:v1)"
    read -r -p "Target Tag: " TARGET_TAG || TARGET_TAG=""

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
read -r -p "Proceed with publish? (y/N): " CONFIRM || CONFIRM=""

if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    bash "$SCRIPT_DIR/publish-model.sh" "$LOCAL_MODEL" "$TARGET_TAG"
else
    echo "❌ Publish cancelled"
    exit 0
fi
