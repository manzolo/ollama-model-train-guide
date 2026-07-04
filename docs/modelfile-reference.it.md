# Riferimento Modelfile di Ollama

Guida completa alla sintassi e ai parametri del Modelfile di Ollama per personalizzare i modelli.

## Sintassi del Modelfile

Un Modelfile utilizza un semplice formato basato su istruzioni, simile ai Dockerfile. Le istruzioni non sono sensibili alle maiuscole/minuscole e possono comparire in qualsiasi ordine (anche se per convenzione `FROM` è la prima).

## Istruzioni principali

### FROM (obbligatoria)

Specifica il modello base da usare.

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

Imposta i parametri di runtime del modello che ne controllano il comportamento.

```dockerfile
PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_k 40
PARAMETER top_p 0.9
```

### SYSTEM

Definisce il system prompt che stabilisce la persona e le istruzioni del modello.

```dockerfile
SYSTEM """
You are a helpful AI assistant specialized in Python programming.
You provide clear, well-commented code examples and explain concepts thoroughly.
"""
```

**Nota**: i system prompt su più righe usano le triple virgolette `"""`

### TEMPLATE

Specifica il template completo del prompt inviato al modello.

```dockerfile
TEMPLATE """
{{ if .System }}System: {{ .System }}

{{ end }}{{ if .Prompt }}User: {{ .Prompt }}

{{ end }}Assistant: {{ .Response }}
"""
```

### ADAPTER

Applica un adapter LoRA o QLoRA sottoposto a fine-tuning al modello base.

```dockerfile
FROM llama3.2:3b
ADAPTER /data/adapters/my-lora-adapter.bin
```

### MESSAGE

Definisce la cronologia della conversazione per il few-shot learning.

```dockerfile
MESSAGE user Tell me about Python
MESSAGE assistant Python is a high-level, interpreted programming language...
MESSAGE user What about its uses?
MESSAGE assistant Python is used for web development, data science, automation...
```

### LICENSE

Specifica la licenza legale con cui il modello viene distribuito.

```dockerfile
LICENSE """
MIT License

Copyright (c) 2024...
"""
```

## Riferimento dei parametri

Tutti i valori si impostano con `PARAMETER <name> <value>`. Per **consigli di tuning e preset pronti da copiare e incollare per ogni caso d'uso**, consulta la [Guida ai parametri](./parameter-guide.md) — la guida canonica sulla scelta dei valori. Questa tabella documenta i parametri disponibili:

| Parametro | Intervallo / Valori | Predefinito | Scopo |
|-----------|----------------|---------|---------|
| `temperature` | 0.0 - 2.0 | 0.8 | Casualità: basso = deterministico/fattuale, alto = creativo |
| `num_ctx` | 512 - 32768 | 2048 | Finestra di contesto in token (più = più memoria) |
| `top_k` | 1 - 100 | 40 | Limita la selezione ai K token più probabili |
| `top_p` | 0.0 - 1.0 | 0.9 | Nucleus sampling: soglia di probabilità cumulativa |
| `repeat_penalty` | 0.0 - 2.0 | 1.1 | Penalizza la ripetizione dei token (consigliato 1.1-1.2) |
| `repeat_last_n` | 0 - 512 | 64 | Token considerati per la penalità di ripetizione |
| `num_predict` | -1, 1 - 4096 | -1 (illimitato) | Numero massimo di token da generare |
| `mirostat` | 0, 1, 2 | 0 (disabilitato) | Campionamento Mirostat (con `mirostat_tau`, `mirostat_eta`) |
| `stop` | stringa/e | — | Sequenza/e di stop che terminano la generazione; ripetibile |
| `seed` | intero | casuale | Seed fisso per output riproducibili |
| `num_gpu` | 0 - N | automatico | Numero di layer del modello da eseguire su GPU (0 = solo CPU) |
| `num_thread` | 1 - N | rilevato automaticamente | Numero di thread CPU da usare |

Esempi:

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

## Esempio completo

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

## Best practice

### 1. Inizia con parametri bilanciati

Parti da valori moderati e regolali in base ai risultati:

```dockerfile
PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_k 40
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1
```

### 2. Ottimizza per il tuo caso d'uso

- **Fattuale/Tecnico**: temperature più bassa (0.2-0.4)
- **Conversazionale**: temperature media (0.6-0.8)
- **Creativo**: temperature più alta (0.9-1.2)

### 3. Bilancia finestra di contesto e memoria

Un contesto più grande = maggiore utilizzo di memoria. Inizia con 4096 e aumenta solo se necessario.

### 4. Testa in modo incrementale

Cambia un parametro alla volta per capirne l'effetto. Esporta e versiona i tuoi Modelfile.

### 5. Usa system prompt chiari

Sii specifico riguardo a:
- Il ruolo e le competenze del modello
- Il comportamento atteso
- Il formato dell'output
- Vincoli e limitazioni

### 6. Controllo di versione

Mantieni i tuoi Modelfile in Git:

```bash
git add models/custom/my-model/Modelfile
git commit -m "Add custom model for technical documentation"
```

## Debug dei Modelfile

### Valida prima di creare

```bash
docker compose exec ollama ollama show test-model --modelfile
```

### Controlla i parametri del modello

```bash
docker compose exec ollama ollama show my-model
```

### Prova con prompt diversi

Crea prompt di esempio che coprano i tuoi casi d'uso e testali sistematicamente.

## Risorse

- [Documentazione ufficiale del Modelfile](https://github.com/ollama/ollama/blob/main/docs/modelfile.md)
- [Repository GitHub di Ollama](https://github.com/ollama/ollama)
- [Libreria dei modelli](https://ollama.com/library)
