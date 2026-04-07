set shell := ["zsh", "-cu"]

default:
  @just --list

env-check:
  @if printenv OPENAI_API_KEY >/dev/null; then echo "OPENAI_API_KEY is set"; else echo "OPENAI_API_KEY is not set"; fi

llama-health:
  curl -sS "${LOCAL_LLAMACPP_BASE_URL:-http://mbp:8080}/v1/models"

eval:
  npx promptfoo eval -c evals/classify-failures/suites/baseline.yaml

eval-edge:
  npx promptfoo eval -c evals/classify-failures/suites/edge.yaml

eval-adversarial:
  npx promptfoo eval -c evals/classify-failures/suites/adversarial.yaml

eval-regression:
  npx promptfoo eval -c evals/classify-failures/suites/regression.yaml

eval-holdout:
  npx promptfoo eval -c evals/classify-failures/suites/holdout.yaml

eval-all:
  npx promptfoo eval -c evals/classify-failures/suites/baseline.yaml && npx promptfoo eval -c evals/classify-failures/suites/edge.yaml && npx promptfoo eval -c evals/classify-failures/suites/adversarial.yaml

eval-latest:
  npx promptfoo@latest eval

eval-model model:
  LOCAL_LLAMACPP_MODEL='{{model}}' npx promptfoo eval -c evals/classify-failures/suites/baseline.yaml

eval-edge-model model:
  LOCAL_LLAMACPP_MODEL='{{model}}' npx promptfoo eval -c evals/classify-failures/suites/edge.yaml

eval-adversarial-model model:
  LOCAL_LLAMACPP_MODEL='{{model}}' npx promptfoo eval -c evals/classify-failures/suites/adversarial.yaml

eval-regression-model model:
  LOCAL_LLAMACPP_MODEL='{{model}}' npx promptfoo eval -c evals/classify-failures/suites/regression.yaml

eval-holdout-model model:
  LOCAL_LLAMACPP_MODEL='{{model}}' npx promptfoo eval -c evals/classify-failures/suites/holdout.yaml

compare-models +models:
  ./scripts/compare_local_models.sh {{models}}

view:
  npx promptfoo view

config:
  sed -n '1,220p' evals/classify-failures/suites/baseline.yaml
