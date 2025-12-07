# Training Datasets

This directory contains training datasets for model customization.

## Example Dataset

**`techcorp-support.jsonl`** - Customer support Q&A dataset
- 10 example question-answer pairs
- Used by `models/examples/techcorp-support/Modelfile`
- Demonstrates few-shot learning with MESSAGE instructions
- Format: JSONL (JSON Lines) with `instruction` and `output` fields

## Dataset Format

Training datasets should be in JSONL format (one JSON object per line):

```jsonl
{"instruction": "Question or prompt", "output": "Expected response"}
{"instruction": "Another question", "output": "Another response"}
```

## Using Your Own Datasets

1. **Create your dataset** in JSONL format:
   ```bash
   # Example: data/training/my-dataset.jsonl
   echo '{"instruction": "What is your product?", "output": "We offer AI solutions"}' > data/training/my-dataset.jsonl
   echo '{"instruction": "How do I get started?", "output": "Visit our website"}' >> data/training/my-dataset.jsonl
   ```

2. **Reference in Modelfile** using MESSAGE instructions:
   ```dockerfile
   FROM llama3.2:1b

   SYSTEM """You are a helpful assistant."""

   MESSAGE user What is your product?
   MESSAGE assistant We offer AI solutions

   MESSAGE user How do I get started?
   MESSAGE assistant Visit our website
   ```

3. **Or use for fine-tuning**:
   - See [`docs/dataset-training-example.md`](../../docs/dataset-training-example.md)
   - Options: Unsloth, Hugging Face Transformers
   - Export to GGUF for use with Ollama

## Best Practices

- **Quality over quantity**: 10 good examples > 100 poor examples
- **Consistent format**: Keep instruction/output structure uniform
- **Diverse examples**: Cover different question types and edge cases
- **Clear responses**: Make outputs specific and actionable
- **Version control**: Track changes to datasets in git

## .gitignore Note

By default, files in this directory are ignored by git (to avoid committing large datasets).

The example dataset (`techcorp-support.jsonl`) is explicitly included for demonstration purposes.

If you want to version control your datasets, add them to `.gitignore` exceptions:
```
!data/training/my-dataset.jsonl
```
