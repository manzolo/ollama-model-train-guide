# Ollama Model Training Guide

[![Documentation](https://img.shields.io/badge/docs-manzolo.github.io-teal?logo=materialformkdocs)](https://manzolo.github.io/ollama-model-train-guide/it/)
[![Test](https://github.com/manzolo/ollama-model-train-guide/actions/workflows/test.yml/badge.svg)](https://github.com/manzolo/ollama-model-train-guide/actions/workflows/test.yml)
[![Validate](https://github.com/manzolo/ollama-model-train-guide/actions/workflows/validate.yml/badge.svg)](https://github.com/manzolo/ollama-model-train-guide/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

🌐 [English](./README.md) | **Italiano**

Un progetto Docker Compose completo per creare, personalizzare e gestire modelli Ollama. Tutto ciò che serve per lavorare con modelli linguistici locali leggeri in un ambiente containerizzato, dalla personalizzazione di base alla gestione avanzata dei modelli.

<a href="https://www.buymeacoffee.com/manzolo">
  <img src=".github/blue-button.png" alt="Buy Me A Coffee" width="200">
</a>

## ✨ Funzionalità

- **Setup con Docker Compose**: ambiente Ollama containerizzato e facile da usare
- **🌐 Interfaccia Chat Web**: interfaccia web moderna su `http://localhost:8080`
- **🧙 Wizard Modelfile**: creazione guidata dei modelli su `http://localhost:8080/wizard`
- **📊 Convertitore Fogli di calcolo**: converte Excel/CSV nel formato di training JSONL
- **🔄 UI per il download dei modelli**: scarica modelli dalla libreria Ollama con avanzamento in tempo reale
- **📝 Modelfile di esempio**: template preconfigurati per i casi d'uso più comuni
- **🛠️ Script di supporto**: automazione comoda per le operazioni ricorrenti
- **🎨 Personalizzazione dei modelli**: regola parametri, prompt e comportamento
- **💾 Import/Export**: condividi e versiona i tuoi modelli personalizzati
- **⚡ Supporto GPU**: accelerazione NVIDIA opzionale tramite `make up-gpu`
- **💿 Storage persistente**: i modelli sopravvivono al riavvio dei container

## 🚀 Avvio rapido

**Nuovo su Ollama?** Leggi prima i [Concetti essenziali](./docs/concepts.it.md) (5 minuti di lettura).

```bash
git clone https://github.com/manzolo/ollama-model-train-guide.git
cd ollama-model-train-guide

make preflight      # 1. Verifica i requisiti di sistema
make setup          # 2. Crea .env e le directory
make up             # 3. Avvia Ollama + Interfaccia Chat
make create-model   # 4. Crea il tuo primo modello personalizzato (interattivo)
```

Poi scarica un modello di base e inizia a chattare:

```bash
docker compose exec ollama ollama pull llama3.2:1b
open http://localhost:8080
```

Tutto qui! 🎉

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/b4703c8f-8d34-4846-894d-699cb503efe9" />

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/ae737805-8df6-4d56-90e6-652dd4620844" />

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/51214062-044f-4f67-86e8-87a4cffe98a8" />

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/8f4d08f9-1740-4266-a04e-b28cf6b3b365" />

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/cd00f10a-cf6c-4504-a07f-7784c3e2bdd6" />

<img width="1000" height="879" alt="immagine" src="https://github.com/user-attachments/assets/195a95de-8235-4145-b3df-8dd547e43d72" />

## 📖 Documentazione

Consultabile anche come sito web all'indirizzo **<https://manzolo.github.io/ollama-model-train-guide/it/>** (generato con MkDocs a partire da `docs/`).

Ordine di lettura consigliato: parti dai **Concetti**, poi segui la tabella dall'alto verso il basso. Le guide di riferimento si consultano all'occorrenza.

| # | Documento | Cosa copre |
|---|-----------|------------|
| 1 | [Concetti essenziali](./docs/concepts.it.md) ⭐ | Modelli, Modelfile, parametri, scelta del modello di base, quale metodo usare — **inizia qui** |
| 2 | [Guida all'installazione](./docs/installation.it.md) | Prerequisiti, setup, configurazione di `.env`, supporto GPU |
| 3 | [Interfaccia Chat Web](./docs/chat-ui.it.md) | Interfaccia web: chat, gestione modelli, convertitore, wizard Modelfile |
| 4 | [Guida alla personalizzazione](./docs/customization-guide.it.md) | System prompt vs few-shot vs fine-tuning — scegli il metodo giusto |
| 5 | [Guida ai parametri](./docs/parameter-guide.it.md) | Preset di parametri pronti all'uso e consigli di tuning (riferimento canonico) |
| 6 | [Modelfile di esempio](./docs/examples.it.md) | Template preconfigurati: chatbot, assistente di codice, traduttore, bot di supporto |
| 7 | [Guida all'uso](./docs/usage.it.md) | Comandi CLI quotidiani e operazioni sui modelli |
| 8 | [Riferimento rapido](./docs/quick-reference.it.md) | Cheat sheet dei comandi e menu interattivi |
| 9 | [Guida al modello personale](./docs/personal-model-guide.it.md) | Crea un assistente personalizzato che conosce le tue informazioni |
| 10 | [Esempio di training con dataset](./docs/dataset-training-example.it.md) | Esempio completo: costruire un bot di supporto da un dataset di Q&A |
| 11 | [Guida al fine-tuning](./docs/fine-tuning-guide.it.md) | Approfondimento: fine-tuning esterno (Unsloth/HF), export GGUF, import in Ollama |
| 12 | [Riferimento Modelfile](./docs/modelfile-reference.it.md) | Riferimento completo della sintassi Modelfile |
| 13 | [Guida all'uso delle API](./docs/api-usage.it.md) | Documentazione dell'API REST di Ollama |
| 14 | [Guida al deployment](./docs/deployment-guide.it.md) | Salva, trasferisci e distribuisci modelli tra istanze |
| 15 | [Uso avanzato](./docs/advanced-usage.it.md) | Template, adapter LoRA, performance, monitoraggio, sicurezza |
| 16 | [Risoluzione dei problemi](./docs/troubleshooting.it.md) | Problemi comuni e soluzioni |

## 🌐 Interfaccia Web

`make up` avvia un'applicazione web Flask insieme a Ollama, con tre pagine:

- **Chat**: http://localhost:8080 — chatta con qualsiasi modello installato, scarica nuovi modelli con avanzamento in tempo reale, crea/modifica Modelfile
- **Convertitore**: http://localhost:8080/converter — converte fogli di calcolo Excel/CSV in dati di training JSONL
- **Wizard**: http://localhost:8080/wizard — creazione guidata di un Modelfile in 6 passi: scegli caso d'uso, modello di base, personalità, regole ed esempi, poi crea il modello con un clic

Vedi la [Guida all'interfaccia Chat](./docs/chat-ui.it.md) per i dettagli. Per avviare Ollama senza l'interfaccia web, usa `make up-core`.

## 📁 Struttura del progetto

```
ollama-model-train-guide/
├── docker-compose.yml      # Servizi: Ollama + Chat UI (profilo "chat")
├── docker-compose.gpu.yml  # Override GPU NVIDIA (make up-gpu)
├── .env                    # Porte, profili, tag immagine Ollama
├── Makefile                # Comandi comodi
├── LICENSE                 # Licenza MIT
├── chat/                   # Applicazione dell'interfaccia web
│   ├── app.py             # App Flask (chat + convertitore + wizard)
│   └── templates/         # Template HTML
├── models/
│   ├── examples/          # Modelfile preconfigurati
│   ├── custom/            # I tuoi Modelfile personalizzati
│   └── saved/             # Modelli esportati
├── data/
│   ├── gguf/             # File GGUF esterni
│   ├── adapters/         # Adapter LoRA
│   └── training/         # Dataset di training
├── scripts/              # Script di supporto (libreria condivisa in scripts/lib/)
└── docs/                 # Documentazione
```

## 🎯 Comandi comuni

### Gestione dell'ambiente

```bash
make preflight          # Verifica i requisiti di sistema
make setup              # Setup iniziale (crea .env)
make up                 # Avvia i servizi (Ollama + Chat UI)
make up-core            # Avvia solo Ollama (senza interfaccia web)
make up-gpu             # Avvia con supporto GPU NVIDIA
make down               # Ferma i servizi
make restart            # Riavvia tutti i servizi
make logs               # Visualizza i log
```

### Operazioni sui modelli

```bash
make pull-base          # Scarica i modelli di base comuni
make create-model       # Crea un modello personalizzato (interattivo)
make chat               # Chatta con un modello (interattivo)
make list-models        # Elenca tutti i modelli
make save-model         # Salva un modello per il deployment (interattivo)
make deploy-model       # Distribuisci un modello salvato (interattivo)
make publish-model      # Pubblica un modello su un registry esterno (interattivo)
make backup-models      # Esegue il backup di tutti i modelli personalizzati
make export-full        # Esporta un modello CON i pesi in un tar (interattivo)
make import-full        # Importa un archivio completo di un modello (interattivo)
```

### Test

```bash
make quick-test         # Test end-to-end rapido
make test               # Esegue i test di validazione
```

## 🌟 Casi d'uso popolari

### 1. Chattare con i modelli

Apri http://localhost:8080, seleziona un modello e inizia a chattare — oppure usa `make chat` dalla CLI. Vedi la [Guida all'interfaccia Chat](./docs/chat-ui.it.md).

### 2. Creare modelli personalizzati

- **Wizard** (il più semplice): apri http://localhost:8080/wizard e segui i passi
- **CLI interattiva**: `make create-model` e scegli un template
- **Da zero**: scrivi un Modelfile in `./models/custom/my-model/` ed esegui `bash scripts/create-custom-model.sh my-model ./models/custom/my-model/Modelfile`

Vedi i [Modelfile di esempio](./docs/examples.it.md) e il [Riferimento Modelfile](./docs/modelfile-reference.it.md).

### 3. Scaricare modelli con l'interfaccia

Apri http://localhost:8080, clicca su "Manage Models", inserisci un nome (es. `llama3.2:1b`) e osserva l'avanzamento in tempo reale. Sfoglia i modelli nella [Libreria Ollama](https://ollama.com/library).

### 4. Convertire fogli di calcolo in dati di training

Apri http://localhost:8080/converter, carica un file Excel/CSV, mappa le colonne domanda/risposta e scarica o salva il JSONL. Vedi [Guida all'interfaccia Chat - Convertitore](./docs/chat-ui.it.md#convertitore-da-foglio-di-calcolo-a-jsonl).

### 5. Addestrare con i tuoi dati

Prepara un dataset JSONL (o usa il convertitore), aggiungi esempi MESSAGE a un Modelfile, crea il modello e itera. Vedi l'[Esempio di training con dataset](./docs/dataset-training-example.it.md) e, per il vero fine-tuning, la [Guida al fine-tuning](./docs/fine-tuning-guide.it.md).

## 🔧 Esempio: creare un chatbot personalizzato

```bash
# 1. Crea un Modelfile
mkdir -p ./models/custom/my-bot
cat > ./models/custom/my-bot/Modelfile << 'EOF'
FROM llama3.2:1b

PARAMETER temperature 0.7
PARAMETER num_ctx 4096

SYSTEM """
You are a friendly customer service assistant for ACME Corp.
Be helpful, professional, and concise.
"""

MESSAGE user "What are your hours?"
MESSAGE assistant "We're open Monday-Friday, 9am-6pm EST."
EOF

# 2. Crea il modello
bash scripts/create-custom-model.sh my-bot ./models/custom/my-bot/Modelfile

# 3. Provalo
docker compose exec ollama ollama run my-bot "Hello!"

# 4. Usalo nell'interfaccia web: apri http://localhost:8080 e seleziona "my-bot"
```

## 🧪 Test

```bash
make quick-test                          # Test end-to-end rapido
make test                                # Test di validazione
bash scripts/test-techcorp-example.sh    # Testa l'esempio del dataset TechCorp
```

GitHub Actions esegue automaticamente i test a ogni push. Vedi [.github/workflows/README.md](.github/workflows/README.md) per i dettagli su CI/CD.

## 🚨 Risoluzione dei problemi

Problemi? Consulta la [Guida alla risoluzione dei problemi](./docs/troubleshooting.it.md) per soluzioni relative all'avvio dei servizi, errori nella creazione dei modelli, problemi di connessione all'API, problemi di performance, spazio su disco e configurazione GPU.

## 🎮 Supporto GPU

Abilita l'accelerazione GPU NVIDIA per un'inferenza 5-10 volte più veloce:

```bash
# 1. Installa il NVIDIA Container Toolkit (vedi la guida all'installazione)
# 2. Avvia con l'override GPU
make up-gpu
```

Questo sovrappone `docker-compose.gpu.yml` al file compose di base — non serve modificare `docker-compose.yml`. Vedi [Guida all'installazione - Supporto GPU](./docs/installation.it.md#supporto-gpu-opzionale).

## 📚 Risorse aggiuntive

- [Documentazione ufficiale di Ollama](https://ollama.com/docs)
- [Specifica del Modelfile](https://github.com/ollama/ollama/blob/main/docs/modelfile.md)
- [Modelli disponibili](https://ollama.com/library)
- [Riferimento dell'API Ollama](https://github.com/ollama/ollama/blob/main/docs/api.md)

## 🤝 Contribuire

I contributi sono benvenuti! Aggiungi Modelfile di esempio, migliora la documentazione, segnala problemi o proponi miglioramenti. Tutte le pull request vengono testate automaticamente tramite GitHub Actions.

## 🧹 Pulizia

**Rimuovi tutti i container e i volumi** (elimina tutti i modelli):
```bash
make clean
```

## 📄 Licenza

Questo progetto è rilasciato sotto licenza MIT — vedi [LICENSE](./LICENSE).

---

**Inizia subito**: `make preflight && make setup && make up` poi apri http://localhost:8080
