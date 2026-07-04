#!/bin/bash
# Shared helper functions for the Ollama model training guide scripts.
#
# This file is meant to be sourced, not executed directly:
#
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "$SCRIPT_DIR/lib/common.sh"
#
# All helpers assume the caller runs with the repository root as the
# current working directory (as the Makefile does).

# check_ollama_running [start-hint]
#
# Verify the Ollama service is up; print an error and exit 1 otherwise.
# start-hint defaults to "docker compose up -d" (test scripts pass "make up").
# The `docker compose ps` output is captured into a variable first so that
# `grep -q` cannot kill it with SIGPIPE under `set -o pipefail`.
check_ollama_running() {
    local hint="${1:-docker compose up -d}"
    local status
    status="$(docker compose ps 2>/dev/null || true)"
    if ! grep -qE "ollama.*(Up|running)" <<< "$status"; then
        echo "❌ Error: Ollama service is not running"
        echo "Please start it with: $hint"
        exit 1
    fi
}

# get_model_names
#
# Print the names of all installed models, one per line (header stripped).
# stdin is redirected from /dev/null so `docker compose exec` (interactive
# by default) cannot swallow the caller's stdin (e.g. piped menu answers).
get_model_names() {
    docker compose exec ollama ollama list < /dev/null | awk 'NR > 1 && NF { print $1 }'
}

# model_exists <model-name>
#
# Return 0 if the model is installed, 1 otherwise. The comparison is an
# exact string match against the NAME column; a bare "name" also matches
# "name:latest" (the tag Ollama assigns by default).
model_exists() {
    local name="$1"
    get_model_names | awk -v n="$name" \
        '$0 == n || $0 == (n ":latest") { found = 1 } END { exit !found }'
}

# pick_model <out-var> <prompt-label> <zero-label> <zero-read-prompt> [highlight-suffix]
#
# Show a numbered menu of installed models and store the selection in the
# variable named by <out-var>.
#   prompt-label     - text before " [0-N]: ", e.g. "Select a model"
#   zero-label       - menu text for option [0], e.g. "Cancel" or "Enter custom name"
#   zero-read-prompt - prompt used to read a manual name when [0] is chosen;
#                      pass "" to make [0] cancel (prints "Cancelled", exit 0)
#   highlight-suffix - appended to models without a ':' tag (likely custom),
#                      e.g. " ⭐" or " ⭐ [likely custom]"; omit for no highlight
pick_model() {
    local out_var="$1" prompt_label="$2" zero_label="$3" zero_read_prompt="$4"
    local highlight_suffix="${5:-}"
    local models=() index=1 line model_name model_size selection

    while IFS= read -r line; do
        # Skip empty lines and header
        [ -z "$line" ] && continue
        [[ "$line" =~ ^NAME ]] && continue

        model_name=$(echo "$line" | awk '{print $1}')
        model_size=$(echo "$line" | awk '{print $2}')
        [ -z "$model_name" ] && continue

        models+=("$model_name")

        # Highlight likely custom models (no ':' tag)
        if [ -n "$highlight_suffix" ] && [[ ! "$model_name" =~ : ]]; then
            echo "  [$index] $model_name ($model_size)$highlight_suffix"
        else
            echo "  [$index] $model_name ($model_size)"
        fi
        index=$((index + 1))
    done < <(docker compose exec ollama ollama list < /dev/null)

    if [ ${#models[@]} -eq 0 ]; then
        echo "  No models found"
        echo ""
        echo "Pull a base model first:"
        echo "  make pull-base"
        exit 1
    fi

    echo ""
    echo "  [0] $zero_label"
    echo ""
    read -r -p "$prompt_label [0-$((index - 1))]: " selection || selection=""

    # Validate input
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 0 ] || [ "$selection" -ge "$index" ]; then
        echo "❌ Invalid selection"
        exit 1
    fi

    if [ "$selection" -eq 0 ]; then
        if [ -z "$zero_read_prompt" ]; then
            echo "Cancelled"
            exit 0
        fi
        read -r -p "$zero_read_prompt" selection || selection=""
        printf -v "$out_var" '%s' "$selection"
    else
        printf -v "$out_var" '%s' "${models[$((selection - 1))]}"
    fi
}

# pick_modelfile <out-var>
#
# Show a numbered menu of the Modelfiles found under ./models/examples and
# ./models/custom and store the selected path in the variable named by
# <out-var>. Option [0] lets the user type a custom path.
pick_modelfile() {
    local out_var="$1"
    local modelfiles=() index=1 dir file display_name selection

    for dir in ./models/examples ./models/custom; do
        [ -d "$dir" ] || continue
        while IFS= read -r file; do
            modelfiles+=("$file")
            display_name="${file#./models/}"
            echo "  [$index] $display_name"
            index=$((index + 1))
        done < <(find "$dir" -name "Modelfile" -type f | sort)
    done

    if [ ${#modelfiles[@]} -eq 0 ]; then
        echo "  No Modelfiles found in models/examples or models/custom"
        exit 1
    fi

    echo ""
    echo "  [0] Enter custom path"
    echo ""
    read -r -p "Select a Modelfile [0-$((index - 1))]: " selection || selection=""

    # Validate input
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 0 ] || [ "$selection" -ge "$index" ]; then
        echo "❌ Invalid selection"
        exit 1
    fi

    if [ "$selection" -eq 0 ]; then
        read -r -p "Enter path to Modelfile: " selection || selection=""
        printf -v "$out_var" '%s' "$selection"
    else
        printf -v "$out_var" '%s' "${modelfiles[$((selection - 1))]}"
    fi
}

# pick_saved_modelfile <out-var> [saved-dir]
#
# Show a numbered menu of saved *.Modelfile files (default: ./models/saved)
# and store the selected path in the variable named by <out-var>.
# Option [0] lets the user type a custom path.
pick_saved_modelfile() {
    local out_var="$1" saved_dir="${2:-./models/saved}"
    local modelfiles=() index=1 file selection

    if [ ! -d "$saved_dir" ]; then
        echo "❌ No saved models directory found at: $saved_dir"
        exit 1
    fi

    while IFS= read -r file; do
        modelfiles+=("$file")
        echo "  [$index] $(basename "$file")"
        index=$((index + 1))
    done < <(find "$saved_dir" -name "*.Modelfile" -type f | sort)

    if [ ${#modelfiles[@]} -eq 0 ]; then
        echo "  No saved Modelfiles found in $saved_dir"
        echo ""
        echo "Save a model first:"
        echo "  make save-model"
        exit 1
    fi

    echo ""
    echo "  [0] Enter custom path"
    echo ""
    read -r -p "Select a saved model [0-$((index - 1))]: " selection || selection=""

    # Validate input
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 0 ] || [ "$selection" -ge "$index" ]; then
        echo "❌ Invalid selection"
        exit 1
    fi

    if [ "$selection" -eq 0 ]; then
        read -r -p "Enter path to Modelfile: " selection || selection=""
        printf -v "$out_var" '%s' "$selection"
    else
        printf -v "$out_var" '%s' "${modelfiles[$((selection - 1))]}"
    fi
}

# strip_ansi
#
# Filter (stdin -> stdout): remove ANSI escape sequences, control characters
# and spinner glyphs from captured terminal output (e.g. `ollama run`
# progress animations), then trim leading/trailing whitespace.
strip_ansi() {
    sed -r 's/\x1B\[[0-9;?]*[a-zA-Z]//g' \
        | sed -r 's/\x1B\][0-9;]*;//g' \
        | tr -d '\000-\037' \
        | sed 's/⠋//g; s/⠙//g; s/⠹//g; s/⠸//g; s/⠼//g; s/⠴//g; s/⠦//g; s/⠧//g; s/⠇//g; s/⠏//g' \
        | sed 's/^\s*//; s/\s*$//'
}

# first_nonempty_line
#
# Filter: print the first non-empty line of stdin. Unlike `grep -v '^$' |
# head -1`, this consumes all input, so it never triggers a SIGPIPE failure
# in upstream commands under `set -o pipefail`, and it exits 0 even when
# the input is entirely empty.
first_nonempty_line() {
    awk 'NF { if (!found) { print; found = 1 } }'
}
