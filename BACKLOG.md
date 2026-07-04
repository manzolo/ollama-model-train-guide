# Backlog

Running notes for the project. Completed items are kept for context; open
items are candidate follow-ups, not commitments.

## Done (July 2026 revamp)

- **Bug fixes**: wired `.env` into `docker-compose.yml` (ports/origins/image tag
  were documented but inert); fixed nonexistent `actions/checkout@v7` → `@v5`;
  `validate.yml` now checks `techcorp-support` and `LICENSE`; added MIT `LICENSE`;
  cleaned `.gitignore` and the duplicate `.PHONY` in the Makefile.
- **Compose/Make**: chat UI moved under compose profile `chat`; added
  `make up-core` (Ollama only) and `make up-gpu` (via `docker-compose.gpu.yml`,
  no more editing compose to enable GPU).
- **Chat app**: bumped to Python 3.12, Flask 3.1, pandas 2.3, etc.; rebuilt and
  smoke-tested (chat/converter/wizard endpoints all 200).
- **Scripts**: extracted `scripts/lib/common.sh` (dedup); all scripts on
  `set -euo pipefail`; exact model-name matching; removed dead `select-*.sh`.
- **Docs**: consolidated duplication (canonical fine-tuning/parameter/decision-tree
  docs); documented the `/wizard` page; added 2026 base-model tables and a
  "What's New in Ollama" note; README quickstart + badges.
- **Docs site**: MkDocs Material on GitHub Pages, deployed by `docs.yml`.
- **Full export/import**: `make export-full` / `make import-full` (tar of
  manifest + blobs, weights included); CI roundtrip in `test.yml`.
- **Bilingual docs**: full Italian translation — MkDocs `mkdocs-static-i18n`
  (EN at root, IT under `/it/`), `README.it.md`, 17 `docs/*.it.md`. EN+IT must
  be kept in sync (see CLAUDE.md "Bilingual Documentation").

## Open / optional follow-ups

- **Full-volume export**: `export-full` handles one model at a time. A whole
  `ollama_data` volume export/import could help full-machine migration (deferred;
  per-model tar chosen first).
- **Base-model refresh cadence**: the "Choosing a Base Model (2026)" tables will
  age. Revisit model recommendations periodically; keep `llama3.2:1b` as the
  lightweight default (incl. CI) unless requirements change.
- **Pin `OLLAMA_IMAGE_TAG`**: currently `latest`. Consider pinning a specific
  Ollama version for reproducible setups and export/import compatibility.
- **Ollama 2026 features**: cloud models, `ollama launch`, web search API are
  mentioned in docs but not integrated — could add opt-in examples if wanted.
- **Translation drift**: if English docs change without updating the `.it.md`
  counterpart, the IT site silently falls back to English for that page. A CI
  check for missing/oudated `.it.md` siblings could catch this.
