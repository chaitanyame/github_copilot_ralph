#!/bin/bash
# context-recovery.sh - Automated context loading for Ralph sessions
# Usage: ./context-recovery.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Ralph Context Recovery"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$PROJECT_ROOT"

# 1. Current branch
echo ""
echo "📌 Current Branch:"
BRANCH=$(git branch --show-current)
echo "   $BRANCH"

# 2. Progress notes summary
echo ""
echo "📝 Progress Notes (last 20 lines):"
if [ -f "memory/claude-progress.md" ]; then
    tail -20 "memory/claude-progress.md" | sed 's/^/   /'
else
    echo "   No progress notes found"
fi

# 3. Feature status
echo ""
echo "📋 Feature Status:"
if [ -f "memory/feature_list.json" ] && command -v jq &> /dev/null; then
    TOTAL=$(jq '.features | length' memory/feature_list.json)
    PASSING=$(jq '[.features[] | select(.passes == true)] | length' memory/feature_list.json)
    echo "   $PASSING / $TOTAL features passing"
    
    echo ""
    echo "   Remaining (passes: false):"
    jq -r '.features[] | select(.passes == false) | "   - F\(.id): \(.name)"' memory/feature_list.json
else
    echo "   Feature list not found or jq not installed"
fi

# 4. Spec context
echo ""
echo "📄 Spec Context:"
SPEC_DIR="specs/$BRANCH"
if [ -d "$SPEC_DIR" ]; then
    if [ -f "$SPEC_DIR/spec.md" ]; then
        echo "   Found: $SPEC_DIR/spec.md"
        head -10 "$SPEC_DIR/spec.md" | sed 's/^/   /'
    fi
else
    echo "   No spec directory for branch: $BRANCH"
fi

# 5. Ralph state
echo ""
echo "🤖 Ralph State:"
if [ -f "memory/.ralph/state.json" ]; then
    cat "memory/.ralph/state.json" | sed 's/^/   /'
else
    echo "   No previous state (fresh start)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Context recovery complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
