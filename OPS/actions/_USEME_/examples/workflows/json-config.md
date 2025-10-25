# JSON Configuration

Using JSON format instead of .env files.

## Example

```yaml
name: JSON Config Example
on: [push]

jobs:
  run-action:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run action with JSON config
        uses: ./deploy/actions/my-action
        with:
          config: config.json
```

## Config File (config.json)

```json
{
  "PASSWORD": "my-password",
  "PROXMOX_HOST": "192.168.1.100",
  "VMID": "1000",
  "HOSTNAME": "my-server",
  "DOMAIN": "example.com"
}
```

## Benefits of JSON

- Structured data format
- Easy to parse programmatically
- Good for complex configurations
- Can use tools like `jq` to manipulate

## When to Use

- Prefer JSON over .env format
- Need nested data structures
- Integrating with JSON-based tools
