# Ollama API Usage Guide

Complete reference for using the Ollama API with your custom models.

## API Endpoints Overview

Ollama provides a REST API accessible at `http://localhost:11434` with the following main endpoints:

- `/api/generate` - Generate text from a prompt
- `/api/chat` - Have a conversation with context
- `/api/tags` - List available models
- `/api/show` - Show model information
- `/api/create` - Create a model from Modelfile
- `/api/pull` - Download a model
- `/api/push` - Upload a model (requires registry)
- `/api/embeddings` - Generate embeddings
- `/api/delete` - Delete a model

## Generate API

### Basic Generation

Generate text from a single prompt without conversation history.

**Request**:
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "my-chatbot",
  "prompt": "Why is the sky blue?",
  "stream": false
}'
```

**Response**:
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

### Streaming Generation

Get response as it's generated (recommended for UIs):

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "my-chatbot",
  "prompt": "Write a story about a robot",
  "stream": true
}'
```

**Response** (multiple JSON objects, one per token):
```json
{"model":"my-chatbot","created_at":"...","response":"Once","done":false}
{"model":"my-chatbot","created_at":"...","response":" upon","done":false}
{"model":"my-chatbot","created_at":"...","response":" a","done":false}
...
{"model":"my-chatbot","created_at":"...","response":"","done":true,"total_duration":5000000000}
```

### With Options

Override model parameters per request:

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

### Available Options

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

## Chat API

### Conversational Context

Maintain conversation history for context-aware responses:

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

**Response**:
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

### System Message

Include a system message to set behavior for this conversation:

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

### Streaming Chat

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "my-chatbot",
  "messages": [
    {"role": "user", "content": "Tell me a joke"}
  ],
  "stream": true
}'
```

## Model Management API

### List Models

```bash
curl http://localhost:11434/api/tags
```

**Response**:
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

### Show Model Info

```bash
curl http://localhost:11434/api/show -d '{
  "name": "my-chatbot"
}'
```

**Response**:
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

### Create Model

```bash
curl http://localhost:11434/api/create -d '{
  "name": "my-new-model",
  "modelfile": "FROM llama3.2:1b\nPARAMETER temperature 0.8\nSYSTEM You are helpful",
  "stream": false
}'
```

### Pull Model

```bash
curl http://localhost:11434/api/pull -d '{
  "name": "llama3.2:1b",
  "stream": true
}'
```

### Delete Model

```bash
curl -X DELETE http://localhost:11434/api/delete -d '{
  "name": "my-chatbot"
}'
```

## Embeddings API

Generate vector embeddings for semantic search:

```bash
curl http://localhost:11434/api/embeddings -d '{
  "model": "my-chatbot",
  "prompt": "The quick brown fox jumps over the lazy dog"
}'
```

**Response**:
```json
{
  "embedding": [0.123, -0.456, 0.789, ...]
}
```

## Code Examples

### Python

#### Simple Generation

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

#### Chat with Context

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

#### Async Generation

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

#### Basic Generation

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

#### Streaming with Fetch

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

#### Chat Class

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

## Error Handling

### Common HTTP Status Codes

- **200 OK**: Request successful
- **400 Bad Request**: Invalid request format
- **404 Not Found**: Model not found
- **500 Internal Server Error**: Server error

### Error Response Format

```json
{
  "error": "model 'nonexistent' not found"
}
```

### Python Error Handling

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

## Best Practices

### 1. Use Streaming for Long Responses

Improves user experience by showing progress:

```python
for chunk in stream_generate(model, prompt):
    print(chunk, end="", flush=True)
```

### 2. Implement Timeouts

Prevent hanging requests:

```python
response = requests.post(url, json=payload, timeout=30)
```

### 3. Handle Context Window Limits

Monitor token counts and trim conversation history:

```python
def trim_messages(messages, max_tokens=4000):
    # Keep system message and recent messages
    if len(messages) > 10:
        return [messages[0]] + messages[-9:]
    return messages
```

### 4. Cache Embeddings

Don't regenerate embeddings for the same text:

```python
embedding_cache = {}

def get_embedding(text):
    if text not in embedding_cache:
        embedding_cache[text] = generate_embedding(text)
    return embedding_cache[text]
```

### 5. Use Connection Pooling

For high-throughput applications:

```python
session = requests.Session()
session.mount('http://', requests.adapters.HTTPAdapter(pool_maxsize=10))
```

## Rate Limiting

Protect your server with rate limiting:

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

## Resources

- [Ollama API Documentation](https://github.com/ollama/ollama/blob/main/docs/api.md)
- [OpenAPI Specification](https://github.com/ollama/ollama/blob/main/docs/openapi.yaml)
- [Community Examples](https://github.com/ollama/ollama#community-integrations)
