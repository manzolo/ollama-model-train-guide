#!/bin/bash
# Interactive model deployment with saved Modelfile selection

set -e

SAVED_DIR="./models/saved"

if [ ! -d "$SAVED_DIR" ]; then
    echo "❌ No saved models directory found at: $SAVED_DIR"
    exit 1
fi

echo "🚀 Deploy a saved model"
echo ""
echo "💾 Available saved models:"
echo ""

# Find all saved Modelfiles
MODELFILES=()
INDEX=1

while IFS= read -r file; do
    MODELFILES+=("$file")
    FILENAME=$(basename "$file")
    echo "  [$INDEX] $FILENAME"
    ((INDEX++))
done < <(find "$SAVED_DIR" -name "*.Modelfile" -type f | sort)

if [ ${#MODELFILES[@]} -eq 0 ]; then
    echo "  No saved Modelfiles found in $SAVED_DIR"
    echo ""
    echo "Save a model first:"
    echo "  make save-model"
    exit 1
fi

echo ""
echo "  [0] Enter custom path"
echo ""
read -p "Select a saved model [0-$((INDEX-1))]: " SELECTION

# Validate input
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 0 ] || [ "$SELECTION" -ge "$INDEX" ]; then
    echo "❌ Invalid selection"
    exit 1
fi

if [ "$SELECTION" -eq 0 ]; then
    read -p "Enter path to Modelfile: " MODELFILE_PATH
else
    MODELFILE_PATH="${MODELFILES[$((SELECTION-1))]}"
fi

# Get model name (optional)
echo ""
read -p "Enter model name (press Enter to use filename): " MODEL_NAME

# Deploy the model
if [ -z "$MODEL_NAME" ]; then
    bash scripts/deploy-model.sh "$MODELFILE_PATH"
else
    bash scripts/deploy-model.sh "$MODELFILE_PATH" "$MODEL_NAME"
fi
