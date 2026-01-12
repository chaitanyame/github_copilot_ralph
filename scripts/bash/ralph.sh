#!/bin/bash
# Ralph - Autonomous loop runner for GitHub Copilot CLI
# Implements continuous feature implementation until all features pass

set -euo pipefail

# ==============================================================================
# Configuration
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SECURITY_SCRIPT="$PROJECT_ROOT/scripts/security.sh"

# Source security layer
source "$SECURITY_SCRIPT"

# Default configuration
MAX_ITERATIONS=${MAX_ITERATIONS:-50}
ALLOW_PROFILE=${ALLOW_PROFILE:-"safe"}
FEATURE_LIST="$PROJECT_ROOT/memory/feature_list.json"
PROGRESS_FILE="$PROJECT_ROOT/memory/claude-progress.md"
STATE_FILE="$PROJECT_ROOT/memory/.ralph/state.json"
PROMPT_FILE="$PROJECT_ROOT/prompts/coder-autonomous.txt"
AUTO_CONTINUE_DELAY=${AUTO_CONTINUE_DELAY:-3}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ==============================================================================
# Utility Functions
# ==============================================================================
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} ✓ $*"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} ✗ $*"
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} ⚠ $*"
}

# ==============================================================================
# Dependency Installation Helpers
# ==============================================================================
install_missing_deps() {
    local missing_gh=$1
    local missing_copilot=$2
    local missing_jq=$3
    local missing_node=$4
    local auto=$5
    
    local INSTALL_SCRIPT="$PROJECT_ROOT/scripts/install-dependencies.sh"
    
    if [[ -f "$INSTALL_SCRIPT" ]]; then
        source "$INSTALL_SCRIPT"
        
        local pkg_manager=$(detect_package_manager)
        log "Detected package manager: $pkg_manager"
        echo ""
        
        if [[ $missing_gh -eq 1 ]]; then
            install_gh "$pkg_manager" "$auto"
        fi
        
        if [[ $missing_copilot -eq 1 ]]; then
            install_gh_copilot "$auto"
        fi
        
        if [[ $missing_jq -eq 1 ]]; then
            install_jq "$pkg_manager" "$auto"
        fi
        
        if [[ $missing_node -eq 1 ]] && [[ "$auto" != "true" ]]; then
            echo ""
            read -p "$(echo -e "${YELLOW}Install Node.js (optional, for Playwright tests)? [y/N]:${NC} ")" node_response
            if [[ "$node_response" =~ ^[yY] ]]; then
                install_node "$pkg_manager" "true"
            fi
        fi
    else
        log_error "Install script not found: $INSTALL_SCRIPT"
        exit 1
    fi
}

install_selective() {
    local missing_gh=$1
    local missing_copilot=$2
    local missing_jq=$3
    local missing_node=$4
    
    local INSTALL_SCRIPT="$PROJECT_ROOT/scripts/install-dependencies.sh"
    
    if [[ -f "$INSTALL_SCRIPT" ]]; then
        source "$INSTALL_SCRIPT"
        
        local pkg_manager=$(detect_package_manager)
        log "Detected package manager: $pkg_manager"
        echo ""
        
        if [[ $missing_gh -eq 1 ]]; then
            read -p "$(echo -e "${YELLOW}Install GitHub CLI (gh)? [Y/n]:${NC} ")" response
            if [[ ! "$response" =~ ^[nN] ]]; then
                install_gh "$pkg_manager" "true"
            fi
        fi
        
        if [[ $missing_copilot -eq 1 ]]; then
            read -p "$(echo -e "${YELLOW}Install GitHub Copilot CLI extension? [Y/n]:${NC} ")" response
            if [[ ! "$response" =~ ^[nN] ]]; then
                install_gh_copilot "true"
            fi
        fi
        
        if [[ $missing_jq -eq 1 ]]; then
            read -p "$(echo -e "${YELLOW}Install jq (JSON parser)? [Y/n]:${NC} ")" response
            if [[ ! "$response" =~ ^[nN] ]]; then
                install_jq "$pkg_manager" "true"
            fi
        fi
        
        if [[ $missing_node -eq 1 ]]; then
            read -p "$(echo -e "${YELLOW}Install Node.js (optional, for Playwright tests)? [y/N]:${NC} ")" response
            if [[ "$response" =~ ^[yY] ]]; then
                install_node "$pkg_manager" "true"
            fi
        fi
    else
        log_error "Install script not found: $INSTALL_SCRIPT"
        exit 1
    fi
}

# ==============================================================================
# Prerequisites Check
# ==============================================================================
check_prerequisites() {
    log "Checking prerequisites..."
    
    local INSTALL_SCRIPT="$PROJECT_ROOT/scripts/install-dependencies.sh"
    local missing_gh=0
    local missing_copilot=0
    local missing_jq=0
    local missing_node=0
    
    echo ""
    log "🔍 Checking required dependencies..."
    echo ""
    
    # Check for gh CLI
    if command -v gh &> /dev/null; then
        log_success "GitHub CLI (gh) - installed ✓"
    else
        log_error "GitHub CLI (gh) - NOT FOUND ✗"
        missing_gh=1
    fi
    
    # Check for gh copilot extension
    if command -v gh &> /dev/null && gh copilot --version &> /dev/null 2>&1; then
        log_success "GitHub Copilot CLI - installed ✓"
    else
        log_error "GitHub Copilot CLI - NOT FOUND ✗"
        missing_copilot=1
    fi
    
    # Check for jq
    if command -v jq &> /dev/null; then
        log_success "jq (JSON parser) - installed ✓"
    else
        log_error "jq (JSON parser) - NOT FOUND ✗"
        missing_jq=1
    fi
    
    # Check for Node.js (optional)
    if command -v node &> /dev/null; then
        log_success "Node.js (optional) - installed ✓"
    else
        log_warning "Node.js (optional) - not found (needed for Playwright tests)"
        missing_node=1
    fi
    
    echo ""
    
    # If any required dependencies missing
    if [[ $missing_gh -eq 1 ]] || [[ $missing_copilot -eq 1 ]] || [[ $missing_jq -eq 1 ]]; then
        log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log "⚠️  Some required dependencies are missing"
        log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        if [[ "$AUTO_INSTALL" == "true" ]]; then
            log "Auto-install mode enabled. Installing dependencies..."
            install_missing_deps "$missing_gh" "$missing_copilot" "$missing_jq" "$missing_node" "true"
        elif [[ "$SKIP_INSTALL" == "true" ]]; then
            log_error "Missing dependencies and --skip-install specified"
            log_error "Install manually or run without --skip-install"
            exit 1
        else
            # Interactive prompt for each dependency
            echo -e "${YELLOW}Would you like to install the missing dependencies?${NC}"
            echo ""
            echo "  [Y] Yes, install all missing dependencies"
            echo "  [n] No, exit and install manually"
            echo "  [s] Select which ones to install"
            echo ""
            read -p "$(echo -e "${BLUE}Your choice [Y/n/s]:${NC} ")" response
            
            case "$response" in
                [nN])
                    log_error "Cannot proceed without required dependencies"
                    log "Install manually:"
                    [[ $missing_gh -eq 1 ]] && log "  • gh CLI: https://cli.github.com/"
                    [[ $missing_copilot -eq 1 ]] && log "  • gh copilot: gh extension install github/gh-copilot"
                    [[ $missing_jq -eq 1 ]] && log "  • jq: https://jqlang.github.io/jq/"
                    exit 1
                    ;;
                [sS])
                    # Selective installation
                    install_selective "$missing_gh" "$missing_copilot" "$missing_jq" "$missing_node"
                    ;;
                *)
                    # Install all
                    install_missing_deps "$missing_gh" "$missing_copilot" "$missing_jq" "$missing_node" "false"
                    ;;
            esac
        fi
        
        # Re-verify after installation
        echo ""
        log "Verifying dependencies after installation..."
        local verify_failed=0
        
        if ! command -v gh &> /dev/null; then
            log_error "GitHub CLI (gh) still not available"
            verify_failed=1
        fi
        if command -v gh &> /dev/null && ! gh copilot --version &> /dev/null 2>&1; then
            log_error "GitHub Copilot CLI extension still not available"
            verify_failed=1
        fi
        if ! command -v jq &> /dev/null; then
            log_error "jq still not available"
            verify_failed=1
        fi
        
        if [[ $verify_failed -eq 1 ]]; then
            log_error "Some dependencies failed to install. Please install manually."
            exit 1
        fi
        
        log_success "All required dependencies verified!"
    else
        log_success "All required dependencies are installed!"
    fi
    
    echo ""
    
    # Check for feature list
    if [[ ! -f "$FEATURE_LIST" ]]; then
        log_error "Feature list not found: $FEATURE_LIST"
        exit 1
    fi
    
    # Check for prompt template
    if [[ ! -f "$PROMPT_FILE" ]]; then
        log_error "Prompt template not found: $PROMPT_FILE"
        log_warning "Please create prompts/coder-autonomous.txt"
        exit 1
    fi
    
    log_success "All prerequisites met"
}

# ==============================================================================
# State Management
# ==============================================================================
init_state() {
    mkdir -p "$(dirname "$STATE_FILE")"
    
    if [[ -f "$STATE_FILE" ]]; then
        log "Resuming from previous state"
        ITERATION=$(jq -r '.iteration // 0' "$STATE_FILE")
    else
        log "Initializing new state"
        ITERATION=0
        echo '{
  "iteration": 0,
  "started_at": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
  "last_feature": null
}' > "$STATE_FILE"
    fi
}

update_state() {
    local iteration=$1
    local last_feature=$2
    
    jq --arg iter "$iteration" \
       --arg feature "$last_feature" \
       --arg updated "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
       '.iteration = ($iter | tonumber) | .last_feature = $feature | .updated_at = $updated' \
       "$STATE_FILE" > "$STATE_FILE.tmp"
    mv "$STATE_FILE.tmp" "$STATE_FILE"
}

# ==============================================================================
# Feature Management
# ==============================================================================
get_feature_stats() {
    local total=$(jq '[.features[]] | length' "$FEATURE_LIST")
    local passing=$(jq '[.features[] | select(.passes == true)] | length' "$FEATURE_LIST")
    local failing=$(jq '[.features[] | select(.passes == false)] | length' "$FEATURE_LIST")
    
    echo "$passing/$total passing ($failing remaining)"
}

get_next_feature() {
    # Get first feature with passes: false
    jq -r '.features[] | select(.passes == false) | .id' "$FEATURE_LIST" | head -n 1
}

all_features_passing() {
    local failing=$(jq '[.features[] | select(.passes == false)] | length' "$FEATURE_LIST")
    [[ $failing -eq 0 ]]
}

# ==============================================================================
# Rate Limit Handling
# ==============================================================================
parse_rate_limit_delay() {
    local response="$1"
    
    # Try to extract reset time from response
    # Format: "resets at 2:30pm" or "resets in 5 minutes"
    if echo "$response" | grep -qi "rate limit"; then
        # Default to 60 seconds if can't parse
        local delay=60
        
        # Try to extract minutes
        if echo "$response" | grep -Eqi "resets? in ([0-9]+) minutes?"; then
            delay=$(echo "$response" | grep -Eoi "resets? in ([0-9]+) minutes?" | grep -Eo '[0-9]+')
            delay=$((delay * 60))
        fi
        
        # Clamp to max 1 hour
        if [[ $delay -gt 3600 ]]; then
            delay=3600
        fi
        
        echo "$delay"
    else
        echo "0"
    fi
}

# ==============================================================================
# Git Operations
# ==============================================================================
ensure_clean_state() {
    if ! git diff --quiet || ! git diff --cached --quiet; then
        log_warning "Working tree has uncommitted changes"
        return 1
    fi
    return 0
}

commit_if_needed() {
    if git diff --quiet && git diff --cached --quiet; then
        log "No changes to commit"
        return 0
    fi
    
    local feature_id=$1
    local commit_msg="ralph: Implement feature $feature_id"
    
    git add -A
    git commit -m "$commit_msg"
    log_success "Committed: $commit_msg"
}

# ==============================================================================
# Copilot Execution
# ==============================================================================
run_copilot_iteration() {
    local iteration=$1
    local feature_id=$2
    
    log "Running Copilot for feature: $feature_id"
    
    # Build context prompt
    local context_prompt=$(cat <<EOF
# AUTONOMOUS CODING SESSION - ITERATION $iteration

You are in AUTONOMOUS mode. This is a FRESH context - you have no memory of previous sessions.

## Current Feature
Feature ID: $feature_id

## Context Files to Read
1. memory/feature_list.json - All features and their status
2. memory/claude-progress.md - Notes from previous sessions
3. Feature specification (if exists)

## Your Task
Implement ONLY feature $feature_id following the 10-step autonomous coding process.
See prompts/coder-autonomous.txt for full instructions.

## Output Requirements
After completing the feature, output EXACTLY ONE of:
- FEATURE_DONE - Feature is complete and verified
- FEATURE_BLOCKED: <reason> - Cannot proceed
- COMPLETE - ALL features pass and git is clean

EOF
)
    
    # Run gh copilot with security profile
    local output_file="/tmp/ralph-copilot-output-$iteration.txt"
    
    if gh copilot suggest --target shell "$context_prompt" > "$output_file" 2>&1; then
        log_success "Copilot iteration completed"
        cat "$output_file"
        
        # Check for completion signals
        if grep -q "FEATURE_DONE" "$output_file"; then
            log_success "Feature marked done"
            return 0
        elif grep -q "COMPLETE" "$output_file"; then
            log_success "All features complete!"
            return 2
        elif grep -q "FEATURE_BLOCKED" "$output_file"; then
            log_error "Feature blocked"
            cat "$output_file" | grep "FEATURE_BLOCKED"
            return 1
        fi
    else
        log_error "Copilot execution failed"
        cat "$output_file"
        
        # Check for rate limiting
        if grep -qi "rate limit" "$output_file"; then
            local delay=$(parse_rate_limit_delay "$(cat "$output_file")")
            log_warning "Rate limited. Waiting $delay seconds..."
            sleep "$delay"
            return 3  # Signal to retry
        fi
        
        return 1
    fi
    
    return 0
}

# ==============================================================================
# Main Loop
# ==============================================================================
main_loop() {
    log "Starting autonomous loop (max $MAX_ITERATIONS iterations)"
    log "Feature list: $FEATURE_LIST"
    log "Security profile: $ALLOW_PROFILE"
    
    for ((i=ITERATION; i<MAX_ITERATIONS; i++)); do
        log ""
        log "========================================="
        log "ITERATION $(($i + 1))/$MAX_ITERATIONS"
        log "========================================="
        
        # Get current stats
        local stats=$(get_feature_stats)
        log "Progress: $stats"
        
        # Check if all features pass
        if all_features_passing; then
            log_success "All features passing!"
            
            # Verify git is clean
            if ensure_clean_state; then
                log_success "Git working tree is clean"
                log_success "🎉 AUTONOMOUS SESSION COMPLETE! 🎉"
                exit 0
            else
                log_warning "Working tree has uncommitted changes. Commit manually."
                exit 1
            fi
        fi
        
        # Get next feature
        local next_feature=$(get_next_feature)
        if [[ -z "$next_feature" ]]; then
            log_error "No next feature found but features are still failing"
            exit 1
        fi
        
        log "Next feature: $next_feature"
        
        # Run Copilot
        run_copilot_iteration "$i" "$next_feature"
        local result=$?
        
        # Handle result
        case $result in
            0)  # Feature done
                update_state "$i" "$next_feature"
                commit_if_needed "$next_feature"
                log "Continuing in ${AUTO_CONTINUE_DELAY}s..."
                sleep "$AUTO_CONTINUE_DELAY"
                ;;
            1)  # Error
                log_error "Iteration failed. Stopping."
                update_state "$i" "$next_feature"
                exit 1
                ;;
            2)  # Complete
                log_success "Session complete!"
                exit 0
                ;;
            3)  # Rate limited, retry
                log "Retrying iteration..."
                continue
                ;;
        esac
    done
    
    log_warning "Reached maximum iterations ($MAX_ITERATIONS)"
    log "Progress: $(get_feature_stats)"
    log "Run again to continue or increase MAX_ITERATIONS"
}

# ==============================================================================
# CLI Entry Point
# ==============================================================================
show_usage() {
    cat <<EOF
Usage: ralph.sh [OPTIONS]

Autonomous loop runner for GitHub Copilot CLI

OPTIONS:
    --max-iterations N    Maximum iterations (default: 50)
    --profile PROFILE     Security profile: locked, safe, dev (default: safe)
    --once                Run single iteration (for testing)
    --resume              Resume from saved state
    --reset               Reset state and start fresh
    --auto-install        Auto-install missing dependencies without prompting
    --skip-install        Fail if dependencies missing (never prompt)
    -h, --help            Show this help message

EXAMPLES:
    ./ralph.sh                              # Run with defaults
    ./ralph.sh --max-iterations 100         # Run up to 100 iterations
    ./ralph.sh --profile locked             # Restricted permissions
    ./ralph.sh --once                       # Single iteration
    ./ralph.sh --resume                     # Resume interrupted session
    ./ralph.sh --auto-install               # Auto-install deps and run

EOF
}

# Parse arguments
RUN_ONCE=0
RESET_STATE=0
AUTO_INSTALL=false
SKIP_INSTALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        --profile)
            ALLOW_PROFILE="$2"
            shift 2
            ;;
        --once)
            RUN_ONCE=1
            shift
            ;;
        --resume)
            # State is loaded by init_state
            shift
            ;;
        --reset)
            RESET_STATE=1
            shift
            ;;
        --auto-install)
            AUTO_INSTALL=true
            shift
            ;;
        --skip-install)
            SKIP_INSTALL=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# ==============================================================================
# Main Execution
# ==============================================================================
cd "$PROJECT_ROOT"

check_prerequisites

if [[ $RESET_STATE -eq 1 ]]; then
    log "Resetting state..."
    rm -f "$STATE_FILE"
fi

init_state

if [[ $RUN_ONCE -eq 1 ]]; then
    log "Running single iteration (test mode)"
    MAX_ITERATIONS=$((ITERATION + 1))
fi

main_loop
