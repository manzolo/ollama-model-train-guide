#!/bin/bash
# Validation tests for Ollama Model Training Guide

set -euo pipefail

echo "🧪 Running validation tests for Ollama Model Training Guide"
echo "=========================================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
# Note: call sites append `|| true` so a failed test is counted and the
# suite keeps running instead of aborting under `set -e`.
run_test() {
    local test_name=$1
    local test_command=$2

    echo -n "Testing: $test_name... "

    if eval "$test_command" &> /dev/null; then
        echo -e "${GREEN}✓ PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

echo "📋 Test 1: Docker Compose Configuration"
run_test "Docker Compose config validation" "docker compose config" || true

echo ""
echo "📋 Test 2: Starting Ollama Service"
docker compose up -d
sleep 5

run_test "Ollama service is running" "docker compose ps | grep -qE 'ollama.*(Up|running)'" || true

echo ""
echo "📋 Test 3: Ollama API Health Check"
run_test "Ollama API is accessible" "curl -sf http://localhost:11434/api/tags" || true

echo ""
echo "📋 Test 4: Directory Structure"
run_test "Models directory exists" "test -d ./models/examples" || true
run_test "Scripts directory exists" "test -d ./scripts" || true
run_test "Data directory exists" "test -d ./data" || true

echo ""
echo "📋 Test 5: Example Modelfiles"
run_test "Chatbot Modelfile exists" "test -f ./models/examples/chatbot/Modelfile" || true
run_test "Code assistant Modelfile exists" "test -f ./models/examples/code-assistant/Modelfile" || true
run_test "Translator Modelfile exists" "test -f ./models/examples/translator/Modelfile" || true
run_test "Creative writer Modelfile exists" "test -f ./models/examples/creative-writer/Modelfile" || true

echo ""
echo "📋 Test 6: Helper Scripts"
run_test "Pull script is executable" "test -x ./scripts/pull-base-models.sh" || true
run_test "Create script is executable" "test -x ./scripts/create-custom-model.sh" || true
run_test "List script is executable" "test -x ./scripts/list-models.sh" || true
run_test "Export script is executable" "test -x ./scripts/export-model.sh" || true
run_test "Import script is executable" "test -x ./scripts/import-model.sh" || true
run_test "Shared library exists" "test -f ./scripts/lib/common.sh" || true

echo ""
echo "📋 Test 7: Pull Base Model (optional - may take time)"
echo -n "Would you like to test pulling a base model? This may take a few minutes. (y/N): "
read -r response || response=""
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Pulling llama3.2:1b..."
    if docker compose exec ollama ollama pull llama3.2:1b; then
        echo -e "${GREEN}✓ Model pulled successfully${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))

        echo ""
        echo "📋 Test 8: Create Custom Model from Modelfile"
        if docker compose exec ollama ollama create test-chatbot -f /models/examples/chatbot/Modelfile; then
            echo -e "${GREEN}✓ Custom model created${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))

            echo ""
            echo "📋 Test 9: List Models"
            MODEL_LIST="$(docker compose exec ollama ollama list || true)"
            if grep -q "test-chatbot" <<< "$MODEL_LIST"; then
                echo -e "${GREEN}✓ Custom model is listed${NC}"
                TESTS_PASSED=$((TESTS_PASSED + 1))
            else
                echo -e "${RED}✗ Custom model not found in list${NC}"
                TESTS_FAILED=$((TESTS_FAILED + 1))
            fi

            echo ""
            echo "📋 Test 10: Model Interaction"
            GENERATE_RESPONSE="$(echo '{"model":"test-chatbot","prompt":"Say hello","stream":false}' | \
               curl -sf http://localhost:11434/api/generate -d @- || true)"
            if grep -q "response" <<< "$GENERATE_RESPONSE"; then
                echo -e "${GREEN}✓ Model responds to prompts${NC}"
                TESTS_PASSED=$((TESTS_PASSED + 1))
            else
                echo -e "${RED}✗ Model did not respond${NC}"
                TESTS_FAILED=$((TESTS_FAILED + 1))
            fi

            echo ""
            echo "📋 Test 11: Export Model Configuration"
            if docker compose exec ollama ollama show test-chatbot --modelfile > /tmp/test-export; then
                if [ -s /tmp/test-export ]; then
                    echo -e "${GREEN}✓ Model exported successfully${NC}"
                    TESTS_PASSED=$((TESTS_PASSED + 1))
                    rm -f /tmp/test-export
                else
                    echo -e "${RED}✗ Exported file is empty${NC}"
                    TESTS_FAILED=$((TESTS_FAILED + 1))
                fi
            else
                echo -e "${RED}✗ Export failed${NC}"
                TESTS_FAILED=$((TESTS_FAILED + 1))
            fi
        else
            echo -e "${RED}✗ Failed to create custom model${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        echo -e "${RED}✗ Failed to pull model${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo -e "${YELLOW}⊘ Skipped model tests${NC}"
fi

echo ""
echo "=========================================================="
echo "Test Results:"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi
