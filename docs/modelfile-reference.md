# Ollama Modelfile Reference

Complete guide to Ollama Modelfile syntax and parameters for customizing models.

## Modelfile Syntax

A Modelfile uses a simple instruction-based format similar to Dockerfiles. Instructions are not case-sensitive and can appear in any order (though `FROM` is conventionally first).

## Core Instructions

### FROM (Required)

Specifies the base model to use.

```dockerfile
# Use an existing Ollama model
FROM llama3.2:1b

# Use a specific model version
FROM mistral:7b-instruct-v0.2

# Use a local GGUF file
FROM /data/gguf/my-model.gguf

# Use a Safetensors model
FROM /path/to/safetensors
```

### PARAMETER

Sets model runtime parameters that control behavior.

```dockerfile
PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_k 40
PARAMETER top_p 0.9
```

### SYSTEM

Defines the system prompt that sets the model's persona and instructions.

```dockerfile
SYSTEM """
You are a helpful AI assistant specialized in Python programming.
You provide clear, well-commented code examples and explain concepts thoroughly.
"""
```

**Note**: Multi-line system prompts use triple quotes `"""`

### TEMPLATE

Specifies the full prompt template sent to the model.

```dockerfile
TEMPLATE """
{{ if .System }}System: {{ .System }}

{{ end }}{{ if .Prompt }}User: {{ .Prompt }}

{{ end }}Assistant: {{ .Response }}
"""
```

### ADAPTER

Applies a fine-tuned LoRA or QLoRA adapter to the base model.

```dockerfile
FROM llama3.2:3b
ADAPTER /data/adapters/my-lora-adapter.bin
```

### MESSAGE

Defines conversation history for few-shot learning.

```dockerfile
MESSAGE user Tell me about Python
MESSAGE assistant Python is a high-level, interpreted programming language...
MESSAGE user What about its uses?
MESSAGE assistant Python is used for web development, data science, automation...
```

### LICENSE

Specifies the legal license under which the model is distributed.

```dockerfile
LICENSE """
MIT License

Copyright (c) 2024...
"""
```

## Parameters Reference

All values are set with `PARAMETER <name> <value>`. For **tuning advice and copy-paste presets per use case**, see the [Parameter Guide](./parameter-guide.md) — the canonical guide on choosing values. This table documents the available parameters:

| Parameter | Range / Values | Default | Purpose |
|-----------|----------------|---------|---------|
| `temperature` | 0.0 - 2.0 | 0.8 | Randomness: low = deterministic/factual, high = creative |
| `num_ctx` | 512 - 32768 | 2048 | Context window in tokens (more = more memory) |
| `top_k` | 1 - 100 | 40 | Limits selection to the K most probable tokens |
| `top_p` | 0.0 - 1.0 | 0.9 | Nucleus sampling: cumulative probability threshold |
| `repeat_penalty` | 0.0 - 2.0 | 1.1 | Penalizes token repetition (1.1-1.2 recommended) |
| `repeat_last_n` | 0 - 512 | 64 | Tokens considered for the repetition penalty |
| `num_predict` | -1, 1 - 4096 | -1 (unlimited) | Maximum number of tokens to generate |
| `mirostat` | 0, 1, 2 | 0 (disabled) | Mirostat sampling (with `mirostat_tau`, `mirostat_eta`) |
| `stop` | string(s) | — | Stop sequence(s) that end generation; repeatable |
| `seed` | integer | random | Fixed seed for reproducible outputs |
| `num_gpu` | 0 - N | automatic | Number of model layers to run on GPU (0 = CPU only) |
| `num_thread` | 1 - N | auto-detected | Number of CPU threads to use |

Examples:

```dockerfile
PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1

# Stop sequences (repeatable)
PARAMETER stop "<|im_end|>"
PARAMETER stop "User:"

# Mirostat sampling
PARAMETER mirostat 2
PARAMETER mirostat_tau 5.0
PARAMETER mirostat_eta 0.1
```

## Complete Example

```dockerfile
# Advanced Modelfile example
FROM llama3.2:3b

# Model behavior parameters
PARAMETER temperature 0.7
PARAMETER num_ctx 8192
PARAMETER top_k 40
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.15
PARAMETER repeat_last_n 128

# Stop sequences
PARAMETER stop "User:"
PARAMETER stop "###"

# System prompt
SYSTEM """
You are an expert software architect with deep knowledge of:
- Distributed systems design
- Cloud-native architectures
- Microservices patterns
- Database design

When answering questions:
1. Provide clear, well-structured explanations
2. Include practical examples and code snippets
3. Consider trade-offs and alternatives
4. Reference industry best practices
"""

# Custom template (optional)
TEMPLATE """
{{ if .System }}### System
{{ .System }}

{{ end }}{{ if .Prompt }}### User
{{ .Prompt }}

{{ end }}### Assistant
{{ .Response }}
"""

# License
LICENSE """
Apache License 2.0
"""
```

## Best Practices

### 1. Start with Balanced Parameters

Begin with moderate values and adjust based on results:

```dockerfile
PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_k 40
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1
```

### 2. Optimize for Your Use Case

- **Factual/Technical**: Lower temperature (0.2-0.4)
- **Conversational**: Medium temperature (0.6-0.8)
- **Creative**: Higher temperature (0.9-1.2)

### 3. Balance Context Window and Memory

Larger context = more memory usage. Start with 4096 and increase only if needed.

### 4. Test Incrementally

Change one parameter at a time to understand its effect. Export and version your Modelfiles.

### 5. Use Clear System Prompts

Be specific about:
- Model's role and expertise
- Expected behavior
- Output format
- Constraints and limitations

### 6. Version Control

Keep your Modelfiles in Git:

```bash
git add models/custom/my-model/Modelfile
git commit -m "Add custom model for technical documentation"
```

## Debugging Modelfiles

### Validate Before Creating

```bash
docker compose exec ollama ollama show test-model --modelfile
```

### Check Model Parameters

```bash
docker compose exec ollama ollama show my-model
```

### Test with Different Prompts

Create sample prompts that cover your use cases and test systematically.

## Resources

- [Official Modelfile Documentation](https://github.com/ollama/ollama/blob/main/docs/modelfile.md)
- [Ollama GitHub Repository](https://github.com/ollama/ollama)
- [Model Library](https://ollama.com/library)
