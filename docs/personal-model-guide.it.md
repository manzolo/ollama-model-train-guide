# Creare un Modello Personalizzato

Guida per creare un modello che conosce le tue informazioni personali.

## Panoramica

Puoi creare un modello personalizzato che ricorda e risponde con le tue informazioni personali (dove vivi, peso, hobby, ecc.) usando due approcci:

1. **System prompt** - Incorpora le informazioni nel messaggio di sistema
2. **Esempi MESSAGE** - Fornisci esempi di few-shot learning

L'esempio fornito usa entrambi per ottenere i migliori risultati.

## Avvio Rapido

### 1. Modifica le Tue Informazioni Personali

Apri e modifica il Modelfile:

```bash
nano models/examples/personal-assistant/Modelfile
```

Sostituisci i segnaposto con le tue informazioni reali:

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

Aggiorna anche gli esempi MESSAGE:

```dockerfile
MESSAGE user How much do I weigh?
MESSAGE assistant Your weight is 75 kg.  # ← Use your actual weight

MESSAGE user What's my name?
MESSAGE assistant Your name is Mario Rossi.  # ← Use your actual name
```

### 2. Crea il Modello

```bash
bash scripts/create-custom-model.sh my-personal-assistant ./models/examples/personal-assistant/Modelfile
```

### 3. Testalo

```bash
docker compose exec ollama ollama run my-personal-assistant
```

Prova a chiedere:
- "Where do I live?"
- "How much do I weigh?"
- "What's my name?"
- "Tell me about my hobbies"

## Personalizzazione Avanzata

### Aggiungi Più Dettagli Personali

Puoi aggiungere qualsiasi informazione desideri:

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

### Aggiungi Esempi Q&A Personalizzati

Fornisci coppie specifiche di domanda-risposta:

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

### Regola lo Stile delle Risposte

Rendilo più colloquiale o formale:

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

## Esempi di Casi d'Uso

### Integrazione con l'Agenda Giornaliera

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

Chiedi: "When is my gym time?" → "You go to the gym on Tuesdays and Thursdays at 19:00."

### Monitoraggio della Salute

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

### Informazioni di Contatto

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

## Suggerimenti per Ottenere i Migliori Risultati

### 1. Sii Specifico e Coerente

```dockerfile
# Good
MESSAGE user Where do I live?
MESSAGE assistant You live in San Piero a Sieve, Tuscany, Italy.

# Better - More detail
MESSAGE user Where do I live?
MESSAGE assistant You live in San Piero a Sieve, a town in the Mugello region of Tuscany, Italy. It's about 30 km north of Florence.
```

### 2. Copri le Varianti delle Domande

```dockerfile
MESSAGE user Where do I live?
MESSAGE assistant You live in San Piero a Sieve, Italy.

MESSAGE user What's my address?
MESSAGE assistant You live in San Piero a Sieve, Tuscany.

MESSAGE user What city am I from?
MESSAGE assistant You're from San Piero a Sieve, in the province of Florence.
```

### 3. Usa una Temperature più Bassa

Per informazioni personali fattuali, usa una temperature più bassa (0.3-0.5) per la coerenza:

```dockerfile
PARAMETER temperature 0.4
```

### 4. Testa a Fondo

Crea uno script di test:

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

## Considerazioni sulla Privacy

⚠️ **Importante**: questo modello memorizza le informazioni personali in testo semplice.

### Consigli sulla Sicurezza

1. **Non condividere il Modelfile** pubblicamente
2. **Aggiungilo a .gitignore**:
   ```bash
   echo "models/examples/personal-assistant/" >> .gitignore
   ```
3. **Tienilo in locale** - non fare push verso i registry
4. **Usa variabili d'ambiente** per i dati sensibili (avanzato):
   ```bash
   # In your script, replace before creating model
   sed "s/\[Your Weight\]/$WEIGHT/g" template.Modelfile > Modelfile
   ```

## Aggiornare le Tue Informazioni

Quando le tue informazioni cambiano:

```bash
# 1. Edit the Modelfile
nano models/examples/personal-assistant/Modelfile

# 2. Recreate the model (overwrites existing)
bash scripts/create-custom-model.sh my-personal-assistant ./models/examples/personal-assistant/Modelfile

# 3. Test the updated model
docker compose exec ollama ollama run my-personal-assistant "What's my weight?"
```

## Esempio Completo

Ecco un esempio completamente personalizzato:

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

## Prossimi Passi

1. Modifica `models/examples/personal-assistant/Modelfile` con le tue informazioni
2. Crea il modello
3. Testalo con varie domande
4. Affina le risposte aggiungendo altri esempi MESSAGE
5. Mantieni aggiornato il tuo Modelfile man mano che le tue informazioni cambiano

Goditi il tuo assistente AI personalizzato! 🎯
