#!/usr/bin/env bash
# =============================================================================
# save-config.sh - Save all exported variables back to config file
# =============================================================================
# Usage: ./scripts/save-config.sh <config-file>
#
# Self-contained: All functionality inline (no external dependencies)
# =============================================================================

CONFIG="${1:-.env}"

if [ ! -f "$CONFIG" ]; then
    echo "ERROR: Config file not found: $CONFIG" >&2
    exit 1
fi

echo "💾 Saving exported variables to: $CONFIG" >&2

# System variables to skip (don't save these)
SKIP_VARS="PATH|HOME|USER|SHELL|PWD|OLDPWD|SHLVL|_|CONFIG|BASH.*|IFS|OPTIND|PPID|UID|EUID|GROUPS|HOSTNAME|TERM|LANG|LC_.*|ACTION_DIR|SCRIPT_DIR|GITHUB.*|LOG_.*|RED|GREEN|YELLOW|BLUE|NC"

# Count how many variables we save
SAVED_COUNT=0

# Inline set_env_var function (no external dependency)
set_env_var() {
    local env_file="$1"
    local key="$2"
    local value="$3"

    # Create file if it doesn't exist
    touch "$env_file"

    # Check if key exists
    if grep -q "^${key}=" "$env_file" 2>/dev/null; then
        # Update existing value (use | as delimiter to handle / in values)
        sed -i.bak "s|^${key}=.*|${key}=${value}|" "$env_file"
        rm -f "${env_file}.bak"
    else
        # Add new value
        echo "${key}=${value}" >> "$env_file"
    fi
}

# Export all current variables back to config
export -p | while read -r line; do
    # Parse: declare -x VAR="value" or declare -x VAR=value
    if [[ "$line" =~ ^declare\ -x\ ([A-Za-z_][A-Za-z0-9_]*)= ]]; then
        var_name="${BASH_REMATCH[1]}"

        # Skip system variables
        if [[ ! "$var_name" =~ ^($SKIP_VARS)$ ]]; then
            var_value="${!var_name}"

            # Update config using inline function
            set_env_var "$CONFIG" "$var_name" "$var_value" 2>/dev/null

            SAVED_COUNT=$((SAVED_COUNT + 1))
        fi
    fi
done

echo "✅ Saved $SAVED_COUNT variables to $CONFIG" >&2

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
} || true  # Never fail the action due to banner issues

exit 0
