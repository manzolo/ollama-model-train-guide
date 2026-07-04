# Guida all'Uso Avanzato

Argomenti avanzati per utenti esperti che lavorano con i modelli Ollama.

## Configurazioni Multi-Modello

### Eseguire Più Modelli Contemporaneamente

Crea istanze di modello con configurazioni diverse:

```bash
# Create variations of the same base model
bash scripts/create-custom-model.sh chatbot-creative ./models/examples/creative-writer/Modelfile
bash scripts/create-custom-model.sh chatbot-focused ./models/examples/code-assistant/Modelfile
bash scripts/create-custom-model.sh chatbot-balanced ./models/examples/chatbot/Modelfile
```

### Test di Confronto tra Modelli

Confronta gli output di modelli diversi:

```bash
#!/bin/bash
PROMPT="Explain quantum computing"

for model in chatbot-creative chatbot-focused chatbot-balanced; do
    echo "=== $model ==="
    echo "$PROMPT" | docker compose exec -T ollama ollama run $model
    echo ""
done
```

## Template Personalizzati

### Sintassi Avanzata dei Template

I template usano la sintassi dei template Go con variabili speciali:

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

### Variabili Disponibili

- `.System`: contenuto del system prompt
- `.Prompt`: input dell'utente
- `.Response`: output del modello (durante la generazione)
- `.Messages`: cronologia completa della conversazione

### Template per Few-Shot Learning

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

## Adattatori LoRA

### Capire LoRA

LoRA (Low-Rank Adaptation) permette il fine-tuning di un piccolo sottoinsieme dei parametri del modello, rendendolo:
- **Efficiente in memoria**: 1-10% della dimensione completa del modello
- **Veloce da addestrare**: ore invece di giorni
- **Componibile**: più adattatori possono essere combinati
- **Condivisibile**: facile distribuire modelli con fine-tuning

**Per addestrare i tuoi adattatori LoRA** (con Unsloth o Hugging Face) e convertire i modelli in GGUF, consulta la [Guida al Fine-Tuning](./fine-tuning-guide.md) — l'approfondimento di riferimento. Questa sezione tratta solo come **usare** adattatori esistenti con Ollama.

### Usare Più Adattatori

Sebbene Ollama supporti un solo adattatore per modello, puoi creare più varianti di modello:

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

### Best Practice per gli Adattatori

1. **Compatibilità del modello base**: assicurati che l'adattatore sia stato addestrato sulla stessa architettura
2. **Corrispondenza della quantizzazione**: fai corrispondere i livelli di quantizzazione (adattatore a 4-bit → modello a 4-bit)
3. **Tracciamento delle versioni**: documenta quale versione del modello base è stata usata
4. **Test**: valida la qualità dell'adattatore prima dell'uso in produzione

## Uso dell'API

### Endpoint Generate

**Risposte in streaming**:

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "my-chatbot",
  "prompt": "Explain Docker",
  "stream": true
}'
```

**Senza streaming con opzioni**:

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

### Endpoint Chat

**Contesto conversazionale**:

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

Genera embedding vettoriali:

```bash
curl http://localhost:11434/api/embeddings -d '{
  "model": "my-chatbot",
  "prompt": "The quick brown fox jumps over the lazy dog"
}'
```

### Integrazione con Python

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

## Ottimizzazione delle Prestazioni

### Gestione della Finestra di Contesto

Un contesto più grande = generazione più lenta. Ottimizza così:

```dockerfile
# Only increase if you need it
PARAMETER num_ctx 4096  # Default, good for most
# PARAMETER num_ctx 8192  # Only for long documents
```

### Compromessi della Quantizzazione

Scegli la quantizzazione in base alle tue esigenze:

```bash
# Highest quality, largest size
ollama pull llama3.2:3b

# Good balance (recommended)
ollama pull llama3.2:3b-q4_0

# Smallest, fastest
ollama pull llama3.2:3b-q2_K
```

### Configurazione dei Layer su GPU

Regola con precisione l'uso della GPU:

```dockerfile
# Use CPU only (testing)
PARAMETER num_gpu 0

# Use specific number of layers on GPU
PARAMETER num_gpu 20

# Auto (default, uses all GPU when available)
# PARAMETER num_gpu -1
```

### Elaborazione in Batch

Elabora più prompt in modo efficiente:

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

## Versionamento e Gestione dei Modelli

### Controllo di Versione con Git

Traccia i tuoi Modelfile:

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

### Framework di Test per i Modelli

Crea una suite di test per i tuoi modelli:

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

File di dati di test (`tests/chatbot-tests.txt`):
```
What is Docker?|container platform virtualization
Explain Python|programming language interpreted
```

Esegui i test:
```bash
bash tests/model-tests.sh my-chatbot tests/chatbot-tests.txt
```

## Prompt Engineering Avanzato

### Ottimizzazione del System Prompt

**Sbagliato** (vago):
```dockerfile
SYSTEM "You are helpful"
```

**Corretto** (specifico):
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

### Prompt Dinamici tramite Template

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

## Monitoraggio e Logging

### Analisi dei Log

Monitora i log di Ollama per individuare problemi:

```bash
# Follow logs
docker compose logs -f ollama

# Search for errors
docker compose logs ollama | grep -i error

# Check memory usage
docker stats ollama
```

### Metriche di Prestazione

Crea uno script di monitoraggio:

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

## Considerazioni sulla Sicurezza

### Sanitizzazione dell'Input

Valida sempre l'input dell'utente:

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

Implementa il rate limiting per l'accesso all'API:

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

### Controllo degli Accessi ai Modelli

Limita l'accesso ai modelli in base al caso d'uso:

```python
ALLOWED_MODELS = {
    "public": ["chatbot-balanced"],
    "authenticated": ["chatbot-balanced", "code-assistant"],
    "admin": ["chatbot-balanced", "code-assistant", "custom-model"]
}

def check_model_access(user_role, model):
    return model in ALLOWED_MODELS.get(user_role, [])
```

## Backup e Migrazione

### Backup dei Modelli

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

### Ripristino dei Modelli

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

## Risorse

- [Ollama GitHub Issues](https://github.com/ollama/ollama/issues)
- [Ollama Discord Community](https://discord.gg/ollama)
- [Model Performance Benchmarks](https://ollama.com/benchmarks)
