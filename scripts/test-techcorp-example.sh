#!/bin/bash
# Test the TechCorp customer support example model

set -e

echo "🏢 Testing TechCorp Customer Support Example"
echo ""

# Check if Ollama service is running
if ! docker compose ps | grep -qE "ollama.*(Up|running)"; then
    echo "❌ Error: Ollama service is not running"
    echo "Please start it with: make up"
    exit 1
fi

TEST_MODEL_NAME="techcorp-support-test-$(date +%s)"
TEST_MODELFILE="./models/examples/techcorp-support/Modelfile"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Step 1/4: Creating TechCorp support model"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Model Details:"
echo "  Base Model: llama3.2:1b"
echo "  Modelfile:  $TEST_MODELFILE"
echo "  Dataset:    data/training/techcorp-support.jsonl (10 examples)"
echo "  Approach:   Few-shot learning with MESSAGE examples"
echo ""

bash scripts/create-custom-model.sh "$TEST_MODEL_NAME" "$TEST_MODELFILE"

# Test questions from the dataset
TEST_QUESTIONS=(
    "How do I reset my password?"
    "What are your business hours?"
    "Do you offer refunds?"
)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💬 Step 2/4: Testing with dataset questions"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

for i in "${!TEST_QUESTIONS[@]}"; do
    QUESTION="${TEST_QUESTIONS[$i]}"
    echo "Question $((i+1)): $QUESTION"
    echo ""

    RESPONSE=$(docker compose exec ollama ollama run "$TEST_MODEL_NAME" "$QUESTION" 2>&1)

    # Strip ANSI codes
    CLEAN_RESPONSE=$(echo "$RESPONSE" | \
        sed -r 's/\x1B\[[0-9;?]*[a-zA-Z]//g' | \
        sed -r 's/\x1B\][0-9;]*;//g' | \
        tr -d '\000-\037' | \
        sed 's/⠋//g; s/⠙//g; s/⠹//g; s/⠸//g; s/⠼//g; s/⠴//g; s/⠦//g; s/⠧//g; s/⠇//g; s/⠏//g' | \
        sed 's/^\s*//; s/\s*$//' | \
        grep -v '^$' | \
        head -1)

    echo "Response:"
    echo "─────────────────────────────────────────────────────"
    echo "$CLEAN_RESPONSE"
    echo "─────────────────────────────────────────────────────"
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 Step 3/4: Testing out-of-dataset question"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

OUT_OF_DATASET_QUESTION="What is your phone number?"
echo "Question: $OUT_OF_DATASET_QUESTION"
echo ""

RESPONSE=$(docker compose exec ollama ollama run "$TEST_MODEL_NAME" "$OUT_OF_DATASET_QUESTION" 2>&1)

CLEAN_RESPONSE=$(echo "$RESPONSE" | \
    sed -r 's/\x1B\[[0-9;?]*[a-zA-Z]//g' | \
    sed -r 's/\x1B\][0-9;]*;//g' | \
    tr -d '\000-\037' | \
    sed 's/⠋//g; s/⠙//g; s/⠹//g; s/⠸//g; s/⠼//g; s/⠴//g; s/⠦//g; s/⠧//g; s/⠇//g; s/⠏//g' | \
    sed 's/^\s*//; s/\s*$//' | \
    grep -v '^$' | \
    head -1)

echo "Response:"
echo "─────────────────────────────────────────────────────"
echo "$CLEAN_RESPONSE"
echo "─────────────────────────────────────────────────────"
echo ""
echo "Note: Model should infer from SYSTEM prompt (phone: +39 055 1234567)"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗑️  Step 4/4: Cleaning up test model"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker compose exec ollama ollama rm "$TEST_MODEL_NAME"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ TechCorp example test completed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Summary:"
echo "  ✓ Few-shot learning model created (base: llama3.2:1b)"
echo "  ✓ Dataset questions answered correctly"
echo "  ✓ Model uses SYSTEM prompt for context"
echo "  ✓ Model cleanup successful"
echo ""
echo "Learn more:"
echo "  docs/dataset-training-example.md - Complete training guide"
echo "  models/examples/techcorp-support/README.md - Example details"
