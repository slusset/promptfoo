#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "usage: $0 <model-id> [<model-id> ...]" >&2
  exit 1
fi

configs=(
  "evals/classify-failures/suites/baseline.yaml"
  "evals/classify-failures/suites/edge.yaml"
  "evals/classify-failures/suites/adversarial.yaml"
)

for model in "$@"; do
  echo
  echo "## MODEL: $model"

  for config in "${configs[@]}"; do
    echo "### SUITE: $config"

    if ! output=$(LOCAL_LLAMACPP_MODEL="$model" npx promptfoo eval -c "$config" 2>&1); then
      echo "$output"
      exit 1
    fi

    echo "$output" | awk '/^Results: / || /^Duration: / || /^Total Tokens: /'
    echo
  done
done
