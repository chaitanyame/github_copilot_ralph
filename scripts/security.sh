#!/bin/bash
# Security layer for autonomous agent execution
# Implements 3-layer defense: allowlist, deny list, and validation

# ==============================================================================
# LAYER 1: ALLOWLIST - Only these commands are permitted
# ==============================================================================
ALLOWED_COMMANDS=(
    "ls" "cat" "grep" "find" "head" "tail" "wc" "echo" "pwd"
    "git" "gh"
    "npm" "npx" "node" "pnpm" "yarn"
    "mkdir" "touch" "chmod" "cp" "mv"
    "playwright" "jest" "vitest"
    "curl" "wget"
    "jq" "sed" "awk"
    "python" "python3" "pip" "pip3"
)

# ==============================================================================
# LAYER 2: DENY LIST - Never allow these patterns
# ==============================================================================
DENIED_PATTERNS=(
    "rm -rf"
    "rm -fr"
    "git push --force"
    "git push -f"
    ":(){ :|:& };:"  # Fork bomb
    "dd if="
    "> /dev/sd"
    "mkfs"
    "fdisk"
    "curl.*|.*sh"    # Pipe to shell
    "wget.*|.*sh"
)

# ==============================================================================
# LAYER 3: DANGEROUS FLAGS - Reject commands with these flags
# ==============================================================================
DANGEROUS_FLAGS=(
    "--force"
    "-f" # When used with rm or git push
    "--no-preserve-root"
    "--delete-excluded"
)

# ==============================================================================
# Validate a single command
# ==============================================================================
validate_command() {
    local cmd="$1"
    
    # Remove leading/trailing whitespace
    cmd=$(echo "$cmd" | xargs)
    
    # Skip empty commands or comments
    [[ -z "$cmd" ]] && return 0
    [[ "$cmd" =~ ^# ]] && return 0
    
    # Extract base command (first word)
    local base_cmd=$(echo "$cmd" | awk '{print $1}')
    
    # Check deny list first (highest priority)
    for pattern in "${DENIED_PATTERNS[@]}"; do
        if [[ "$cmd" =~ $pattern ]]; then
            echo "ERROR: Denied pattern detected: $pattern"
            echo "Command: $cmd"
            return 1
        fi
    done
    
    # Check if base command is in allowlist
    local allowed=0
    for allowed_cmd in "${ALLOWED_COMMANDS[@]}"; do
        if [[ "$base_cmd" == "$allowed_cmd" ]]; then
            allowed=1
            break
        fi
    done
    
    if [[ $allowed -eq 0 ]]; then
        echo "ERROR: Command not in allowlist: $base_cmd"
        echo "Command: $cmd"
        echo "Allowed commands: ${ALLOWED_COMMANDS[*]}"
        return 1
    fi
    
    # Check for dangerous flags (context-aware)
    if [[ "$base_cmd" == "rm" ]] && [[ "$cmd" =~ -[rf] ]]; then
        # Only allow rm -rf for specific safe patterns
        if [[ ! "$cmd" =~ node_modules ]] && [[ ! "$cmd" =~ \.git ]]; then
            echo "ERROR: Dangerous rm -rf usage"
            echo "Command: $cmd"
            return 1
        fi
    fi
    
    if [[ "$base_cmd" == "git" ]] && [[ "$cmd" =~ push.*--force ]]; then
        echo "ERROR: git push --force is not allowed"
        echo "Command: $cmd"
        return 1
    fi
    
    return 0
}

# ==============================================================================
# Main validation function - validates full command string
# ==============================================================================
validate_bash_command() {
    local full_command="$1"
    
    # Split by common separators: && || ; |
    IFS=$'\n'
    local commands=($(echo "$full_command" | sed 's/&&/\n/g; s/||/\n/g; s/;/\n/g; s/|/\n/g'))
    unset IFS
    
    for cmd in "${commands[@]}"; do
        if ! validate_command "$cmd"; then
            return 1
        fi
    done
    
    return 0
}

# ==============================================================================
# If script is executed directly (not sourced), validate input
# ==============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 '<command to validate>'"
        echo "Example: $0 'git status && npm test'"
        exit 1
    fi
    
    if validate_bash_command "$1"; then
        echo "✓ Command validated successfully"
        exit 0
    else
        echo "✗ Command validation failed"
        exit 1
    fi
fi
