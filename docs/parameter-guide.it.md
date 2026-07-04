# Guida ai parametri - Valori predefiniti rapidi

**Non complicarti la vita con i parametri!** Usa questi valori predefiniti collaudati e regolali solo se necessario.

---

## 🎯 I 3 parametri di cui hai davvero bisogno

### 1. Temperature (Creatività)

Controlla la casualità dell'output. **Questo è il parametro più importante.**

| Valore | Comportamento | Caso d'uso |
|-------|----------|----------|
| **0.1-0.3** | Prevedibile, coerente, fattuale | Generazione di codice, supporto tecnico, estrazione di dati |
| **0.6-0.8** | Bilanciato, conversazione naturale | Chatbot generici, Q&A, tutoraggio |
| **1.0-1.5** | Creativo, vario, sorprendente | Scrittura creativa, brainstorming, narrazione |

**Raccomandazione predefinita: 0.7**

### 2. Finestra di contesto (num_ctx)

Quanta cronologia della conversazione il modello ricorda (in token).

| Valore | Comportamento | Caso d'uso |
|-------|----------|----------|
| **2048** | 2-3 scambi | Q&A rapidi, attività semplici |
| **4096** | 5-10 scambi | Conversazioni normali (consigliato) |
| **8192** | Discussioni lunghe | Analisi complesse, revisione del codice |

**Raccomandazione predefinita: 4096**

### 3. Top-P (Nucleus Sampling)

Controlla la diversità dell'output. Mantienilo semplice.

| Valore | Comportamento |
|-------|----------|
| **0.9** | Buon valore predefinito per quasi tutto |
| **1.0** | Massima diversità (usare con temperature bassa) |

**Raccomandazione predefinita: 0.9**

---

## 📋 Template da copiare e incollare

### Chatbot generico (il più comune)
```
PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
```

### Assistente per il codice
```
PARAMETER temperature 0.3
PARAMETER num_ctx 8192
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1
```

### Bot di assistenza clienti
```
PARAMETER temperature 0.3
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
```

### Scrittore creativo
```
PARAMETER temperature 1.2
PARAMETER num_ctx 8192
PARAMETER top_p 0.95
```

### Traduttore
```
PARAMETER temperature 0.2
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
```

### Estrazione dati / Output strutturato
```
PARAMETER temperature 0.1
PARAMETER num_ctx 2048
PARAMETER top_p 0.9
```

---

## 🔧 Parametri opzionali (avanzati)

Questi sono i comandi di regolazione fine. **Saltali a meno che tu non abbia esigenze specifiche.**

### top_k (Pool di selezione dei token)
- **Predefinito: 40**
- Più alto = output più vario
- Più basso = output più focalizzato
- Intervallo: 1-100

```
PARAMETER top_k 40
```

### repeat_penalty (Controllo della ripetizione)
- **Predefinito: 1.1**
- Più alto = meno ripetizioni (può rendere l'output strano)
- Più basso = più ripetizioni (naturale ma ridondante)
- Intervallo: 0.5-2.0

```
PARAMETER repeat_penalty 1.1
```

### stop (Sequenze di stop)
Interrompe la generazione quando compaiono queste stringhe.

```
PARAMETER stop "User:"
PARAMETER stop "###"
```

### num_predict (Lunghezza massima della risposta)
Numero massimo di token nella risposta.

```
PARAMETER num_predict 512
```

### seed (Riproducibilità)
Imposta un seed per output coerenti (utile per i test).

```
PARAMETER seed 42
```

---

## 🎨 Guida visiva alla temperature

```
Temperature Scale:
0.0 ───────────────────────── 2.0
 │           │           │
Robotic   Natural   Chaotic
```

**Esempi a diverse temperature:**

**Domanda:** "Quanto fa 2+2?"

| Temp | Risposta |
|------|----------|
| 0.1  | "2+2 fa 4." |
| 0.7  | "La risposta a 2+2 è 4. Si tratta di aritmetica di base." |
| 1.5  | "Beh, se parliamo di matematica standard, 2+2 ci dà 4, anche se in alcuni contesti astratti..." |

**Noti la differenza?** Più bassa = diretta, più alta = elaborata.

---

## 🧪 Come sperimentare

### Passo 1: Inizia con i valori predefiniti
```
PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
```

### Passo 2: Testa il tuo modello
```bash
make chat
# Select your model and test with real prompts
```

### Passo 3: Regola UN parametro alla volta

**Se l'output è troppo noioso/ripetitivo:**
- Aumenta la temperature di 0.2

**Se l'output è troppo casuale/incoerente:**
- Diminuisci la temperature di 0.2

**Se il modello "dimentica" le parti precedenti della conversazione:**
- Aumenta num_ctx a 8192

**Se le risposte sono troppo lunghe:**
- Aggiungi `PARAMETER num_predict 256`

### Passo 4: Ricrea il modello
```bash
# Edit your Modelfile with new parameters
bash scripts/create-custom-model.sh my-model ./models/custom/my-model/Modelfile
```

---

## 💡 Problemi comuni e soluzioni

### "Il modello dà sempre la stessa risposta"
**Problema:** Temperature troppo bassa
**Soluzione:** Aumentala a 0.7 o più

### "L'output del modello è insensato/incoerente"
**Problema:** Temperature troppo alta
**Soluzione:** Diminuiscila a 0.7 o meno

### "Il modello dimentica ciò che ho detto prima"
**Problema:** Finestra di contesto troppo piccola
**Soluzione:** Aumenta num_ctx a 8192

### "Il modello ripete costantemente le frasi"
**Problema:** Penalità di ripetizione troppo bassa
**Soluzione:** Imposta `repeat_penalty 1.2`

### "Le risposte vengono troncate a metà frase"
**Problema:** Lunghezza massima della risposta troppo breve
**Soluzione:** Aggiungi `PARAMETER num_predict 1024`

---

## 📊 Tabella di confronto dei parametri

| Caso d'uso | Temp | num_ctx | top_p | repeat_penalty |
|----------|------|---------|-------|----------------|
| **Chatbot** | 0.7 | 4096 | 0.9 | 1.1 |
| **Codice** | 0.3 | 8192 | 0.9 | 1.1 |
| **Assistenza** | 0.3 | 4096 | 0.9 | 1.0 |
| **Creativo** | 1.2 | 8192 | 0.95 | 1.0 |
| **Traduttore** | 0.2 | 4096 | 0.9 | 1.0 |
| **Estrazione dati** | 0.1 | 2048 | 0.9 | 1.0 |

---

## 🚀 Raccomandazioni per l'avvio rapido

**Vuoi solo iniziare?** Usa questo:

```dockerfile
FROM llama3.2:1b

PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_p 0.9

SYSTEM """
Your instructions here...
"""
```

**Questo funziona per l'80% dei casi d'uso!**

Regola la temperature dopo aver fatto dei test:
- Troppo prevedibile? → Aumentala a 0.9
- Troppo casuale? → Abbassala a 0.5

---

## 📖 Riferimento completo dei parametri

Per la documentazione completa dei parametri, vedi [Riferimento Modelfile](./modelfile-reference.md).

---

## 🎓 Percorso di apprendimento

1. **Settimana 1:** Usa i valori predefiniti (temp 0.7, ctx 4096, top_p 0.9)
2. **Settimana 2:** Sperimenta solo con la temperature
3. **Settimana 3:** Prova diverse finestre di contesto
4. **Settimana 4:** Esplora i parametri avanzati

**Non cercare di ottimizzare tutto in una volta!**

---

## 🔗 Prossimi passi

- **Applica queste impostazioni:** [Modelfile di esempio](./examples.md)
- **Comprendi i concetti:** [Concetti essenziali](./concepts.md)
- **Riferimento completo:** [Riferimento Modelfile](./modelfile-reference.md)

---

**Ricorda:** Dei buoni prompt contano più di parametri perfetti! Dedica il tuo tempo a migliorare il tuo prompt SYSTEM, non a modificare all'infinito dei numeri.
