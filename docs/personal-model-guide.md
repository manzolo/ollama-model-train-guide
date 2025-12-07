# Creating a Personalized Model

Guide for creating a model that knows your personal information.

## Overview

You can create a customized model that remembers and responds with your personal information (where you live, weight, hobbies, etc.) using two approaches:

1. **SYSTEM prompt** - Embed information in the system message
2. **MESSAGE examples** - Provide few-shot learning examples

The provided example uses both for best results.

## Quick Start

### 1. Edit Your Personal Information

Open and edit the Modelfile:

```bash
nano models/examples/personal-assistant/Modelfile
```

Replace the placeholders with your actual information:

```dockerfile
SYSTEM """
USER PERSONAL INFORMATION:
- Name: Mario Rossi                    # ← Your name
- Location: San Piero a Sieve, Italy   # ← Already set
- Weight: 75 kg                        # ← Your weight
- Occupation: Software Developer       # ← Your job
- Hobbies: Cycling, Cooking            # ← Your hobbies
- Favorite Food: Pizza                 # ← Your favorite food
- Family: Married, 2 children          # ← Family info
"""
```

Also update the MESSAGE examples:

```dockerfile
MESSAGE user How much do I weigh?
MESSAGE assistant Your weight is 75 kg.  # ← Use your actual weight

MESSAGE user What's my name?
MESSAGE assistant Your name is Mario Rossi.  # ← Use your actual name
```

### 2. Create the Model

```bash
bash scripts/create-custom-model.sh my-personal-assistant ./models/examples/personal-assistant/Modelfile
```

### 3. Test It

```bash
docker compose exec ollama ollama run my-personal-assistant
```

Try asking:
- "Where do I live?"
- "How much do I weigh?"
- "What's my name?"
- "Tell me about my hobbies"

## Advanced Customization

### Add More Personal Details

You can add any information you want:

```dockerfile
SYSTEM """
USER PERSONAL INFORMATION:
- Name: Mario Rossi
- Location: San Piero a Sieve, Italy
- Weight: 75 kg
- Height: 175 cm
- Age: 35
- Birthday: January 15
- Occupation: Software Developer
- Company: TechCorp Italia
- Hobbies: Cycling, Cooking, Photography
- Favorite Food: Pizza Margherita
- Favorite Drink: Espresso
- Favorite Sport: Calcio (Juventus fan)
- Family: Wife Anna, children Luca (8) and Sofia (5)
- Pet: Dog named Rex
- Car: Fiat 500
- Education: University of Florence, Computer Science
- Languages: Italian (native), English (fluent), German (basic)
- Favorite Music: Italian rock, Jazz
- Favorite Movie: Cinema Paradiso
"""
```

### Add Custom Q&A Examples

Provide specific question-answer pairs:

```dockerfile
MESSAGE user What's my favorite restaurant?
MESSAGE assistant Your favorite restaurant is Trattoria da Beppe in San Piero a Sieve, where you love their ribollita and bistecca alla fiorentina.

MESSAGE user What do I do for work?
MESSAGE assistant You work as a software developer at TechCorp Italia, specializing in cloud infrastructure and DevOps.

MESSAGE user Tell me about my family
MESSAGE assistant You're married to Anna and have two children: Luca who is 8 years old and Sofia who is 5. You also have a dog named Rex.

MESSAGE user What are my hobbies?
MESSAGE assistant You enjoy cycling through the Tuscan countryside on weekends, cooking traditional Italian dishes, and photography. You particularly love capturing landscapes around Mugello.
```

### Adjust Response Style

Make it more conversational or formal:

```dockerfile
# Casual/Friendly
SYSTEM """
You're a friendly personal assistant who knows me well.
Use casual language and be warm in your responses.
...
"""

# Professional/Formal  
SYSTEM """
You are a professional personal assistant.
Respond concisely and professionally.
...
"""
```

## Example Use Cases

### Daily Planner Integration

```dockerfile
SYSTEM """
...
SCHEDULE:
- Work hours: 9:00-18:00 Monday-Friday
- Gym: Tuesday and Thursday 19:00
- Family dinner: Sunday 13:00
- Weekly team meeting: Monday 10:00
"""
```

Ask: "When is my gym time?" → "You go to the gym on Tuesdays and Thursdays at 19:00."

### Health Tracking

```dockerfile
SYSTEM """
...
HEALTH INFO:
- Target weight: 72 kg
- Current weight: 75 kg
- Allergies: Nuts, Shellfish
- Medications: None
- Blood type: A+
"""
```

### Contact Information

```dockerfile
SYSTEM """
...
CONTACTS:
- Doctor: Dr. Bianchi - +39 055 1234567
- Dentist: Dr. Verde - +39 055 7654321
- Mechanic: Auto Rossi - +39 055 9876543
- Best friend: Marco - +39 333 1234567
"""

MESSAGE user What's my doctor's number?
MESSAGE assistant Your doctor is Dr. Bianchi and their number is +39 055 1234567.
```

## Tips for Best Results

### 1. Be Specific and Consistent

```dockerfile
# Good
MESSAGE user Where do I live?
MESSAGE assistant You live in San Piero a Sieve, Tuscany, Italy.

# Better - More detail
MESSAGE user Where do I live?
MESSAGE assistant You live in San Piero a Sieve, a town in the Mugello region of Tuscany, Italy. It's about 30 km north of Florence.
```

### 2. Cover Variations of Questions

```dockerfile
MESSAGE user Where do I live?
MESSAGE assistant You live in San Piero a Sieve, Italy.

MESSAGE user What's my address?
MESSAGE assistant You live in San Piero a Sieve, Tuscany.

MESSAGE user What city am I from?
MESSAGE assistant You're from San Piero a Sieve, in the province of Florence.
```

### 3. Use Lower Temperature

For factual personal information, use lower temperature (0.3-0.5) for consistency:

```dockerfile
PARAMETER temperature 0.4
```

### 4. Test Thoroughly

Create a test script:

```bash
#!/bin/bash
# test-personal-model.sh

QUESTIONS=(
    "Where do I live?"
    "What's my weight?"
    "What's my name?"
    "What are my hobbies?"
)

for q in "${QUESTIONS[@]}"; do
    echo "Q: $q"
    echo "$q" | docker compose exec -T ollama ollama run my-personal-assistant
    echo ""
done
```

## Privacy Considerations

⚠️ **Important**: This model stores personal information in plain text.

### Security Tips

1. **Don't share the Modelfile** publicly
2. **Add to .gitignore**:
   ```bash
   echo "models/examples/personal-assistant/" >> .gitignore
   ```
3. **Keep it local** - don't push to registries
4. **Use environment variables** for sensitive data (advanced):
   ```bash
   # In your script, replace before creating model
   sed "s/\[Your Weight\]/$WEIGHT/g" template.Modelfile > Modelfile
   ```

## Updating Your Information

When your information changes:

```bash
# 1. Edit the Modelfile
nano models/examples/personal-assistant/Modelfile

# 2. Recreate the model (overwrites existing)
bash scripts/create-custom-model.sh my-personal-assistant ./models/examples/personal-assistant/Modelfile

# 3. Test the updated model
docker compose exec ollama ollama run my-personal-assistant "What's my weight?"
```

## Complete Example

Here's a fully customized example:

```dockerfile
FROM llama3.2:1b

PARAMETER temperature 0.4
PARAMETER num_ctx 4096

SYSTEM """
You are Mario's personal AI assistant with knowledge about him.

PERSONAL INFO:
- Name: Mario Rossi
- Location: San Piero a Sieve, Tuscany, Italy
- Weight: 75 kg, Height: 175 cm
- Age: 35, Birthday: January 15
- Occupation: Software Developer at TechCorp Italia
- Family: Wife Anna, children Luca (8) and Sofia (5), dog Rex

PREFERENCES:
- Food: Pizza Margherita, Ribollita
- Drink: Espresso
- Sport: Calcio (Juventus fan)
- Hobbies: Cycling, Cooking, Photography

ROUTINE:
- Work: Monday-Friday 9:00-18:00
- Gym: Tuesday, Thursday 19:00
- Cycling: Saturday morning

Respond naturally and helpfully to questions about Mario.
"""

MESSAGE user Where do I live?
MESSAGE assistant You live in San Piero a Sieve, a lovely town in Tuscany, about 30km north of Florence.

MESSAGE user How much do I weigh?
MESSAGE assistant Your current weight is 75 kg at a height of 175 cm.

MESSAGE user What's my family like?
MESSAGE assistant You're married to Anna and have two children: Luca who is 8 years old and Sofia who is 5. You also have a dog named Rex.

MESSAGE user When do I go to the gym?
MESSAGE assistant You go to the gym on Tuesdays and Thursdays at 19:00.
```

## Next Steps

1. Edit `models/examples/personal-assistant/Modelfile` with your info
2. Create the model
3. Test it with various questions
4. Refine the responses by adding more MESSAGE examples
5. Keep your Modelfile updated as your information changes

Enjoy your personalized AI assistant! 🎯
