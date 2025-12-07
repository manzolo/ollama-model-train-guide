#!/bin/bash
# Backup all custom models (non-base models)

set -e

# Display usage
usage() {
    echo "Usage: $0 [output-directory]"
    echo ""
    echo "Backs up all custom models to Modelfiles"
    echo ""
    echo "Arguments:"
    echo "  output-directory  - (Optional) Directory to save backups (default: ./backups/models)"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 /path/to/backup/location"
    exit 1
}

OUTPUT_DIR=${1:-./backups/models}

# Check if Ollama service is running
if ! docker compose ps | grep -qE "ollama.*(Up|running)"; then
    echo "❌ Error: Ollama service is not running"
    echo "Please start it with: docker compose up -d"
    exit 1
fi

# Create output directory with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$OUTPUT_DIR/$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

echo "💾 Backing up all models"
echo "Backup location: $BACKUP_DIR"
echo ""

# Get list of all models
MODELS=$(docker compose exec ollama ollama list | tail -n +2 | awk '{print $1}' | grep -v "^$")

if [ -z "$MODELS" ]; then
    echo "⚠️  No models found to backup"
    exit 0
fi

COUNT=0
while IFS= read -r model; do
    # Skip empty lines
    [ -z "$model" ] && continue

    SAFE_NAME="${model//\//_}"
    OUTPUT_FILE="$BACKUP_DIR/${SAFE_NAME}.Modelfile"

    echo "📦 Backing up: $model"
    docker compose exec ollama ollama show "$model" --modelfile > "$OUTPUT_FILE" 2>/dev/null || {
        echo "   ⚠️  Skipped (might be a base model or corrupted)"
        rm -f "$OUTPUT_FILE"
        continue
    }

    COUNT=$((COUNT + 1))
done <<< "$MODELS"

echo ""
echo "✅ Backup complete!"
echo "Backed up $COUNT model(s) to: $BACKUP_DIR"
echo ""
echo "To restore a model:"
echo "  bash scripts/deploy-model.sh $BACKUP_DIR/<model>.Modelfile"
