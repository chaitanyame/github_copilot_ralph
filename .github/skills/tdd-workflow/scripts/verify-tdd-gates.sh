#!/bin/bash
# verify-tdd-gates.sh - Validates TDD compliance for features
# Usage: ./verify-tdd-gates.sh [feature-id]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FEATURE_LIST="$PROJECT_ROOT/memory/feature_list.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 TDD Gate Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -f "$FEATURE_LIST" ]; then
    echo -e "${RED}❌ Feature list not found: $FEATURE_LIST${NC}"
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠ jq not installed, using basic parsing${NC}"
    echo "Install jq for better validation"
    exit 0
fi

# Get features
FEATURES=$(jq -r '.features[] | @base64' "$FEATURE_LIST" 2>/dev/null || echo "")

if [ -z "$FEATURES" ]; then
    echo -e "${YELLOW}⚠ No features found in feature list${NC}"
    exit 0
fi

GATE1_VIOLATIONS=0
GATE2_VIOLATIONS=0
TOTAL=0

for row in $FEATURES; do
    _jq() {
        echo "$row" | base64 --decode | jq -r "${1}"
    }
    
    ID=$(_jq '.id')
    NAME=$(_jq '.name')
    PASSES=$(_jq '.passes')
    TEST_FILE=$(_jq '.test_file // empty')
    TEST_FAILS_BEFORE=$(_jq '.test_fails_before // false')
    TEST_PASSES_AFTER=$(_jq '.test_passes_after // false')
    
    TOTAL=$((TOTAL + 1))
    
    echo ""
    echo "Feature $ID: $NAME"
    
    # Gate 1: Check if test exists for features being worked on
    if [ "$PASSES" = "false" ]; then
        if [ -z "$TEST_FILE" ]; then
            echo -e "  ${YELLOW}⚠ Gate 1: No test file specified yet${NC}"
        elif [ "$TEST_FAILS_BEFORE" = "false" ]; then
            echo -e "  ${RED}❌ Gate 1 VIOLATION: test_fails_before not set${NC}"
            GATE1_VIOLATIONS=$((GATE1_VIOLATIONS + 1))
        else
            echo -e "  ${GREEN}✓ Gate 1: Test exists and failed before implementation${NC}"
        fi
    fi
    
    # Gate 2: Check if completed features have test verification
    if [ "$PASSES" = "true" ]; then
        if [ "$TEST_PASSES_AFTER" = "false" ]; then
            echo -e "  ${RED}❌ Gate 2 VIOLATION: passes=true but test_passes_after=false${NC}"
            GATE2_VIOLATIONS=$((GATE2_VIOLATIONS + 1))
        else
            echo -e "  ${GREEN}✓ Gate 2: Test verified passing${NC}"
        fi
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: $TOTAL features checked"

if [ $GATE1_VIOLATIONS -gt 0 ] || [ $GATE2_VIOLATIONS -gt 0 ]; then
    echo -e "${RED}❌ Gate 1 Violations: $GATE1_VIOLATIONS${NC}"
    echo -e "${RED}❌ Gate 2 Violations: $GATE2_VIOLATIONS${NC}"
    exit 1
else
    echo -e "${GREEN}✓ All TDD gates passed${NC}"
    exit 0
fi
