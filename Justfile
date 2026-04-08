set shell := ["zsh", "-cu"]

default:
  @just --list

env-check:
  @set -a; if [ -f .env ]; then source .env; fi; set +a; if printenv OPENAI_API_KEY >/dev/null; then echo "OPENAI_API_KEY is set"; else echo "OPENAI_API_KEY is not set"; fi

llama-serve-local:
  llama-server -hf ggml-org/gemma-4-E4B-it-GGUF:Q8_0 --host 127.0.0.1 --port 8080

llama-serve-lan:
  llama-server -hf ggml-org/gemma-4-E4B-it-GGUF:Q8_0 --host 0.0.0.0 --port 8080

llama-health:
  set -a; if [ -f .env ]; then source .env; fi; set +a; curl -sS "${LOCAL_LLAMACPP_BASE_URL:-http://localhost:8080}/v1/models"

eval:
  set -a; if [ -f .env ]; then source .env; fi; set +a; npx promptfoo eval -c evals/classify-failures/suites/baseline.yaml

eval-edge:
  set -a; if [ -f .env ]; then source .env; fi; set +a; npx promptfoo eval -c evals/classify-failures/suites/edge.yaml

eval-adversarial:
  set -a; if [ -f .env ]; then source .env; fi; set +a; npx promptfoo eval -c evals/classify-failures/suites/adversarial.yaml

eval-regression:
  set -a; if [ -f .env ]; then source .env; fi; set +a; npx promptfoo eval -c evals/classify-failures/suites/regression.yaml

eval-holdout:
  set -a; if [ -f .env ]; then source .env; fi; set +a; npx promptfoo eval -c evals/classify-failures/suites/holdout.yaml

eval-all:
  set -a; if [ -f .env ]; then source .env; fi; set +a; npx promptfoo eval -c evals/classify-failures/suites/baseline.yaml && npx promptfoo eval -c evals/classify-failures/suites/edge.yaml && npx promptfoo eval -c evals/classify-failures/suites/adversarial.yaml

eval-latest:
  set -a; if [ -f .env ]; then source .env; fi; set +a; npx promptfoo@latest eval

eval-model model:
  set -a; if [ -f .env ]; then source .env; fi; set +a; LOCAL_LLAMACPP_MODEL='{{model}}' npx promptfoo eval -c evals/classify-failures/suites/baseline.yaml

eval-edge-model model:
  set -a; if [ -f .env ]; then source .env; fi; set +a; LOCAL_LLAMACPP_MODEL='{{model}}' npx promptfoo eval -c evals/classify-failures/suites/edge.yaml

eval-adversarial-model model:
  set -a; if [ -f .env ]; then source .env; fi; set +a; LOCAL_LLAMACPP_MODEL='{{model}}' npx promptfoo eval -c evals/classify-failures/suites/adversarial.yaml

eval-regression-model model:
  set -a; if [ -f .env ]; then source .env; fi; set +a; LOCAL_LLAMACPP_MODEL='{{model}}' npx promptfoo eval -c evals/classify-failures/suites/regression.yaml

eval-holdout-model model:
  set -a; if [ -f .env ]; then source .env; fi; set +a; LOCAL_LLAMACPP_MODEL='{{model}}' npx promptfoo eval -c evals/classify-failures/suites/holdout.yaml

compare-models +models:
  set -a; if [ -f .env ]; then source .env; fi; set +a; ./scripts/compare_local_models.sh {{models}}

view:
  set -a; if [ -f .env ]; then source .env; fi; set +a; npx promptfoo view

config:
  sed -n '1,220p' evals/classify-failures/suites/baseline.yaml
