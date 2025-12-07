# GitHub Actions Workflows

This directory contains automated CI/CD workflows for the Ollama Model Training Guide project.

## Workflows

### 1. Test Ollama Model Workflow (`test.yml`)

**Triggers:**
- Push to `main` or `master` branch
- Pull requests to `main` or `master` branch
- Manual workflow dispatch

**What it does:**
1. Sets up Docker environment
2. Starts Ollama service
3. Pulls base model (`llama3.2:1b` - a lightweight 1.3GB model)
4. Runs end-to-end test (`make quick-test`) which:
   - Creates a temporary test model using the chatbot example
   - Based on `llama3.2:1b` with custom system prompt
   - Sends test prompt: "Hello! Can you introduce yourself in one sentence?"
   - Verifies the model responds correctly
   - Cleans up the test model automatically
5. Displays clean output (ANSI escape codes stripped for readability)

**Duration:** ~3-5 minutes (depending on model download)

**Why llama3.2:1b?**
- Small size (1.3GB) - faster CI/CD
- Fast inference on CPU
- Sufficient for testing model creation workflow
- Same model used in examples

### 2. Validate Configuration (`validate.yml`)

**Triggers:**
- Push to `main` or `master` branch
- Pull requests to `main` or `master` branch
- Manual workflow dispatch

**What it does:**
1. Validates Docker Compose configuration
2. Checks Makefile syntax
3. Verifies all scripts are executable
4. Confirms example Modelfiles exist
5. Validates directory structure
6. Checks for required files

**Duration:** ~30 seconds

## Status Badges

Add these to your README.md:

```markdown
![Test Workflow](https://github.com/manzolo/ollama-model-train-guide/actions/workflows/test.yml/badge.svg)
![Validate Workflow](https://github.com/manzolo/ollama-model-train-guide/actions/workflows/validate.yml/badge.svg)
```

## Running Workflows Manually

You can trigger workflows manually from the GitHub Actions tab:
1. Go to your repository on GitHub
2. Click "Actions" tab
3. Select the workflow
4. Click "Run workflow"

## Local Testing

Before pushing, you can run the same checks locally:

```bash
# Run validation
docker compose config
make help
make setup

# Run quick test
make up
docker compose exec ollama ollama pull llama3.2:1b
make quick-test
make down
```

## Notes

- The test workflow requires ~2GB of disk space for the base model
- GitHub Actions provides sufficient resources for running Ollama models
- Workflows run in isolated environments and don't affect your local setup
