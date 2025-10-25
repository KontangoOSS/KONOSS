# Multiple Configurations

Run the same action multiple times with different config files.

## Example

```yaml
name: Multiple Configs Example
on: [push]

jobs:
  deploy-all:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      # Deploy production
      - name: Deploy production
        uses: ./deploy/actions/my-action
        with:
          config: .env.production

      # Deploy staging
      - name: Deploy staging
        uses: ./deploy/actions/my-action
        with:
          config: .env.staging

      # Deploy development
      - name: Deploy development
        uses: ./deploy/actions/my-action
        with:
          config: .env.development
```

## Config Files

**.env.production:**
```bash
ENVIRONMENT=production
PROXMOX_HOST=192.168.1.100
VMID=1000
HOSTNAME=prod-server
```

**.env.staging:**
```bash
ENVIRONMENT=staging
PROXMOX_HOST=192.168.1.101
VMID=2000
HOSTNAME=staging-server
```

**.env.development:**
```bash
ENVIRONMENT=development
PROXMOX_HOST=192.168.1.102
VMID=3000
HOSTNAME=dev-server
```

## When to Use

- Multi-environment deployments
- Same action, different configurations
- Parallel or sequential processing
- Testing across multiple scenarios
