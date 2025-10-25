# Using Reusable Actions

You **CAN** call another action from within Step 2, but there are some limitations with composite actions.

## ✅ What Works: Call Actions from Workflows

The best pattern is to **chain actions in your workflow**, not within the action itself:

```yaml
name: My Workflow
on: [push]

jobs:
  my-job:
    runs-on: ubuntu-latest
    steps:
      # Step 1: Run first action
      - name: Load config
        id: config
        uses: ./deploy/actions/load-config
        with:
          config: .env

      # Step 2: Run your custom action with config from step 1
      - name: Process data
        uses: ./deploy/actions/process-data
        with:
          config: ${{ steps.config.outputs.config }}

      # Step 3: Run another action
      - name: Deploy
        uses: ./deploy/actions/deploy
        with:
          config: ${{ steps.config.outputs.config }}
```

## ❌ Limitations: Composite Actions Cannot Call Other Actions

Unfortunately, **composite actions cannot use the `uses:` keyword** to call other actions. From the GitHub Actions docs:

> Composite actions can only run commands with `shell` and `run` keywords. They cannot use `uses:` to call other actions.

## 🔧 Workaround: Use Scripts Instead

Since composite actions can't call other actions, the pattern we use is:

### Option 1: External Scripts (Recommended for Complex Logic)

Put your logic in `scripts/`:

```yaml
# action.yml - Step 2
- name: Execute action logic
  shell: bash
  run: |
    CONFIG="${{inputs.config}}"
    ACTION_DIR="$(dirname "$GITHUB_ACTION_PATH")"
    source "$ACTION_DIR/scripts/prime.sh" "$CONFIG"

    # Call Python script
    python3 "$ACTION_DIR/scripts/my-logic.py" --arg "$SOME_VAR"

    # Or bash script
    "$ACTION_DIR/scripts/my-logic.sh"
```

### Option 2: Inline Bash (Recommended for Simple Logic)

For simple logic, just write it inline in Step 2:

```yaml
# action.yml - Step 2
- name: Execute action logic
  shell: bash
  run: |
    CONFIG="${{inputs.config}}"
    ACTION_DIR="$(dirname "$GITHUB_ACTION_PATH")"
    source "$ACTION_DIR/scripts/prime.sh" "$CONFIG"

    echo "🔧 Running logic..."
    export STATUS="completed"
    export RESULT="success"
    echo "✅ Done"
```

## 🎯 Best Practice: Keep It Simple

The _USEME_ template is designed for you to:

1. **Edit action.yml Step 2 directly** for simple logic
2. **Add custom scripts to scripts/** for complex logic
3. **Chain multiple actions in workflows** for multi-step processes

This keeps each action **self-contained** and **easy to understand**.

## Example: Phase Integration

See [phase-list-secrets](../phase-list-secrets/action.yml) for a real example:

```yaml
# Step 2 calls Python script directly
- name: Execute action logic
  shell: bash
  run: |
    source "$ACTION_DIR/scripts/prime.sh" "$CONFIG"

    # Build arguments
    ARGS=(--host "$PHASE_HOST" --token "$PHASE_SECRET")

    # Call self-contained Python script
    python3 "$ACTION_DIR/scripts/phase-list.py" "${ARGS[@]}"
```

## Summary

- ❌ Cannot use `uses:` to call other actions from composite actions
- ✅ Can call scripts (bash, python, etc.) from `scripts/` folder
- ✅ Can write inline bash in Step 2
- ✅ Can chain multiple actions in workflows
