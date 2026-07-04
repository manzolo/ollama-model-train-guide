# Ollama Model Training Guide

Un ambiente Docker Compose per creare, personalizzare e gestire modelli linguistici [Ollama](https://ollama.com) — senza bisogno di un cluster di GPU. Personalizza i modelli con i Modelfile (come i Dockerfile, ma per gli LLM), sperimenta tramite un'interfaccia web e distribuisci le tue creazioni ad altre istanze.

## Avvio rapido

```bash
make preflight      # verifica i requisiti di sistema
make setup          # crea .env e le directory
make up             # avvia Ollama + interfaccia web
make create-model   # crea il tuo primo modello personalizzato (interattivo)
```

Poi apri:

- **Interfaccia Chat** — <http://localhost:8080>
- **Wizard Modelfile** — <http://localhost:8080/wizard>
- **Convertitore Foglio di calcolo → JSONL** — <http://localhost:8080/converter>
- **API Ollama** — <http://localhost:11434>

## Dove andare adesso

| Se vuoi... | Leggi |
|---|---|
| Capire modelli, Modelfile e parametri | [Concetti](concepts.md) |
| Installare e configurare l'ambiente | [Installazione](installation.md) |
| Consultare velocemente un comando | [Riferimento rapido](quick-reference.md) |
| Creare un modello senza usare il terminale | [Interfaccia Web](chat-ui.md) |
| Scegliere tra prompt, few-shot e fine-tuning | [Scegliere un metodo](customization-guide.md) |
| Addestrare sul tuo dataset di Q&A | [Esempio di training con dataset](dataset-training-example.md) |
| Risolvere qualcosa che si è rotto | [Risoluzione dei problemi](troubleshooting.md) |

Il codice sorgente completo, il tracker delle issue e il README si trovano su [GitHub](https://github.com/manzolo/ollama-model-train-guide).
