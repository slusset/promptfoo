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

- `promptfooconfig.yaml` - baseline suite
- `promptfooconfig.edge.yaml` - edge-case suite
- `promptfooconfig.adversarial.yaml` - noisy/adversarial suite
- `prompts/classify_failure.yaml` - task prompt and decision rules
- `providers/local-llamacpp.js` - promptfoo provider shim for local llama.cpp/OpenAI-compatible chat completions
- `MODEL_COMPARISON_LOG.md` - reusable run log for side-by-side model comparison
- `scripts/compare_local_models.sh` - compact multi-model comparison runner
- `Justfile` - convenience commands

## Quick start

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

Run both:

```bash
just eval-all
```

View recent promptfoo results:

```bash
just view
```

View the comparison log template:

```bash
just compare-log
```

Run one suite against a specific model id:

```bash
just eval-model 'your-model-id'
just eval-edge-model 'your-model-id'
just eval-adversarial-model 'your-model-id'
```

Run all three suites for multiple model ids:

```bash
just compare-models 'model-a' 'model-b'
```

## Suite strategy

### 1. Baseline suite

Use `promptfooconfig.yaml` for obvious, representative cases.

Purpose:

- verify the prompt and provider wiring
- establish a stable regression baseline
- compare models on easy-to-medium examples

### 2. Edge suite

Use `promptfooconfig.edge.yaml` for boundary cases.

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

Use `promptfooconfig.adversarial.yaml` for noisy, truncated, and mixed-signal artifacts.

Purpose:

- test robustness against realistic messy logs
- reduce keyword overfitting
- verify the model still chooses the right label when multiple signals appear together

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
