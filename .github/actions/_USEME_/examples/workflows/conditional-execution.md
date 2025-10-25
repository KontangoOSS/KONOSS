# Conditional Execution

Run action only when certain conditions are met.

## Example: Branch-based Execution

```yaml
name: Conditional Example
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      # Only run on main branch
      - name: Deploy to production
        if: github.ref == 'refs/heads/main'
        uses: ./deploy/actions/my-action
        with:
          config: .env.production

      # Only run on develop branch
      - name: Deploy to staging
        if: github.ref == 'refs/heads/develop'
        uses: ./deploy/actions/my-action
        with:
          config: .env.staging
```

## Example: File-based Condition

```yaml
name: Conditional on Files
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Check if config exists
        id: check_config
        run: |
          if [ -f .env.production ]; then
            echo "exists=true" >> $GITHUB_OUTPUT
          else
            echo "exists=false" >> $GITHUB_OUTPUT
          fi

      # Only run if config file exists
      - name: Run action
        if: steps.check_config.outputs.exists == 'true'
        uses: ./deploy/actions/my-action
        with:
          config: .env.production
```

## Example: Status-based Condition

```yaml
name: Conditional on Previous Step
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run tests
        id: tests
        run: |
          # Run your tests
          pytest
          echo "status=success" >> $GITHUB_OUTPUT

      # Only deploy if tests passed
      - name: Deploy
        if: steps.tests.outputs.status == 'success'
        uses: ./deploy/actions/my-action
        with:
          config: .env
```

## When to Use

- Branch-specific deployments
- Conditional based on test results
- Only run if files exist
- Skip on certain conditions (failures, drafts, etc.)
