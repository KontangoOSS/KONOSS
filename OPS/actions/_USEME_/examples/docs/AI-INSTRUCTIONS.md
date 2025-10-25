# AI Agent Instructions - _USEME_ Template

**Target Audience:** AI assistants (Claude, ChatGPT, etc.) helping developers create Gitea Actions

**Version:** 1.0
**Last Updated:** 2025-10-25
**Context Retention:** This template will move to many locations. All context is embedded here.

---

## Table of Contents

1. [Quick Start Workflow](#quick-start-workflow)
2. [Deep Context for AI Agents](#deep-context-for-ai-agents)
3. [The 3-Step Pattern (Critical Understanding)](#the-3-step-pattern-critical-understanding)
4. [File-by-File Implementation Guide](#file-by-file-implementation-guide)
5. [Self-Contained Principles (Non-Negotiable)](#self-contained-principles-non-negotiable)
6. [Common Implementation Patterns](#common-implementation-patterns)
7. [Testing Requirements](#testing-requirements)
8. [Common Mistakes & How to Avoid](#common-mistakes--how-to-avoid)
9. [Complete Example Walkthrough](#complete-example-walkthrough)
10. [Context Preservation](#context-preservation)

---

## Quick Start Workflow

When a user asks you to create a new action from this template, follow this exact sequence:

### Step 1: Copy Template
```bash
cp -r deploy/actions/_USEME_ deploy/actions/[action-name]
cd deploy/actions/[action-name]
```

### Step 2: Delete Examples Folder
```bash
rm -rf examples/
```

**Why:** Examples are only for the _USEME_ template itself. Production actions document everything in README.md.

### Step 3: Update action.yml

**Critical changes:**
1. **Metadata** (lines 1-3):
   ```yaml
   name: 'Your Action Name'
   description: 'Clear description of what this action does'
   author: 'Kontango Limited'
   ```

2. **Step 2 Logic** (between ✏️ markers, ~lines 60-73):
   ```yaml
   # ╔═══════════════════════════════════════════╗
   # ║      ✏️  EDIT YOUR CODE HERE              ║
   # ╚═══════════════════════════════════════════╝

   # Your implementation here
   echo "Processing..."
   ./scripts/your-script.sh
   export STATUS="completed"

   # ╔═══════════════════════════════════════════╗
   # ║      ✏️  END OF YOUR CODE                 ║
   # ╚═══════════════════════════════════════════╝
   ```

**DO NOT EDIT:**
- Step 1 (config loading)
- Step 3 (config saving)
- Any script paths or sourcing logic

### Step 4: Update action-spec.json

This is the **single source of truth**. Update these sections:

**A. Metadata** (lines 2-5):
```json
{
  "name": "Action Name",
  "description": "What this action does",
  "version": "1.0.0",
  "author": "Kontango Limited"
}
```

**B. Config Schema** (lines 27-35):
```json
{
  "config_schema": {
    "description": "Fields for configuration",
    "fields": {
      "REQUIRED_FIELD_1": "required",
      "REQUIRED_FIELD_2": "required",
      "OPTIONAL_FIELD_1": "optional",
      "OPTIONAL_FIELD_2": "optional"
    }
  }
}
```

**Field values:**
- `"required"` - Field MUST be present (validated in Step 1)
- `"optional"` - Field documented but not required

**C. Dependencies** (lines 37-42):
```json
{
  "dependencies": {
    "description": "System packages needed",
    "packages": [
      "bash",
      "jq",
      "any-other-packages-you-need"
    ]
  }
}
```

**Critical:** List EVERY system package your action needs. This enables automatic dep checking.

### Step 5: Write README.md

Create comprehensive user documentation:
- What the action does
- Required config fields (table format)
- Usage examples
- Security warnings (if applicable)
- Troubleshooting

### Step 6: Test
```bash
./scripts/test.sh
```

Should see: `✅ ALL TESTS PASSED`

### Step 7: Commit

You're done! The action is production-ready.

---

## Deep Context for AI Agents

### Why This Template Exists

**Problems it solves:**
1. **Config chaos** - Actions need config, but loading/validating is boilerplate
2. **Dependency hell** - External script references break when action is copied
3. **Security risks** - Secrets leak into logs during debugging
4. **Maintenance burden** - Complex script hierarchies hard to maintain
5. **Poor reusability** - Actions tied to specific repo structures

**How it solves them:**
1. **Unified config system** - One script does: load→validate→export→log
2. **Self-contained mandate** - Everything in action folder, zero external refs
3. **Secure logging** - Variable names only, values never logged
4. **Ultra-clean structure** - 3 scripts total (was 8 originally)
5. **True portability** - Copy folder anywhere → works immediately

### Architecture Philosophy

#### Principle 1: Self-Contained Always

**Problem:** Actions referencing `../../scripts/helper.sh` break when:
- Copied to different repo
- Moved to different organization
- Used in different platform
- Folder structure changes

**Solution:** Everything needed is INSIDE the action folder.

**Implementation rules:**
- All scripts in `scripts/` folder
- All functions inlined (no external sourcing)
- No `../../` references EVER
- Copy action folder = works standalone

**How to verify:**
```bash
# This should work from ANY location
mkdir /tmp/test
cp -r deploy/actions/my-action /tmp/test/
cd /tmp/test/my-action
./scripts/test.sh  # Should pass
```

#### Principle 2: Single Source of Truth

**Problem:** Config schemas duplicated across:
- schema.json
- action.yml comments
- README.md tables
- Example files

Result: They get out of sync, confusion ensues.

**Solution:** `action-spec.json` is the ONLY source of truth.

**What it contains:**
- Config schema (required/optional fields)
- Dependencies (system packages)
- Input/output definitions
- Usage examples
- Metadata
- Self-contained checklist

**How scripts use it:**
```bash
# load-and-validate.sh reads required fields from action-spec.json
REQUIRED_FIELDS=$(jq -r '.config_schema.fields |
    to_entries[] |
    select(.value == "required") |
    .key' "$ACTION_DIR/action-spec.json")

# Validates them
for field in $REQUIRED_FIELDS; do
    if [ -z "${!field}" ]; then
        echo "❌ Missing required field: $field"
        exit 1
    fi
done
```

**Benefit:** Update one file, everything stays in sync.

#### Principle 3: Unified Process Over Hierarchy

**Original design (bad):**
```
scripts/
├── konoss-banner.sh        ← Shows banner
├── set-env-var.sh          ← Sets variables
├── check-dependencies.sh   ← Checks deps
├── prime.sh                ← Exports variables
├── validate-config.sh      ← Validates fields
├── load-and-validate.sh    ← Calls all above
├── save-config.sh          ← Calls some above
└── test.sh                 ← Tests
```

**Problems:**
- 8 files calling each other
- Complex dependency chains
- Hard to understand flow
- Difficult to maintain
- Not truly self-contained (sourcing external files)

**Final design (good):**
```
scripts/
├── load-and-validate.sh  # ALL Step 1 logic inlined
├── save-config.sh        # ALL Step 3 logic inlined
└── test.sh               # Comprehensive testing
```

**Benefits:**
- 3 files only
- All logic inlined
- Easy to understand
- Easy to maintain
- Truly self-contained

#### Principle 4: Security by Design

**The logging problem:**
```bash
# Typical debugging (BAD - exposes secrets):
echo "Loaded variables:"
echo "API_KEY=$API_KEY"
echo "PASSWORD=$PASSWORD"
# ❌ Secrets in logs!
```

**Our solution:**
```bash
# Secure logging (GOOD - names only):
{
    echo "Variable Names (values hidden for security):"
    jq -r 'keys[]' "$CONFIG" | while read -r key; do
        echo "  ✓ $key"  # ✅ Name only, value NEVER shown
    done
} > "$LOG_FILE"
```

**Guarantees:**
1. Variable names logged (for debugging)
2. Values NEVER logged (security)
3. `.logs/` gitignored (never committed)
4. Test verifies no leaks (Test 7)
5. Safe to review, safe to share

#### Principle 5: Dual Documentation

**Problem:** Documentation either:
- Too technical for humans (walls of code)
- Too vague for AI (unclear steps)

**Solution:** Separate docs for each audience:

**For Humans:**
- `PRODUCTION_READY.md` - Overview, philosophy, examples
- Main `README.md` - Quick start, features, usage
- `PUBLIC_RELEASE_CHECKLIST.md` - Verification

**For AI:**
- `AI-INSTRUCTIONS.md` - Step-by-step, file-by-file
- Clear do's and don'ts
- Implementation patterns
- Common mistakes

**Result:** Both audiences successful.

---

## The 3-Step Pattern (Critical Understanding)

### The Pattern Structure

**Every action follows this exact pattern:**

```yaml
runs:
  using: composite
  steps:
    # ╔═══════════════════════════════════════════════════════╗
    # ║  STEP 1: Validate and load configuration             ║
    # ║  DO NOT EDIT - This is automatic                     ║
    # ╚═══════════════════════════════════════════════════════╝
    - name: Validate and load configuration
      shell: bash
      run: |
        CONFIG="${{inputs.config}}"
        ACTION_DIR="$(dirname "$GITHUB_ACTION_PATH")"
        source "$ACTION_DIR/scripts/load-and-validate.sh" "$CONFIG"

    # ╔═══════════════════════════════════════════════════════╗
    # ║  STEP 2: Execute action logic                        ║
    # ║  ✏️  EDIT THIS - Add your custom logic here          ║
    # ╚═══════════════════════════════════════════════════════╝
    - name: Execute action logic
      shell: bash
      run: |
        # ╔═══════════════════════════════════════════╗
        # ║      ✏️  EDIT YOUR CODE HERE              ║
        # ╚═══════════════════════════════════════════╝

        # Your implementation here
        # Variables are ready to use: echo "$MY_VAR"
        # Update variables: export MY_VAR="new"
        # Call scripts: ./scripts/my-script.sh

        # ╔═══════════════════════════════════════════╗
        # ║      ✏️  END OF YOUR CODE                 ║
        # ╚═══════════════════════════════════════════╝

    # ╔═══════════════════════════════════════════════════════╗
    # ║  STEP 3: Save configuration                          ║
    # ║  DO NOT EDIT - This is automatic                     ║
    # ╚═══════════════════════════════════════════════════════╝
    - name: Save configuration
      shell: bash
      run: |
        CONFIG="${{inputs.config}}"
        ACTION_DIR="$(dirname "$GITHUB_ACTION_PATH")"
        source "$ACTION_DIR/scripts/save-config.sh" "$CONFIG"
```

### What Happens in Each Step

#### Step 1: load-and-validate.sh

**Does everything needed before your code runs:**

1. **Check dependencies**
   ```bash
   # Reads from action-spec.json
   DEPS=$(jq -r '.dependencies.packages[]' "$ACTION_DIR/action-spec.json")
   for dep in $DEPS; do
       if ! command -v "$dep" &>/dev/null; then
           echo "❌ Missing dependency: $dep"
           exit 1
       fi
   done
   ```

2. **Load config** (supports .env, .json, .txt)
   ```bash
   # .env/.txt format
   if [[ "$CONFIG" == *.env ]] || [[ "$CONFIG" == *.txt ]]; then
       while IFS='=' read -r key value; do
           [[ -z "$key" || "$key" =~ ^# ]] && continue
           export "$key=$value"
       done < "$CONFIG"
   fi

   # .json format
   if [[ "$CONFIG" == *.json ]]; then
       while IFS='=' read -r line; do
           [[ "$line" =~ ^_  ]] && continue  # Skip _comment
           export "$line"
       done < <(jq -r 'to_entries[] | "\(.key)=\(.value)"' "$CONFIG")
   fi
   ```

3. **Validate required fields**
   ```bash
   # Reads from action-spec.json
   REQUIRED_FIELDS=$(jq -r '.config_schema.fields |
       to_entries[] |
       select(.value == "required") |
       .key' "$ACTION_DIR/action-spec.json")

   for field in $REQUIRED_FIELDS; do
       if [ -z "${!field}" ]; then
           echo "❌ Missing required field: $field"
           exit 1
       fi
   done
   ```

4. **Export all variables**
   - Variables are now available to child processes
   - Step 2 can use them: `echo "$MY_VAR"`

5. **Create secure audit log**
   ```bash
   LOG_DIR="${ACTION_DIR}/.logs"
   mkdir -p "$LOG_DIR"
   LOG_FILE="$LOG_DIR/config-load-$(date +%Y%m%d-%H%M%S).log"

   {
       echo "Variable Names (values hidden for security):"
       # Log names only, NEVER values
       jq -r 'keys[]' "$CONFIG" | while read -r key; do
           echo "  ✓ $key"
       done
   } > "$LOG_FILE"
   ```

6. **Show KONOSS banner**
   - Professional branding
   - Error-safe (|| true)

**Result:** Variables loaded, validated, exported, logged (securely), ready for Step 2.

#### Step 2: Your Custom Logic

**This is the ONLY step you edit.**

**What you can do:**

1. **Read variables:**
   ```bash
   echo "Deploying to $SERVER_HOST"
   echo "Using port $PORT"
   ```

2. **Update variables:**
   ```bash
   export SERVER_HOST="new-server.com"
   export PORT="8080"
   ```

3. **Add new variables:**
   ```bash
   export DEPLOYED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
   export DEPLOYMENT_ID="$(uuidgen)"
   ```

4. **Call scripts:**
   ```bash
   ./scripts/deploy.sh
   ./scripts/notify.sh
   ```

5. **Conditional logic:**
   ```bash
   if [ "$ENVIRONMENT" = "production" ]; then
       ./scripts/prod-checks.sh
   fi
   ```

**Important rules:**
- Use `export` for variables that should persist
- Call scripts with `./scripts/` prefix
- Variables automatically saved in Step 3
- Don't manually save config (Step 3 does it)

#### Step 3: save-config.sh

**Saves all variables back to config:**

1. **Collect exported variables**
   ```bash
   # Get all environment variables
   # Filter out colors, paths, system vars
   SKIP_VARS="RED|GREEN|YELLOW|BLUE|NC|ACTION_DIR|SCRIPT_DIR|PATH|HOME"
   ```

2. **Write to config file**
   ```bash
   # Inline set_env_var function
   set_env_var() {
       local env_file="$1"
       local key="$2"
       local value="$3"

       if grep -q "^${key}=" "$env_file"; then
           # Update existing
           sed -i.bak "s|^${key}=.*|${key}=${value}|" "$env_file"
       else
           # Add new
           echo "${key}=${value}" >> "$env_file"
       fi
   }
   ```

3. **Show KONOSS banner**
   - Marks completion
   - Shows support contact

**Result:** Config file updated with all changes, action complete.

### Why This Pattern Works

**Traditional approach (manual):**
```yaml
- name: Load
  run: |
    source .env
    if [ -z "$REQUIRED_VAR" ]; then exit 1; fi

- name: Work
  run: |
    echo $REQUIRED_VAR
    NEW_VAR="value"

- name: Save
  run: |
    echo "NEW_VAR=$NEW_VAR" >> .env
```

**Problems:**
- Manual validation every time
- Only .env format supported
- No secure logging
- Variables don't persist automatically
- Tons of boilerplate

**Our approach (automatic):**
```yaml
- name: Load  # ✅ Automatic: deps→load→validate→export→log
- name: Work  # ✏️ Your code only
- name: Save  # ✅ Automatic: save→banner
```

**Benefits:**
- Zero boilerplate
- Multi-format support (.env, .json, .txt)
- Automatic validation
- Secure logging
- Variables auto-persist
- Professional branding

---

## File-by-File Implementation Guide

### action.yml - The Action Definition

**Location:** Root of action folder
**Purpose:** Defines the Gitea Action interface and implements 3-step pattern

**What to edit:**

1. **Metadata** (top of file):
   ```yaml
   name: 'Your Action Name'
   description: 'Clear, concise description'
   author: 'Kontango Limited'
   ```

2. **Inputs** (if you need additional inputs):
   ```yaml
   inputs:
     config:
       description: 'Config file path'
       required: true
     custom_param:
       description: 'Your custom parameter'
       required: false
   ```

3. **Step 2 logic** (between ✏️ markers):
   ```yaml
   # ╔═══════════════════════════════════════════╗
   # ║      ✏️  EDIT YOUR CODE HERE              ║
   # ╚═══════════════════════════════════════════╝

   # Your implementation

   # ╔═══════════════════════════════════════════╗
   # ║      ✏️  END OF YOUR CODE                 ║
   # ╚═══════════════════════════════════════════╝
   ```

**What NOT to edit:**
- Step 1 (config loading)
- Step 3 (config saving)
- Script paths
- Sourcing logic
- Any other steps

**Why:** Steps 1 and 3 are automatic, battle-tested, and handle everything correctly.

### action-spec.json - Single Source of Truth

**Location:** Root of action folder
**Purpose:** Complete action descriptor - config schema, dependencies, metadata

**Critical sections:**

**1. Metadata:**
```json
{
  "name": "Action Name",
  "description": "What it does",
  "version": "1.0.0",
  "author": "Kontango Limited"
}
```

**2. Config Schema:**
```json
{
  "config_schema": {
    "description": "Configuration fields for this action",
    "fields": {
      "REQUIRED_FIELD": "required",
      "OPTIONAL_FIELD": "optional"
    }
  }
}
```

**Field types:**
- `"required"` - Validated in Step 1, must be present
- `"optional"` - Documented but not validated

**3. Dependencies:**
```json
{
  "dependencies": {
    "description": "System packages needed",
    "packages": [
      "bash",     // Always needed
      "jq",       // Always needed (for JSON parsing)
      "curl",     // If making HTTP requests
      "python3",  // If using Python
      "docker"    // If using Docker
    ]
  }
}
```

**Always include:**
- `bash` - Required
- `jq` - Required for JSON parsing and validation

**Add everything else your action needs.**

**4. Inputs/Outputs:**
```json
{
  "inputs": {
    "config": {
      "description": "Configuration file path",
      "required": true,
      "type": "string"
    }
  },
  "outputs": {
    "status": {
      "description": "Action completion status",
      "type": "string"
    }
  }
}
```

**5. Usage Examples:**
```json
{
  "usage": {
    "basic": {
      "description": "Basic usage",
      "example": "- name: My Action\n  uses: ./deploy/actions/my-action\n  with:\n    config: .env"
    }
  }
}
```

**Why this file is critical:**
- Scripts read from it (validation, dep checking)
- Single source of truth (no duplication)
- AI agents know where to look
- Everything stays in sync

### scripts/load-and-validate.sh - Step 1 Implementation

**Location:** `scripts/load-and-validate.sh`
**Purpose:** All-in-one Step 1 script
**Edit this:** NEVER (unless extending template itself)

**What it does:**

1. **Dependency checking** (inlined, no external script):
   ```bash
   DEPS=$(jq -r '.dependencies.packages[]' "$ACTION_DIR/action-spec.json")
   for dep in $DEPS; do
       if ! command -v "$dep" &>/dev/null; then
           echo "❌ Missing dependency: $dep"
           exit 1
       fi
   done
   ```

2. **Multi-format parsing** (handles .env, .json, .txt):
   ```bash
   if [[ "$CONFIG" == *.env ]] || [[ "$CONFIG" == *.txt ]]; then
       while IFS='=' read -r key value; do
           [[ -z "$key" || "$key" =~ ^# ]] && continue
           export "$key=$value"
       done < "$CONFIG"
   elif [[ "$CONFIG" == *.json ]]; then
       while IFS='=' read -r line; do
           [[ "$line" =~ ^_ ]] && continue
           export "$line"
       done < <(jq -r 'to_entries[] | "\(.key)=\(.value)"' "$CONFIG")
   fi
   ```

3. **Field validation** (from action-spec.json):
   ```bash
   REQUIRED_FIELDS=$(jq -r '.config_schema.fields |
       to_entries[] |
       select(.value == "required") |
       .key' "$ACTION_DIR/action-spec.json")

   for field in $REQUIRED_FIELDS; do
       if [ -z "${!field}" ]; then
           echo "❌ Missing required field: $field"
           exit 1
       fi
   done
   ```

4. **Secure logging** (names only, no values):
   ```bash
   {
       echo "Variable Names (values hidden for security):"
       jq -r 'keys[]' "$CONFIG" | while read -r key; do
           echo "  ✓ $key"  # Name only!
       done
   } > "$LOG_FILE"
   ```

5. **KONOSS banner** (inlined, no external script):
   ```bash
   {
       echo "╔═══════════════════...═══╗"
       echo "║   KONOSS ASCII ART      ║"
       echo "╚═══════════════════...═══╝"
   } || true  # Never fail
   ```

**Why not edit:**
- Battle-tested logic
- Security built-in
- Handles all formats
- Comprehensive logging
- Professional branding

**When to edit:**
- Extending template itself
- Adding new config format
- Changing validation logic

### scripts/save-config.sh - Step 3 Implementation

**Location:** `scripts/save-config.sh`
**Purpose:** All-in-one Step 3 script
**Edit this:** NEVER (unless extending template itself)

**What it does:**

1. **Collects variables** (all exported vars):
   ```bash
   SKIP_VARS="RED|GREEN|YELLOW|BLUE|NC|ACTION_DIR|SCRIPT_DIR|PATH|HOME"
   ```

2. **Saves to config** (inline function):
   ```bash
   set_env_var() {
       local env_file="$1"
       local key="$2"
       local value="$3"

       if grep -q "^${key}=" "$env_file"; then
           sed -i.bak "s|^${key}=.*|${key}=${value}|" "$env_file"
       else
           echo "${key}=${value}" >> "$env_file"
       fi
   }
   ```

3. **Shows banner** (inlined):
   ```bash
   {
       echo "╔═══════════════════...═══╗"
       echo "║   KONOSS ASCII ART      ║"
       echo "╚═══════════════════...═══╝"
   } || true
   ```

**Why not edit:**
- Handles all variables correctly
- Preserves file format
- Professional completion
- Error-safe

### scripts/test.sh - Comprehensive Testing

**Location:** `scripts/test.sh`
**Purpose:** 10 comprehensive tests
**Edit this:** YES - Add action-specific tests

**The 10 tests:**

1. File structure
2. .env loading
3. .json loading
4. Validation failure
5. Save config
6. Dependency checking
7. **Secure logging** (critical security test)
8. Banner safety
9. Valid JSON
10. Scripts executable

**How to add your tests:**

```bash
# After test 10, add:

test_start "Test my specific functionality"
# Your test logic here
if [ condition ]; then
    test_pass
else
    test_fail "Description of failure"
fi
```

**Test helper functions:**
```bash
test_start "Test name"     # Starts a test
test_pass                  # Marks success
test_fail "Reason"         # Marks failure
```

---

## Self-Contained Principles (Non-Negotiable)

### The Golden Rule

**"Copy the action folder anywhere → it must work immediately"**

### What "Self-Contained" Means

✅ **GOOD - Self-Contained:**
```bash
# All scripts in action folder
./scripts/deploy.sh
./scripts/helpers.sh
./scripts/utils.sh

# Reading from action folder
source "$ACTION_DIR/scripts/load-and-validate.sh"

# All dependencies listed
"packages": ["bash", "jq", "curl"]
```

❌ **BAD - NOT Self-Contained:**
```bash
# External references
../../other-folder/helper.sh
/absolute/path/to/script.sh
~/scripts/utility.sh

# Assuming tools exist
curl ...  # But not in dependencies

# Relying on repo structure
../../../config/settings.json
```

### Verification Test

**The copy test:**
```bash
# Copy action to completely different location
mkdir /tmp/isolated-test
cp -r deploy/actions/my-action /tmp/isolated-test/
cd /tmp/isolated-test/my-action

# Create minimal config
cat > test.env << 'EOF'
REQUIRED_FIELD=value
EOF

# Run test
./scripts/test.sh

# Should pass ✅
```

**If test fails:** Action is NOT self-contained. Fix it.

### How to Maintain Self-Containment

**1. Copy scripts locally:**
```bash
# Instead of this:
source ../../scripts/helper.sh

# Do this:
cp ../../scripts/helper.sh scripts/
# Then in action:
source "$ACTION_DIR/scripts/helper.sh"
```

**2. Inline helper functions:**
```bash
# Instead of external file, inline in main script:
my_helper_function() {
    # function code
}
```

**3. List ALL dependencies:**
```json
{
  "dependencies": {
    "packages": [
      "bash",
      "jq",
      "every",
      "single",
      "package",
      "you",
      "use"
    ]
  }
}
```

**4. Use relative paths:**
```bash
# Good
./scripts/my-script.sh
"$ACTION_DIR/scripts/helper.sh"

# Bad
/absolute/path/script.sh
../../other/folder/script.sh
```

---

## Common Implementation Patterns

### Pattern 1: Simple Variable Update

**Use case:** Set status, timestamp, version

```yaml
# Step 2:
export STATUS="deployed"
export DEPLOYED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
export VERSION="1.0.0"
```

**Result:** Variables saved in Step 3 automatically.

### Pattern 2: Call External Script

**Use case:** Run deployment, tests, builds

**First, ensure script is in scripts/ folder:**
```bash
cp path/to/deploy.sh scripts/
chmod +x scripts/deploy.sh
```

**Then in Step 2:**
```yaml
echo "Running deployment..."
./scripts/deploy.sh "$SERVER_HOST" "$DEPLOY_PATH"

export DEPLOY_STATUS="$?"
export DEPLOYED_AT="$(date -u)"
```

### Pattern 3: Conditional Logic

**Use case:** Different behavior per environment

```yaml
if [ "$ENVIRONMENT" = "production" ]; then
    echo "Production - running full checks"
    ./scripts/prod-checks.sh
    export CHECKS_RUN="full"
else
    echo "Non-production - basic checks only"
    ./scripts/basic-checks.sh
    export CHECKS_RUN="basic"
fi
```

### Pattern 4: Multi-Step Process

**Use case:** Build → Test → Deploy

```yaml
echo "Building..."
npm run build || { export BUILD_STATUS="failed"; exit 1; }
export BUILD_STATUS="success"

echo "Testing..."
npm test || { export TEST_STATUS="failed"; exit 1; }
export TEST_STATUS="success"

echo "Deploying..."
./scripts/deploy.sh || { export DEPLOY_STATUS="failed"; exit 1; }
export DEPLOY_STATUS="success"

export COMPLETED_AT="$(date -u)"
```

### Pattern 5: API Calls with Error Handling

**Use case:** Call external API, handle failures

```yaml
echo "Calling deployment API..."
RESPONSE=$(curl -s -w "%{http_code}" -X POST \
    -H "Authorization: Bearer $API_KEY" \
    -d '{"version":"$VERSION"}' \
    "$API_ENDPOINT")

HTTP_CODE="${RESPONSE: -3}"
if [ "$HTTP_CODE" = "200" ]; then
    export DEPLOY_STATUS="success"
else
    export DEPLOY_STATUS="failed"
    export DEPLOY_ERROR="HTTP $HTTP_CODE"
    exit 1
fi
```

### Pattern 6: Generate and Save ID/Token

**Use case:** Create deployment ID, save for later

```yaml
echo "Generating deployment ID..."
export DEPLOYMENT_ID="$(uuidgen)"
export DEPLOYMENT_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo "Deployment ID: $DEPLOYMENT_ID"

# Will be saved automatically in Step 3
```

### Pattern 7: Read Secret from File

**Use case:** Load sensitive data securely

```yaml
# Read secret from file (not in config)
if [ -f "/secrets/api-key" ]; then
    API_KEY=$(cat /secrets/api-key)
    export API_KEY
else
    echo "❌ Secret file not found"
    exit 1
fi

# Use it
curl -H "Authorization: Bearer $API_KEY" ...
```

**Note:** Secret values still won't appear in logs (secure logging).

---

## Testing Requirements

### Local Testing (Required)

**Run before committing:**
```bash
./scripts/test.sh
```

**Expected output:**
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

### CI/CD Testing (Recommended)

**Create `.gitea/workflows/test-action.yml`:**

```yaml
name: Test My Action

on:
  push:
    paths:
      - 'deploy/actions/my-action/**'
  pull_request:
    paths:
      - 'deploy/actions/my-action/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      # Test with .env format
      - name: Create test .env
        run: |
          cat > test.env << 'EOF'
          REQUIRED_FIELD=test_value
          ANOTHER_FIELD=test
          EOF

      - name: Test .env format
        uses: ./deploy/actions/my-action
        with:
          config: test.env

      # Test with .json format
      - name: Create test .json
        run: |
          cat > test.json << 'EOF'
          {
            "REQUIRED_FIELD": "test_value",
            "ANOTHER_FIELD": "test"
          }
          EOF

      - name: Test .json format
        uses: ./deploy/actions/my-action
        with:
          config: test.json

      # Test validation failure
      - name: Create invalid config
        run: |
          cat > invalid.env << 'EOF'
          ANOTHER_FIELD=test
          EOF

      - name: Test validation failure
        uses: ./deploy/actions/my-action
        with:
          config: invalid.env
        continue-on-error: true

      # Verify it failed
      - name: Check validation failed
        run: |
          if [ $? -eq 0 ]; then
            echo "❌ Should have failed validation"
            exit 1
          fi
```

### Custom Tests (Add to test.sh)

**Example:**

```bash
# After the 10 standard tests, add your own:

# Test 11: Your specific functionality
test_start "Test deployment script exists"

if [ -f "./scripts/deploy.sh" ]; then
    test_pass
else
    test_fail "deploy.sh not found"
fi

# Test 12: Config has correct fields
test_start "Test config example has all required fields"

if grep -q "SERVER_HOST=" examples/configs/config-example.env && \
   grep -q "DEPLOY_PATH=" examples/configs/config-example.env; then
    test_pass
else
    test_fail "Missing required fields in example"
fi
```

---

## Common Mistakes & How to Avoid

### Mistake 1: Editing Step 1 or Step 3

❌ **Wrong:**
```yaml
# Step 1: Validate and load configuration
- name: Validate and load configuration
  run: |
    CONFIG="${{inputs.config}}"
    source ...
    # Adding custom validation here ❌
    if [ -z "$CUSTOM_FIELD" ]; then
        echo "Missing custom field"
    fi
```

✅ **Right:**
```yaml
# Step 1: Don't edit

# Step 2: Add custom validation here
- name: Execute action logic
  run: |
    if [ -z "$CUSTOM_FIELD" ]; then
        echo "Missing custom field"
        exit 1
    fi
```

**Why:** Steps 1 and 3 are automatic and tested. Custom logic goes in Step 2.

### Mistake 2: Forgetting config_schema

❌ **Wrong:**
```json
{
  "config_schema": {
    "fields": {
      "EXAMPLE_FIELD": "required"
    }
  }
}
```

But your action actually uses:
```yaml
echo "$SERVER_HOST"
echo "$DEPLOY_PATH"
```

✅ **Right:**
```json
{
  "config_schema": {
    "fields": {
      "SERVER_HOST": "required",
      "DEPLOY_PATH": "required",
      "SSH_KEY": "optional"
    }
  }
}
```

**Why:** Validation only checks fields in schema. Missing fields = no validation = runtime failures.

### Mistake 3: Not Listing Dependencies

❌ **Wrong:**
```json
{
  "dependencies": {
    "packages": ["bash", "jq"]
  }
}
```

But your action uses:
```yaml
curl -X POST ...
docker run ...
python3 script.py
```

✅ **Right:**
```json
{
  "dependencies": {
    "packages": ["bash", "jq", "curl", "docker", "python3"]
  }
}
```

**Why:** Missing deps = action fails on systems without them. Explicit > implicit.

### Mistake 4: External Script References

❌ **Wrong:**
```yaml
# Step 2:
../../scripts/helper.sh
/absolute/path/to/deploy.sh
```

✅ **Right:**
```bash
# First copy scripts:
cp ../../scripts/helper.sh scripts/
cp /absolute/path/to/deploy.sh scripts/

# Then in Step 2:
./scripts/helper.sh
./scripts/deploy.sh
```

**Why:** Self-contained = works anywhere.

### Mistake 5: Keeping examples/ Folder

❌ **Wrong:**
```
my-action/
├── action.yml
├── action-spec.json
├── scripts/
└── examples/  ❌ Still here!
```

✅ **Right:**
```bash
rm -rf examples/

my-action/
├── action.yml
├── action-spec.json
├── README.md
└── scripts/
```

**Why:** Examples are only for _USEME_ template. Production actions = no examples folder.

### Mistake 6: Logging Secret Values

❌ **Wrong:**
```yaml
# Step 2:
echo "API_KEY=$API_KEY"
echo "PASSWORD=$PASSWORD"
cat .env  # Shows all values!
```

✅ **Right:**
```yaml
# Step 2:
echo "Using API key from config"
echo "Authentication configured"
# Values are in logs automatically (names only)
```

**Why:** Secure logging built-in. Don't manually log values.

### Mistake 7: Not Using export

❌ **Wrong:**
```yaml
# Step 2:
STATUS="deployed"
TIMESTAMP=$(date)
```

✅ **Right:**
```yaml
# Step 2:
export STATUS="deployed"
export TIMESTAMP=$(date)
```

**Why:** Without `export`, variables don't persist to Step 3, won't be saved.

### Mistake 8: Hardcoding Values

❌ **Wrong:**
```yaml
# Step 2:
SERVER="production.example.com"  # Hardcoded!
./scripts/deploy.sh "$SERVER"
```

✅ **Right:**
```json
// action-spec.json
{
  "config_schema": {
    "fields": {
      "SERVER": "required"
    }
  }
}
```

```yaml
# Step 2:
./scripts/deploy.sh "$SERVER"  # From config
```

**Why:** Config-driven = flexible, reusable.

---

## Complete Example Walkthrough

**User request:** "Create an action that deploys a Docker container to a remote server"

### Step 1: Copy Template

```bash
cp -r deploy/actions/_USEME_ deploy/actions/docker-deploy
cd deploy/actions/docker-deploy
```

### Step 2: Delete Examples

```bash
rm -rf examples/
```

### Step 3: Update action.yml

**Metadata:**
```yaml
name: 'Docker Deploy'
description: 'Deploys Docker container to remote server via SSH'
author: 'Kontango Limited'
```

**Step 2 Logic:**
```yaml
# ╔═══════════════════════════════════════════╗
# ║      ✏️  EDIT YOUR CODE HERE              ║
# ╚═══════════════════════════════════════════╝

echo "🐳 Deploying Docker container..."
echo "Server: $SERVER_HOST"
echo "Container: $DOCKER_IMAGE"

# Build and tag image
docker build -t "$DOCKER_IMAGE:$VERSION" .
docker tag "$DOCKER_IMAGE:$VERSION" "$DOCKER_IMAGE:latest"

# Push to registry
docker push "$DOCKER_IMAGE:$VERSION"
docker push "$DOCKER_IMAGE:latest"

# Deploy to server
ssh "$SSH_USER@$SERVER_HOST" << 'ENDSSH'
docker pull "$DOCKER_IMAGE:latest"
docker stop "$CONTAINER_NAME" || true
docker rm "$CONTAINER_NAME" || true
docker run -d \
    --name "$CONTAINER_NAME" \
    -p "$PORT:$PORT" \
    "$DOCKER_IMAGE:latest"
ENDSSH

export DEPLOY_STATUS="success"
export DEPLOYED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
export DEPLOYED_VERSION="$VERSION"

echo "✅ Deployment complete!"

# ╔═══════════════════════════════════════════╗
# ║      ✏️  END OF YOUR CODE                 ║
# ╚═══════════════════════════════════════════╝
```

### Step 4: Update action-spec.json

```json
{
  "name": "Docker Deploy",
  "description": "Deploys Docker container to remote server",
  "version": "1.0.0",
  "author": "Kontango Limited",

  "config_schema": {
    "description": "Docker deployment configuration",
    "fields": {
      "SERVER_HOST": "required",
      "SSH_USER": "required",
      "DOCKER_IMAGE": "required",
      "CONTAINER_NAME": "required",
      "VERSION": "required",
      "PORT": "optional"
    }
  },

  "dependencies": {
    "description": "Required system packages",
    "packages": [
      "bash",
      "jq",
      "docker",
      "ssh"
    ]
  }
}
```

### Step 5: Create README.md

```markdown
# Docker Deploy Action

Deploys a Docker container to a remote server via SSH.

## Required Configuration

| Field | Type | Description |
|-------|------|-------------|
| `SERVER_HOST` | required | Remote server hostname |
| `SSH_USER` | required | SSH username |
| `DOCKER_IMAGE` | required | Docker image name |
| `CONTAINER_NAME` | required | Container name |
| `VERSION` | required | Version tag |
| `PORT` | optional | Port mapping (default: 8080) |

## Usage

```yaml
- name: Deploy Docker Container
  uses: ./deploy/actions/docker-deploy
  with:
    config: deploy-config.env
```

## Example Config

```bash
# deploy-config.env
SERVER_HOST=production.example.com
SSH_USER=deployer
DOCKER_IMAGE=myapp
CONTAINER_NAME=myapp-prod
VERSION=1.0.0
PORT=8080
```

## Security

- Ensure SSH keys are configured
- Use secrets for sensitive data
- Logs are secure (no secret values)
```

### Step 6: Test

```bash
./scripts/test.sh
```

Output:
```
Running _USEME_ Template Tests...
Test 1: Check file structure... ✅ PASS
Test 2: Load .env config... ✅ PASS
...
✅ ALL TESTS PASSED
```

### Step 7: Done!

Action is production-ready:
- ✅ Self-contained
- ✅ Validated config
- ✅ Secure logging
- ✅ Professional branding
- ✅ Tested
- ✅ Documented

---

## Advanced Topics & Lessons Learned

### Working with Shell Variables Across Steps

**CRITICAL: Each step in a Gitea/GitHub Action runs in a SEPARATE shell.**

Variables set in Step 1 are NOT automatically available in Step 2 or Step 3.

#### The Problem

```yaml
# Step 1
- name: Load config
  run: |
    source scripts/load-and-validate.sh config.env
    echo "VAR=$VAR"  # ✅ Works here

# Step 2
- name: Use config
  run: |
    echo "VAR=$VAR"  # ❌ Empty! Different shell
```

#### The Solution: Re-load the Config File

**The config file is the source of truth.** Load it in each step:

```yaml
# Step 1: Validate and load
- name: Validate and load configuration
  run: |
    CONFIG="${{inputs.config}}"
    source scripts/load-and-validate.sh "$CONFIG"

# Step 2: Execute (reload config)
- name: Execute action logic
  run: |
    CONFIG="${{inputs.config}}"
    source scripts/load-and-validate.sh "$CONFIG" >/dev/null 2>&1

    # Now variables are available
    echo "VAR=$VAR"  # ✅ Works

# Step 3: Save (reload config)
- name: Save configuration
  run: |
    CONFIG="${{inputs.config}}"
    source scripts/save-config.sh "$CONFIG"
```

**Why this works:**
- Config files (.env, .json, .txt) persist between steps
- `load-and-validate.sh` is idempotent (safe to call multiple times)
- Each step gets fresh validated variables
- No need for GITHUB_ENV hacks

#### Testing with Subshells

When testing locally, simulate separate shells:

```bash
#!/usr/bin/env bash
CONFIG="test.env"

# Step 1 (separate shell)
bash -c "source scripts/load-and-validate.sh '$CONFIG'"

# Step 2 (separate shell - reload)
bash << 'STEP2'
    set -a
    source test.env
    set +a

    echo "VAR=$VAR"  # ✅ Available
    python3 my-script.py --var "$VAR"
STEP2

# Step 3 (separate shell)
bash -c "source scripts/save-config.sh '$CONFIG'"
```

**DO NOT** try to preserve variables between shells with pipes:
```bash
# ❌ WRONG - creates subshell, variables lost
source config.env | tail -5
echo "$VAR"  # Empty!

# ✅ CORRECT - source in current shell
source config.env
echo "$VAR"  # Works!
```

### Python SDK Integration Patterns

#### Example: Phase SDK

When integrating with Python SDKs, **read the SDK documentation** carefully:

**Problem:** Phase API was using `app_id` (UUID) but SDK uses `app_name` (string):

```python
# ❌ WRONG (doesn't match SDK)
options = GetAllSecretsOptions(
    env_name=args.env,
    app_id=args.app_id  # SDK doesn't accept this!
)

# ✅ CORRECT (matches SDK docs)
options = GetAllSecretsOptions(
    env_name=args.env,
    app_name=args.app_name  # SDK requires app name
)
```

**Config must match:**
```bash
# ❌ WRONG
PHASE_APP_ID=cd3468f0-ca70-4393-b6a3-d0d10a9707cb

# ✅ CORRECT
PHASE_APP_NAME=MyApplication
```

**Lesson:** Always check SDK documentation for exact parameter names and types.

#### Running Python Scripts in Same Shell

Python scripts run as child processes and need environment variables:

```bash
# Variables must be exported for child processes
export PHASE_SECRET="$PHASE_SECRET"
export PHASE_APP_NAME="$PHASE_APP_NAME"

# Now Python can access them
python3 my-script.py --token "$PHASE_SECRET"
```

**The load-and-validate.sh script exports variables automatically** for you:
```bash
source scripts/load-and-validate.sh config.env
# All variables are now exported for child processes
python3 my-script.py  # ✅ Can access env vars
```

### Error Handling Patterns

#### Robust Python Script Execution

```yaml
- name: Execute action logic
  run: |
    CONFIG="${{inputs.config}}"
    source scripts/load-and-validate.sh "$CONFIG" >/dev/null 2>&1

    # Set defaults for optional variables
    PHASE_HOST="${PHASE_HOST:-https://phase.kontango.org}"
    PHASE_ENV="${PHASE_ENV:-production}"

    # Check script exists
    SCRIPT="$ACTION_DIR/scripts/my-script.py"
    if [ ! -f "$SCRIPT" ]; then
        echo "❌ Error: Script not found: $SCRIPT" >&2
        exit 1
    fi

    # Build arguments
    ARGS=(
        --host "$PHASE_HOST"
        --token "$PHASE_SECRET"
        --app-name "$PHASE_APP_NAME"
    )

    # Execute with error handling
    if ! python3 "$SCRIPT" "${ARGS[@]}" 2>&1; then
        echo "❌ Script failed with exit code $?" >&2
        exit 1
    fi

    echo "✅ Script completed successfully"
```

#### Validating Required Variables

```bash
# After loading config, verify critical variables
if [ -z "$PHASE_APP_NAME" ]; then
    echo "❌ Error: PHASE_APP_NAME is required but not set" >&2
    exit 1
fi

if [ -z "$PHASE_SECRET" ]; then
    echo "❌ Error: PHASE_SECRET is required but not set" >&2
    exit 1
fi
```

**Note:** The `load-and-validate.sh` script does this automatically based on `action-spec.json`, but you can add extra runtime checks for dynamic requirements.

#### Handling Optional Variables with Defaults

```bash
# Use parameter expansion for defaults
PHASE_HOST="${PHASE_HOST:-https://phase.kontango.org}"
PHASE_ENV="${PHASE_ENV:-production}"
TIMEOUT="${TIMEOUT:-30}"

# Or set defaults explicitly
: "${PHASE_HOST:=https://phase.kontango.org}"
: "${PHASE_ENV:=production}"
```

#### Graceful Failure

```bash
# Set -e for early exit on errors
set -e

# But allow specific commands to fail gracefully
if ! optional_command; then
    echo "⚠️  Warning: Optional command failed, continuing..."
fi

# Or use || for fallback
SECRET_COUNT=$(echo "$OUTPUT" | jq 'length' 2>/dev/null || echo "0")
```

### Common Pitfalls & Solutions

#### Pitfall 1: Variables Not Available in Child Processes

**Problem:**
```bash
MY_VAR="value"
python3 script.py  # Can't access MY_VAR
```

**Solution:**
```bash
export MY_VAR="value"
python3 script.py  # ✅ Can access MY_VAR
```

Or use `load-and-validate.sh` which exports automatically.

#### Pitfall 2: Pipes Create Subshells

**Problem:**
```bash
source config.env | grep "SUCCESS"
echo "$VAR"  # ❌ Empty! Source ran in subshell
```

**Solution:**
```bash
# Source without piping
source config.env
# Then use variables
echo "$VAR"  # ✅ Works
```

#### Pitfall 3: SDK Parameter Mismatches

**Problem:** Using wrong parameter names from API docs instead of SDK docs.

**Solution:**
1. Find the SDK documentation (not just API docs)
2. Check example code in SDK repo
3. Match parameter names exactly
4. Test with real credentials

#### Pitfall 4: Assuming Variables Persist Between Steps

**Problem:**
```yaml
# Step 1
- run: export MY_VAR="value"

# Step 2
- run: echo "$MY_VAR"  # ❌ Empty
```

**Solution:** Use config files as the source of truth and reload in each step.

### Testing Best Practices

#### Test in Isolated Environment

```bash
# Copy action to temp location
mkdir /tmp/test-action
cp -r deploy/actions/my-action /tmp/test-action/
cd /tmp/test-action

# Create minimal test config
cat > test.env <<EOF
REQUIRED_VAR=test_value
EOF

# Test it works standalone
./scripts/test.sh
```

#### Test with Real Credentials (Safely)

```bash
# Create test config with real credentials
cat > test-real.env <<EOF
API_KEY=$(pass show my-api-key)
APP_NAME=MyTestApp
EOF

# Add to .gitignore
echo "test-real.env" >> .gitignore

# Test with real API
source scripts/load-and-validate.sh test-real.env
python3 scripts/my-script.py --api-key "$API_KEY"

# Clean up
rm test-real.env
```

#### Simulate 3-Step Pattern Locally

```bash
#!/usr/bin/env bash
CONFIG="test.env"

# Step 1: Validate
bash -c "source scripts/load-and-validate.sh '$CONFIG' | tail -5"

# Step 2: Execute (in separate shell)
bash << 'STEP2'
    set -a
    source test.env
    set +a

    python3 scripts/my-script.py --var "$MY_VAR"
STEP2

# Step 3: Save
bash -c "source scripts/save-config.sh '$CONFIG' | tail -5"
```

---

## Context Preservation

### Why This Documentation Is Verbose

This _USEME_ template will be copied to:
- Multiple repositories
- Different organizations
- Different platforms
- Public releases

**You (future AI agent) may encounter this template with:**
- No surrounding context
- No conversation history
- No knowledge of original design
- No access to original developers

**That's why everything is documented here:**
- Design decisions and why
- Implementation details and how
- Common issues and solutions
- Complete examples and patterns
- Testing strategy and verification

### Using This Documentation

**When you encounter this template:**

1. **Read this file first** - Complete AI context
2. **Read PRODUCTION_READY.md** - Deep technical details
3. **Read PUBLIC_RELEASE_CHECKLIST.md** - Verification
4. **Read action-spec.json** - Action specifics

**You now have:**
- Complete architectural understanding
- Implementation knowledge
- Testing requirements
- Security considerations
- Common patterns
- Troubleshooting

**Use it to:**
- Create new actions correctly
- Debug existing actions
- Extend the template
- Help users effectively

---

## Final Checklist for AI Agents

Before completing an action creation task, verify:

### Files
- [ ] action.yml updated (name, description, Step 2)
- [ ] action-spec.json updated (schema, dependencies)
- [ ] examples/ folder deleted
- [ ] README.md created with full docs
- [ ] All scripts in scripts/ folder

### Self-Contained
- [ ] No ../../ references
- [ ] No external dependencies
- [ ] All helpers inlined or in scripts/
- [ ] All packages in dependencies.packages

### Testing
- [ ] ./scripts/test.sh passes
- [ ] Added action-specific tests
- [ ] Created CI/CD workflow (optional)

### Security
- [ ] No secrets in logs verified
- [ ] No hardcoded credentials
- [ ] Secure logging maintained

### Documentation
- [ ] README.md complete
- [ ] Config fields documented
- [ ] Usage examples provided
- [ ] No personal/private info

### Final Test
```bash
# The copy test
mkdir /tmp/test
cp -r deploy/actions/my-action /tmp/test/
cd /tmp/test/my-action
./scripts/test.sh
# Should pass ✅
```

---

**You have complete context. Create amazing, self-contained, production-ready actions!**

**Crafted with ☕ by Kontango Limited, CO**
**Making DevOps Actually Fun Since... Well, Now! 🚀**

*Version 1.0 - AI Agent Guide*
*Last Updated: 2025-10-25*
