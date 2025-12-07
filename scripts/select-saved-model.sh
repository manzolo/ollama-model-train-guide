#!/bin/bash
# Helper script to select a saved Modelfile interactively

set -e

SAVED_DIR=${1:-./models/saved}

if [ ! -d "$SAVED_DIR" ]; then
    echo "❌ No saved models directory found at: $SAVED_DIR" >&2
    exit 1
fi

echo "💾 Available saved models:" >&2
echo "" >&2

# Find all saved Modelfiles
MODELFILES=()
INDEX=1

while IFS= read -r file; do
    MODELFILES+=("$file")
    FILENAME=$(basename "$file")
    echo "  [$INDEX] $FILENAME" >&2
    ((INDEX++))
done < <(find "$SAVED_DIR" -name "*.Modelfile" -type f | sort)

if [ ${#MODELFILES[@]} -eq 0 ]; then
    echo "  No saved Modelfiles found in $SAVED_DIR" >&2
    echo "" >&2
    echo "Save a model first:" >&2
    echo "  make save-model" >&2
    exit 1
fi

echo "" >&2
echo "  [0] Enter custom path" >&2
echo "" >&2
read -p "Select a saved model [0-$((INDEX-1))]: " SELECTION

# Validate input
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 0 ] || [ "$SELECTION" -ge "$INDEX" ]; then
    echo "❌ Invalid selection" >&2
    exit 1
fi

if [ "$SELECTION" -eq 0 ]; then
    read -p "Enter path to Modelfile: " CUSTOM_PATH
    echo "$CUSTOM_PATH"
else
    SELECTED_FILE="${MODELFILES[$((SELECTION-1))]}"
    echo "$SELECTED_FILE"
fi
