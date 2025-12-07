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

### temperature

**Range**: 0.0 - 2.0  
**Default**: 0.8

Controls randomness in output generation.

- **0.0 - 0.3**: Highly focused, deterministic (good for code, factual answers)
- **0.4 - 0.7**: Balanced (general chat, Q&A)
- **0.8 - 1.2**: Creative (writing, brainstorming)
- **1.3 - 2.0**: Very creative, unpredictable (experimental)

```dockerfile
PARAMETER temperature 0.7
```

### num_ctx (Context Window)

**Range**: 512 - 32768  
**Default**: 2048

Number of tokens the model considers for context.

- **2048**: Standard for most tasks
- **4096**: Good for longer conversations
- **8192+**: For processing large documents or code files

```dockerfile
PARAMETER num_ctx 4096
```

**Note**: Larger context windows require more memory.

### top_k

**Range**: 1 - 100  
**Default**: 40

Limits token selection to the top K most probable tokens.

- **Lower** (10-20): More focused, predictable
- **Medium** (30-50): Balanced
- **Higher** (60-100): More diverse

```dockerfile
PARAMETER top_k 40
```

### top_p (Nucleus Sampling)

**Range**: 0.0 - 1.0  
**Default**: 0.9

Cumulative probability threshold for token selection.

- **0.8**: More focused
- **0.9**: Balanced
- **0.95-1.0**: More diverse

```dockerfile
PARAMETER top_p 0.9
```

### repeat_penalty

**Range**: 0.0 - 2.0  
**Default**: 1.1

Penalizes token repetition.

- **1.0**: No penalty
- **1.1-1.2**: Mild penalty (recommended)
- **1.3-1.5**: Strong penalty
- **1.5+**: Very strong (may affect coherence)

```dockerfile
PARAMETER repeat_penalty 1.1
```

### repeat_last_n

**Range**: 0 - 512  
**Default**: 64

Number of tokens to consider for repetition penalty.

```dockerfile
PARAMETER repeat_last_n 64
```

### num_predict

**Range**: -1, 1 - 4096  
**Default**: -1 (unlimited)

Maximum number of tokens to generate.

```dockerfile
# Limit to 100 tokens
PARAMETER num_predict 100

# Unlimited (default)
PARAMETER num_predict -1
```

### mirostat

**Values**: 0, 1, 2  
**Default**: 0 (disabled)

Enables Mirostat sampling for controlling perplexity.

```dockerfile
PARAMETER mirostat 2
PARAMETER mirostat_tau 5.0
PARAMETER mirostat_eta 0.1
```

### stop

Defines stop sequences to end generation.

```dockerfile
PARAMETER stop "<|im_end|>"
PARAMETER stop "</s>"
PARAMETER stop "User:"
```

### num_gpu

**Range**: 0 - N  
**Default**: Automatic

Number of GPU layers to use.

```dockerfile
# Use CPU only
PARAMETER num_gpu 0

# Use specific number of layers on GPU
PARAMETER num_gpu 32
```

### num_thread

**Range**: 1 - N  
**Default**: Auto-detected

Number of CPU threads to use.

```dockerfile
PARAMETER num_thread 8
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
