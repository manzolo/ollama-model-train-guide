# Guida all'uso delle API di Ollama

Riferimento completo per l'utilizzo delle API di Ollama con i tuoi modelli personalizzati.

## Panoramica degli endpoint API

Ollama fornisce un'API REST accessibile all'indirizzo `http://localhost:11434` con i seguenti endpoint principali:

- `/api/generate` - Genera testo a partire da un prompt
- `/api/chat` - Sostiene una conversazione con contesto
- `/api/tags` - Elenca i modelli disponibili
- `/api/show` - Mostra le informazioni di un modello
- `/api/create` - Crea un modello da un Modelfile
- `/api/pull` - Scarica un modello
- `/api/push` - Carica un modello (richiede un registry)
- `/api/embeddings` - Genera embedding
- `/api/delete` - Elimina un modello

## API Generate

### Generazione di base

Genera testo a partire da un singolo prompt senza cronologia della conversazione.

**Richiesta**:
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "my-chatbot",
  "prompt": "Why is the sky blue?",
  "stream": false
}'
```

**Risposta**:
```json
{
  "model": "my-chatbot",
  "created_at": "2024-12-07T12:00:00.000Z",
  "response": "The sky appears blue because...",
  "done": true,
  "total_duration": 5000000000,
  "load_duration": 1000000000,
  "prompt_eval_count": 10,
  "eval_count": 50
}
```

### Generazione in streaming

Ottieni la risposta man mano che viene generata (consigliato per le UI):

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "my-chatbot",
  "prompt": "Write a story about a robot",
  "stream": true
}'
```

**Risposta** (più oggetti JSON, uno per token):
```json
{"model":"my-chatbot","created_at":"...","response":"Once","done":false}
{"model":"my-chatbot","created_at":"...","response":" upon","done":false}
{"model":"my-chatbot","created_at":"...","response":" a","done":false}
...
{"model":"my-chatbot","created_at":"...","response":"","done":true,"total_duration":5000000000}
```

### Con opzioni

Sovrascrivi i parametri del modello per singola richiesta:

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "my-chatbot",
  "prompt": "Write a creative story",
  "stream": false,
  "options": {
    "temperature": 1.2,
    "top_k": 50,
    "top_p": 0.95,
    "num_predict": 200
  }
}'
```

### Opzioni disponibili

```json
{
  "temperature": 0.8,     // Randomness (0.0-2.0)
  "top_k": 40,           // Top-K sampling
  "top_p": 0.9,          // Top-P sampling  
  "num_ctx": 4096,       // Context window
  "num_predict": -1,     // Max tokens (-1 = unlimited)
  "repeat_penalty": 1.1, // Repetition penalty
  "repeat_last_n": 64,   // Tokens to check for repeat
  "stop": ["User:", "\n\n"], // Stop sequences
  "seed": 42             // Random seed for reproducibility
}
```

## API Chat

### Contesto conversazionale

Mantieni la cronologia della conversazione per risposte consapevoli del contesto:

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "my-chatbot",
  "messages": [
    {
      "role": "user",
      "content": "What is Docker?"
    },
    {
      "role": "assistant",
      "content": "Docker is a platform for containerization..."
    },
    {
      "role": "user",
      "content": "How does it differ from VMs?"
    }
  ],
  "stream": false
}'
```

**Risposta**:
```json
{
  "model": "my-chatbot",
  "created_at": "2024-12-07T12:00:00.000Z",
  "message": {
    "role": "assistant",
    "content": "Docker differs from VMs in several ways..."
  },
  "done": true
}
```

### Messaggio di sistema

Includi un messaggio di sistema per impostare il comportamento in questa conversazione:

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "my-chatbot",
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful coding assistant. Answer in bullet points."
    },
    {
      "role": "user",
      "content": "Explain Python decorators"
    }
  ]
}'
```

### Chat in streaming

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "my-chatbot",
  "messages": [
    {"role": "user", "content": "Tell me a joke"}
  ],
  "stream": true
}'
```

## API di gestione dei modelli

### Elencare i modelli

```bash
curl http://localhost:11434/api/tags
```

**Risposta**:
```json
{
  "models": [
    {
      "name": "my-chatbot:latest",
      "modified_at": "2024-12-07T12:00:00Z",
      "size": 1234567890,
      "digest": "sha256:..."
    }
  ]
}
```

### Mostrare le informazioni di un modello

```bash
curl http://localhost:11434/api/show -d '{
  "name": "my-chatbot"
}'
```

**Risposta**:
```json
{
  "modelfile": "FROM llama3.2:1b\nPARAMETER temperature 0.7\n...",
  "parameters": "temperature 0.7\nnum_ctx 4096",
  "template": "{{ .System }}\n{{ .Prompt }}",
  "details": {
    "format": "gguf",
    "family": "llama",
    "parameter_size": "1B",
    "quantization_level": "Q4_0"
  }
}
```

### Creare un modello

```bash
curl http://localhost:11434/api/create -d '{
  "name": "my-new-model",
  "modelfile": "FROM llama3.2:1b\nPARAMETER temperature 0.8\nSYSTEM You are helpful",
  "stream": false
}'
```

### Scaricare un modello

```bash
curl http://localhost:11434/api/pull -d '{
  "name": "llama3.2:1b",
  "stream": true
}'
```

### Eliminare un modello

```bash
curl -X DELETE http://localhost:11434/api/delete -d '{
  "name": "my-chatbot"
}'
```

## API Embeddings

Genera embedding vettoriali per la ricerca semantica:

```bash
curl http://localhost:11434/api/embeddings -d '{
  "model": "my-chatbot",
  "prompt": "The quick brown fox jumps over the lazy dog"
}'
```

**Risposta**:
```json
{
  "embedding": [0.123, -0.456, 0.789, ...]
}
```

## Esempi di codice

### Python

#### Generazione semplice

```python
import requests
import json

def generate_text(model, prompt, stream=False):
    url = "http://localhost:11434/api/generate"
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": stream
    }
    
    response = requests.post(url, json=payload)
    
    if stream:
        for line in response.iter_lines():
            if line:
                data = json.loads(line)
                print(data.get("response", ""), end="", flush=True)
                if data.get("done"):
                    break
    else:
        return response.json()["response"]

# Usage
result = generate_text("my-chatbot", "What is Python?")
print(result)
```

#### Chat con contesto

```python
class OllamaChat:
    def __init__(self, model):
        self.model = model
        self.messages = []
        self.url = "http://localhost:11434/api/chat"
    
    def send_message(self, content, role="user"):
        self.messages.append({"role": role, "content": content})
        
        response = requests.post(self.url, json={
            "model": self.model,
            "messages": self.messages,
            "stream": False
        })
        
        result = response.json()
        assistant_message = result["message"]
        self.messages.append(assistant_message)
        
        return assistant_message["content"]
    
    def reset(self):
        self.messages = []

# Usage
chat = OllamaChat("my-chatbot")
print(chat.send_message("Hello!"))
print(chat.send_message("What can you help me with?"))
```

#### Generazione asincrona

```python
import asyncio
import aiohttp

async def generate_async(model, prompt):
    url = "http://localhost:11434/api/generate"
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False
    }
    
    async with aiohttp.ClientSession() as session:
        async with session.post(url, json=payload) as response:
            result = await response.json()
            return result["response"]

# Usage
async def main():
    tasks = [
        generate_async("my-chatbot", "What is AI?"),
        generate_async("my-chatbot", "What is ML?"),
        generate_async("my-chatbot", "What is DL?"),
    ]
    results = await asyncio.gather(*tasks)
    for i, result in enumerate(results, 1):
        print(f"Response {i}: {result}")

asyncio.run(main())
```

### JavaScript/Node.js

#### Generazione di base

```javascript
const axios = require('axios');

async function generate(model, prompt) {
  const response = await axios.post('http://localhost:11434/api/generate', {
    model: model,
    prompt: prompt,
    stream: false
  });
  
  return response.data.response;
}

// Usage
generate('my-chatbot', 'What is JavaScript?')
  .then(result => console.log(result))
  .catch(error => console.error(error));
```

#### Streaming con Fetch

```javascript
async function generateStream(model, prompt) {
  const response = await fetch('http://localhost:11434/api/generate', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      model: model,
      prompt: prompt,
      stream: true
    })
  });

  const reader = response.body.getReader();
  const decoder = new TextDecoder();

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    const chunk = decoder.decode(value);
    const lines = chunk.split('\n').filter(line => line.trim());
    
    for (const line of lines) {
      const data = JSON.parse(line);
      process.stdout.write(data.response);
      if (data.done) return;
    }
  }
}

// Usage
generateStream('my-chatbot', 'Write a short poem');
```

#### Classe Chat

```javascript
class OllamaChat {
  constructor(model) {
    this.model = model;
    this.messages = [];
    this.url = 'http://localhost:11434/api/chat';
  }

  async sendMessage(content) {
    this.messages.push({ role: 'user', content });

    const response = await axios.post(this.url, {
      model: this.model,
      messages: this.messages,
      stream: false
    });

    const assistantMessage = response.data.message;
    this.messages.push(assistantMessage);

    return assistantMessage.content;
  }

  reset() {
    this.messages = [];
  }
}

// Usage
const chat = new OllamaChat('my-chatbot');
chat.sendMessage('Hello!').then(console.log);
```

### Go

```go
package main

import (
    "bytes"
    "encoding/json"
    "fmt"
    "net/http"
)

type GenerateRequest struct {
    Model  string `json:"model"`
    Prompt string `json:"prompt"`
    Stream bool   `json:"stream"`
}

type GenerateResponse struct {
    Response string `json:"response"`
    Done     bool   `json:"done"`
}

func generate(model, prompt string) (string, error) {
    url := "http://localhost:11434/api/generate"
    
    reqBody, _ := json.Marshal(GenerateRequest{
        Model:  model,
        Prompt: prompt,
        Stream: false,
    })
    
    resp, err := http.Post(url, "application/json", bytes.NewBuffer(reqBody))
    if err != nil {
        return "", err
    }
    defer resp.Body.Close()
    
    var result GenerateResponse
    if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
        return "", err
    }
    
    return result.Response, nil
}

func main() {
    result, err := generate("my-chatbot", "What is Go?")
    if err != nil {
        fmt.Println("Error:", err)
        return
    }
    fmt.Println(result)
}
```

## Gestione degli errori

### Codici di stato HTTP comuni

- **200 OK**: Richiesta riuscita
- **400 Bad Request**: Formato della richiesta non valido
- **404 Not Found**: Modello non trovato
- **500 Internal Server Error**: Errore del server

### Formato della risposta di errore

```json
{
  "error": "model 'nonexistent' not found"
}
```

### Gestione degli errori in Python

```python
def generate_with_error_handling(model, prompt):
    try:
        response = requests.post(
            "http://localhost:11434/api/generate",
            json={"model": model, "prompt": prompt, "stream": False},
            timeout=30
        )
        response.raise_for_status()
        return response.json()["response"]
        
    except requests.exceptions.ConnectionError:
        return "Error: Could not connect to Ollama server"
    except requests.exceptions.Timeout:
        return "Error: Request timed out"
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 404:
            return f"Error: Model '{model}' not found"
        return f"HTTP Error: {e.response.status_code}"
    except Exception as e:
        return f"Unexpected error: {str(e)}"
```

## Best practice

### 1. Usa lo streaming per le risposte lunghe

Migliora l'esperienza utente mostrando l'avanzamento:

```python
for chunk in stream_generate(model, prompt):
    print(chunk, end="", flush=True)
```

### 2. Implementa i timeout

Evita richieste bloccate:

```python
response = requests.post(url, json=payload, timeout=30)
```

### 3. Gestisci i limiti della context window

Monitora il conteggio dei token e riduci la cronologia della conversazione:

```python
def trim_messages(messages, max_tokens=4000):
    # Keep system message and recent messages
    if len(messages) > 10:
        return [messages[0]] + messages[-9:]
    return messages
```

### 4. Metti in cache gli embedding

Non rigenerare gli embedding per lo stesso testo:

```python
embedding_cache = {}

def get_embedding(text):
    if text not in embedding_cache:
        embedding_cache[text] = generate_embedding(text)
    return embedding_cache[text]
```

### 5. Usa il connection pooling

Per applicazioni ad alto throughput:

```python
session = requests.Session()
session.mount('http://', requests.adapters.HTTPAdapter(pool_maxsize=10))
```

## Rate limiting

Proteggi il tuo server con il rate limiting:

```python
import time
from collections import deque

class RateLimiter:
    def __init__(self, max_calls, period):
        self.max_calls = max_calls
        self.period = period
        self.calls = deque()
    
    def __call__(self, func):
        def wrapper(*args, **kwargs):
            now = time.time()
            # Remove old calls
            while self.calls and self.calls[0] < now - self.period:
                self.calls.popleft()
            
            if len(self.calls) >= self.max_calls:
                sleep_time = self.period - (now - self.calls[0])
                time.sleep(sleep_time)
            
            self.calls.append(time.time())
            return func(*args, **kwargs)
        return wrapper

@RateLimiter(max_calls=10, period=60)  # 10 calls per minute
def generate_text(prompt):
    # Your API call here
    pass
```

## Risorse

- [Documentazione API di Ollama](https://github.com/ollama/ollama/blob/main/docs/api.md)
- [Specifica OpenAPI](https://github.com/ollama/ollama/blob/main/docs/openapi.yaml)
- [Esempi della community](https://github.com/ollama/ollama#community-integrations)
