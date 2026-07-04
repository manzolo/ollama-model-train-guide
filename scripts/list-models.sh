#!/bin/bash
# List all available Ollama models

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

check_ollama_running

echo "📋 Available Ollama models:"
echo ""

docker compose exec ollama ollama list
