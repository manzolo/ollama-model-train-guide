#!/bin/bash
# Interactive full model import with archive selection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ARCHIVE_DIR="./backups/full"

check_ollama_running

echo "📥 Import a full model archive (weights included)"
echo ""
echo "📦 Available archives in $ARCHIVE_DIR:"
echo ""

archives=()
index=1
if [ -d "$ARCHIVE_DIR" ]; then
    while IFS= read -r file; do
        archives+=("$file")
        size="$(du -h "$file" | awk '{print $1}')"
        echo "  [$index] $(basename "$file") ($size)"
        index=$((index + 1))
    done < <(find "$ARCHIVE_DIR" -name "*.tar" -type f | sort)
fi

if [ ${#archives[@]} -eq 0 ]; then
    echo "  No archives found"
    echo ""
    echo "Create one first with:"
    echo "  make export-full"
    echo ""
fi

echo "  [0] Enter custom path"
echo ""
read -r -p "Select an archive [0-$((index - 1))]: " selection || selection=""

if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 0 ] || [ "$selection" -ge "$index" ]; then
    echo "❌ Invalid selection"
    exit 1
fi

if [ "$selection" -eq 0 ]; then
    read -r -p "Enter path to archive: " TAR_FILE || TAR_FILE=""
else
    TAR_FILE="${archives[$((selection - 1))]}"
fi

bash "$SCRIPT_DIR/import-model-full.sh" "$TAR_FILE"
