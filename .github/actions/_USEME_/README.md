# _USEME_ - Production-Ready Action Template

**🎯 Copy this template to create self-contained actions with automatic config management.**

## 🚀 Quick Start

```yaml
# Step 1: Config automatically loaded and validated ✅
# Step 2: Your code here - all variables ready!
- name: Execute action logic
  run: |
    echo "Host: $PROXMOX_HOST"      # Variables just work!
    export STATUS="deployed"        # Update variables
    ./my-script.py                  # Call your scripts
# Step 3: Config automatically saved ✅
```

**That's it!** No manual loading, no re-sourcing, just script as normal.

## ⚡ What You Get

A **completely self-contained** action with:

- ✅ **Unified config process** - Single script handles everything (deps → load → validate → export)
- ✅ **Multi-format support** - .env, .json, .txt formats all work seamlessly
- ✅ **Automatic validation** - Schema-based required/optional field checking
- ✅ **Child process ready** - Variables exported and verified accessible
- ✅ **Secure logging** - Audit logs with variable names only (values hidden for security)
- ✅ **KONOSS branding** - Beautiful banner shows at load completion
- ✅ **Auto-save** - Variables automatically saved back to config
- ✅ **Local testing** - Test script included for quick dev testing
- ✅ **CI/CD ready** - Example workflow for automated testing
- ✅ **Zero external dependencies** - All scripts included, fully self-contained
- ✅ **Clear structure** - Visual markers show exactly where to edit

## 📁 What's Included

```
_USEME_/
├── action.yml              # Template with 3-step pattern
├── action-spec.json        # 📋 Complete descriptor (schema/deps/metadata)
├── README.md               # This comprehensive guide
├── .gitignore              # Excludes .logs/ from git (security!)
├── scripts/                # 🎯 Just 3 scripts - ultra-clean!
│   ├── load-and-validate.sh # Step 1: deps→load→validate→export→log→banner
│   ├── save-config.sh      # Step 3: save variables + banner
│   └── test.sh             # Local test script template
├── .logs/                  # 🔒 Secure audit logs (gitignored, variable names only)
└── examples/               # All documentation & examples (DELETE in production)
    ├── README.md           # Navigation hub for all docs & examples
    ├── docs/               # Core documentation
    │   ├── PRODUCTION_READY.md      # Human quick start guide
    │   ├── AI-INSTRUCTIONS.md       # AI agent instructions
    │   └── PUBLIC_RELEASE_CHECKLIST.md
    ├── configs/            # Configuration file examples
    │   ├── config-example.env
    │   ├── config-example.json
    │   └── config-example.txt
    └── workflows/          # Workflow usage examples
        ├── basic-usage.md
        ├── json-config.md
        ├── chaining-actions.md
        └── ... (7 workflow examples)
```

## 📚 Looking for Examples?

**See [examples/](examples/)** for complete documentation and usage scenarios:
- 👤 **Human Guide:** [examples/docs/PRODUCTION_READY.md](examples/docs/PRODUCTION_READY.md)
- 🤖 **AI Guide:** [examples/docs/AI-INSTRUCTIONS.md](examples/docs/AI-INSTRUCTIONS.md)
- 🌟 **Quick Start:** [examples/workflows/basic-usage.md](examples/workflows/basic-usage.md)
- 📋 **All Configs:** [examples/configs/](examples/configs/)
- 🔧 **All Workflows:** [examples/workflows/](examples/workflows/)

## 🤖 AI/Developer Checklist

**Copy this template and follow these steps in order:**

```bash
# 1. Copy template
cp -r deploy/actions/_USEME_ deploy/actions/my-action
cd deploy/actions/my-action

# 2. Update action.yml
#    - Change name/description
#    - Add custom inputs/outputs
#    - Implement Step 2 logic between ✏️ markers

# 3. Copy any external scripts needed into scripts/ folder
#    - CRITICAL: Actions must be self-contained!
#    - Copy phase-manager scripts, utility scripts, etc.
#    - Do NOT reference ../../other-folder/script.sh

# 4. Update action-spec.json with your action details
#    - CRITICAL: Define config_schema.fields (required/optional config vars)
#    - CRITICAL: List ALL dependencies in dependencies.packages array
#    - Update inputs, outputs, usage examples
#    - Use self_contained checklist to verify nothing is missing
#
# Example action-spec.json:
#   "config_schema": {
#     "fields": {
#       "PROXMOX_HOST": "required",
#       "VMID": "required",
#       "HOSTNAME": "optional"
#     }
#   },
#   "dependencies": {
#     "packages": ["bash", "jq", "python3", "python3-pip"]
#   }

# 5. Delete examples/ folder
rm -rf examples/

# 6. Write comprehensive README.md
#    - Features, usage examples, config tables
#    - Security warnings (if applicable)
#    - Troubleshooting section

# 7. Create local test script in scripts/test.sh
#    - Quick tests you can run locally
#    - Test validation, config loading
#    - Make executable: chmod +x scripts/test.sh

# 8. Create CI/CD test workflow
#    - Test .env, .json, .txt formats
#    - Test validation (missing required fields should fail)
#    - Test action-specific functionality
#    - Create .gitea/workflows/test-my-action.yml

# 9. Verify self-contained checklist (action-spec.json)
#     ✅ All dependencies documented
#     ✅ No external script references
#     ✅ requirements.txt or package.json created
#     ✅ Action works when copied standalone

# 10. Run tests locally before committing
cd deploy/actions/my-action && scripts/test.sh
```

**See detailed instructions below ↓**

---

## Quick Start for AI/Developers

Follow these steps **in order** after copying the template:

### 1. Copy the template

```bash
cp -r deploy/actions/_USEME_ deploy/actions/my-action
cd deploy/actions/my-action
```

### 2. Customize files in this exact order

**IMPORTANT:** Complete each step before moving to the next!

#### a) `action.yml` - Define your action

Update the name and description:
```yaml
name: 'My Action'
description: 'What this action does'
```

Add your logic in **Step 2** between the edit markers:
```yaml
# ╔═══════════════════════════════════════════════════════════╗
# ║                                                           ║
# ║                  ✏️  EDIT YOUR CODE HERE                  ║
# ║                                                           ║
# ╚═══════════════════════════════════════════════════════════╝

# Example: echo "VMID: $VMID"
# Example: export STATUS="completed"

# ╔═══════════════════════════════════════════════════════════╗
# ║                                                           ║
# ║                  ✏️  END OF YOUR CODE                     ║
# ║                                                           ║
# ╚═══════════════════════════════════════════════════════════╝
```

**Important:** Always follow this pattern:
1. Config is already loaded - variables are ready to use
2. READ variables: `echo "Host: $PROXMOX_HOST"`
3. UPDATE variables: `export PROXMOX_HOST="new-value"`
4. ADD variables: `export NEW_VAR="value"`

#### b) `action-spec.json` - Define config validation & dependencies (REQUIRED)

Update the `config_schema.fields` section with your required/optional fields:
```json
{
  "config_schema": {
    "fields": {
      "PASSWORD": "required",
      "PROXMOX_HOST": "required",
      "VMID": "required",
      "HOSTNAME": "optional",
      "DOMAIN": "optional"
    }
  },
  "dependencies": {
    "packages": ["bash", "jq"]
  }
}
```

Field values can be:
- `"required"` - Field must be present (validated in Step 1)
- `"optional"` - Field is documented but not validated

Add ALL system packages your action needs to the `dependencies.packages` array.

#### c) `examples/configs/` - Update example config files (REQUIRED)

Edit the example files to match your action-spec.json:
- `examples/configs/config-example.env` - Example .env format
- `examples/configs/config-example.json` - Example JSON format
- `examples/configs/config-example.txt` - Example .txt format

These serve as templates for developers using your action.

#### d) `action-spec.json` - Add usage examples and metadata (OPTIONAL)

Optionally add usage examples and metadata to help users understand your action:
```json
{
  "usage": {
    "basic": {
      "description": "Standard usage",
      "example": "- name: My Action\n  uses: ./deploy/actions/my-action\n  with:\n    config: .env"
    }
  },
  "self_contained": {
    "checklist": [
      "All scripts copied to scripts/ folder",
      "No references to ../../other-folder/",
      "All dependencies listed in dependencies.packages array"
    ]
  }
}
```

The action-spec.json is the **single source of truth** for your entire action.

#### e) `EXAMPLES.md` - Add usage examples

Replace template examples with real ones:
```markdown
# My Action - Quick Examples

## Basic Usage
\`\`\`yaml
- name: My Action
  uses: ./deploy/actions/my-action
  with:
    config: .env
    my_param: 'value'
\`\`\`
```

#### f) `README.md` - Write full documentation

Replace this template with comprehensive docs:
- Features list
- Complete usage examples
- Input/output tables
- Security warnings (if applicable)
- Troubleshooting section

#### g) **Delete the examples/ folder** (for production actions only)

**IMPORTANT:** The examples/ folder is only for the _USEME_ template!

```bash
rm -rf examples/
```

For production actions, all documentation goes in README.md.

### 3. Create tests for your action

**EVERY ACTION MUST HAVE TESTS!** You need **TWO types of tests**:

1. **Local test script** (`test.sh`) - For quick local testing
2. **CI/CD workflow** (`.gitea/workflows/test-my-action.yml`) - For automated testing

#### A. Create local test script

Create `test.sh` in the action folder for quick local testing:

```bash
#!/usr/bin/env bash
# Local test script for my-action
set -e

echo "Running local tests for my-action..."

# Test 1: Valid config
cat > test.env <<EOF
REQUIRED_FIELD=test_value
OPTIONAL_FIELD=optional_value
EOF

source scripts/prime.sh test.env
echo "✅ Config loaded successfully"

# Test 2: Validation (missing required field - should fail)
cat > test-invalid.env <<EOF
OPTIONAL_FIELD=value
EOF

if ! source scripts/load-and-validate.sh test-invalid.env 2>&1 | grep -q "Missing required"; then
    echo "✅ Validation correctly failed"
else
    echo "❌ Validation should have failed"
    exit 1
fi

# Cleanup
rm -f test.env test-invalid.env

echo "✅ All local tests passed!"
```

Make it executable:
```bash
chmod +x test.sh
```

Run tests locally:
```bash
./test.sh
```

#### B. Create CI/CD test workflow

Create `.gitea/workflows/test-my-action.yml` for automated testing:

```yaml
name: Test My Action
on:
  pull_request:
    paths:
      - 'deploy/actions/my-action/**'
  workflow_dispatch:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      # Test 1: Basic functionality with .env config
      - name: Create test config
        run: |
          cat > test.env <<EOF
          REQUIRED_FIELD=test_value
          OPTIONAL_FIELD=optional_value
          EOF

      - name: Run action
        id: test
        uses: ./deploy/actions/my-action
        with:
          config: test.env

      - name: Verify output
        run: |
          echo "Output: ${{ steps.test.outputs.config }}"
          # Add your verification logic here

      # Test 2: Validate required fields (should fail)
      - name: Test missing required field
        id: test_fail
        continue-on-error: true
        run: |
          cat > test-invalid.env <<EOF
          OPTIONAL_FIELD=value
          EOF

      - name: Run action with invalid config
        uses: ./deploy/actions/my-action
        with:
          config: test-invalid.env
        continue-on-error: true

      - name: Verify validation failed
        run: |
          if [ "${{ steps.test_fail.outcome }}" != "failure" ]; then
            echo "Expected validation to fail!"
            exit 1
          fi

      # Test 3: JSON config format
      - name: Test JSON config
        run: |
          cat > test.json <<EOF
          {
            "REQUIRED_FIELD": "test_value",
            "OPTIONAL_FIELD": "optional_value"
          }
          EOF

      - name: Run action with JSON
        uses: ./deploy/actions/my-action
        with:
          config: test.json
```

#### Test checklist

Before submitting your action, verify:

- [ ] Test with .env config format
- [ ] Test with .json config format
- [ ] Test with .txt config format
- [ ] Test validation fails for missing required fields
- [ ] Test all action outputs
- [ ] Test action-specific functionality
- [ ] Test error handling
- [ ] Document all tests in test workflow

### 4. Use in workflow

**From GitHub (Recommended):**
```yaml
- name: Run my action
  uses: KontangoOSS/KONOSS/OPS/actions/my-action@main
  with:
    config: .env
```

**From Local Repository:**
```yaml
- name: Run my action
  uses: ./OPS/actions/my-action
  with:
    config: .env
```

Done! ✨

## The Pattern

Every action follows this simple **3-step pattern**:

```
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: UNIFIED LOAD & VALIDATE                            │
│ ─────────────────────────────────────────────────────────── │
│ 🎯 Single script does everything:                          │
│   [1/5] Check dependencies (action-spec.json)              │
│   [2/5] Load config (.env/.json/.txt)                      │
│   [3/5] Validate required fields                           │
│   [4/5] Verify variables are accessible                    │
│   [5/5] Report summary                                     │
│                                                             │
│ ✓ All variables exported for child processes               │
│ ✓ DO NOT EDIT                                              │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: YOUR ACTION LOGIC                                  │
│ ─────────────────────────────────────────────────────────── │
│ ✏️  SCRIPT AS NORMAL - All variables are ready!            │
│                                                             │
│ • READ: echo "Host: $PROXMOX_HOST"                        │
│ • UPDATE: export PROXMOX_HOST="new-value"                 │
│ • ADD: export NEW_VAR="value"                             │
│ • Call scripts: ./my-script.py                            │
│ • Use in commands: ssh $PROXMOX_HOST                      │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: SAVE CONFIG                                        │
│ ─────────────────────────────────────────────────────────── │
│ ✓ Saves all exported variables back to config file         │
│ ✓ Displays KONOSS branding banner                         │
│ ✓ DO NOT EDIT                                              │
└─────────────────────────────────────────────────────────────┘
```

**Key Points:**
- 🎯 **Unified process** - Single script handles deps → load → validate → export → log → banner
- ✅ **Variables ready** - After Step 1, script as normal (no re-loading needed)
- ✅ **Child process safe** - Variables verified accessible for all spawned processes
- 🔒 **Secure logging** - Audit logs in `.logs/` with variable names only (values hidden)
- 🏢 **KONOSS banner** - Shows at completion with branding and support links
- ✏️  **Simple editing** - Just write bash in Step 2 between the markers
- 🔄 **Auto-save** - Use `export VAR="value"` and Step 3 saves it

**Can I call another action from Step 2?**

No - composite actions cannot use `uses:` to call other actions (GitHub/Gitea limitation). Instead:
- ✅ **Call scripts** from `scripts/` folder (Python, Bash, etc.)
- ✅ **Write inline bash** in Step 2 for simple logic
- ✅ **Chain multiple actions** in your workflow (recommended pattern)

See [examples/using-reusable-actions.md](examples/using-reusable-actions.md) for details.

## File Structure

**Template (_USEME_):**

```
_USEME_/
├── action.yml              # Action definition template
├── action-spec.json        # Complete descriptor (schema/deps/metadata)
├── README.md               # This documentation
├── .gitignore              # Excludes .logs/ from git
└── scripts/                # 🎯 Just 3 scripts - ultra-clean!
    ├── load-and-validate.sh # Step 1: All-in-one loader (DO NOT EDIT)
    ├── save-config.sh      # Step 3: All-in-one saver (DO NOT EDIT)
    └── test.sh             # Test script template
```

**Production Action (after customization):**

```
my-action/
├── action.yml              # Customized with your logic in Step 2
├── action-spec.json        # Complete descriptor (schema/deps/metadata/examples)
├── README.md               # Full documentation for your action
└── scripts/                # ALL scripts needed (self-contained)
    ├── load-and-validate.sh # Step 1 loader (DO NOT EDIT)
    ├── save-config.sh      # Step 3 saver (DO NOT EDIT)
    ├── test.sh             # Local test script (YOU WRITE THIS)
    └── my-script.py        # YOUR custom scripts HERE
```

**CRITICAL: Self-Contained Requirements**
- ✅ **ALL scripts** in `scripts/` folder (including test.sh)
- ✅ **action-spec.json** at root level (single source of truth)
- ✅ **NO external dependencies** (e.g., `../../phase-manager/script.sh`)
- ✅ **Copy needed scripts** from other folders into `scripts/`
- ✅ **All dependencies** listed in action-spec.json dependencies.packages
- ✅ **Examples folder DELETED** for production actions
- ✅ **Everything works** from the action folder alone
- ❌ Do NOT reference anything outside the action folder

## Rules

✅ **DO:**
- Read variables: `echo $CONTAINER_IP`
- Set variables: `export NEW_VAR="value"`
- Each step loads config independently
- **Update action-spec.json with all config fields and dependencies**
- **Add real examples to EXAMPLES.md**
- Include security warnings if needed

❌ **DON'T:**
- Use `GITHUB_ENV` or `GITHUB_OUTPUT` for config data
- Assume variables persist between steps
- Edit Step 1 or Step 3
- Edit the scripts/ folder (self-contained, do not modify)
- **Leave template placeholders in final files**
- **Skip updating action-spec.json**
- **Skip creating tests**
- **Keep the examples/ folder in production actions**

## Code Examples

**Using action from GitHub:**
```yaml
- name: My Action
  uses: KontangoOSS/KONOSS/OPS/actions/my-action@main
  with:
    config: .env
```

**Using action from local repository:**
```yaml
- name: My Action
  uses: ./OPS/actions/my-action
  with:
    config: .env
```

**Chaining actions:**
```yaml
- name: First Action
  id: first
  uses: KontangoOSS/KONOSS/OPS/actions/first-action@main
  with:
    config: .env

- name: Second Action
  uses: KontangoOSS/KONOSS/OPS/actions/second-action@main
  with:
    config: ${{ steps.first.outputs.config }}
```

## Config Validation (Step 1)

Every action is **self-contained** and validates config files against `action-spec.json` before execution:

### How It Works

1. **Step 1** checks dependencies listed in action-spec.json
2. **Step 1** loads your config file and checks for required fields
3. If any required fields are missing, the action fails immediately
4. **No external dependencies** - all scripts are self-contained
5. Works with .env, .json, and .txt config formats

### Schema Format

Simple key/value pairs in `action-spec.json` under `config_schema.fields`:
```json
{
  "config_schema": {
    "fields": {
      "PASSWORD": "required",
      "PROXMOX_HOST": "required",
      "VMID": "required",
      "HOSTNAME": "optional",
      "DOMAIN": "optional"
    }
  }
}
```

Only "required" fields are validated - "optional" fields are for documentation only.

### Supported Config Formats

All three formats are validated identically:

**`.env` format:**
```bash
PASSWORD=value
HOSTNAME=example
```

**`.json` format:**
```json
{
  "PASSWORD": "value",
  "HOSTNAME": "example"
}
```

**`.txt` format:**
```bash
PASSWORD=value
HOSTNAME=example
```

See `examples/config-example.*` files for complete examples.

## 🔒 Secure Logging

Every config load is automatically logged to `.logs/config-load-YYYYMMDD-HHMMSS.log` with **security-first design**:

### What Gets Logged (SAFE):
- ✅ Variable **names** (e.g., `API_KEY`, `PASSWORD`, `PROXMOX_HOST`)
- ✅ Validation results (which fields passed/failed)
- ✅ Dependency check results
- ✅ Timestamp and config file path
- ✅ Variable count

### What's NEVER Logged (SECURE):
- ❌ Variable **values** (secrets stay secret!)
- ❌ API keys, passwords, tokens
- ❌ Any sensitive data

### Example Log:

```
╔════════════════════════════════════════════════════════════╗
║  Config Load Log - 2025-10-25 13:16:53              ║
╚════════════════════════════════════════════════════════════╝

Config File: .env
Variables Loaded: 5

Variable Names (values hidden for security):
────────────────────────────────────────────────────────────
  ✓ PROXMOX_HOST
  ✓ API_KEY          ← Name logged, value hidden!
  ✓ PASSWORD         ← Name logged, value hidden!
  ✓ VMID
  ✓ HOSTNAME

Required Fields Validated:
────────────────────────────────────────────────────────────
  ✓ PROXMOX_HOST (present)
  ✓ VMID (present)

Dependencies:
────────────────────────────────────────────────────────────
  ✓ bash
  ✓ jq

════════════════════════════════════════════════════════════
✅ Config load completed successfully
════════════════════════════════════════════════════════════
```

### Security Features:

- 🔒 `.logs/` directory is **gitignored** (never committed)
- 🔒 Only variable **names** are logged (values stripped)
- 🔒 Logs help with debugging without exposing secrets
- 🔒 Timestamped logs for audit trail
- 🔒 Safe to review and share for troubleshooting

**Why This Matters:** You can debug config issues, audit variable loading, and troubleshoot problems without ever exposing sensitive values.

## Production Checklist

Before using your action, ensure:

**Required:**
- [ ] `action.yml` has accurate name and description
- [ ] `action.yml` Step 2 logic implemented between ✏️ markers
- [ ] `action-spec.json` config_schema.fields defines all required/optional config vars
- [ ] `action-spec.json` dependencies.packages lists ALL system packages needed
- [ ] `action-spec.json` updated with inputs/outputs/usage examples
- [ ] `examples/` folder DELETED (only needed in _USEME_ template)
- [ ] `README.md` is complete with full documentation
- [ ] All template placeholders removed
- [ ] Test workflow created in `.gitea/workflows/test-my-action.yml`
- [ ] Tests cover: .env, .json, .txt formats
- [ ] Tests cover: validation (missing required fields)
- [ ] Tests cover: action-specific functionality
- [ ] All tests passing locally

**Optional:**
- [ ] Security warnings added to README (if applicable)
- [ ] Troubleshooting section in README
- [ ] Error handling tested

## Example Actions

See these production-ready examples with tests:

- **[phase-list-secrets](../phase-list-secrets/)** - Lists Phase secrets with preview mode
  - Test file: `../../.gitea/workflows/test-phase-list-secrets.yml`
  - Shows: config validation, multiple formats, output verification
  - 8 test cases covering all functionality

- **[phase-load-secrets](../phase-load-secrets/)** - Loads secrets from Phase (if exists)
- **[install-dependencies](../install-dependencies/)** - System dependency installation (if exists)

## 🏢 KONOSS Branding

Every action automatically displays the KONOSS branding banner at the end of **Step 3: Save Config** to help users find us!

### How It Works

The `save-config.sh` script automatically sources and displays the banner using [scripts/konoss-banner.sh](scripts/konoss-banner.sh):

```bash
# Show KONOSS branding banner (silently fail if there's an issue - never block the action)
if [ -f "$SCRIPT_DIR/konoss-banner.sh" ]; then
    {
        source "$SCRIPT_DIR/konoss-banner.sh" 2>/dev/null && \
        show_konoss_banner
    } || true  # Never fail the action due to banner issues
fi
```

**Error Handling:** The banner is designed to **never fail your action**. Even if the banner script has issues, the action will continue successfully. The `|| true` ensures the action always exits with success code 0.

### The Banner

```
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║   ██╗  ██╗ ██████╗ ███╗   ██╗ ██████╗ ███████╗███████╗          ║
║   ██║ ██╔╝██╔═══██╗████╗  ██║██╔═══██╗██╔════╝██╔════╝          ║
║   █████╔╝ ██║   ██║██╔██╗ ██║██║   ██║███████╗███████╗          ║
║   ██╔═██╗ ██║   ██║██║╚██╗██║██║   ██║╚════██║╚════██║          ║
║   ██║  ██╗╚██████╔╝██║ ╚████║╚██████╔╝███████║███████║          ║
║   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚══════╝          ║
║                                                                   ║
║           Making DevOps Actually Fun Since... Well, Now! 🚀      ║
║              Crafted with ☕ by Kontango Limited, CO              ║
║                                                                   ║
║           📧 hello@kontango.us                                    ║
║           💻 github.com/KontangoOSS                               ║
║           📚 kontango.gitbook.io/kontango                         ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

### Reusable Anywhere

The `konoss-banner.sh` script is **completely reusable**! You can use it in any of your own scripts:

```bash
#!/usr/bin/env bash
# Your custom script

# Source the banner
source /path/to/konoss-banner.sh

# Do your work here
echo "Doing some work..."

# Show the banner at the end
show_konoss_banner
```

### Why It's There

- 🌟 **Brand awareness** - Helps users find Kontango for more open source tools
- 💡 **Support** - Shows where to get help (hello@kontango.us)
- 📚 **Learn more** - Points to docs and GitHub for contributions
- ❤️  **Community** - Makes DevOps approachable and fun!

**DO NOT remove the banner** - it's how we get credit for our work and help the community find us! 🙏

---

## See Also

- [examples/](examples/) - Complete documentation hub
  - [docs/PRODUCTION_READY.md](examples/docs/PRODUCTION_READY.md) - Human quick start
  - [docs/AI-INSTRUCTIONS.md](examples/docs/AI-INSTRUCTIONS.md) - AI agent guide
  - [workflows/](examples/workflows/) - Workflow usage examples
  - [configs/](examples/configs/) - Configuration file examples
- [action-spec.json](action-spec.json) - Complete action descriptor
- [action.yml](action.yml) - Action template
- [scripts/load-and-validate.sh](scripts/load-and-validate.sh) - All-in-one config loader
- [scripts/save-config.sh](scripts/save-config.sh) - All-in-one config saver
