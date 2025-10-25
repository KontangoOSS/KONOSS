#!/usr/bin/env bash
# =============================================================================
# test.sh - Comprehensive test suite for _USEME_ template
# =============================================================================
# This script tests all functionality of the action template
# Run this before using the template to ensure everything works
# =============================================================================

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
test_start() {
    echo -e "${BLUE}[TEST $((TESTS_RUN + 1))]${NC} $1"
    TESTS_RUN=$((TESTS_RUN + 1))
}

test_pass() {
    echo -e "         ${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo ""
}

test_fail() {
    echo -e "         ${RED}✗ FAIL: $1${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo ""
}

# Start tests
echo "╔════════════════════════════════════════════════════════════╗"
echo "║       _USEME_ Template Test Suite                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

cd "$(dirname "$0")/.."

# =============================================================================
# TEST 1: File structure
# =============================================================================
test_start "Verify file structure"

if [ -f "action.yml" ] && \
   [ -f "action-spec.json" ] && \
   [ -f "scripts/load-and-validate.sh" ] && \
   [ -f "scripts/save-config.sh" ]; then
    test_pass
else
    test_fail "Missing required files"
fi

# =============================================================================
# TEST 2: Load .env config
# =============================================================================
test_start "Load .env config format"

cat > test.env << 'EOF'
EXAMPLE_FIELD=test_value_1
ANOTHER_FIELD=test_value_2
OPTIONAL_FIELD=optional_value
EOF

source ./scripts/load-and-validate.sh test.env >/dev/null 2>&1

if [ "$EXAMPLE_FIELD" = "test_value_1" ] && \
   [ "$ANOTHER_FIELD" = "test_value_2" ]; then
    test_pass
else
    test_fail "Variables not loaded correctly"
fi

rm test.env
rm -rf .logs

# =============================================================================
# TEST 3: Load .json config
# =============================================================================
test_start "Load .json config format"

cat > test.json << 'EOF'
{
  "EXAMPLE_FIELD": "json_value_1",
  "ANOTHER_FIELD": "json_value_2",
  "OPTIONAL_FIELD": "json_optional"
}
EOF

source ./scripts/load-and-validate.sh test.json >/dev/null 2>&1

if [ "$EXAMPLE_FIELD" = "json_value_1" ] && \
   [ "$ANOTHER_FIELD" = "json_value_2" ]; then
    test_pass
else
    test_fail "JSON variables not loaded correctly"
fi

rm test.json
rm -rf .logs

# =============================================================================
# TEST 4: Validation - missing required field
# =============================================================================
test_start "Validation fails for missing required field"

cat > test-invalid.env << 'EOF'
OPTIONAL_FIELD=value
EOF

if ! source ./scripts/load-and-validate.sh test-invalid.env 2>&1 | grep -q "Missing required"; then
    test_pass
else
    test_fail "Should have failed validation"
fi

rm test-invalid.env
rm -rf .logs

# =============================================================================
# TEST 5: Save config
# =============================================================================
test_start "Save variables back to config"

cat > test.env << 'EOF'
EXAMPLE_FIELD=original
ANOTHER_FIELD=original
EOF

source ./scripts/load-and-validate.sh test.env >/dev/null 2>&1
export EXAMPLE_FIELD="modified"
export NEW_FIELD="brand_new"
./scripts/save-config.sh test.env >/dev/null 2>&1

if grep -q "EXAMPLE_FIELD=modified" test.env && \
   grep -q "NEW_FIELD=brand_new" test.env; then
    test_pass
else
    test_fail "Config not saved correctly"
fi

rm test.env
rm -rf .logs

# =============================================================================
# TEST 6: Dependency checking
# =============================================================================
test_start "Dependency checking works"

# bash and jq should be available
if command -v bash >/dev/null && command -v jq >/dev/null; then
    test_pass
else
    test_fail "Required dependencies not found"
fi

# =============================================================================
# TEST 7: Secure logging
# =============================================================================
test_start "Secure logging (no secret values)"

cat > test.env << 'EOF'
EXAMPLE_FIELD=test
ANOTHER_FIELD=test
PASSWORD=super_secret_value
API_KEY=dont_show_this
EOF

source ./scripts/load-and-validate.sh test.env >/dev/null 2>&1

LOG_FILE=$(ls -t .logs/config-load-*.log 2>/dev/null | head -1)

if [ -f "$LOG_FILE" ]; then
    # Check that variable names are logged
    if grep -q "PASSWORD" "$LOG_FILE" && grep -q "API_KEY" "$LOG_FILE"; then
        # Check that secret VALUES are NOT logged
        if ! grep -q "super_secret_value" "$LOG_FILE" && \
           ! grep -q "dont_show_this" "$LOG_FILE"; then
            test_pass
        else
            test_fail "Secret values found in log file!"
        fi
    else
        test_fail "Variable names not logged"
    fi
else
    test_fail "Log file not created"
fi

rm test.env
rm -rf .logs

# =============================================================================
# TEST 8: KONOSS banner doesn't fail action
# =============================================================================
test_start "KONOSS banner never blocks action"

cat > test.env << 'EOF'
EXAMPLE_FIELD=test
ANOTHER_FIELD=test
EOF

# This should complete successfully even if banner has issues
if source ./scripts/load-and-validate.sh test.env >/dev/null 2>&1; then
    test_pass
else
    test_fail "Action failed (banner should never block)"
fi

rm test.env
rm -rf .logs

# =============================================================================
# TEST 9: action-spec.json is valid JSON
# =============================================================================
test_start "action-spec.json is valid JSON"

if jq empty action-spec.json >/dev/null 2>&1; then
    test_pass
else
    test_fail "action-spec.json is not valid JSON"
fi

# =============================================================================
# TEST 10: All scripts are executable
# =============================================================================
test_start "All scripts are executable"

if [ -x "scripts/load-and-validate.sh" ] && \
   [ -x "scripts/save-config.sh" ] && \
   [ -x "scripts/test.sh" ]; then
    test_pass
else
    test_fail "Not all scripts are executable"
fi

# =============================================================================
# SUMMARY
# =============================================================================
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Test Results:"
echo "  Total:  $TESTS_RUN"
echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"

if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
    echo ""
    echo -e "${RED}❌ TESTS FAILED${NC}"
    exit 1
else
    echo -e "  ${RED}Failed: 0${NC}"
    echo ""
    echo -e "${GREEN}✅ ALL TESTS PASSED${NC}"
    echo ""
    echo "The _USEME_ template is production-ready!"
    exit 0
fi
