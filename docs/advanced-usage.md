# Advanced Usage Guide

Advanced topics for power users working with Ollama models.

## Multi-Model Setups

### Running Multiple Models Simultaneously

Create model instances with different configurations:

```bash
# Create variations of the same base model
bash scripts/create-custom-model.sh chatbot-creative ./models/examples/creative-writer/Modelfile
bash scripts/create-custom-model.sh chatbot-focused ./models/examples/code-assistant/Modelfile
bash scripts/create-custom-model.sh chatbot-balanced ./models/examples/chatbot/Modelfile
```

### Model Comparison Testing

Compare outputs from different models:

```bash
#!/bin/bash
PROMPT="Explain quantum computing"

for model in chatbot-creative chatbot-focused chatbot-balanced; do
    echo "=== $model ==="
    echo "$PROMPT" | docker compose exec -T ollama ollama run $model
    echo ""
done
```

## Custom Templates

### Advanced Template Syntax

Templates use Go template syntax with special variables:

```dockerfile
TEMPLATE """
{{- if .System }}### System Instructions
{{ .System }}
{{ end }}
{{- if .Prompt }}### User Query
{{ .Prompt }}
{{ end }}
### AI Response
{{ .Response }}
"""
```

### Variables Available

- `.System`: System prompt content
- `.Prompt`: User's input
- `.Response`: Model's output (during generation)
- `.Messages`: Full conversation history

### Few-Shot Learning Template

```dockerfile
TEMPLATE """
You are an expert translator. Here are some examples:

English: Hello
Spanish: Hola

English: Goodbye  
Spanish: Adiós

{{ if .Prompt }}English: {{ .Prompt }}
Spanish: {{ end }}{{ .Response }}
"""
```

## LoRA Adapters

### Understanding LoRA

LoRA (Low-Rank Adaptation) allows fine-tuning only a small subset of model parameters, making it:
- **Memory efficient**: 1-10% of full model size
- **Fast to train**: Hours instead of days
- **Composable**: Multiple adapters can be combined
- **Shareable**: Easy to distribute fine-tuned models

### Using Multiple Adapters

While Ollama supports one adapter per model, you can create multiple model variants:

```bash
# Adapter for medical terminology
FROM llama3.2:3b
ADAPTER /data/adapters/medical-lora.bin
SYSTEM "You are a medical AI assistant"
```

```bash
# Adapter for legal documents
FROM llama3.2:3b
ADAPTER /data/adapters/legal-lora.bin
SYSTEM "You are a legal document analyst"
```

### Adapter Best Practices

1. **Base model compatibility**: Ensure adapter was trained on same architecture
2. **Quantization matching**: Match quantization levels (4-bit adapter → 4-bit model)
3. **Version tracking**: Document which base model version was used
4. **Testing**: Validate adapter quality before production use

## API Usage

### Generate Endpoint

**Streaming responses**:

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "my-chatbot",
  "prompt": "Explain Docker",
  "stream": true
}'
```

**Non-streaming with options**:

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "my-chatbot",
  "prompt": "Write a haiku about coding",
  "stream": false,
  "options": {
    "temperature": 1.0,
    "top_k": 50,
    "top_p": 0.95
  }
}'
```

### Chat Endpoint

**Conversational context**:

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "my-chatbot",
  "messages": [
    {"role": "user", "content": "What is Python?"},
    {"role": "assistant", "content": "Python is a programming language..."},
    {"role": "user", "content": "What are its main features?"}
  ]
}'
```

### Embeddings

Generate vector embeddings:

```bash
curl http://localhost:11434/api/embeddings -d '{
  "model": "my-chatbot",
  "prompt": "The quick brown fox jumps over the lazy dog"
}'
```

### Python Integration

```python
import requests
import json

def chat_with_model(model, prompt, context=[]):
    """Chat with an Ollama model"""
    url = "http://localhost:11434/api/chat"
    
    messages = context + [{"role": "user", "content": prompt}]
    
    response = requests.post(url, json={
        "model": model,
        "messages": messages,
        "stream": False
    })
    
    result = response.json()
    return result["message"]["content"]

# Usage
response = chat_with_model("my-chatbot", "Hello!")
print(response)
```

## Performance Optimization

### Context Window Management

Larger context = slower generation. Optimize by:

```dockerfile
# Only increase if you need it
PARAMETER num_ctx 4096  # Default, good for most
# PARAMETER num_ctx 8192  # Only for long documents
```

### Quantization Trade-offs

Choose quantization based on needs:

```bash
# Highest quality, largest size
ollama pull llama3.2:3b

# Good balance (recommended)
ollama pull llama3.2:3b-q4_0

# Smallest, fastest
ollama pull llama3.2:3b-q2_K
```

### GPU Layer Configuration

Fine-tune GPU usage:

```dockerfile
# Use CPU only (testing)
PARAMETER num_gpu 0

# Use specific number of layers on GPU
PARAMETER num_gpu 20

# Auto (default, uses all GPU when available)
# PARAMETER num_gpu -1
```

### Batch Processing

Process multiple prompts efficiently:

```python
import concurrent.futures
import requests

def process_prompt(prompt):
    response = requests.post("http://localhost:11434/api/generate", json={
        "model": "my-chatbot",
        "prompt": prompt,
        "stream": False
    })
    return response.json()["response"]

prompts = [
    "What is AI?",
    "Explain machine learning",
    "What is deep learning?"
]

with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
    results = list(executor.map(process_prompt, prompts))

for prompt, result in zip(prompts, results):
    print(f"Q: {prompt}\nA: {result}\n")
```

## Model Versioning and Management

### Version Control with Git

Track your Modelfiles:

```bash
# Initialize git in custom models
cd models/custom
git init

# Create versioned models
mkdir v1-chatbot
# ... create Modelfile
git add v1-chatbot/
git commit -m "Initial chatbot model"

# Iterate
mkdir v2-chatbot
# ... improve Modelfile
git add v2-chatbot/
git commit -m "Improved system prompt and parameters"
```

### Model Testing Framework

Create a test suite for your models:

```bash
#!/bin/bash
# tests/model-tests.sh

MODEL=$1
TEST_FILE=$2

while IFS='|' read -r prompt expected_keywords; do
    echo "Testing: $prompt"
    
    response=$(echo "$prompt" | docker compose exec -T ollama ollama run $MODEL)
    
    for keyword in $expected_keywords; do
        if echo "$response" | grep -qi "$keyword"; then
            echo "✓ Found keyword: $keyword"
        else
            echo "✗ Missing keyword: $keyword"
        fi
    done
    echo ""
done < "$TEST_FILE"
```

Test data file (`tests/chatbot-tests.txt`):
```
What is Docker?|container platform virtualization
Explain Python|programming language interpreted
```

Run tests:
```bash
bash tests/model-tests.sh my-chatbot tests/chatbot-tests.txt
```

## Advanced Prompt Engineering

### System Prompt Optimization

**Bad** (vague):
```dockerfile
SYSTEM "You are helpful"
```

**Good** (specific):
```dockerfile
SYSTEM """
You are a technical support specialist for cloud infrastructure.

Your responses must:
- Start with a direct answer
- Provide step-by-step instructions when relevant
- Include command examples in code blocks
- Mention potential pitfalls
- Be concise (under 200 words unless user asks for detail)

When you don't know something, admit it and suggest where to find the answer.
"""
```

### Dynamic Prompts via Templates

```dockerfile
TEMPLATE """
{{- if .System }}[SYSTEM]
{{ .System }}
[/SYSTEM]

{{ end -}}
[RULES]
- Be concise
- Use bullet points
- Include examples
[/RULES]

{{- if .Prompt }}
[USER]
{{ .Prompt }}
[/USER]

{{ end -}}
[ASSISTANT]
{{ .Response }}
"""
```

## Monitoring and Logging

### Log Analysis

Monitor Ollama logs for issues:

```bash
# Follow logs
docker compose logs -f ollama

# Search for errors
docker compose logs ollama | grep -i error

# Check memory usage
docker stats ollama
```

### Performance Metrics

Create a monitoring script:

```python
import time
import requests
import statistics

def benchmark_model(model, prompt, runs=5):
    """Benchmark model response time"""
    times = []
    
    for _ in range(runs):
        start = time.time()
        requests.post("http://localhost:11434/api/generate", json={
            "model": model,
            "prompt": prompt,
            "stream": False
        })
        times.append(time.time() - start)
    
    return {
        "avg": statistics.mean(times),
        "min": min(times),
        "max": max(times),
        "stdev": statistics.stdev(times) if len(times) > 1 else 0
    }

results = benchmark_model("my-chatbot", "Hello, world!")
print(f"Average: {results['avg']:.2f}s")
print(f"Min: {results['min']:.2f}s, Max: {results['max']:.2f}s")
```

## Security Considerations

### Input Sanitization

Always validate user input:

```python
def sanitize_prompt(prompt):
    """Basic prompt sanitization"""
    # Limit length
    max_length = 1000
    prompt = prompt[:max_length]
    
    # Remove potential injection attempts
    dangerous_patterns = [
        "SYSTEM",
        "[INST]",
        "</s>",
    ]
    
    for pattern in dangerous_patterns:
        prompt = prompt.replace(pattern, "")
    
    return prompt
```

### Rate Limiting

Implement rate limiting for API access:

```python
from flask_limiter import Limiter
from flask import Flask

app = Flask(__name__)
limiter = Limiter(app, default_limits=["100 per hour"])

@app.route("/chat")
@limiter.limit("10 per minute")
def chat():
    # Your Ollama API call here
    pass
```

### Model Access Control

Restrict model access based on use case:

```python
ALLOWED_MODELS = {
    "public": ["chatbot-balanced"],
    "authenticated": ["chatbot-balanced", "code-assistant"],
    "admin": ["chatbot-balanced", "code-assistant", "custom-model"]
}

def check_model_access(user_role, model):
    return model in ALLOWED_MODELS.get(user_role, [])
```

## Backup and Migration

### Backup Models

```bash
#!/bin/bash
# backup-models.sh

BACKUP_DIR="backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Export all custom models
docker compose exec ollama ollama list | tail -n +2 | while read -r line; do
    model=$(echo "$line" | awk '{print $1}')
    echo "Backing up $model..."
    docker compose exec ollama ollama show "$model" --modelfile > "$BACKUP_DIR/$model-Modelfile"
done

echo "Backup complete: $BACKUP_DIR"
```

### Restore Models

```bash
#!/bin/bash
# restore-models.sh

BACKUP_DIR=$1

for modelfile in "$BACKUP_DIR"/*-Modelfile; do
    model=$(basename "$modelfile" -Modelfile)
    echo "Restoring $model..."
    docker compose exec ollama ollama create "$model" -f "/host/$modelfile"
done
```

## Resources

- [Ollama GitHub Issues](https://github.com/ollama/ollama/issues)
- [Ollama Discord Community](https://discord.gg/ollama)
- [Model Performance Benchmarks](https://ollama.com/benchmarks)
