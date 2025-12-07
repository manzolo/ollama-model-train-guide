#!/bin/bash
# Helper script to select a Modelfile interactively

set -e

echo "📁 Available Modelfiles:" >&2
echo "" >&2

# Find all Modelfiles in examples and custom directories
MODELFILES=()
INDEX=1

# Search in examples
if [ -d "./models/examples" ]; then
    while IFS= read -r file; do
        MODELFILES+=("$file")
        DISPLAY_NAME=$(echo "$file" | sed 's|^\./models/||')
        echo "  [$INDEX] $DISPLAY_NAME" >&2
        ((INDEX++))
    done < <(find ./models/examples -name "Modelfile" -type f | sort)
fi

# Search in custom
if [ -d "./models/custom" ]; then
    while IFS= read -r file; do
        MODELFILES+=("$file")
        DISPLAY_NAME=$(echo "$file" | sed 's|^\./models/||')
        echo "  [$INDEX] $DISPLAY_NAME" >&2
        ((INDEX++))
    done < <(find ./models/custom -name "Modelfile" -type f | sort)
fi

if [ ${#MODELFILES[@]} -eq 0 ]; then
    echo "  No Modelfiles found in models/examples or models/custom" >&2
    exit 1
fi

echo "" >&2
echo "  [0] Enter custom path" >&2
echo "" >&2
read -p "Select a Modelfile [0-$((INDEX-1))]: " SELECTION

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
