#!/bin/bash
# Pre-flight check script
# Validates system requirements before setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Status tracking
ERRORS=0
WARNINGS=0

echo ""
echo -e "${BLUE}🚀 Ollama Model Training Guide - Pre-flight Check${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check 1: Docker installed
echo -n "Checking Docker installation... "
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | grep -oP '\d+\.\d+\.\d+' | head -1)
    echo -e "${GREEN}✓ Found Docker $DOCKER_VERSION${NC}"
else
    echo -e "${RED}✗ Docker not found${NC}"
    echo -e "${RED}  Please install Docker: https://docs.docker.com/get-docker/${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check 2: Docker daemon running
echo -n "Checking Docker daemon... "
if docker info &> /dev/null; then
    echo -e "${GREEN}✓ Docker daemon is running${NC}"
else
    echo -e "${RED}✗ Docker daemon not running${NC}"
    echo -e "${RED}  Please start Docker: sudo systemctl start docker${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check 3: Docker Compose installed
echo -n "Checking Docker Compose... "
if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version | grep -oP '\d+\.\d+\.\d+' | head -1)
    echo -e "${GREEN}✓ Found Docker Compose $COMPOSE_VERSION${NC}"

    # Version check (need 2.0+)
    MAJOR_VERSION=$(echo $COMPOSE_VERSION | cut -d. -f1)
    if [ "$MAJOR_VERSION" -lt 2 ]; then
        echo -e "${YELLOW}  ⚠ Warning: Docker Compose 2.0+ recommended${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${RED}✗ Docker Compose not found${NC}"
    echo -e "${RED}  Please install Docker Compose 2.0+${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check 4: Disk space
echo -n "Checking disk space... "
AVAILABLE_GB=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE_GB" -ge 10 ]; then
    echo -e "${GREEN}✓ ${AVAILABLE_GB}GB available${NC}"
elif [ "$AVAILABLE_GB" -ge 5 ]; then
    echo -e "${YELLOW}⚠ ${AVAILABLE_GB}GB available (10GB+ recommended)${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${RED}✗ Only ${AVAILABLE_GB}GB available${NC}"
    echo -e "${RED}  Minimum 10GB required for base models${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check 5: RAM
echo -n "Checking system memory... "
TOTAL_RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
if [ "$TOTAL_RAM_GB" -ge 8 ]; then
    echo -e "${GREEN}✓ ${TOTAL_RAM_GB}GB RAM${NC}"
elif [ "$TOTAL_RAM_GB" -ge 4 ]; then
    echo -e "${YELLOW}⚠ ${TOTAL_RAM_GB}GB RAM (8GB+ recommended)${NC}"
    echo -e "${YELLOW}  You may only be able to run small models (1B-3B)${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${RED}✗ Only ${TOTAL_RAM_GB}GB RAM${NC}"
    echo -e "${RED}  Minimum 8GB recommended, you may experience issues${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check 6: Ports availability
echo -n "Checking port 11434 (Ollama API)... "
if ! lsof -i:11434 &> /dev/null && ! netstat -tuln 2>/dev/null | grep -q ":11434 "; then
    echo -e "${GREEN}✓ Available${NC}"
else
    echo -e "${YELLOW}⚠ Port 11434 already in use${NC}"
    echo -e "${YELLOW}  You can change OLLAMA_PORT in .env file${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

echo -n "Checking port 8080 (Chat UI)... "
if ! lsof -i:8080 &> /dev/null && ! netstat -tuln 2>/dev/null | grep -q ":8080 "; then
    echo -e "${GREEN}✓ Available${NC}"
else
    echo -e "${YELLOW}⚠ Port 8080 already in use${NC}"
    echo -e "${YELLOW}  You can change CHAT_PORT in .env file${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# Check 7: Docker permissions
echo -n "Checking Docker permissions... "
if docker ps &> /dev/null; then
    echo -e "${GREEN}✓ User can run Docker commands${NC}"
else
    echo -e "${YELLOW}⚠ Docker permission issues detected${NC}"
    echo -e "${YELLOW}  You may need to add user to docker group:${NC}"
    echo -e "${YELLOW}  sudo usermod -aG docker \$USER${NC}"
    echo -e "${YELLOW}  Then log out and back in${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# Check 8: GPU (optional)
echo -n "Checking for NVIDIA GPU... "
if command -v nvidia-smi &> /dev/null; then
    if nvidia-smi &> /dev/null; then
        GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
        echo -e "${GREEN}✓ Found: $GPU_NAME${NC}"
        echo -e "${BLUE}  💡 You can enable GPU in docker-compose.yml for 5-10x speedup${NC}"
        echo -e "${BLUE}  📖 See docs/installation.md for GPU setup instructions${NC}"
    else
        echo -e "${YELLOW}⚠ nvidia-smi command exists but failed to run${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${BLUE}ℹ No NVIDIA GPU detected (optional, CPU works fine)${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}📊 Pre-flight Check Summary${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! You're ready to go.${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run: make setup && make up"
    echo "  2. Open: http://localhost:8080"
    echo ""
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    echo -e "${YELLOW}You can proceed, but may want to address warnings first.${NC}"
    echo ""
    echo "To continue anyway:"
    echo "  make setup && make up"
    echo ""
    exit 0
else
    echo -e "${RED}❌ $ERRORS critical error(s) found${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}   $WARNINGS warning(s) found${NC}"
    fi
    echo ""
    echo -e "${RED}Please fix the errors above before proceeding.${NC}"
    echo ""
    echo "Resources:"
    echo "  - Installation guide: docs/installation.md"
    echo "  - Troubleshooting: docs/troubleshooting.md"
    echo ""
    exit 1
fi
