#!/usr/bin/env bash
# =============================================================================
# load-and-validate.sh - Unified config loader and validator
# =============================================================================
# Usage: source ./scripts/load-and-validate.sh <config-file>
#
# This script MUST be SOURCED (not executed) so variables are available
# in the calling shell and all child processes.
#
# What it does:
#   1. Checks dependencies (from action-spec.json)
#   2. Loads config file (.env, .json, or .txt)
#   3. Exports all variables
#   4. Validates required fields
#   5. Verifies variables are accessible
#
# After sourcing, all config variables are available for normal scripting.
# =============================================================================

CONFIG="${1:-.env}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ACTION_SPEC="$ACTION_DIR/action-spec.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  Config Loading & Validation Process                      ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# =============================================================================
# STEP 1: CHECK DEPENDENCIES
# =============================================================================
echo -e "${BLUE}[1/5]${NC} Checking dependencies..."

if [ ! -f "$ACTION_SPEC" ]; then
    echo -e "${RED}❌ action-spec.json not found${NC}" >&2
    return 1
fi

# Read dependencies array
PACKAGES=$(jq -r '.dependencies.packages[]? // empty' "$ACTION_SPEC" 2>/dev/null)

if [ -z "$PACKAGES" ]; then
    echo -e "      ${GREEN}✓${NC} No dependencies required"
else
    # Detect package manager
    if command -v apt-get &> /dev/null; then
        PKG_MGR="apt-get"
        INSTALL_CMD="apt-get install -y"
        CHECK_CMD="dpkg -l"
    elif command -v yum &> /dev/null; then
        PKG_MGR="yum"
        INSTALL_CMD="yum install -y"
        CHECK_CMD="rpm -q"
    elif command -v brew &> /dev/null; then
        PKG_MGR="brew"
        INSTALL_CMD="brew install"
        CHECK_CMD="brew list"
    else
        PKG_MGR="none"
    fi

    MISSING=()

    # Check each package
    while IFS= read -r pkg; do
        if command -v "$pkg" &> /dev/null; then
            echo -e "      ${GREEN}✓${NC} $pkg"
        else
            if [ "$PKG_MGR" != "none" ] && $CHECK_CMD "$pkg" &> /dev/null; then
                echo -e "      ${GREEN}✓${NC} $pkg (installed)"
            else
                echo -e "      ${YELLOW}⚠${NC} $pkg (missing)"
                MISSING+=("$pkg")
            fi
        fi
    done <<< "$PACKAGES"

    # Install missing packages
    if [ ${#MISSING[@]} -gt 0 ]; then
        if [ "$PKG_MGR" = "none" ]; then
            echo -e "${RED}❌ Missing packages: ${MISSING[*]}${NC}" >&2
            echo "   Please install manually (no package manager detected)" >&2
            return 1
        fi

        echo -e "      ${YELLOW}Installing: ${MISSING[*]}${NC}"

        if [ "$PKG_MGR" = "apt-get" ]; then
            apt-get update -qq 2>/dev/null || true
        fi

        if $INSTALL_CMD ${MISSING[*]} >/dev/null 2>&1; then
            echo -e "      ${GREEN}✓ Packages installed${NC}"
        else
            echo -e "${RED}❌ Failed to install packages${NC}" >&2
            return 1
        fi
    fi

    echo -e "      ${GREEN}✅ All dependencies satisfied${NC}"
fi

echo ""

# =============================================================================
# STEP 2: LOAD CONFIG FILE
# =============================================================================
echo -e "${BLUE}[2/5]${NC} Loading config file: $CONFIG"

# Check if config exists
if [ ! -f "$CONFIG" ]; then
    echo -e "${RED}❌ Config file not found: $CONFIG${NC}" >&2
    return 1
fi

# Detect file type and load
if [[ "$CONFIG" == *.json ]]; then
    # Load from JSON
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}❌ jq not installed, cannot parse JSON${NC}" >&2
        return 1
    fi

    # Export each key-value pair from JSON
    while IFS='=' read -r key value; do
        export "$key=$value"
    done < <(jq -r 'to_entries | .[] | "\(.key)=\(.value)"' "$CONFIG")

    VAR_COUNT=$(jq 'length' "$CONFIG")
else
    # Load from .env or .txt file
    VAR_COUNT=0
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Extract key and value
        if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"

            # Remove surrounding quotes if present
            if [[ "$value" =~ ^\"(.*)\"$ ]] || [[ "$value" =~ ^\'(.*)\'$ ]]; then
                value="${BASH_REMATCH[1]}"
            fi

            # Export the variable
            export "$key=$value"
            ((VAR_COUNT++))
        fi
    done < "$CONFIG"
fi

echo -e "      ${GREEN}✓ Loaded $VAR_COUNT variables${NC}"
echo ""

# =============================================================================
# STEP 3: VALIDATE REQUIRED FIELDS
# =============================================================================
echo -e "${BLUE}[3/5]${NC} Validating required fields..."

# Get required fields from action-spec.json
REQUIRED_FIELDS=$(jq -r '.config_schema.fields | to_entries | .[] | select(.value == "required") | .key' "$ACTION_SPEC" 2>/dev/null || echo "")

if [ -z "$REQUIRED_FIELDS" ]; then
    echo -e "      ${YELLOW}⚠${NC} No required fields defined in action-spec.json"
else
    MISSING_FIELDS=()
    VALID_FIELDS=()

    # Check each required field
    for field in $REQUIRED_FIELDS; do
        if [ -z "${!field:-}" ]; then
            echo -e "      ${RED}✗${NC} $field (missing)"
            MISSING_FIELDS+=("$field")
        else
            echo -e "      ${GREEN}✓${NC} $field"
            VALID_FIELDS+=("$field")
        fi
    done

    # Fail if any required fields are missing
    if [ ${#MISSING_FIELDS[@]} -gt 0 ]; then
        echo ""
        echo -e "${RED}❌ Missing required fields: ${MISSING_FIELDS[*]}${NC}" >&2
        return 1
    fi

    echo -e "      ${GREEN}✅ All required fields present${NC}"
fi

echo ""

# =============================================================================
# STEP 4: VERIFY VARIABLE ACCESS
# =============================================================================
echo -e "${BLUE}[4/5]${NC} Verifying variable access..."

# Test that variables are exported and accessible
TEST_PASSED=true

# Get first few variables to test
SAMPLE_VARS=$(jq -r '.config_schema.fields | to_entries | .[0:3] | .[] | .key' "$ACTION_SPEC" 2>/dev/null || echo "")

if [ -n "$SAMPLE_VARS" ]; then
    for var in $SAMPLE_VARS; do
        if [ -n "${!var:-}" ]; then
            # Variable is accessible (don't print value - may contain secrets)
            echo -e "      ${GREEN}✓${NC} $var is accessible"
        else
            echo -e "      ${YELLOW}⚠${NC} $var not set (may be optional)"
        fi
    done
else
    # No schema defined, test first exported variable
    FIRST_VAR=$(env | grep -v "^_" | head -1 | cut -d'=' -f1)
    if [ -n "$FIRST_VAR" ] && [ -n "${!FIRST_VAR:-}" ]; then
        echo -e "      ${GREEN}✓${NC} Variables are exported and accessible"
    fi
fi

echo -e "      ${GREEN}✅ Variables ready for child processes${NC}"
echo ""

# =============================================================================
# STEP 5: SUMMARY & LOGGING
# =============================================================================
echo -e "${BLUE}[5/5]${NC} Summary & Logging"
echo -e "      ${GREEN}✓${NC} Dependencies: All satisfied"
echo -e "      ${GREEN}✓${NC} Config loaded: $VAR_COUNT variables from $CONFIG"
echo -e "      ${GREEN}✓${NC} Validation: All required fields present"
echo -e "      ${GREEN}✓${NC} Access: Variables exported for child processes"
echo ""

# Create secure log file (without secrets)
LOG_DIR="${ACTION_DIR}/.logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/config-load-$(date +%Y%m%d-%H%M%S).log"

{
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  Config Load Log - $(date '+%Y-%m-%d %H:%M:%S')              ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Config File: $CONFIG"
    echo "Variables Loaded: $VAR_COUNT"
    echo ""
    echo "Variable Names (values hidden for security):"
    echo "────────────────────────────────────────────────────────────"

    # List variable names only (no values - security!)
    if [[ "$CONFIG" == *.json ]]; then
        jq -r 'keys[]' "$CONFIG" 2>/dev/null | while read -r key; do
            echo "  ✓ $key"
        done
    else
        grep -v '^#' "$CONFIG" | grep '=' | cut -d'=' -f1 | while read -r key; do
            [ -n "$key" ] && echo "  ✓ $key"
        done
    fi

    echo ""
    echo "Required Fields Validated:"
    echo "────────────────────────────────────────────────────────────"
    if [ -n "$REQUIRED_FIELDS" ]; then
        for field in $REQUIRED_FIELDS; do
            if [ -z "${!field:-}" ]; then
                echo "  ✗ $field (MISSING)"
            else
                echo "  ✓ $field (present)"
            fi
        done
    else
        echo "  (no required fields defined)"
    fi

    echo ""
    echo "Dependencies:"
    echo "────────────────────────────────────────────────────────────"
    if [ -n "$PACKAGES" ]; then
        while IFS= read -r pkg; do
            if command -v "$pkg" &> /dev/null; then
                echo "  ✓ $pkg"
            else
                echo "  ✗ $pkg"
            fi
        done <<< "$PACKAGES"
    else
        echo "  (no dependencies required)"
    fi

    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "✅ Config load completed successfully"
    echo "════════════════════════════════════════════════════════════"
} > "$LOG_FILE" 2>&1

echo -e "      ${GREEN}✓${NC} Secure log saved: ${LOG_FILE/$HOME/\~}"
echo ""

# Show KONOSS branding banner (inline - no external dependency)
{
    echo "" >&2
    echo "╔═══════════════════════════════════════════════════════════════════╗" >&2
    echo "║                                                                   ║" >&2
    echo "║   ██╗  ██╗ ██████╗ ███╗   ██╗ ██████╗ ███████╗███████╗          ║" >&2
    echo "║   ██║ ██╔╝██╔═══██╗████╗  ██║██╔═══██╗██╔════╝██╔════╝          ║" >&2
    echo "║   █████╔╝ ██║   ██║██╔██╗ ██║██║   ██║███████╗███████╗          ║" >&2
    echo "║   ██╔═██╗ ██║   ██║██║╚██╗██║██║   ██║╚════██║╚════██║          ║" >&2
    echo "║   ██║  ██╗╚██████╔╝██║ ╚████║╚██████╔╝███████║███████║          ║" >&2
    echo "║   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚══════╝          ║" >&2
    echo "║                                                                   ║" >&2
    echo "║           Making DevOps Actually Fun Since... Well, Now! 🚀      ║" >&2
    echo "║              Crafted with ☕ by Kontango Limited, CO              ║" >&2
    echo "║                                                                   ║" >&2
    echo "║           📧 hello@kontango.us                                    ║" >&2
    echo "║           💻 github.com/KontangoOSS                               ║" >&2
    echo "║           📚 kontango.gitbook.io/kontango                         ║" >&2
    echo "║                                                                   ║" >&2
    echo "╚═══════════════════════════════════════════════════════════════════╝" >&2
} || true  # Never fail due to banner issues

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ✅ Config ready - you can now script as normal!          ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

return 0
