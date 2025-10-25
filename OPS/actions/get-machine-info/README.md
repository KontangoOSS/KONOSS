# Get Machine Info Action

A simple, self-contained action that collects current machine/system information and exports it to configuration variables.

## Features

- Collects comprehensive system information automatically
- No configuration required - just run it!
- Exports all data to config file for use in other actions
- Works on Linux and macOS
- Pretty-printed summary output
- Zero external dependencies (uses standard Unix utilities)

## Collected Information

| Variable | Description | Example |
|----------|-------------|---------|
| `MACHINE_HOSTNAME` | System hostname | `server-01` |
| `MACHINE_IP` | Primary IP address | `192.168.1.100` |
| `MACHINE_OS` | Operating system | `Linux` |
| `MACHINE_KERNEL` | Kernel version | `6.14.0-33-generic` |
| `MACHINE_ARCH` | System architecture | `x86_64` |
| `MACHINE_CPU_MODEL` | CPU model name | `Intel(R) Core(TM) i7-9700K` |
| `MACHINE_CPU_COUNT` | Number of CPU cores | `8` |
| `MACHINE_MEM_TOTAL_GB` | Total memory in GB | `32` |
| `MACHINE_MEM_AVAILABLE_GB` | Available memory in GB | `16` |
| `MACHINE_DISK_USAGE` | Root partition usage % | `45%` |
| `MACHINE_DISK_AVAILABLE` | Available disk space | `120G` |
| `MACHINE_UPTIME` | System uptime | `up 5 days, 3 hours` |
| `MACHINE_INFO_TIMESTAMP` | Collection timestamp (UTC) | `2025-10-25 14:30:00 UTC` |

## Usage

### From GitHub (Recommended)

Use the action from GitHub by checking out the repository first:

```yaml
- name: Checkout KONOSS
  uses: actions/checkout@v4
  with:
    repository: KontangoOSS/KONOSS
    ref: main

- name: Get Machine Info
  uses: ./OPS/actions/get-machine-info
  with:
    config: machine-info.env
```

### From Local Repository

If you're already in the KONOSS repository:

```yaml
- name: Get Machine Info
  uses: ./OPS/actions/get-machine-info
  with:
    config: machine-info.env
```

### Chaining with Other Actions

Collect machine info and use it in subsequent actions:

```yaml
- name: Checkout KONOSS
  uses: actions/checkout@v4
  with:
    repository: KontangoOSS/KONOSS
    ref: main

- name: Collect Machine Info
  id: machine
  uses: ./OPS/actions/get-machine-info
  with:
    config: .env

- name: Use Machine Context
  run: |
    source ${{ steps.machine.outputs.config }}
    echo "Running on: $MACHINE_HOSTNAME"
```

The subsequent steps will have access to all `MACHINE_*` variables.

### Standalone (No Config File)

Just collect and display the info:

```yaml
- name: Checkout KONOSS
  uses: actions/checkout@v4
  with:
    repository: KontangoOSS/KONOSS
    ref: main

- name: Show Machine Info
  uses: ./OPS/actions/get-machine-info
```

Variables are still exported for use in the same workflow.

## Example Output

```
🔧 Collecting machine information...

╔════════════════════════════════════════════════════════════╗
║           Machine Information Summary                     ║
╚════════════════════════════════════════════════════════════╝

  Hostname:       server-01
  IP Address:     192.168.1.100
  OS:             Linux
  Kernel:         6.14.0-33-generic
  Architecture:   x86_64
  CPU:            Intel(R) Core(TM) i7-9700K CPU @ 3.60GHz
  CPU Cores:      8
  Memory Total:   32GB
  Memory Avail:   16GB
  Disk Usage:     45%
  Disk Avail:     120G
  Uptime:         up 5 days, 3 hours
  Collected:      2025-10-25 14:30:00 UTC

════════════════════════════════════════════════════════════
✅ Machine information collected successfully
```

## Use Cases

1. **Logging/Auditing** - Capture machine info at the start of deployments
2. **Conditional Logic** - Make decisions based on available resources
3. **Documentation** - Auto-document deployment environments
4. **Monitoring** - Track resource usage over time
5. **Debugging** - Include system info in error reports

## Platform Compatibility

- **Linux**: Full support (tested on Ubuntu, Debian, CentOS, RHEL)
- **macOS**: Full support with automatic fallbacks
- **Windows**: Not supported (Unix-like systems only)

## Technical Notes

- Memory info uses `/proc/meminfo` on Linux, `sysctl` on macOS
- CPU info uses `/proc/cpuinfo` on Linux, `sysctl` on macOS
- IP address detection tries multiple methods for compatibility
- All commands have fallbacks for different system configurations
- Gracefully handles missing information (displays "unknown")

## Dependencies

Only standard Unix utilities (already installed on all systems):
- `bash`
- `coreutils` (hostname, uname, df, date, awk, grep)

## Self-Contained

This action is completely self-contained:
- All scripts included in `scripts/` folder
- No external dependencies
- Can be copied and used standalone
- No references to external paths

## License

MIT License - Kontango Limited

## Support

- Email: hello@kontango.us
- GitHub: https://github.com/KontangoOSS
- Docs: https://kontango.gitbook.io/kontango
