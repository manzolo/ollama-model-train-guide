# Example Spreadsheets for Testing

This directory contains example spreadsheet files you can use to test the spreadsheet-to-JSONL converter.

## Available Examples

### 1. Customer Support Q&A

**Files:**
- `customer-support-qa.csv` (CSV format)
- `customer-support-qa.xlsx` (Excel format)

**Content:** 15 common customer support questions and answers
- Returns and refunds
- Shipping and tracking
- Payment methods
- Store policies
- Contact information

**Columns:**
- `question` or `instruction`
- `answer` or `output`

### 2. Tech Platform FAQ

**File:** `tech-platform-faq.csv`

**Content:** 15 technical support questions for a coding platform
- Programming languages
- Debugging features
- Collaboration tools
- Deployment options
- Security features

**Columns:**
- `question`
- `answer`

## How to Use

### Option 1: Web Converter (Recommended)

1. **Access the converter:**
   ```bash
   make chat-web
   # Opens http://localhost:8080, then click "Converter" in the sidebar
   ```

2. **Upload a file:**
   - Drag and drop any example file
   - Or click to browse and select

3. **Convert:**
   - Preview shows automatically
   - Adjust column names if needed
   - Click "Convert to JSONL"
   - Output saved to `data/training/`

### Option 2: Command Line

```bash
# Using the converter API
curl -X POST http://localhost:8080/api/converter/convert \
  -F "file=@data/examples/customer-support-qa.csv" \
  -F "instruction_col=question" \
  -F "output_col=answer"
```

## Creating Your Own

### CSV Format

Create a simple CSV file:

```csv
instruction,output
"Your question here?","Your answer here."
"Another question?","Another answer."
```

**Tips:**
- Use quotes for text with commas
- First row is column headers
- UTF-8 encoding recommended

### Excel Format

Create in Excel or Google Sheets:

| instruction | output |
|-------------|--------|
| Question 1 | Answer 1 |
| Question 2 | Answer 2 |

**Tips:**
- Keep it simple (no formulas, merged cells)
- One sheet only
- Export as .xlsx

## Common Use Cases

### 1. Customer Support Bot

Use `customer-support-qa.*` files to create a support bot:

```bash
# Convert
make converter
# Upload customer-support-qa.csv

# Create model
bash scripts/create-custom-model.sh support-bot ./models/custom/support/Modelfile
```

### 2. Technical Documentation

Use `tech-platform-faq.csv` for technical Q&A:

```bash
# Convert to JSONL
# Then use in Modelfile or for fine-tuning
```

### 3. Training Data Collection

Start with examples, then add your own data:

1. Download example as template
2. Replace with your Q&A pairs
3. Convert to JSONL
4. Train your model

## Troubleshooting

### "Column not found" Error

**Problem:** Converter can't find specified columns

**Solution:** 
- Check column names in preview
- Common names: `instruction`, `output`, `question`, `answer`
- Case-sensitive!

### Empty Output

**Problem:** JSONL file is empty after conversion

**Solution:**
- Ensure both columns have data
- Remove empty rows
- Check for special characters

### File Won't Upload

**Problem:** Cannot upload file

**Solution:**
- Check file size (max 16MB)
- Save as CSV UTF-8 if special characters
- Try CSV instead of Excel

## Next Steps

After converting:

1. **Review the JSONL** in `data/training/`
2. **Create a Modelfile** with MESSAGE examples
3. **Train your model** using the dataset
4. **Test thoroughly** with various inputs

See the main [README](../../README.md) for complete training guide.
