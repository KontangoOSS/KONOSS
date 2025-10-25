# Using with Secrets

Combine config files with repository secrets for sensitive data.

## Example

```yaml
name: Secrets Example
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      # Load secrets from Phase (or other secret manager)
      - name: Load secrets
        uses: ./deploy/actions/phase-load-secrets
        with:
          config: .env
          phase_app_id: ${{ secrets.PHASE_APP_ID }}
          phase_env: production
          phase_secret: ${{ secrets.PHASE_SECRET }}

      # Run action with config that now has secrets
      - name: Run action
        uses: ./deploy/actions/my-action
        with:
          config: .env
```

## Config File (.env)

**Before loading secrets:**
```bash
PROXMOX_HOST=192.168.1.100
VMID=1000
HOSTNAME=my-server
```

**After phase-load-secrets action:**
```bash
PROXMOX_HOST=192.168.1.100
VMID=1000
HOSTNAME=my-server
PASSWORD=super-secret-password
API_TOKEN=abc123xyz789
SSH_PRIVATE_KEY=-----BEGIN RSA PRIVATE KEY-----...
```

## Best Practices

1. **Never commit secrets** to config files
2. **Use secret managers** (Phase, GitHub Secrets, etc.)
3. **Load secrets early** in the workflow
4. **Required secrets** should be in schema.json for validation

## Schema Configuration

```json
{
  "PROXMOX_HOST": "required",
  "VMID": "required",
  "PASSWORD": "required",
  "API_TOKEN": "required",
  "HOSTNAME": "optional"
}
```

## When to Use

- Working with sensitive data
- Production deployments
- API keys and tokens needed
- SSH keys or certificates required
