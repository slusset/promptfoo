# Promptfoo local eval sandbox

This repo is a small, task-specific eval harness for comparing local or cloud LLMs on an engineering-artifact classification task.

Current task:

- input: an engineering artifact, error, stack trace, or test failure
- output: exactly one label
  - `test_failure`
  - `build_failure`
  - `config_error`
  - `runtime_error`

The current provider is wired to a local llama.cpp-compatible endpoint, which makes it easy to compare models running on a local machine such as an MBP M4 Max.

Provider connectivity is environment-driven. The checked-in configs default to `http://localhost:8080`, and `LOCAL_LLAMACPP_BASE_URL` / `LOCAL_LLAMACPP_MODEL` can override that per laptop.

## Why this repo exists

This is not a generic benchmark. It is a custom eval suite tailored to a specific use case:

- compare local models on a task you actually care about
- keep the task narrow and measurable
- discover failure modes
- turn those failure modes into new regression cases

That lets you answer:

- which model is most accurate for this task?
- where does each model break?
- what mistakes are systematic?
- is a smaller/faster local model good enough?

## Layout

- `evals/classify-failures/suites/` - runnable Promptfoo suite entrypoints
- `evals/classify-failures/tests/` - suite-specific case lists
- `evals/classify-failures/prompts/classify_failure.yaml` - task prompt and decision rules
- `evals/classify-failures/providers/local-llamacpp.js` - promptfoo provider shim for local llama.cpp/OpenAI-compatible chat completions
- `evals/classify-failures/README.md` - task-local workflow notes
- `evals/hello-world/promptfooconfig.yaml` - minimal example project
- `promptfooconfig*.yaml` - root compatibility entrypoints
- `scripts/compare_local_models.sh` - compact multi-model comparison runner
- `Justfile` - convenience commands

## Quick start

Create a local `.env` file for the laptop you are on:

```bash
cp .env.example .env
```

Adjust the endpoint if this machine should call a remote host instead of its own local server:

```bash
LOCAL_LLAMACPP_BASE_URL=http://localhost:8080
LOCAL_LLAMACPP_MODEL=ggml-org/gemma-4-E4B-it-GGUF:Q8_0
```

Check the local model endpoint:

```bash
just llama-health
```

Run the baseline suite:

```bash
just eval
```

Run the edge-case suite:

```bash
just eval-edge
```

Run the adversarial/noisy suite:

```bash
just eval-adversarial
```

Run the regression suite:

```bash
just eval-regression
```

Run the holdout suite:

```bash
just eval-holdout
```

Run the core comparison suites:

```bash
just eval-all
```

View recent promptfoo results:

```bash
just view
```

Run one suite against a specific model id:

```bash
just eval-model 'your-model-id'
just eval-edge-model 'your-model-id'
just eval-adversarial-model 'your-model-id'
just eval-regression-model 'your-model-id'
just eval-holdout-model 'your-model-id'
```

Run all three suites for multiple model ids:

```bash
just compare-models 'model-a' 'model-b'
```

## Suite strategy

### 1. Baseline suite

Use `evals/classify-failures/suites/baseline.yaml` for obvious, representative cases.

Purpose:

- verify the prompt and provider wiring
- establish a stable regression baseline
- compare models on easy-to-medium examples

### 2. Edge suite

Use `evals/classify-failures/suites/edge.yaml` for boundary cases.

Purpose:

- stress label confusion boundaries
- find systematic mistakes
- keep tricky cases separate from the baseline

Examples:

- test hooks that fail because of config
- test panics that still belong to a test runner context
- build failures reported inside Docker or bundlers
- runtime failures that look operational rather than purely code-level

### 3. Adversarial suite

Use `evals/classify-failures/suites/adversarial.yaml` for noisy, truncated, and mixed-signal artifacts.

Purpose:

- test robustness against realistic messy logs
- reduce keyword overfitting
- verify the model still chooses the right label when multiple signals appear together

### 4. Regression suite

Use `evals/classify-failures/suites/regression.yaml` for confirmed misses from real evaluation runs.

Purpose:

- convert model mistakes into locked regression coverage
- keep the most important failures small and visible
- make prompt or rubric edits earn their keep

### 5. Holdout suite

Use `evals/classify-failures/suites/holdout.yaml` for frozen cases that you do not tune against.

Purpose:

- detect overfitting to baseline, edge, and regression cases
- preserve a cleaner signal for periodic quality checks
- keep at least one suite honest

## Organization best practices

- Create one eval project per use case under `evals/`.
- Keep `suites/` as thin entrypoints and `tests/` as the source-of-truth case lists.
- Reuse providers across projects instead of copying provider logic into each suite.
- Add confirmed misses to `regression.yaml` first, then decide later whether they belong in a broader suite.
- Keep `holdout.yaml` frozen once it starts carrying meaningful signal.
- Compare one axis at a time: prompt, provider, or test set composition.
- Preserve root compatibility configs only as convenience entrypoints, not as the canonical home of the eval.

## Recommended eval methodology

The intended loop is:

1. define the task narrowly
2. create a baseline suite
3. add edge cases
4. run multiple models against the same suite
5. inspect misses
6. convert misses into new tests
7. rerun

This means **failure modes are not noise**. They are the main input for improving the eval.

## Model comparison workflow

When comparing models:

1. keep the prompt fixed
2. keep the test files fixed
3. swap only the provider/model
4. record:
   - baseline score
   - edge-case score
   - adversarial score
   - common confusion pairs
   - speed/latency
   - practical deployment fit on your hardware


The local provider also supports runtime overrides:

- `LOCAL_LLAMACPP_MODEL`
- `LOCAL_LLAMACPP_BASE_URL`

Good comparison questions:

- does the model collapse multiple labels into one?
- does it over-predict runtime errors?
- does it respect test-runner context?
- is the added accuracy worth the added latency/memory footprint?

## Next expansion ideas

- adversarial/noisy formatting suite
- out-of-domain / unknown cases
- multi-model comparison configs
- confusion-matrix reporting
- per-label summary scripts

## Learn more

- Configuration guide: https://promptfoo.dev/docs/configuration/guide
- All providers: https://promptfoo.dev/docs/providers
- Assertions & metrics: https://promptfoo.dev/docs/configuration/expected-outputs
