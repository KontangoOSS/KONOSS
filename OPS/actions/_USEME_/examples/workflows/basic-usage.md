# Basic Usage

The simplest way to use this action with default settings.

## Example

```yaml
name: Basic Example
on: [push]

jobs:
  run-action:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run action with .env config
        uses: ./deploy/actions/my-action
        with:
          config: .env
```

## What Happens

1. Action loads variables from `.env` file
2. Validates required fields from `schema/schema.json`
3. Runs your action logic
4. Saves any updated variables back to `.env`

## Config File (.env)

```bash
# Required fields (from schema.json)
PASSWORD=my-password
PROXMOX_HOST=192.168.1.100
VMID=1000

# Optional fields
HOSTNAME=my-server
DOMAIN=example.com
```

## When to Use

- Simple single-step workflows
- Working with .env files
- Don't need to chain multiple actions
