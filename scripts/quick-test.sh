#!/bin/bash
# Quick test: Create a model, test it, and clean up

set -e

echo "🧪 Quick Model Test"
echo ""
echo "This will:"
echo "  1. Create a test model from an example"
echo "  2. Send a test prompt to it"
echo "  3. Delete the test model"
echo ""
read -p "Continue? (y/N): " CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Test cancelled"
    exit 0
fi

# Check if Ollama service is running
if ! docker compose ps | grep -qE "ollama.*(Up|running)"; then
    echo "❌ Error: Ollama service is not running"
    echo "Please start it with: make up"
    exit 1
fi

TEST_MODEL_NAME="test-chatbot-$(date +%s)"
TEST_MODELFILE="./models/examples/chatbot/Modelfile"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Step 1/3: Creating test model '$TEST_MODEL_NAME'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

bash scripts/create-custom-model.sh "$TEST_MODEL_NAME" "$TEST_MODELFILE"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💬 Step 2/3: Testing model with a prompt"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Sending test prompt: 'Hello! Can you introduce yourself in one sentence?'"
echo ""

RESPONSE=$(docker compose exec ollama ollama run "$TEST_MODEL_NAME" "Hello! Can you introduce yourself in one sentence?" 2>&1)

echo "Response:"
echo "─────────────────────────────────────────────────────"
echo "$RESPONSE"
echo "─────────────────────────────────────────────────────"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗑️  Step 3/3: Cleaning up test model"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker compose exec ollama ollama rm "$TEST_MODEL_NAME"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Quick test completed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Summary:"
echo "  ✓ Model creation works"
echo "  ✓ Model responds to prompts"
echo "  ✓ Model cleanup works"
echo ""
echo "You can now create your own models with:"
echo "  make create-model"
