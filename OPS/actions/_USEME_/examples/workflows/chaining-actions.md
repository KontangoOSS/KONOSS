# Chaining Actions - Multi-Step Workflows

Since composite actions **cannot call other actions**, the recommended pattern is to **chain actions in your workflow**.

## Basic Pattern: Sequential Actions

Each action processes the config and passes it to the next action:

```yaml
name: Multi-Step Deployment
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      # Action 1: Validate and prepare config
      - name: Validate configuration
        id: validate
        uses: ./deploy/actions/validate-config
        with:
          config: .env

      # Action 2: Provision infrastructure (uses output from Action 1)
      - name: Provision infrastructure
        id: provision
        uses: ./deploy/actions/provision-vm
        with:
          config: ${{ steps.validate.outputs.config }}

      # Action 3: Deploy application (uses output from Action 2)
      - name: Deploy application
        id: deploy
        uses: ./deploy/actions/deploy-app
        with:
          config: ${{ steps.provision.outputs.config }}

      # Action 4: Run tests
      - name: Run tests
        uses: ./deploy/actions/run-tests
        with:
          config: ${{ steps.deploy.outputs.config }}
```

## How Config Chaining Works

Each action in the _USEME_ template:

1. **Receives** config via `inputs.config`
2. **Loads** config into environment variables
3. **Modifies** variables with `export VAR="value"`
4. **Saves** updated config back to file
5. **Outputs** the config path via `outputs.config`

The next action receives the updated config!

## Summary

- ❌ Cannot call actions from within composite actions
- ✅ Chain actions in workflow using `steps.id.outputs.config`
- ✅ Each action modifies config and passes to next action
- ✅ Keep each action simple with ONE responsibility
