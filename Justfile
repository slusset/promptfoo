set shell := ["zsh", "-cu"]

default:
  @just --list

env-check:
  @if printenv OPENAI_API_KEY >/dev/null; then echo "OPENAI_API_KEY is set"; else echo "OPENAI_API_KEY is not set"; fi

llama-health:
  curl -sS http://localhost:8080/v1/models

eval:
  npx promptfoo eval -c promptfooconfig.baseline.yaml

eval-edge:
  npx promptfoo eval -c promptfooconfig.edge.yaml

eval-adversarial:
  npx promptfoo eval -c promptfooconfig.adversarial.yaml

eval-all:
  npx promptfoo eval -c promptfooconfig.baseline.yaml && npx promptfoo eval -c promptfooconfig.edge.yaml && npx promptfoo eval -c promptfooconfig.adversarial.yaml

eval-latest:
  npx promptfoo@latest eval

eval-model model:
  LOCAL_LLAMACPP_MODEL='{{model}}' npx promptfoo eval -c promptfooconfig.baseline.yaml

eval-edge-model model:
  LOCAL_LLAMACPP_MODEL='{{model}}' npx promptfoo eval -c promptfooconfig.edge.yaml

eval-adversarial-model model:
  LOCAL_LLAMACPP_MODEL='{{model}}' npx promptfoo eval -c promptfooconfig.adversarial.yaml

compare-models +models:
  ./scripts/compare_local_models.sh {{models}}

view:
  npx promptfoo view

config:
  sed -n '1,220p' promptfooconfig.baseline.yaml
