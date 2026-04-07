# classify-failures

Task-specific Promptfoo project for classifying engineering artifacts into one label:

- `test_failure`
- `build_failure`
- `config_error`
- `runtime_error`

## Layout

- `suites/` contains runnable Promptfoo entrypoints.
- `tests/` contains only test cases, split by suite purpose.
- `prompts/` contains the task prompt and labeling rules.
- `providers/` contains reusable provider shims.

## Suite roles

- `baseline.yaml`: representative, obvious cases. Keep this stable and easy to interpret.
- `edge.yaml`: ambiguous boundary cases that reveal label confusion.
- `adversarial.yaml`: noisy, truncated, or mixed-signal logs that stress robustness.
- `regression.yaml`: confirmed model misses that should never silently regress.
- `holdout.yaml`: frozen cases reserved for untuned checks; do not use it for prompt iteration.

## Working rules

1. Add new real-world misses to `tests/regression.yaml` first.
2. Promote a case into `tests/baseline.yaml` only if it becomes a stable must-pass example.
3. Keep `tests/holdout.yaml` small and intentionally untouched during routine prompt tuning.
4. Change one axis at a time when comparing models: prompt, provider, or suite composition.
5. Record model id, suite names, and prompt revision in your comparison notes.

## Commands

From the repo root:

```bash
just eval
just eval-edge
just eval-adversarial
just eval-regression
just eval-holdout
```
