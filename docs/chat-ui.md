# Chat Web UI Guide

The Ollama Model Training Guide includes a modern web interface for interacting with your models, managing them, and converting training data.

## Accessing the Web UI

Start the services:
```bash
make up
```

Then open your browser to: **http://localhost:8080**

The UI is automatically started alongside Ollama and connects to the API at `http://ollama:11434`. The chat service runs under the Compose profile `chat`; use `make up-core` (or set `COMPOSE_PROFILES=` in `.env`) to run Ollama without it.

The web app has three pages:

| Page | URL | Purpose |
|------|-----|---------|
| **Chat** | http://localhost:8080 | Chat with models, pull/manage models, edit Modelfiles |
| **Converter** | http://localhost:8080/converter | Convert Excel/CSV spreadsheets to JSONL training data |
| **Wizard** | http://localhost:8080/wizard | Guided step-by-step Modelfile creation |

## Features Overview

The Chat UI provides:
- **Interactive Chat**: Talk with your models in a modern chat interface
- **Model Selection**: Easily switch between installed models
- **Model Management**: Pull models from Ollama library with real-time progress
- **Spreadsheet Converter**: Convert Excel/CSV files to JSONL training format
- **Modelfile Wizard**: Create a custom model in 6 guided steps, no syntax required
- **Model Selector Dropdown**: Enhanced dropdown with modern styling and search

## Chat Interface

### Starting a Conversation

1. **Select a Model**: Click the model selector dropdown at the top
2. **Choose from Available Models**: All installed models appear in the list
3. **Start Typing**: Enter your message in the input box
4. **Send**: Press Enter or click Send

### Model Selector

The enhanced model selector features:
- **Modern Styling**: Clean, professional appearance with custom styling
- **Interactive States**: Hover and focus effects for better UX
- **Custom Arrow**: Styled dropdown arrow
- **Responsive Design**: Works on desktop and mobile

To switch models mid-conversation:
1. Click the model dropdown
2. Select a different model
3. Continue chatting (previous conversation context may be lost)

### Chat Features

- **Streaming Responses**: See the model's response as it's generated
- **Message History**: Scroll through previous messages
- **Copy Responses**: Copy model responses to clipboard
- **Clear Chat**: Start a fresh conversation

## Model Management

### Pulling Models

Click the **"Manage Models"** button to access model pulling:

1. **Enter Model Name**: Type the model name (e.g., `llama3.2`, `mistral:7b`)
2. **Click "Pull Model"**: Start downloading
3. **Watch Progress**: Real-time progress bar shows:
   - Download speed
   - Percentage complete
   - Estimated time remaining
   - Current status (downloading, verifying, etc.)

**Popular Models to Try**:
- `llama3.2:1b` - Fast, lightweight (1.3GB)
- `llama3.2:3b` - Balanced quality (2GB)
- `mistral:7b` - High quality (4.1GB)
- `phi3:mini` - Compact and fast (2.3GB)
- `codellama:7b` - Code generation (3.8GB)

Browse all models at [Ollama Library](https://ollama.com/library).

### Viewing Installed Models

The model selector dropdown automatically shows all installed models. Models are pulled from the Ollama API and updated when you:
- Refresh the page
- Pull a new model
- Delete a model (via CLI)

## Spreadsheet to JSONL Converter

The converter helps you prepare training datasets from spreadsheets.

### Accessing the Converter

Two ways to access:

1. **Via Sidebar**: Click "Converter" in the Chat UI sidebar
2. **Direct URL**: Navigate to `http://localhost:8080/converter`

### Converting Files

#### Step 1: Upload Your File

**Supported Formats**:
- Excel: `.xlsx`, `.xls`
- CSV: `.csv`

**Upload Methods**:
- **Drag & Drop**: Drag your file onto the upload area
- **Click to Browse**: Click the upload area and select a file

#### Step 2: Configure Columns

The converter will:
- **Auto-detect** column names that contain "question", "query", "prompt", "answer", "response"
- Show a preview of your data
- Let you manually select columns if auto-detection fails

**Column Mapping**:
- **Question/Prompt Column**: Contains the user questions or prompts
- **Answer/Response Column**: Contains the assistant responses

Example spreadsheet structure:

| Question | Answer |
|----------|--------|
| How do I reset my password? | Click "Forgot Password" on the login page... |
| What are your business hours? | We're open Monday-Friday, 9am-5pm EST. |

#### Step 3: Preview

Review the preview to ensure:
- Columns are correctly mapped
- Data looks correct
- No missing or malformed entries

#### Step 4: Convert & Save

1. **Click "Convert"**
2. **Save File**: The JSONL file is automatically saved to `./data/training/`
3. **Use in Training**: Reference the file in your Modelfile

### Output Format

The converter creates JSONL (JSON Lines) format:

```jsonl
{"role": "user", "content": "How do I reset my password?"}
{"role": "assistant", "content": "Click 'Forgot Password' on the login page..."}
{"role": "user", "content": "What are your business hours?"}
{"role": "assistant", "content": "We're open Monday-Friday, 9am-5pm EST."}
```

### Using Converted Data

After converting, use the data in a Modelfile:

```dockerfile
FROM llama3.2:1b

PARAMETER temperature 0.3

SYSTEM """
You are a customer support assistant.
"""

# Load examples from converted data
MESSAGE user "How do I reset my password?"
MESSAGE assistant "Click 'Forgot Password' on the login page and follow the instructions sent to your email."

MESSAGE user "What are your business hours?"
MESSAGE assistant "We're open Monday-Friday, 9am-5pm EST."
```

See [Dataset Training Example](./dataset-training-example.md) for complete guide.

## Modelfile Wizard

The wizard walks you through creating a custom model without writing any Modelfile syntax by hand.

### Accessing the Wizard

Navigate to `http://localhost:8080/wizard` (or use the link from the Chat UI).

### The 6 Steps

1. **Use case**: Pick what your model will do — Chatbot, Code Assistant, Customer Support, Creative Writer, Translator, or Data Extraction. Each use case applies a proven parameter preset (temperature, `num_ctx`, `top_p`, and `repeat_penalty` where relevant), matching the presets in the [Parameter Guide](./parameter-guide.md). For example, "Creative Writer" sets temperature 1.2 with an 8192-token context, while "Data Extraction" sets temperature 0.1.

2. **Base model**: Choose the base model from a dropdown (`llama3.2:1b` is the recommended starting point; `llama3.2:3b`, `mistral:7b`, and `phi3:mini` are also offered). You can edit the generated Modelfile afterwards to use any other model you have pulled.

3. **Personality**: Write the system prompt describing how the model should act and respond. Be specific — "explain step-by-step" works better than "be helpful".

4. **Rules (optional)**: Add individual constraints such as "Keep responses under 3 sentences" or "Use markdown formatting". These are appended to the system prompt as a rules list.

5. **Examples (optional)**: Add example question/answer pairs. These become `MESSAGE user` / `MESSAGE assistant` few-shot examples in the Modelfile; 3-5 quality examples are usually enough.

6. **Result**: The wizard generates the Modelfile (via the app's `POST /api/wizard/generate` endpoint) and shows it for review. Enter a model name (lowercase letters, numbers, and hyphens) and click **Save & Create Model**:
   - The Modelfile is saved to `models/custom/<name>/Modelfile`
   - The model is built immediately in the Ollama instance
   - You can then select it in the chat dropdown or run it with `make chat`

### Tips

- The base model you choose must be pulled first (via "Manage Models" or `docker compose exec ollama ollama pull <model>`), otherwise model creation fails.
- The generated Modelfile is a normal file under `models/custom/` — you can edit it later and re-create the model, or version it in Git.
- To understand what each generated parameter does, see the [Parameter Guide](./parameter-guide.md).

## Web UI Configuration

### Port Configuration

The default port is `8080`. To change it:

1. Edit `.env` (the value is interpolated into the compose file as `${CHAT_PORT:-8080}:8080`):
   ```bash
   CHAT_PORT=8081
   ```

2. Recreate the containers (required for port changes):
   ```bash
   make down && make up
   ```

3. Access at new port: `http://localhost:8081`

### API Connection

The Chat UI connects to Ollama API at `http://ollama:11434` by default (internal Docker network).

If you need to connect to an external Ollama instance, edit `docker-compose.yml`:

```yaml
chat:
  environment:
    - OLLAMA_API=http://external-ollama-host:11434
```

## Troubleshooting

### Chat UI won't load

**Check services are running**:
```bash
docker compose ps
```

Both `ollama` and `ollama-chat` should be "Up".

**Check logs**:
```bash
docker compose logs chat
```

**Restart services**:
```bash
make restart
```

### Models not showing in dropdown

**Verify Ollama is running**:
```bash
docker compose exec ollama ollama list
```

**Check API connection**:
```bash
curl http://localhost:11434/api/tags
```

If this fails, check `docker-compose.yml` for correct API URL.

### Model pulling fails

**Check internet connection**:
```bash
docker compose exec ollama ping -c 3 ollama.com
```

**Check disk space**:
```bash
df -h
docker system df
```

**Try via CLI**:
```bash
docker compose exec ollama ollama pull llama3.2:1b
```

### Converter upload fails

**Check file permissions**:
```bash
ls -la ./data/training/
```

The directory should be writable by the Docker container.

**Check file size**:
Very large files may timeout. Try splitting into smaller files.

**Check file format**:
- Ensure Excel files are `.xlsx` or `.xls`
- Ensure CSV files are properly formatted

### Styling issues

**Clear browser cache**:
- Press `Ctrl+Shift+R` (Windows/Linux)
- Press `Cmd+Shift+R` (Mac)

**Try different browser**:
The UI is tested on Chrome, Firefox, and Safari.

## Advanced Usage

### Customizing the UI

The Chat UI code is in `./chat/`:

```
chat/
├── app.py              # Flask application (chat, converter, wizard)
├── templates/          # HTML templates
│   ├── chat.html      # Chat interface
│   ├── converter.html # Converter interface
│   └── wizard.html    # Modelfile wizard
├── Dockerfile          # Container configuration
└── requirements.txt    # Python dependencies
```

To customize:
1. Edit files in `./chat/`
2. Rebuild the container:
   ```bash
   docker compose build chat
   docker compose up -d
   ```

### Using the API Directly

The Chat UI uses the Ollama API. You can call it directly:

**Generate response**:
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:1b",
  "prompt": "Hello!",
  "stream": true
}'
```

**Chat with context**:
```bash
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2:1b",
  "messages": [
    {"role": "user", "content": "What is Docker?"}
  ],
  "stream": true
}'
```

See [API Usage Guide](./api-usage.md) for complete API documentation.

## Keyboard Shortcuts

- **Enter**: Send message
- **Shift+Enter**: New line in message
- **Esc**: Clear input (when focused)
- **Ctrl+L**: Clear chat history (coming soon)

## Next Steps

- [Usage Guide](./usage.md) - Learn CLI commands and model management
- [Examples](./examples.md) - Pre-configured model templates
- [Dataset Training Example](./dataset-training-example.md) - Train with your own data
- [API Usage](./api-usage.md) - Programmatic access to models
