#!/bin/bash
# install-dependencies.sh - Auto-install missing dependencies for Ralph
# Part of Agent Harness Framework

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[installer]${NC} $*"; }
log_success() { echo -e "${GREEN}[installer]${NC} ✓ $*"; }
log_error() { echo -e "${RED}[installer]${NC} ✗ $*"; }
log_warning() { echo -e "${YELLOW}[installer]${NC} ⚠ $*"; }

# ==============================================================================
# Package Manager Detection
# ==============================================================================
detect_package_manager() {
    if command -v brew &> /dev/null; then
        echo "brew"
    elif command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v apk &> /dev/null; then
        echo "apk"
    elif command -v winget &> /dev/null; then
        echo "winget"
    elif command -v choco &> /dev/null; then
        echo "choco"
    elif command -v scoop &> /dev/null; then
        echo "scoop"
    else
        echo "unknown"
    fi
}

# ==============================================================================
# Prompt for Permission
# ==============================================================================
prompt_install() {
    local tool_name="$1"
    local auto_install="${2:-false}"
    
    if [[ "$auto_install" == "true" ]]; then
        return 0
    fi
    
    echo ""
    read -p "$(echo -e "${YELLOW}Install $tool_name? [Y/n]:${NC} ")" response
    case "$response" in
        [nN][oO]|[nN])
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

# ==============================================================================
# Install GitHub CLI
# ==============================================================================
install_gh() {
    local pkg_manager="$1"
    local auto_install="${2:-false}"
    
    log "GitHub CLI (gh) is required for autonomous mode"
    
    if ! prompt_install "GitHub CLI (gh)" "$auto_install"; then
        log_warning "Skipping gh installation"
        return 1
    fi
    
    log "Installing GitHub CLI..."
    
    case "$pkg_manager" in
        brew)
            brew install gh
            ;;
        apt)
            # Add GitHub's official repository
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update
            sudo apt install gh -y
            ;;
        dnf|yum)
            sudo dnf install gh -y || sudo yum install gh -y
            ;;
        pacman)
            sudo pacman -S github-cli --noconfirm
            ;;
        apk)
            apk add github-cli
            ;;
        winget)
            winget install --id GitHub.cli -e --accept-source-agreements --accept-package-agreements
            ;;
        choco)
            choco install gh -y
            ;;
        scoop)
            scoop install gh
            ;;
        *)
            log_error "Unknown package manager. Please install gh manually:"
            log_error "  https://cli.github.com/"
            return 1
            ;;
    esac
    
    log_success "GitHub CLI installed"
    return 0
}

# ==============================================================================
# Install GitHub Copilot CLI Extension
# ==============================================================================
install_gh_copilot() {
    local auto_install="${1:-false}"
    
    log "GitHub Copilot CLI extension is required for autonomous mode"
    
    if ! prompt_install "GitHub Copilot CLI extension" "$auto_install"; then
        log_warning "Skipping gh copilot installation"
        return 1
    fi
    
    log "Installing GitHub Copilot CLI extension..."
    
    # Check if gh is authenticated
    if ! gh auth status &> /dev/null; then
        log_warning "GitHub CLI not authenticated. Running 'gh auth login'..."
        gh auth login
    fi
    
    gh extension install github/gh-copilot
    
    log_success "GitHub Copilot CLI extension installed"
    return 0
}

# ==============================================================================
# Install jq
# ==============================================================================
install_jq() {
    local pkg_manager="$1"
    local auto_install="${2:-false}"
    
    log "jq is required for JSON parsing"
    
    if ! prompt_install "jq" "$auto_install"; then
        log_warning "Skipping jq installation"
        return 1
    fi
    
    log "Installing jq..."
    
    case "$pkg_manager" in
        brew)
            brew install jq
            ;;
        apt)
            sudo apt update && sudo apt install jq -y
            ;;
        dnf|yum)
            sudo dnf install jq -y || sudo yum install jq -y
            ;;
        pacman)
            sudo pacman -S jq --noconfirm
            ;;
        apk)
            apk add jq
            ;;
        winget)
            winget install --id jqlang.jq -e --accept-source-agreements --accept-package-agreements
            ;;
        choco)
            choco install jq -y
            ;;
        scoop)
            scoop install jq
            ;;
        *)
            log_error "Unknown package manager. Please install jq manually:"
            log_error "  https://jqlang.github.io/jq/"
            return 1
            ;;
    esac
    
    log_success "jq installed"
    return 0
}

# ==============================================================================
# Install Node.js (optional)
# ==============================================================================
install_node() {
    local pkg_manager="$1"
    local auto_install="${2:-false}"
    
    log "Node.js is optional but recommended for Playwright tests"
    
    if ! prompt_install "Node.js" "$auto_install"; then
        log_warning "Skipping Node.js installation"
        return 1
    fi
    
    log "Installing Node.js..."
    
    case "$pkg_manager" in
        brew)
            brew install node
            ;;
        apt)
            # Install via NodeSource for latest LTS
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt install nodejs -y
            ;;
        dnf|yum)
            curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
            sudo dnf install nodejs -y || sudo yum install nodejs -y
            ;;
        pacman)
            sudo pacman -S nodejs npm --noconfirm
            ;;
        apk)
            apk add nodejs npm
            ;;
        winget)
            winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements
            ;;
        choco)
            choco install nodejs-lts -y
            ;;
        scoop)
            scoop install nodejs-lts
            ;;
        *)
            log_error "Unknown package manager. Please install Node.js manually:"
            log_error "  https://nodejs.org/"
            return 1
            ;;
    esac
    
    log_success "Node.js installed"
    return 0
}

# ==============================================================================
# Check and Install All Dependencies
# ==============================================================================
check_and_install_all() {
    local auto_install="${1:-false}"
    local skip_optional="${2:-false}"
    local failed=0
    
    log "Detecting package manager..."
    local pkg_manager=$(detect_package_manager)
    log "Found package manager: $pkg_manager"
    
    echo ""
    log "Checking required dependencies..."
    echo ""
    
    # Check gh CLI
    if ! command -v gh &> /dev/null; then
        if ! install_gh "$pkg_manager" "$auto_install"; then
            failed=1
        fi
    else
        log_success "GitHub CLI (gh) already installed"
    fi
    
    # Check gh copilot extension
    if command -v gh &> /dev/null; then
        if ! gh copilot --version &> /dev/null 2>&1; then
            if ! install_gh_copilot "$auto_install"; then
                failed=1
            fi
        else
            log_success "GitHub Copilot CLI extension already installed"
        fi
    fi
    
    # Check jq
    if ! command -v jq &> /dev/null; then
        if ! install_jq "$pkg_manager" "$auto_install"; then
            failed=1
        fi
    else
        log_success "jq already installed"
    fi
    
    # Check Node.js (optional)
    if [[ "$skip_optional" != "true" ]]; then
        if ! command -v node &> /dev/null; then
            install_node "$pkg_manager" "$auto_install" || true
        else
            log_success "Node.js already installed"
        fi
    fi
    
    echo ""
    
    if [[ $failed -eq 1 ]]; then
        log_error "Some required dependencies could not be installed"
        return 1
    fi
    
    log_success "All required dependencies are installed"
    return 0
}

# ==============================================================================
# Main Entry Point (when run directly)
# ==============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    AUTO_INSTALL=false
    SKIP_OPTIONAL=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto|--yes|-y)
                AUTO_INSTALL=true
                shift
                ;;
            --skip-optional)
                SKIP_OPTIONAL=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "OPTIONS:"
                echo "  --auto, --yes, -y    Auto-install without prompting"
                echo "  --skip-optional      Skip optional dependencies (Node.js)"
                echo "  -h, --help           Show this help"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    check_and_install_all "$AUTO_INSTALL" "$SKIP_OPTIONAL"
fi
