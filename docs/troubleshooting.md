# Troubleshooting Guide

Common issues and solutions for the Ollama Model Training Guide.

## Table of Contents

- [Service Issues](#service-issues)
- [Model Issues](#model-issues)
- [Network and API Issues](#network-and-api-issues)
- [Performance Issues](#performance-issues)
- [Disk Space Issues](#disk-space-issues)
- [Chat UI Issues](#chat-ui-issues)
- [Converter Issues](#converter-issues)
- [GPU Issues](#gpu-issues)

---

## Service Issues

### Ollama service won't start

**Symptoms**: `docker compose up` fails or service immediately exits

**Check Docker is running**:
```bash
docker ps
# If this fails, Docker daemon is not running
```

**Solution**:
```bash
# Ubuntu/Debian
sudo systemctl start docker
sudo systemctl enable docker

# Check status
sudo systemctl status docker
```

**Check logs**:
```bash
make logs
# Or:
docker compose logs ollama
```

Look for error messages indicating:
- Port conflicts
- Volume mount issues
- Permission problems

**Restart services**:
```bash
make restart
```

### Chat UI won't start

**Check both services**:
```bash
docker compose ps
```

Both `ollama` and `ollama-chat` should be "Up".

**Check Chat logs**:
```bash
docker compose logs chat
```

**Rebuild Chat container**:
```bash
docker compose build chat
docker compose up -d
```

### Container immediately exits

**Check for port conflicts**:
```bash
# Check if port 11434 is already in use
netstat -an | grep 11434

# Check if port 8080 is already in use
netstat -an | grep 8080
```

**Solution**: Change ports in `.env`:
```bash
OLLAMA_PORT=11435
CHAT_PORT=8081
```

Then restart:
```bash
make restart
```

### Permission denied errors

**Add user to docker group**:
```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

**Fix volume permissions**:
```bash
# Check volume ownership
docker volume inspect ollama_data

# If needed, fix permissions
docker compose down
docker volume rm ollama_data
make up
```

---

## Model Issues

### Model creation fails

**Symptoms**: `bash scripts/create-custom-model.sh` fails with error

**Verify base model exists**:
```bash
docker compose exec ollama ollama list
```

If base model missing, pull it:
```bash
docker compose exec ollama ollama pull llama3.2:1b
```

**Validate Modelfile syntax**:
```bash
# Check Modelfile exists
cat ./models/custom/my-model/Modelfile

# Verify FROM line uses correct model name
grep "FROM" ./models/custom/my-model/Modelfile
```

**Common syntax errors**:
- Missing `FROM` line
- Incorrect base model name
- Malformed PARAMETER lines
- Missing quotes in SYSTEM prompt

**Test Modelfile manually**:
```bash
docker compose exec ollama ollama create test -f /models/examples/chatbot/Modelfile
```

### Model downloads fail or timeout

**Check internet connection**:
```bash
docker compose exec ollama ping -c 3 ollama.com
```

**Check Docker network**:
```bash
docker network ls
docker network inspect ollama-model-train-guide_default
```

**Retry with larger timeout**:
```bash
# Some models are large (>10GB) and may take time
docker compose exec ollama ollama pull mistral:7b
# Wait patiently...
```

**Check disk space** (see [Disk Space Issues](#disk-space-issues))

### Model responses are poor quality

**Adjust temperature**:
- Too high (>1.5): Random, incoherent
- Too low (<0.1): Repetitive, rigid

**Increase context window**:
```dockerfile
PARAMETER num_ctx 8192
# Instead of 2048
```

**Use better base model**:
- Upgrade from 1B to 3B or 7B model
- Try different model families (Mistral, CodeLlama, etc.)

**Add few-shot examples**:
```dockerfile
MESSAGE user "Example question?"
MESSAGE assistant "Example high-quality answer."
```

### Model runs out of memory

**Symptoms**: Service crashes, "out of memory" errors

**Use smaller model**:
- `llama3.2:1b` instead of `mistral:7b`
- Quantized versions (if available)

**Reduce context window**:
```dockerfile
PARAMETER num_ctx 2048
# Instead of 8192
```

**Increase system RAM** or enable GPU acceleration

**Check Docker resource limits**:
```bash
docker stats
```

---

## Network and API Issues

### API not accessible

**Check service is running**:
```bash
docker compose ps
```

**Verify port mapping**:
```bash
netstat -an | grep 11434
```

**Test API directly**:
```bash
curl http://localhost:11434/api/tags
```

If this fails:
```bash
# Check firewall
sudo ufw status

# Try from within container
docker compose exec ollama curl http://localhost:11434/api/tags
```

### API returns errors

**"model not found"**:
```bash
# List available models
docker compose exec ollama ollama list

# Pull missing model
docker compose exec ollama ollama pull <model-name>
```

**Connection timeout**:
```bash
# Check if Ollama is responsive
docker compose logs ollama

# Restart if needed
make restart
```

**Rate limiting or slow responses**:
- Reduce concurrent requests
- Enable GPU acceleration
- Use smaller models

### Cannot connect from external host

**Ollama is bound to 0.0.0.0** by default in `docker-compose.yml`.

**Check firewall rules**:
```bash
sudo ufw allow 11434/tcp
sudo ufw allow 8080/tcp
```

**Verify Docker network**:
```bash
docker compose exec ollama env | grep OLLAMA_HOST
# Should show: OLLAMA_HOST=0.0.0.0
```

---

## Performance Issues

### Slow model responses

**Enable GPU acceleration**:
See [Installation Guide - GPU Support](./installation.md#gpu-support-optional)

**Use smaller models**:
- `llama3.2:1b` (fastest)
- `phi3:mini` (fast and good quality)
- `llama3.2:3b` (balanced)

**Reduce context window**:
```dockerfile
PARAMETER num_ctx 2048
```

**Check system resources**:
```bash
docker stats
htop  # or top
```

Look for:
- High CPU usage
- Memory pressure
- Disk I/O bottlenecks

**Upgrade hardware**:
- Add more RAM (16GB+ recommended)
- Use SSD instead of HDD
- Add GPU acceleration

### High memory usage

**Check memory consumption**:
```bash
docker stats ollama
```

**Solutions**:
- Use smaller models (1B-3B instead of 7B+)
- Reduce context window
- Limit concurrent requests
- Enable GPU to offload from CPU memory

### Chat UI is slow

**Check API response time**:
```bash
time curl http://localhost:11434/api/generate -d '{"model":"llama3.2:1b","prompt":"Hi","stream":false}'
```

If API is slow, see model performance issues above.

**Check browser console** for JavaScript errors:
- Open DevTools (F12)
- Check Console tab for errors
- Check Network tab for slow requests

---

## Disk Space Issues

### Not enough space for models

**Check available space**:
```bash
df -h
docker system df
```

**Check model sizes**:
```bash
docker compose exec ollama ollama list
```

**Clean up Docker resources**:
```bash
# Remove unused images
docker image prune -a

# Remove unused volumes (CAUTION: may delete models)
docker volume prune

# Full cleanup
docker system prune -a --volumes
```

**Delete unused models**:
```bash
docker compose exec ollama ollama rm <unused-model>
```

**Move Docker data directory**:
```bash
# Stop Docker
sudo systemctl stop docker

# Edit daemon.json
sudo nano /etc/docker/daemon.json
# Add: {"data-root": "/new/path"}

# Move data
sudo mv /var/lib/docker /new/path/

# Start Docker
sudo systemctl start docker
```

### Volume is full

**Check volume size**:
```bash
docker volume inspect ollama_data
```

**Recreate volume with more space**:
```bash
# Backup models first!
make backup-models

# Remove old volume
docker compose down
docker volume rm ollama_data

# Start fresh
make up
make pull-base
```

---

## Chat UI Issues

### Models not showing in dropdown

**Verify Ollama API is accessible**:
```bash
curl http://localhost:11434/api/tags
```

**Check Chat UI logs**:
```bash
docker compose logs chat
```

**Restart Chat UI**:
```bash
docker compose restart chat
```

**Clear browser cache**:
- Press `Ctrl+Shift+R` (Windows/Linux)
- Press `Cmd+Shift+R` (Mac)

### Model pulling shows no progress

**Check if model is actually downloading**:
```bash
docker compose logs -f ollama
```

**Try pulling via CLI**:
```bash
docker compose exec ollama ollama pull llama3.2:1b
```

**Check network speed**:
```bash
# Test download speed
docker compose exec ollama curl -o /dev/null http://speedtest.example.com/file
```

### Chat responses cut off

**Increase context window** in model's Modelfile:
```dockerfile
PARAMETER num_ctx 8192
```

**Check for API timeout** in Chat UI logs:
```bash
docker compose logs chat | grep timeout
```

---

## Converter Issues

### File upload fails

**Check file size**:
Very large files (>50MB) may timeout. Try splitting into smaller files.

**Check file format**:
- Ensure `.xlsx`, `.xls`, or `.csv`
- Ensure file is not corrupted

**Check permissions**:
```bash
ls -la ./data/training/
```

Directory should be writable.

**Check logs**:
```bash
docker compose logs chat | grep converter
```

### Conversion produces empty file

**Check column mapping**:
- Ensure correct columns are selected
- Preview data before converting
- Verify source data has content

**Check output file**:
```bash
cat ./data/training/output.jsonl
```

**Manual conversion**:
Try using the Python script directly:
```bash
python3 scripts/spreadsheet-to-jsonl.py input.csv output.jsonl --preview 5
```

### Auto-detection fails

**Manually specify columns** in the UI:
- Select "Question" column from dropdown
- Select "Answer" column from dropdown
- Preview to verify

**Check column names** in source file:
- Use clear names like "question", "answer"
- Avoid special characters
- Use first row as headers

---

## GPU Issues

### GPU not detected

**Check NVIDIA driver**:
```bash
nvidia-smi
```

If this fails, install/update NVIDIA drivers.

**Check NVIDIA Container Toolkit**:
```bash
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi
```

**Verify Docker Compose GPU config**:
```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
```

**Restart Docker**:
```bash
sudo systemctl restart docker
make restart
```

### GPU not being used

**Check Ollama is detecting GPU**:
```bash
docker compose exec ollama nvidia-smi
```

**Check during inference**:
```bash
# In one terminal
watch -n 1 nvidia-smi

# In another terminal
docker compose exec ollama ollama run llama3.2:1b "Long prompt here..."
```

GPU usage should increase during generation.

**Ensure model fits in VRAM**:
- Check GPU memory with `nvidia-smi`
- Use smaller models if needed
- Monitor VRAM usage

### Out of GPU memory

**Use smaller models**:
- Try quantized versions
- Use 1B-3B models instead of 7B+

**Reduce batch size** (for API usage):
Lower concurrent requests to reduce VRAM usage.

**Check other GPU processes**:
```bash
nvidia-smi
# Look for other processes using GPU
```

---

## Getting Additional Help

### Check Logs

**All services**:
```bash
make logs
```

**Specific service**:
```bash
docker compose logs ollama
docker compose logs chat
```

**Follow logs in real-time**:
```bash
docker compose logs -f
```

### Run Tests

**Quick test**:
```bash
make quick-test
```

**Validation tests**:
```bash
make test
```

**TechCorp dataset example**:
```bash
bash scripts/test-techcorp-example.sh
```

### Collect Debug Information

```bash
# System info
uname -a
docker --version
docker compose version

# Service status
docker compose ps
docker compose logs --tail=50

# Resource usage
docker stats --no-stream
df -h

# Network
netstat -an | grep -E "11434|8080"

# Models
docker compose exec ollama ollama list
```

### Community Resources

- [Ollama Documentation](https://ollama.com/docs)
- [Ollama GitHub Issues](https://github.com/ollama/ollama/issues)
- [Docker Documentation](https://docs.docker.com)
- [Project GitHub Issues](https://github.com/manzolo/ollama-model-train-guide/issues)

### Still Stuck?

1. **Search existing issues** on GitHub
2. **Create a new issue** with:
   - Description of the problem
   - Error messages
   - Log output
   - System information
   - Steps to reproduce

---

## Preventive Maintenance

### Regular Cleanup

```bash
# Weekly: Clean up Docker resources
docker system prune

# Monthly: Review and delete unused models
docker compose exec ollama ollama list
docker compose exec ollama ollama rm <unused-model>

# Quarterly: Backup custom models
make backup-models
```

### Monitor Disk Space

```bash
# Check before pulling large models
df -h
docker system df
```

### Keep Services Updated

```bash
# Pull latest Ollama image
docker compose pull

# Rebuild Chat UI with updates
docker compose build chat

# Restart services
make restart
```

### Backup Strategy

```bash
# Backup custom Modelfiles
make backup-models

# Export important models
bash scripts/export-model.sh my-important-model ./backups/my-model.Modelfile

# Backup training data
cp -r ./data/training ./backups/training-$(date +%Y%m%d)
```
