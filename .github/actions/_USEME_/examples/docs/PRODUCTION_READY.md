# _USEME_ Template - Complete Production Documentation

**Version:** 1.0
**Last Updated:** 2025-10-25
**Status:** Production Ready
**Platform:** Gitea Actions (GitHub Actions compatible)
**Author:** Kontango Limited, CO

---

## Table of Contents

1. [Overview](#overview)
2. [Philosophy & Design Decisions](#philosophy--design-decisions)
3. [Complete Architecture](#complete-architecture)
4. [The 3-Step Pattern Explained](#the-3-step-pattern-explained)
5. [Implementation Details](#implementation-details)
6. [Security Architecture](#security-architecture)
7. [Testing Strategy](#testing-strategy)
8. [How to Use This Template](#how-to-use-this-template)
9. [Troubleshooting](#troubleshooting)
10. [Evolution & Lessons Learned](#evolution--lessons-learned)

---

## Overview

### What Is This?

The _USEME_ template is a **production-ready, self-contained Gitea Action template** for creating reusable CI/CD actions with automatic configuration management. It was designed to solve the common pain points of action development:

- **Configuration chaos** - Different formats, manual loading, validation hell
- **Dependency nightmares** - External scripts, broken references, missing packages
- **Security risks** - Secrets in logs, exposed credentials
- **Maintenance burden** - Complex script hierarchies, unclear structure
- **Poor documentation** - Unclear how to use or extend

### What You Get

A **completely self-contained action template** with:

- ✅ **Unified config system** - Single script handles everything (deps→load→validate→export→log→banner)
- ✅ **Multi-format support** - .env, .json, .txt all work seamlessly
- ✅ **Automatic validation** - Schema-based required/optional field checking
- ✅ **Secure logging** - Audit logs with variable names only (values hidden for security)
- ✅ **KONOSS branding** - Professional banner shows company identity
- ✅ **Zero external dependencies** - Everything inlined, fully self-contained
- ✅ **Ultra-clean structure** - Just 3 core scripts total
- ✅ **Comprehensive testing** - 10 tests covering all functionality
- ✅ **Production metadata** - Proper naming, descriptions, documentation

### Quick Stats

- **Lines of code:** ~500 (across all scripts)
- **Scripts:** 3 core (down from 8 original)
- **Tests:** 10 comprehensive
- **Config formats:** 3 (.env, .json, .txt)
- **Dependencies:** bash, jq (that's it!)
- **Documentation:** Complete for humans AND AI

---

## Philosophy & Design Decisions

### Core Principles

#### 1. **Self-Contained Always**

**Problem:** Actions that reference `../../other-folder/script.sh` break when copied standalone.

**Solution:** Everything needed is inside the action folder. All helper scripts are inlined. No external references ever.

**Implementation:**
- All functionality is in `scripts/` folder
- Helper functions inlined directly in main scripts
- No sourcing of external files (except within action folder)
- Copy the action folder anywhere → it works

**Why This Matters:** Actions are truly reusable. Copy to another repo, another organization, another platform → works immediately.

#### 2. **Single Source of Truth**

**Problem:** Config schemas in multiple files (schema.json, action.yml, README) get out of sync.

**Solution:** `action-spec.json` is the **single source of truth** for everything.

**Contains:**
- Config schema (required/optional fields)
- Dependencies (system packages)
- Input/output definitions
- Usage examples
- Metadata
- Self-contained checklist

**Why This Matters:** Update one file, everything stays in sync. AI agents know exactly where to look.

#### 3. **Unified Process Over Script Hierarchy**

**Problem:** Original had 8 scripts calling each other in complex dependency chains.

**Solution:** Consolidated to 3 scripts with all functionality inlined.

**Before:**
```
scripts/
├── konoss-banner.sh
├── set-env-var.sh
├── check-dependencies.sh
├── prime.sh
├── validate-config.sh
├── load-and-validate.sh
├── save-config.sh
└── test.sh
```

**After:**
```
scripts/
├── load-and-validate.sh  # Does EVERYTHING for Step 1
├── save-config.sh        # Does EVERYTHING for Step 3
└── test.sh               # Comprehensive test suite
```

**Why This Matters:** Easier to understand, maintain, and debug. No hunting through file hierarchies.

#### 4. **Security by Design**

**Problem:** Logs with `echo $PASSWORD` expose secrets. Debugging without logs is impossible.

**Solution:** Secure logging that logs variable NAMES only, never values.

**Implementation:**
```bash
# NEVER do this (exposes values):
echo "PASSWORD=$PASSWORD"

# ALWAYS do this (names only):
echo "  ✓ PASSWORD"  # Name logged, value hidden
```

**Why This Matters:** Safe debugging without security risks. Audit trail without exposure.

#### 5. **Human AND AI Friendly**

**Problem:** Documentation either too technical for humans or too vague for AI.

**Solution:** Dual documentation strategy:
- `PRODUCTION_READY.md` - Human-friendly quick start
- `AI-INSTRUCTIONS.md` - Step-by-step AI instructions
- `PUBLIC_RELEASE_CHECKLIST.md` - Verification guide

**Why This Matters:** Both humans and AI can use the template effectively without confusion.

---

## Complete Architecture

### Directory Structure

```
_USEME_/
├── action.yml              # Gitea Action definition (3-step pattern)
├── action-spec.json        # 📋 SINGLE SOURCE OF TRUTH
├── README.md               # Main user-facing documentation
├── .gitignore              # Security (excludes .logs/)
│
├── scripts/                # 🎯 Just 3 scripts - ultra-clean!
│   ├── load-and-validate.sh # Step 1: deps→load→validate→export→log→banner
│   ├── save-config.sh       # Step 3: save variables + banner
│   └── test.sh              # 10 comprehensive tests
│
├── .logs/                  # 🔒 Secure audit logs (gitignored)
│   └── config-load-*.log   # Timestamped, names only
│
└── examples/               # All docs & examples (DELETE in production)
    ├── README.md           # Navigation hub
    ├── docs/               # Core documentation
    │   ├── PRODUCTION_READY.md      # ← YOU ARE HERE
    │   ├── AI-INSTRUCTIONS.md       # AI guide
    │   └── PUBLIC_RELEASE_CHECKLIST.md
    ├── configs/            # Config file examples
    │   ├── config-example.env
    │   ├── config-example.json
    │   └── config-example.txt
    └── workflows/          # Workflow usage examples
        ├── basic-usage.md
        ├── json-config.md
        ├── chaining-actions.md
        ├── multiple-configs.md
        ├── with-secrets.md
        ├── conditional-execution.md
        └── using-reusable-actions.md
```

### File Responsibilities

#### `action.yml`
- Defines the Gitea Action
- Implements the 3-step pattern
- Minimal logic (just calls scripts)
- Contains edit markers for user code

**Key sections:**
1. **Step 1:** Call `load-and-validate.sh`
2. **Step 2:** User's custom logic (between ✏️ markers)
3. **Step 3:** Call `save-config.sh`

#### `action-spec.json`
- **Config schema** - Required/optional fields
- **Dependencies** - System packages needed
- **Inputs/Outputs** - Action interface
- **Usage examples** - How to use the action
- **Self-contained checklist** - Verification points

**Critical fields:**
```json
{
  "config_schema": {
    "fields": {
      "EXAMPLE_FIELD": "required",
      "OPTIONAL_FIELD": "optional"
    }
  },
  "dependencies": {
    "packages": ["bash", "jq"]
  }
}
```

#### `scripts/load-and-validate.sh`
The **all-in-one Step 1 script**. Does everything needed before user code runs:

1. **Check dependencies** - Verify all packages available
2. **Load config** - Parse .env/.json/.txt files
3. **Validate** - Check required fields present
4. **Export variables** - Make available to child processes
5. **Secure logging** - Log names only to audit file
6. **Show banner** - Display KONOSS branding

**Inline functionality:**
- Dependency checking (no check-dependencies.sh needed)
- Multi-format parsing (handles .env, .json, .txt)
- Field validation (no validate-config.sh needed)
- Variable export (no prime.sh needed)
- KONOSS banner (no konoss-banner.sh needed)

**Security features:**
- Never logs variable values
- Creates timestamped audit logs
- Logs to `.logs/` (gitignored)
- Safe for debugging

#### `scripts/save-config.sh`
The **all-in-one Step 3 script**. Saves variables and shows completion:

1. **Collect variables** - Get all exported vars
2. **Set variables** - Write back to config file
3. **Show banner** - Display KONOSS branding

**Inline functionality:**
- `set_env_var()` function (no set-env-var.sh needed)
- KONOSS banner (no konoss-banner.sh needed)
- Smart skipping (colors, special vars)

**Features:**
- Updates existing variables
- Adds new variables
- Preserves file format
- Never fails (error-safe)

#### `scripts/test.sh`
**Comprehensive test suite** covering all functionality:

1. File structure test
2. .env config loading
3. .json config loading
4. Validation failure (missing required fields)
5. Save config functionality
6. Dependency checking
7. **Secure logging** (critical security test)
8. Banner safety (never blocks)
9. JSON validity
10. Script executability

**Why 10 tests?** Covers every critical path and security feature.

---

## The 3-Step Pattern Explained

### The Pattern

Every action follows this exact pattern:

```yaml
# Step 1: Validate and load configuration ✅
- name: Validate and load configuration
  shell: bash
  run: |
    CONFIG="${{inputs.config}}"
    ACTION_DIR="$(dirname "$GITHUB_ACTION_PATH")"
    source "$ACTION_DIR/scripts/load-and-validate.sh" "$CONFIG"

# Step 2: Execute action logic ✏️
- name: Execute action logic
  shell: bash
  run: |
    # ╔═══════════════════════════════════════════╗
    # ║      ✏️  EDIT YOUR CODE HERE              ║
    # ╚═══════════════════════════════════════════╝

    echo "EXAMPLE_FIELD: $EXAMPLE_FIELD"
    export NEW_VAR="new_value"

    # ╔═══════════════════════════════════════════╗
    # ║      ✏️  END OF YOUR CODE                 ║
    # ╚═══════════════════════════════════════════╝

# Step 3: Save configuration ✅
- name: Save configuration
  shell: bash
  run: |
    CONFIG="${{inputs.config}}"
    ACTION_DIR="$(dirname "$GITHUB_ACTION_PATH")"
    source "$ACTION_DIR/scripts/save-config.sh" "$CONFIG"
```

### Why This Pattern?

#### Traditional Approach (Manual)
```yaml
- name: Load config
  run: |
    source .env
    if [ -z "$REQUIRED_VAR" ]; then
      echo "Missing REQUIRED_VAR"
      exit 1
    fi

- name: Do work
  run: |
    echo $REQUIRED_VAR
    NEW_VAR="value"

- name: Save config
  run: |
    echo "NEW_VAR=$NEW_VAR" >> .env
```

**Problems:**
- Manual validation every time
- No format flexibility (.env only)
- No secure logging
- Variables don't persist between steps
- Lots of boilerplate

#### Our Approach (Automatic)
```yaml
- name: Load  # ✅ Automatic
- name: Work  # ✏️ Your code
- name: Save  # ✅ Automatic
```

**Benefits:**
- Validation automatic
- Multi-format support
- Secure logging built-in
- Variables auto-persist
- Zero boilerplate

### Step-by-Step Flow

#### Step 1: Load & Validate
```
load-and-validate.sh $CONFIG
    ↓
1. Check dependencies (bash, jq)
    ↓
2. Detect config format (.env/.json/.txt)
    ↓
3. Parse and load variables
    ↓
4. Validate required fields
    ↓
5. Export all variables
    ↓
6. Create secure audit log
    ↓
7. Show KONOSS banner
    ↓
Variables ready for Step 2 ✅
```

#### Step 2: User Code
```
User's custom logic
    ↓
- Read variables: echo $EXAMPLE_FIELD
- Update variables: export EXAMPLE_FIELD="new"
- Add variables: export NEW_VAR="value"
- Call scripts: ./my-script.sh
    ↓
Variables modified, ready for Step 3 ✅
```

#### Step 3: Save Config
```
save-config.sh $CONFIG
    ↓
1. Collect all exported variables
    ↓
2. Write back to config file
    ↓
3. Show KONOSS banner
    ↓
Config saved, action complete ✅
```

---

## Implementation Details

### Multi-Format Config Support

The template supports three config formats transparently:

#### .env Format (Recommended)
```bash
# Comments supported
EXAMPLE_FIELD=value_here
ANOTHER_FIELD=another_value

# Empty lines OK
OPTIONAL_FIELD=optional_value
```

**Parsing logic:**
```bash
if [[ "$CONFIG" == *.env ]] || [[ "$CONFIG" == *.txt ]]; then
    while IFS='=' read -r key value; do
        [[ -z "$key" || "$key" =~ ^# ]] && continue
        export "$key=$value"
    done < "$CONFIG"
fi
```

#### JSON Format
```json
{
  "_comment": "Comments as keys",
  "EXAMPLE_FIELD": "value_here",
  "ANOTHER_FIELD": "another_value",
  "OPTIONAL_FIELD": "optional_value"
}
```

**Parsing logic:**
```bash
if [[ "$CONFIG" == *.json ]]; then
    while IFS='=' read -r line; do
        [[ "$line" =~ ^_  ]] && continue  # Skip comment keys
        export "$line"
    done < <(jq -r 'to_entries[] | "\(.key)=\(.value)"' "$CONFIG")
fi
```

#### .txt Format
Same as .env format, just different extension for organization.

### Validation System

**Schema definition** (in action-spec.json):
```json
{
  "config_schema": {
    "fields": {
      "REQUIRED_VAR": "required",
      "OPTIONAL_VAR": "optional"
    }
  }
}
```

**Validation logic** (in load-and-validate.sh):
```bash
# Extract required fields from action-spec.json
REQUIRED_FIELDS=$(jq -r '.config_schema.fields |
    to_entries[] |
    select(.value == "required") |
    .key' "$ACTION_DIR/action-spec.json")

# Validate each required field
for field in $REQUIRED_FIELDS; do
    if [ -z "${!field}" ]; then
        echo "❌ Missing required field: $field"
        exit 1
    fi
done
```

**Why this works:**
- Schema in one place (action-spec.json)
- Auto-validation on every run
- Clear error messages
- Fail fast on missing fields

### Secure Logging Implementation

**The Problem:**
```bash
# NEVER do this - exposes secrets!
echo "Loaded variables:"
for var in PASSWORD API_KEY SECRET_TOKEN; do
    echo "$var=${!var}"  # ❌ SECRET VALUES IN LOGS
done
```

**Our Solution:**
```bash
# Log variable NAMES only
{
    echo "Variable Names (values hidden for security):"
    if [[ "$CONFIG" == *.json ]]; then
        jq -r 'keys[]' "$CONFIG" | while read -r key; do
            echo "  ✓ $key"  # ✅ Name only, value hidden
        done
    else
        grep -v '^#' "$CONFIG" | grep '=' | cut -d'=' -f1 | while read -r key; do
            [ -n "$key" ] && echo "  ✓ $key"  # ✅ Name only
        done
    fi
} > "$LOG_FILE"
```

**Log output example:**
```
╔════════════════════════════════════════════════════════╗
║  Config Load Log - 2025-10-25 13:16:53                ║
╚════════════════════════════════════════════════════════╝

Config File: production.env
Variables Loaded: 5

Variable Names (values hidden for security):
────────────────────────────────────────────────────────
  ✓ PROXMOX_HOST
  ✓ API_KEY          ← Name logged, value NEVER shown
  ✓ PASSWORD         ← Name logged, value NEVER shown
  ✓ VMID
  ✓ HOSTNAME

Required Fields Validated:
────────────────────────────────────────────────────────
  ✓ PROXMOX_HOST (present)
  ✓ VMID (present)

════════════════════════════════════════════════════════
✅ Config load completed successfully
════════════════════════════════════════════════════════
```

**Security guarantees:**
1. Variable values NEVER appear in logs
2. Only variable names logged
3. `.logs/` directory gitignored
4. Safe to debug, safe to share
5. Audit trail without exposure

### KONOSS Branding Integration

**Why it's there:**
- Brand awareness for Kontango Limited
- Shows where to get support (hello@kontango.us)
- Points to GitHub and docs
- Makes DevOps fun and approachable
- Community building

**How it works:**
- Inlined directly in scripts (no external dependency)
- Shown at end of Step 1 (after load)
- Shown at end of Step 3 (after save)
- Error-safe (`|| true` ensures never fails action)

**The banner:**
```
╔═══════════════════════════════════════════════════════════════════╗
║   ██╗  ██╗ ██████╗ ███╗   ██╗ ██████╗ ███████╗███████╗          ║
║   ██║ ██╔╝██╔═══██╗████╗  ██║██╔═══██╗██╔════╝██╔════╝          ║
║   █████╔╝ ██║   ██║██╔██╗ ██║██║   ██║███████╗███████╗          ║
║   ██╔═██╗ ██║   ██║██║╚██╗██║██║   ██║╚════██║╚════██║          ║
║   ██║  ██╗╚██████╔╝██║ ╚████║╚██████╔╝███████║███████║          ║
║   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚══════╝          ║
║                                                                   ║
║           Making DevOps Actually Fun Since... Well, Now! 🚀      ║
║              Crafted with ☕ by Kontango Limited, CO              ║
║           📧 hello@kontango.us                                    ║
║           💻 github.com/KontangoOSS                               ║
╚═══════════════════════════════════════════════════════════════════╝
```

**Implementation:**
```bash
# Inline banner function (in load-and-validate.sh and save-config.sh)
{
    echo "" >&2
    echo "╔═══════════════════════...═══╗" >&2
    # ... ASCII art ...
    echo "║   Making DevOps Actually Fun Since... Well, Now! 🚀   ║" >&2
    echo "╚═══════════════════════...═══╝" >&2
} || true  # Never fail action due to banner
```

### Dependency Management

**Philosophy:** Explicit over implicit. List ALL dependencies.

**In action-spec.json:**
```json
{
  "dependencies": {
    "packages": ["bash", "jq", "python3", "python3-pip"],
    "python": ["requests", "pyyaml"],
    "notes": "All system packages and language-specific deps"
  }
}
```

**Checking logic** (in load-and-validate.sh):
```bash
# Read dependencies from action-spec.json
DEPS=$(jq -r '.dependencies.packages[]' "$ACTION_DIR/action-spec.json")

# Check each one
for dep in $DEPS; do
    if ! command -v "$dep" &>/dev/null; then
        echo "❌ Missing dependency: $dep"
        exit 1
    fi
done
```

**Why this matters:**
- Actions fail fast if dependencies missing
- Clear error messages
- Easy to see what's needed
- Package manager agnostic (apt-get, yum, brew all work)

---

## Security Architecture

### Defense in Depth

Multiple layers of security:

1. **Secure Logging**
   - Variable names only, never values
   - `.logs/` gitignored
   - Timestamped audit trail

2. **No Secret Exposure**
   - Logs safe to review
   - Safe to share for debugging
   - Test verifies no secrets leak

3. **Input Validation**
   - Required fields checked
   - Fail fast on missing data
   - Clear error messages

4. **Error Safety**
   - Banner never fails action
   - Graceful degradation
   - `|| true` pattern

5. **Git Safety**
   - `.gitignore` excludes logs
   - Test files excluded
   - No secrets in repo

### Security Testing

**Test 7: Secure Logging**
```bash
# Create config with secrets
cat > test.env << 'EOF'
PASSWORD=super_secret_value
API_KEY=dont_show_this
EOF

# Load it
source ./scripts/load-and-validate.sh test.env

# Check log
LOG_FILE=$(ls -t .logs/config-load-*.log | head -1)

# Verify names ARE logged
grep -q "PASSWORD" "$LOG_FILE"  # ✅ Should find
grep -q "API_KEY" "$LOG_FILE"   # ✅ Should find

# Verify values are NOT logged
! grep -q "super_secret_value" "$LOG_FILE"  # ✅ Should NOT find
! grep -q "dont_show_this" "$LOG_FILE"      # ✅ Should NOT find
```

This test **guarantees** secrets never appear in logs.

---

## Testing Strategy

### The 10 Tests

#### Test 1: File Structure
Verifies all required files exist:
- action.yml
- action-spec.json
- scripts/load-and-validate.sh
- scripts/save-config.sh
- scripts/test.sh

**Why:** Catches missing files immediately.

#### Test 2: Load .env Config
Tests basic .env file loading:
```bash
EXAMPLE_FIELD=test
ANOTHER_FIELD=test
```

**Why:** Most common format, must work perfectly.

#### Test 3: Load .json Config
Tests JSON parsing:
```json
{"EXAMPLE_FIELD": "test", "ANOTHER_FIELD": "test"}
```

**Why:** Ensures jq parsing works correctly.

#### Test 4: Validation Fails Correctly
Tests missing required field detection:
```bash
# Missing EXAMPLE_FIELD
ANOTHER_FIELD=test
```

**Why:** Must fail fast on invalid configs.

#### Test 5: Save Config
Tests variable persistence:
```bash
export NEW_VAR="new_value"
# Should appear in config file
```

**Why:** Step 3 must save variables correctly.

#### Test 6: Dependency Checking
Tests that dependency check logic works:
```bash
# Should find bash, jq
# Should fail gracefully if missing
```

**Why:** Actions must know about missing deps.

#### Test 7: Secure Logging (CRITICAL)
Tests no secrets in logs:
```bash
PASSWORD=secret
# Log should contain "PASSWORD" but NOT "secret"
```

**Why:** Security. This is non-negotiable.

#### Test 8: Banner Safety
Tests banner never blocks:
```bash
# Even if banner fails, action succeeds
```

**Why:** Branding shouldn't break functionality.

#### Test 9: Valid JSON
Tests action-spec.json is valid:
```bash
jq . action-spec.json
```

**Why:** Invalid JSON breaks everything.

#### Test 10: Scripts Executable
Tests all scripts have execute permission:
```bash
[ -x scripts/load-and-validate.sh ]
[ -x scripts/save-config.sh ]
[ -x scripts/test.sh ]
```

**Why:** Non-executable scripts cause confusing errors.

### Test Philosophy

- **Fast** - All tests run in <5 seconds
- **Comprehensive** - Every critical path covered
- **Isolated** - Each test independent
- **Clear** - Pass/fail obvious
- **Automated** - Run locally or in CI/CD

---

## How to Use This Template

### Quick Start (5 Minutes)

```bash
# 1. Copy template
cp -r deploy/actions/_USEME_ deploy/actions/my-action
cd deploy/actions/my-action

# 2. Update action.yml
vim action.yml
# Change name, description
# Add your logic in Step 2 between ✏️ markers

# 3. Update action-spec.json
vim action-spec.json
# Define config_schema.fields (required/optional)
# List dependencies.packages

# 4. Update config examples
vim examples/configs/config-example.env
# Replace EXAMPLE_FIELD with your fields

# 5. Delete examples folder
rm -rf examples/

# 6. Test
./scripts/test.sh
# Should see: ✅ ALL TESTS PASSED

# 7. Write README
vim README.md
# Document your action

# Done! 🎉
```

### Detailed Steps

#### Step 1: Copy Template
```bash
cp -r deploy/actions/_USEME_ deploy/actions/my-action
cd deploy/actions/my-action
```

**What this does:**
- Creates new action from template
- All files copied
- Ready to customize

#### Step 2: Customize action.yml

**Update metadata:**
```yaml
name: 'My Action'
description: 'Does something awesome'
author: 'Your Name'
```

**Add inputs:**
```yaml
inputs:
  config:
    description: 'Config file (.env, .json, .txt)'
    required: true
  my_param:
    description: 'My custom parameter'
    required: false
```

**Add your logic in Step 2:**
```yaml
# Step 2: Execute action logic
- name: Execute action logic
  shell: bash
  run: |
    # ╔═══════════════════════════════════════════╗
    # ║      ✏️  EDIT YOUR CODE HERE              ║
    # ╚═══════════════════════════════════════════╝

    # Your code here!
    echo "Processing VMID: $VMID"
    ./scripts/my-script.sh
    export STATUS="completed"

    # ╔═══════════════════════════════════════════╗
    # ║      ✏️  END OF YOUR CODE                 ║
    # ╚═══════════════════════════════════════════╝
```

#### Step 3: Update action-spec.json

**Define config schema:**
```json
{
  "config_schema": {
    "fields": {
      "PROXMOX_HOST": "required",
      "VMID": "required",
      "HOSTNAME": "optional",
      "DOMAIN": "optional"
    }
  }
}
```

**List dependencies:**
```json
{
  "dependencies": {
    "packages": ["bash", "jq", "curl", "python3"]
  }
}
```

#### Step 4: Update Examples

Edit config examples to match your schema:
- `examples/configs/config-example.env`
- `examples/configs/config-example.json`
- `examples/configs/config-example.txt`

Replace `EXAMPLE_FIELD` with your actual fields.

#### Step 5: Delete Examples Folder

```bash
rm -rf examples/
```

**Why:** The examples/ folder is only for the _USEME_ template. Production actions put all docs in README.md.

#### Step 6: Test

```bash
./scripts/test.sh
```

Should see:
```
Running _USEME_ Template Tests...

Test 1: Check file structure... ✅ PASS
Test 2: Load .env config... ✅ PASS
Test 3: Load .json config... ✅ PASS
Test 4: Validation fails on missing required field... ✅ PASS
Test 5: Save config... ✅ PASS
Test 6: Dependency checking... ✅ PASS
Test 7: Secure logging... ✅ PASS
Test 8: Banner safety... ✅ PASS
Test 9: Valid JSON... ✅ PASS
Test 10: Scripts executable... ✅ PASS

✅ ALL TESTS PASSED
```

#### Step 7: Write Documentation

Update README.md with:
- What the action does
- Required config fields
- Usage examples
- Security warnings (if applicable)
- Troubleshooting

#### Step 8: Create CI/CD Test

Create `.gitea/workflows/test-my-action.yml`:
```yaml
name: Test My Action

on:
  push:
    paths:
      - 'deploy/actions/my-action/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Test with .env config
        uses: ./deploy/actions/my-action
        with:
          config: test.env

      - name: Test with .json config
        uses: ./deploy/actions/my-action
        with:
          config: test.json

      - name: Test validation failure
        uses: ./deploy/actions/my-action
        with:
          config: invalid.env
        continue-on-error: true
```

---

## Troubleshooting

### Common Issues

#### Issue: "Missing required field: EXAMPLE_FIELD"

**Cause:** Config file missing required field.

**Solution:**
1. Check action-spec.json for required fields
2. Ensure config file has all required fields
3. Check for typos in field names

```bash
# Check required fields
jq '.config_schema.fields' action-spec.json

# Check config file
cat .env
```

#### Issue: "Command not found: jq"

**Cause:** Missing dependency.

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq

# Or update action-spec.json to not require jq
```

#### Issue: Variables not persisting between steps

**Cause:** Not using export, or not calling save-config.sh.

**Solution:**
```bash
# WRONG (doesn't persist)
MY_VAR="value"

# RIGHT (persists)
export MY_VAR="value"

# AND ensure Step 3 calls save-config.sh
```

#### Issue: Secrets appearing in logs

**Cause:** Manual logging or debugging echo statements.

**Solution:**
- Never `echo $PASSWORD`
- Never `cat .env` in logs
- Use secure logging only
- Check `.logs/` files to verify

#### Issue: Banner breaks action

**Should never happen!** Banner is error-safe with `|| true`.

**If it does:**
```bash
# Check banner code has error handling
{
    # banner code
} || true  # ← This should be there
```

---

## Evolution & Lessons Learned

### The Journey

#### Original Design (Script Hierarchy Hell)
**8 scripts:**
- konoss-banner.sh
- set-env-var.sh
- check-dependencies.sh
- prime.sh
- validate-config.sh
- load-and-validate.sh
- save-config.sh
- test.sh

**Problems:**
- Complex dependencies
- Hard to understand flow
- Difficult to maintain
- External references
- Not truly self-contained

#### First Consolidation
**Attempt:** Merge some scripts, keep helpers.

**Problem:** Still had external dependencies, not fully self-contained.

#### Final Design (Ultra-Clean)
**3 scripts:**
- load-and-validate.sh (all-in-one Step 1)
- save-config.sh (all-in-one Step 3)
- test.sh (comprehensive testing)

**Solution:** Inline everything. No external dependencies. True self-contained.

### Key Lessons

#### 1. Simplicity Wins
**Lesson:** Fewer files = easier to understand.

**Before:** 8 scripts calling each other
**After:** 3 scripts, all functionality inlined
**Result:** Developers immediately understand the flow

#### 2. Security Can't Be Afterthought
**Lesson:** Build security in from the start.

**Implementation:**
- Secure logging from day one
- Test that verifies no secrets leak
- `.gitignore` for logs
- Clear documentation on security

**Result:** Zero security incidents, safe debugging

#### 3. Documentation For Both Audiences
**Lesson:** Humans and AI need different docs.

**Solution:**
- PRODUCTION_READY.md - Human overview
- AI-INSTRUCTIONS.md - Step-by-step for AI
- Clear separation of concerns

**Result:** Both audiences successful

#### 4. Testing Is Non-Negotiable
**Lesson:** Untested code will break in production.

**Implementation:**
- 10 comprehensive tests
- Security test (critical)
- Run before every commit
- CI/CD integration

**Result:** Catch issues before production

#### 5. Self-Contained Means TRULY Self-Contained
**Lesson:** "Self-contained except for..." isn't self-contained.

**Wrong:**
- Referencing `../../scripts/helper.sh`
- Depending on repo structure
- External dependencies

**Right:**
- Everything in action folder
- Copy action folder = works
- Zero external references

**Result:** True reusability

### What We'd Do Differently

If starting from scratch:

1. **Start with 3 scripts** - Don't build hierarchy first
2. **Test security earlier** - Catch issues sooner
3. **Document as we go** - Easier than retrofitting
4. **More examples sooner** - Helps understand use cases
5. **AI docs from start** - AI is using this too

### What We Got Right

1. **Single source of truth** - action-spec.json saved us
2. **3-step pattern** - Consistent, predictable
3. **Secure logging** - Never exposed secrets
4. **KONOSS branding** - Professional identity
5. **Comprehensive docs** - Both human and AI

---

## Final Notes

### This Template Will Move

This _USEME_ template will be copied to many locations:
- Other repos
- Other organizations
- Other platforms
- Public releases

**That's why this documentation is verbose.**

Everything you need to know is here:
- Why decisions were made
- How things work
- What to watch out for
- How to troubleshoot

**Future AI/Developer:** You have all the context. Use it well.

### Production Checklist

Before using in production:

- [ ] action.yml customized (name, description, logic)
- [ ] action-spec.json updated (schema, dependencies)
- [ ] Config examples updated to match schema
- [ ] examples/ folder deleted
- [ ] README.md written
- [ ] All tests passing (`./scripts/test.sh`)
- [ ] CI/CD tests created
- [ ] Security reviewed (no secrets in logs)
- [ ] Documentation complete

### Support

- **Email:** hello@kontango.us
- **GitHub:** github.com/KontangoOSS
- **Docs:** kontango.gitbook.io/kontango

### License

This template is part of the Kontango open source ecosystem.

---

**Crafted with ☕ by Kontango Limited, CO**
**Making DevOps Actually Fun Since... Well, Now! 🚀**

*Version 1.0 - Production Ready*
*Last Updated: 2025-10-25*
