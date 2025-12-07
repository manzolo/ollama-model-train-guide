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
BASE_MODEL="llama3.2:1b"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Step 1/4: Creating test model '$TEST_MODEL_NAME'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Test Details:"
echo "  Base Model: $BASE_MODEL"
echo "  Modelfile:  $TEST_MODELFILE"
echo "  Test Model: $TEST_MODEL_NAME"
echo ""

bash scripts/create-custom-model.sh "$TEST_MODEL_NAME" "$TEST_MODELFILE"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💬 Step 2/4: Testing model with a prompt"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Sending test prompt: 'Hello! Can you introduce yourself in one sentence?'"
echo ""

# Capture response and strip ANSI escape codes for clean output
RESPONSE=$(docker compose exec ollama ollama run "$TEST_MODEL_NAME" "Hello! Can you introduce yourself in one sentence?" 2>&1)

# Strip all ANSI escape codes and control characters
# This removes spinner animations, cursor movements, colors, etc.
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
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔌 Step 3/4: Testing API Endpoints"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Testing /api/models..."
if curl -s -f http://localhost:8080/api/models > /dev/null; then
    echo "  ✓ /api/models is reachable"
else
    echo "  ❌ /api/models failed"
    exit 1
fi

echo "Testing /api/converter/convert (Real File)..."
# Create a dummy CSV file
TEST_CSV="test_conversion.csv"
echo "instruction,output" > "$TEST_CSV"
echo "What is 1+1?,It is 2." >> "$TEST_CSV"

# Test conversion (download mode)
HTTP_CODE=$(curl -s -o converted.jsonl -w "%{http_code}" -X POST http://localhost:8080/api/converter/convert -F "file=@$TEST_CSV")

if [ "$HTTP_CODE" -eq 200 ]; then
    if grep -q "It is 2" converted.jsonl; then
        echo "  ✓ /api/converter/convert successfully converted CSV to JSONL"
    else
        echo "  ❌ /api/converter/convert returned 200 but content is unexpected"
        cat converted.jsonl
        rm -f "$TEST_CSV" converted.jsonl
        exit 1
    fi
else
    echo "  ❌ /api/converter/convert failed (Code: $HTTP_CODE)"
    rm -f "$TEST_CSV" converted.jsonl
    exit 1
fi

# Cleanup
rm -f "$TEST_CSV" converted.jsonl

echo "Testing /api/modelfile (Create & Delete)..."
# Create a temporary Modelfile
TEST_MF_NAME="api-test-bot"
TEST_MF_CONTENT="FROM llama3.2:1b\nSYSTEM You are a test bot."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:8080/api/modelfile -H "Content-Type: application/json" -d "{\"name\": \"$TEST_MF_NAME\", \"content\": \"$TEST_MF_CONTENT\"}")

# Retrieve path for deletion
MF_PATH="/models/custom/$TEST_MF_NAME/Modelfile"

if [ "$HTTP_CODE" -eq 200 ]; then
    echo "  ✓ /api/modelfile (POST) created a Modelfile"
    
    # Clean it up via API
    DEL_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "http://localhost:8080/api/modelfile?path=${MF_PATH}")
    if [ "$DEL_CODE" -eq 200 ]; then
        echo "  ✓ /api/modelfile (DELETE) deleted the Modelfile"
    else
        echo "  ❌ /api/modelfile (DELETE) failed (Code: $DEL_CODE)"
        exit 1
    fi
else
    # 409 is acceptable if it exists from a previous failed run, try to delete it to be clean
    if [ "$HTTP_CODE" -eq 409 ]; then
         echo "  ⚠️ /api/modelfile (POST) returned 409 (already exists), attempting cleanup..."
         curl -s -X DELETE "http://localhost:8080/api/modelfile?path=${MF_PATH}" > /dev/null
    else
        echo "  ❌ /api/modelfile (POST) failed (Code: $HTTP_CODE)"
        exit 1
    fi
fi

echo "Testing /api/pull-model (Real Pull)..."
# Pull a tiny model (all-minilm is ~20MB)
echo "  Pulling all-minilm..."
curl -s -X POST http://localhost:8080/api/pull-model -H "Content-Type: application/json" -d '{"name": "all-minilm"}' > /dev/null

# Verify it exists
if curl -s http://localhost:8080/api/models | grep -q "all-minilm"; then
    echo "  ✓ /api/pull-model successfully pulled the model"
else
    echo "  ❌ /api/pull-model failed (Model not found in list)"
    exit 1
fi

echo "Testing /api/create-model (Real Creation)..."
# 1. Create Modelfile
TEST_CREATE_NAME="api-created-bot"
TEST_CREATE_MF_CONTENT="FROM all-minilm\nSYSTEM You are an API test bot."
curl -s -X POST http://localhost:8080/api/modelfile -H "Content-Type: application/json" -d "{\"name\": \"$TEST_CREATE_NAME\", \"content\": \"$TEST_CREATE_MF_CONTENT\"}" > /dev/null

# 2. Create Model from it
echo "  Creating model from API..."
curl -s -X POST http://localhost:8080/api/create-model -H "Content-Type: application/json" -d "{\"name\": \"$TEST_CREATE_NAME\", \"path\": \"/models/custom/$TEST_CREATE_NAME/Modelfile\"}" > /dev/null

# 3. Verify
if curl -s http://localhost:8080/api/models | grep -q "$TEST_CREATE_NAME"; then
    echo "  ✓ /api/create-model successfully created the model"
    
    # 4. Cleanup Model
    curl -s -X DELETE "http://localhost:8080/api/delete-model?name=$TEST_CREATE_NAME" > /dev/null
    # 5. Cleanup Modelfile
    curl -s -X DELETE "http://localhost:8080/api/modelfile?path=/models/custom/$TEST_CREATE_NAME/Modelfile" > /dev/null
else
    echo "  ❌ /api/create-model failed (Model not found in list)"
    exit 1
fi

echo "Testing /api/create-model (Validation)..."
# Expect 400 for missing path
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:8080/api/create-model -H "Content-Type: application/json" -d "{\"name\": \"test-model-api\"}")
if [ "$HTTP_CODE" -eq 400 ]; then
    echo "  ✓ /api/create-model correctly returns 400 for missing path"
else
     echo "  ❌ /api/create-model failed validation check (Code: $HTTP_CODE)"
     exit 1
fi

echo "Testing /api/delete-model (Validation)..."
# Expect 400 for missing name
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE http://localhost:8080/api/delete-model)
if [ "$HTTP_CODE" -eq 400 ]; then
    echo "  ✓ /api/delete-model correctly returns 400 for missing name"
else
     echo "  ❌ /api/delete-model failed validation check (Code: $HTTP_CODE)"
     exit 1
fi


echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗑️  Step 4/4: Cleaning up test model"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker compose exec ollama ollama rm "$TEST_MODEL_NAME"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Quick test completed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Summary:"
echo "  ✓ Model creation works (base: $BASE_MODEL)"
echo "  ✓ Model responds to prompts"
echo "  ✓ Model cleanup works"
echo ""
echo "You can now create your own models with:"
echo "  make create-model"
