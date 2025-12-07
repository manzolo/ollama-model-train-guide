# TechCorp Customer Support Assistant

An example model demonstrating few-shot learning with a customer support dataset.

## What This Example Shows

This model demonstrates how to create a specialized customer support bot using:
- **System prompt** with company-specific information
- **Few-shot examples** (MESSAGE instructions) from a training dataset
- **Lower temperature** (0.3) for consistent, factual responses

## Dataset

The training examples come from `data/training/techcorp-support.jsonl`, which contains 10 Q&A pairs about:
- Password reset procedures
- Business hours and contact information
- Shipping and returns policies
- Payment methods
- Order tracking

## Creating the Model

```bash
make create-model
# Select: techcorp-support/Modelfile
# Name it: techcorp-support
```

Or directly:
```bash
bash scripts/create-custom-model.sh techcorp-support ./models/examples/techcorp-support/Modelfile
```

## Testing

```bash
make chat
# Select techcorp-support

# Try these questions:
# - "How do I reset my password?"
# - "What are your business hours?"
# - "Do you offer refunds?"
# - "How can I contact sales?"
```

## Learn More

For a complete guide on training models with your own datasets, see:
- [Dataset Training Example Guide](../../../docs/dataset-training-example.md)

This shows:
- How to prepare custom datasets
- Fine-tuning with Unsloth or Hugging Face
- Exporting to GGUF format
- When to use few-shot vs fine-tuning
