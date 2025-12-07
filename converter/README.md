# Spreadsheet to JSONL Converter

A web-based tool to convert Excel or CSV files to JSONL format for training Ollama models.

## Features

- 📊 **Multiple Format Support**: Excel (.xlsx, .xls) and CSV files
- 🎯 **Auto-Detection**: Automatically detects column names
- 👀 **Preview**: See file contents before conversion
- 🖱️ **Drag & Drop**: Easy file upload
- 🎨 **Modern UI**: Clean, intuitive interface
- ⚡ **Fast**: Instant conversion
- 💾 **Direct Save**: Saves to `data/training/` directory

## Quick Start

### 1. Start the Service

```bash
# Start all services (includes converter)
make up

# Or start services individually
docker compose up -d
```

The converter will be available at: **http://localhost:5000**

### 2. Open the Web Interface

```bash
make converter
# Opens http://localhost:5000 in your browser
```

### 3. Prepare Your Spreadsheet

Your Excel/CSV file should have at least two columns:
- One for **questions/instructions**
- One for **answers/outputs**

**Example CSV**:
```csv
instruction,output
How do I reset my password?,Go to Settings > Security > Reset Password
What are your hours?,We're open Monday-Friday 9AM-5PM
Where are you located?,123 Main Street Florence Italy
```

**Example Excel**:
| question | answer |
|----------|--------|
| How do I reset my password? | Go to Settings > Security > Reset Password |
| What are your hours? | We're open Monday-Friday 9AM-5PM |
| Where are you located? | 123 Main Street, Florence, Italy |

### 4. Convert

1. **Upload** your file (drag & drop or click to browse)
2. **Preview** will show automatically
3. **Specify column names** (auto-detected if named `instruction`/`output` or `question`/`answer`)
4. **Click "Convert to JSONL"**
5. **Done!** File saved to `data/training/yourfile.jsonl`

## Column Name Mapping

The converter needs to know which columns contain:
- **Instructions** (questions, prompts, inputs)
- **Outputs** (answers, responses, completions)

Common column names that are auto-detected:
- Instructions: `instruction`, `question`, `input`, `prompt`
- Outputs: `output`, `answer`, `response`, `completion`

If your columns have different names, just type them in the form fields.

## Example Workflow

### From Spreadsheet to Model

1. **Create your dataset** in Excel or Google Sheets
2. **Export as CSV or XLSX**
3. **Convert** using the web interface
4. **Create a Modelfile** using the MESSAGE approach:

```bash
# Create Modelfile that uses your dataset
cat > models/custom/my-model/Modelfile << 'EOF'
FROM llama3.2:1b
PARAMETER temperature 0.4

SYSTEM "You are a helpful assistant."

# Add examples from your converted JSONL
MESSAGE user How do I reset my password?
MESSAGE assistant Go to Settings > Security > Reset Password
EOF

# Create the model
bash scripts/create-custom-model.sh my-model ./models/custom/my-model/Modelfile
```

Or for **fine-tuning**, use the JSONL file directly with Unsloth/Hugging Face (see [`docs/dataset-training-example.md`](../docs/dataset-training-example.md)).

## Advanced Usage

### API Endpoint

You can also convert programmatically:

```bash
curl -X POST http://localhost:5000/convert \
  -F "file=@mydata.xlsx" \
  -F "instruction_col=question" \
  -F "output_col=answer"
```

Response:
```json
{
  "success": true,
  "message": "Converted successfully!",
  "output_file": "mydata.jsonl",
  "rows_converted": 50
}
```

### Preview Endpoint

Preview file contents without converting:

```bash
curl -X POST http://localhost:5000/preview \
  -F "file=@mydata.xlsx"
```

### Python Script

Use the converter in your own scripts:

```python
import requests

files = {'file': open('mydata.xlsx', 'rb')}
data = {
    'instruction_col': 'question',
    'output_col': 'answer'
}

response = requests.post('http://localhost:5000/convert', files=files, data=data)
print(response.json())
```

## Tips for Best Results

### 1. Clean Your Data

Remove:
- Empty rows
- Headers beyond the first row
- Formatting (bold, colors, etc.)
- Special characters that might cause issues

### 2. Consistent Format

Ensure all entries follow the same pattern:
```csv
question,answer
"Question here?","Complete answer here."
"Another question?","Another answer."
```

### 3. Validate Column Names

Before uploading, check your column headers match what you'll specify in the converter.

### 4. Review the Preview

Always check the preview to ensure data is being read correctly.

## Troubleshooting

### "Column not found" Error

**Problem**: Converter can't find the specified column

**Solution**: 
1. Check the preview to see actual column names
2. Update the form fields to match exactly (case-sensitive)
3. Remove any leading/trailing spaces from column headers

### Empty JSONL File

**Problem**: Converted file is empty

**Solution**:
1. Check that both columns have data
2. Ensure no completely empty rows
3. Verify column names are correct

### File Upload Fails

**Problem**: File won't upload

**Solution**:
1. Check file size (max 16MB)
2. Verify file format (.xlsx, .xls, or .csv)
3. Try converting to CSV first

### Encoding Issues

**Problem**: Special characters appear incorrectly

**Solution**: Save your CSV with UTF-8 encoding:
- Excel: Save As > CSV UTF-8
- Google Sheets: Download > CSV

## Configuration

### Change Port

Edit `docker-compose.yml`:
```yaml
converter:
  ports:
    - "5001:5000"  # Change 5001 to your preferred port
```

Then restart:
```bash
docker compose down
docker compose up -d
```

### Increase Upload Limit

Edit `converter/app.py`:
```python
app.config['MAX_CONTENT_LENGTH'] = 32 * 1024 * 1024  # 32MB
```

Rebuild:
```bash
docker compose build converter
docker compose up -d converter
```

## Development

### Running Locally (without Docker)

```bash
cd converter
pip install -r requirements.txt
python app.py
```

Visit http://localhost:5000

### Modify the UI

Edit `converter/templates/index.html` and refresh your browser.

## Security Notes

- Service runs locally only by default
- No data is sent to external servers
- Files are deleted after conversion
- Only accessible from your machine

For production use:
1. Add authentication
2. Configure HTTPS
3. Implement rate limiting
4. Add input validation

## Next Steps

After converting your spreadsheet:

1. **Review the JSONL file** in `data/training/`
2. **Choose your approach**:
   - **Quick**: Use Modelfile with MESSAGE examples
   - **Advanced**: Fine-tune with Unsloth/HuggingFace
3. **Follow the training guide**: [`docs/dataset-training-example.md`](../docs/dataset-training-example.md)

## Support

For issues or questions:
1. Check the logs: `docker compose logs converter`
2. Verify service is running: `docker compose ps`
3. Test health endpoint: `curl http://localhost:5000/health`

---

Happy converting! 🎉
