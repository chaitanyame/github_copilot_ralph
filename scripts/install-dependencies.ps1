# install-dependencies.ps1 - Auto-install missing dependencies for Ralph
# Part of Agent Harness Framework

[CmdletBinding()]
param(
    [Alias("y", "yes")]
    [switch]$Auto,
    [switch]$SkipOptional,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# ==============================================================================
# Logging Functions
# ==============================================================================
function Write-Log {
    param([string]$Message, [string]$Level = "Info")
    
    $color = switch ($Level) {
        "Success" { "Green" }
        "Error"   { "Red" }
        "Warning" { "Yellow" }
        default   { "Cyan" }
    }
    
    $prefix = switch ($Level) {
        "Success" { "✓" }
        "Error"   { "✗" }
        "Warning" { "⚠" }
        default   { "•" }
    }
    
    Write-Host "[installer] $prefix $Message" -ForegroundColor $color
}

# ==============================================================================
# Package Manager Detection
# ==============================================================================
function Get-PackageManager {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        return "winget"
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        return "choco"
    } elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
        return "scoop"
    } else {
        return "unknown"
    }
}

# ==============================================================================
# Prompt for Permission
# ==============================================================================
function Request-InstallPermission {
    param(
        [string]$ToolName,
        [bool]$AutoInstall = $false
    )
    
    if ($AutoInstall) {
        return $true
    }
    
    Write-Host ""
    $response = Read-Host "Install $ToolName? [Y/n]"
    
    if ($response -match "^[nN]") {
        return $false
    }
    
    return $true
}

# ==============================================================================
# Install GitHub CLI
# ==============================================================================
function Install-GitHubCLI {
    param(
        [string]$PackageManager,
        [bool]$AutoInstall = $false
    )
    
    Write-Log "GitHub CLI (gh) is required for autonomous mode"
    
    if (-not (Request-InstallPermission -ToolName "GitHub CLI (gh)" -AutoInstall $AutoInstall)) {
        Write-Log "Skipping gh installation" -Level Warning
        return $false
    }
    
    Write-Log "Installing GitHub CLI..."
    
    switch ($PackageManager) {
        "winget" {
            winget install --id GitHub.cli -e --accept-source-agreements --accept-package-agreements
        }
        "choco" {
            choco install gh -y
        }
        "scoop" {
            scoop install gh
        }
        default {
            Write-Log "No package manager found. Please install gh manually:" -Level Error
            Write-Log "  https://cli.github.com/" -Level Error
            return $false
        }
    }
    
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    Write-Log "GitHub CLI installed" -Level Success
    return $true
}

# ==============================================================================
# Install GitHub Copilot CLI Extension
# ==============================================================================
function Install-GitHubCopilotCLI {
    param(
        [bool]$AutoInstall = $false
    )
    
    Write-Log "GitHub Copilot CLI extension is required for autonomous mode"
    
    if (-not (Request-InstallPermission -ToolName "GitHub Copilot CLI extension" -AutoInstall $AutoInstall)) {
        Write-Log "Skipping gh copilot installation" -Level Warning
        return $false
    }
    
    Write-Log "Installing GitHub Copilot CLI extension..."
    
    # Check if gh is authenticated
    try {
        $null = gh auth status 2>&1
    } catch {
        Write-Log "GitHub CLI not authenticated. Running 'gh auth login'..." -Level Warning
        gh auth login
    }
    
    gh extension install github/gh-copilot
    
    Write-Log "GitHub Copilot CLI extension installed" -Level Success
    return $true
}

# ==============================================================================
# Install jq
# ==============================================================================
function Install-Jq {
    param(
        [string]$PackageManager,
        [bool]$AutoInstall = $false
    )
    
    Write-Log "jq is required for JSON parsing"
    
    if (-not (Request-InstallPermission -ToolName "jq" -AutoInstall $AutoInstall)) {
        Write-Log "Skipping jq installation" -Level Warning
        return $false
    }
    
    Write-Log "Installing jq..."
    
    switch ($PackageManager) {
        "winget" {
            winget install --id jqlang.jq -e --accept-source-agreements --accept-package-agreements
        }
        "choco" {
            choco install jq -y
        }
        "scoop" {
            scoop install jq
        }
        default {
            Write-Log "No package manager found. Please install jq manually:" -Level Error
            Write-Log "  https://jqlang.github.io/jq/" -Level Error
            return $false
        }
    }
    
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    Write-Log "jq installed" -Level Success
    return $true
}

# ==============================================================================
# Install Node.js (optional)
# ==============================================================================
function Install-NodeJS {
    param(
        [string]$PackageManager,
        [bool]$AutoInstall = $false
    )
    
    Write-Log "Node.js is optional but recommended for Playwright tests"
    
    if (-not (Request-InstallPermission -ToolName "Node.js" -AutoInstall $AutoInstall)) {
        Write-Log "Skipping Node.js installation" -Level Warning
        return $false
    }
    
    Write-Log "Installing Node.js..."
    
    switch ($PackageManager) {
        "winget" {
            winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements
        }
        "choco" {
            choco install nodejs-lts -y
        }
        "scoop" {
            scoop install nodejs-lts
        }
        default {
            Write-Log "No package manager found. Please install Node.js manually:" -Level Error
            Write-Log "  https://nodejs.org/" -Level Error
            return $false
        }
    }
    
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    Write-Log "Node.js installed" -Level Success
    return $true
}

# ==============================================================================
# Check and Install All Dependencies
# ==============================================================================
function Install-AllDependencies {
    param(
        [bool]$AutoInstall = $false,
        [bool]$SkipOptionalDeps = $false
    )
    
    Write-Log "Detecting package manager..."
    $pkgManager = Get-PackageManager
    Write-Log "Found package manager: $pkgManager"
    
    Write-Host ""
    Write-Log "Checking required dependencies..."
    Write-Host ""
    
    $failed = $false
    
    # Check gh CLI
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        if (-not (Install-GitHubCLI -PackageManager $pkgManager -AutoInstall $AutoInstall)) {
            $failed = $true
        }
    } else {
        Write-Log "GitHub CLI (gh) already installed" -Level Success
    }
    
    # Check gh copilot extension
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        try {
            $null = gh copilot --version 2>&1
            Write-Log "GitHub Copilot CLI extension already installed" -Level Success
        } catch {
            if (-not (Install-GitHubCopilotCLI -AutoInstall $AutoInstall)) {
                $failed = $true
            }
        }
    }
    
    # Check jq
    if (-not (Get-Command jq -ErrorAction SilentlyContinue)) {
        if (-not (Install-Jq -PackageManager $pkgManager -AutoInstall $AutoInstall)) {
            $failed = $true
        }
    } else {
        Write-Log "jq already installed" -Level Success
    }
    
    # Check Node.js (optional)
    if (-not $SkipOptionalDeps) {
        if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
            Install-NodeJS -PackageManager $pkgManager -AutoInstall $AutoInstall | Out-Null
        } else {
            Write-Log "Node.js already installed" -Level Success
        }
    }
    
    Write-Host ""
    
    if ($failed) {
        Write-Log "Some required dependencies could not be installed" -Level Error
        return $false
    }
    
    Write-Log "All required dependencies are installed" -Level Success
    return $true
}

# ==============================================================================
# Main Entry Point
# ==============================================================================

if ($Help) {
    @"
Usage: .\install-dependencies.ps1 [OPTIONS]

OPTIONS:
    -Auto, -y, -yes        Auto-install without prompting
    -SkipOptional          Skip optional dependencies (Node.js)
    -Help                  Show this help

EXAMPLES:
    .\install-dependencies.ps1
    .\install-dependencies.ps1 -Auto
    .\install-dependencies.ps1 -SkipOptional
"@
    exit 0
}

$result = Install-AllDependencies -AutoInstall $Auto.IsPresent -SkipOptionalDeps $SkipOptional.IsPresent

if (-not $result) {
    exit 1
}
