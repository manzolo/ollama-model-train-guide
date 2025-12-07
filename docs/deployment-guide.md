# Model Deployment Guide

This guide explains how to save, deploy, and manage models across multiple self-hosted Ollama instances.

## Overview

When working with self-hosted Ollama services, you often need to:
- Deploy custom models to production servers
- Share models between development and staging environments
- Backup models for disaster recovery
- Transfer models between team members

This project includes scripts and make commands to streamline these workflows.

## Quick Start

### Save a Model

Save a model's Modelfile for deployment:

```bash
# Interactive
make save-model

# Or specify directly
bash scripts/save-model.sh my-chatbot

# Save to custom location
bash scripts/save-model.sh my-chatbot ./backups/production
```

This creates a Modelfile at `./models/saved/my-chatbot.Modelfile` (or your specified location).

### Deploy a Model

Deploy a saved Modelfile to the current Ollama instance:

```bash
# Interactive
make deploy-model

# Or specify directly
bash scripts/deploy-model.sh ./models/saved/my-chatbot.Modelfile

# Deploy with a different name
bash scripts/deploy-model.sh ./models/saved/my-chatbot.Modelfile production-chatbot
```

### Backup All Models

Create a timestamped backup of all custom models:

```bash
# Default location: ./backups/models/YYYYMMDD_HHMMSS/
make backup-models

# Or specify custom location
bash scripts/backup-models.sh /mnt/backup/ollama-models
```

## Deployment Workflows

### Workflow 1: Development to Production

1. **On development server**, create and test your model:
   ```bash
   # Create custom model
   bash scripts/create-custom-model.sh my-app-assistant ./models/custom/app-assistant/Modelfile

   # Test it
   docker compose exec ollama ollama run my-app-assistant "Test prompt"
   ```

2. **Save the model**:
   ```bash
   bash scripts/save-model.sh my-app-assistant
   # Creates: ./models/saved/my-app-assistant.Modelfile
   ```

3. **Transfer to production server**:
   ```bash
   scp ./models/saved/my-app-assistant.Modelfile user@prod-server:/opt/ollama/models/saved/
   ```

4. **On production server**, deploy:
   ```bash
   cd /opt/ollama
   bash scripts/deploy-model.sh ./models/saved/my-app-assistant.Modelfile
   ```

5. **Verify deployment**:
   ```bash
   docker compose exec ollama ollama list
   docker compose exec ollama ollama run my-app-assistant "Test prompt"
   ```

### Workflow 2: Team Collaboration

Share models via version control:

1. **Developer A** creates a model:
   ```bash
   bash scripts/create-custom-model.sh team-assistant ./models/custom/team/Modelfile
   bash scripts/save-model.sh team-assistant ./models/custom/team/
   ```

2. **Commit to repository**:
   ```bash
   git add models/custom/team/
   git commit -m "Add team assistant model"
   git push
   ```

3. **Developer B** pulls and deploys:
   ```bash
   git pull
   bash scripts/deploy-model.sh ./models/custom/team/team-assistant.Modelfile
   ```

### Workflow 3: Disaster Recovery

Regular backups ensure you can recover from data loss:

1. **Schedule regular backups** (e.g., daily cron job):
   ```bash
   # Add to crontab
   0 2 * * * cd /opt/ollama && bash scripts/backup-models.sh /mnt/backup/ollama
   ```

2. **If disaster strikes**, restore from backup:
   ```bash
   # List available backups
   ls -la /mnt/backup/ollama/

   # Deploy models from specific backup
   for modelfile in /mnt/backup/ollama/20240315_020000/*.Modelfile; do
       bash scripts/deploy-model.sh "$modelfile"
   done
   ```

### Workflow 4: Multi-Environment Deployment

Deploy the same model to dev, staging, and prod:

1. **Create master Modelfile** in version control:
   ```bash
   # models/production/customer-support/Modelfile
   FROM llama3.2:3b
   PARAMETER temperature 0.6
   SYSTEM """You are a helpful customer support assistant..."""
   ```

2. **Deploy to all environments**:
   ```bash
   # Development
   ssh dev-server "cd /opt/ollama && bash scripts/deploy-model.sh ./models/production/customer-support/Modelfile"

   # Staging
   ssh stage-server "cd /opt/ollama && bash scripts/deploy-model.sh ./models/production/customer-support/Modelfile"

   # Production
   ssh prod-server "cd /opt/ollama && bash scripts/deploy-model.sh ./models/production/customer-support/Modelfile"
   ```

## What Gets Saved/Deployed?

### Saved in Modelfile
- Base model reference (FROM)
- All parameters (temperature, num_ctx, etc.)
- System prompt (SYSTEM)
- Custom template (TEMPLATE, if defined)
- Few-shot examples (MESSAGE, if defined)
- Adapter references (ADAPTER, if defined)

### NOT Saved in Modelfile
- **Base model weights**: The underlying model (e.g., llama3.2:3b) must be available on the target instance
- **GGUF files**: External model files must be copied separately
- **LoRA adapters**: Adapter files must be transferred separately

## Important Notes

### Base Model Availability

When you deploy a Modelfile, the target instance must have access to the base model:

```dockerfile
FROM llama3.2:3b  # This model must exist on target instance
```

**Before deploying**, ensure base model is available:
```bash
# On target instance
docker compose exec ollama ollama pull llama3.2:3b
```

### External GGUF Models

If your model uses a local GGUF file:

```dockerfile
FROM /data/gguf/my-custom-model.gguf
```

You must transfer the GGUF file separately:
```bash
scp ./data/gguf/my-custom-model.gguf user@target:/opt/ollama/data/gguf/
```

### LoRA Adapters

If your model uses adapters:

```dockerfile
FROM llama3.2:3b
ADAPTER /data/adapters/my-adapter.bin
```

Transfer the adapter file:
```bash
scp ./data/adapters/my-adapter.bin user@target:/opt/ollama/data/adapters/
```

## Automation Scripts

### Automated Deployment Script Example

Create a deployment automation script:

```bash
#!/bin/bash
# deploy-to-production.sh

MODEL_NAME=$1
PROD_SERVER="user@prod-server"
PROD_PATH="/opt/ollama"

# Save model
bash scripts/save-model.sh "$MODEL_NAME"

# Transfer
scp "./models/saved/${MODEL_NAME}.Modelfile" "$PROD_SERVER:$PROD_PATH/models/saved/"

# Deploy remotely
ssh "$PROD_SERVER" "cd $PROD_PATH && bash scripts/deploy-model.sh ./models/saved/${MODEL_NAME}.Modelfile"

echo "✅ Deployed $MODEL_NAME to production"
```

### Automated Backup Script Example

```bash
#!/bin/bash
# backup-to-s3.sh

BACKUP_DIR="/tmp/ollama-backup"

# Create backup
bash scripts/backup-models.sh "$BACKUP_DIR"

# Upload to S3
LATEST_BACKUP=$(ls -t "$BACKUP_DIR" | head -1)
aws s3 sync "$BACKUP_DIR/$LATEST_BACKUP" "s3://my-bucket/ollama-backups/$LATEST_BACKUP/"

# Cleanup local backup
rm -rf "$BACKUP_DIR"

echo "✅ Backup uploaded to S3"
```

## Troubleshooting

### Model Not Found After Deployment

**Issue**: Deployed model doesn't appear in `ollama list`

**Solutions**:
1. Check base model exists: `docker compose exec ollama ollama pull <base-model>`
2. Check Modelfile syntax: Look for errors in deployment output
3. Verify container has access to referenced files (GGUF, adapters)

### Different Behavior on Target Instance

**Issue**: Model behaves differently on target vs source

**Possible causes**:
1. Different base model versions
2. Missing adapter files
3. Hardware differences (CPU vs GPU)

**Solution**: Ensure identical base models and all dependencies are present

### Backup Script Skips Models

**Issue**: Some models aren't included in backups

**Reason**: Script only exports custom models, not base models from Ollama library

**Solution**: This is intended behavior. Base models should be pulled from Ollama library on target instances

## Best Practices

1. **Version Control**: Keep Modelfiles in Git for tracking changes
2. **Naming Convention**: Use descriptive names (e.g., `customer-support-v2`, `code-assistant-python`)
3. **Regular Backups**: Schedule automated backups for custom models
4. **Test Before Production**: Always test deployments in staging first
5. **Document Dependencies**: Note base models and adapters in README or documentation
6. **Environment Parity**: Use same base model versions across environments

## See Also

- [Modelfile Reference](./modelfile-reference.md)
- [Fine-Tuning Guide](./fine-tuning-guide.md)
- [API Usage](./api-usage.md)
