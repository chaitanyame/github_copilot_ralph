# Security layer for autonomous agent execution (PowerShell)
# Implements 3-layer defense: allowlist, deny list, and validation

# ==============================================================================
# LAYER 1: ALLOWLIST - Only these commands are permitted
# ==============================================================================
$Script:ALLOWED_COMMANDS = @(
    "Get-ChildItem", "ls", "dir", "cat", "Get-Content", "Select-String", "grep"
    "git", "gh"
    "npm", "npx", "node", "pnpm", "yarn"
    "New-Item", "mkdir", "Copy-Item", "cp", "Move-Item", "mv"
    "playwright", "jest", "vitest"
    "curl", "Invoke-WebRequest", "wget"
    "python", "pip"
    "Write-Host", "echo", "Get-Location", "pwd"
)

# ==============================================================================
# LAYER 2: DENY LIST - Never allow these patterns
# ==============================================================================
$Script:DENIED_PATTERNS = @(
    "Remove-Item.*-Recurse.*-Force"
    "rm.*-rf"
    "git push --force"
    "git push -f"
    "Invoke-Expression"
    "iex"
    "Invoke-Command.*-ScriptBlock"
    "Start-Process.*-Verb RunAs"  # Elevation
    "Format-Volume"
    "Clear-Disk"
)

# ==============================================================================
# LAYER 3: DANGEROUS FLAGS
# ==============================================================================
$Script:DANGEROUS_FLAGS = @(
    "-Force"
    "-Recurse.*-Force"
    "--force"
    "-f"
)

# ==============================================================================
# Validate a single command
# ==============================================================================
function Test-SingleCommand {
    param(
        [string]$Command
    )
    
    # Remove leading/trailing whitespace
    $Command = $Command.Trim()
    
    # Skip empty commands or comments
    if ([string]::IsNullOrWhiteSpace($Command) -or $Command.StartsWith("#")) {
        return $true
    }
    
    # Extract base command (first word)
    $BaseCommand = ($Command -split '\s+')[0]
    
    # Check deny list first (highest priority)
    foreach ($pattern in $Script:DENIED_PATTERNS) {
        if ($Command -match $pattern) {
            Write-Error "ERROR: Denied pattern detected: $pattern"
            Write-Error "Command: $Command"
            return $false
        }
    }
    
    # Check if base command is in allowlist
    $allowed = $false
    foreach ($allowedCmd in $Script:ALLOWED_COMMANDS) {
        if ($BaseCommand -eq $allowedCmd) {
            $allowed = $true
            break
        }
    }
    
    if (-not $allowed) {
        Write-Error "ERROR: Command not in allowlist: $BaseCommand"
        Write-Error "Command: $Command"
        Write-Error "Allowed commands: $($Script:ALLOWED_COMMANDS -join ', ')"
        return $false
    }
    
    # Check for dangerous patterns (context-aware)
    if ($BaseCommand -in @("Remove-Item", "rm") -and $Command -match "-Recurse.*-Force|rm.*-rf") {
        # Only allow for specific safe patterns
        if ($Command -notmatch "node_modules|\.git") {
            Write-Error "ERROR: Dangerous Remove-Item -Recurse -Force usage"
            Write-Error "Command: $Command"
            return $false
        }
    }
    
    if ($BaseCommand -eq "git" -and $Command -match "push.*(--force|-f)") {
        Write-Error "ERROR: git push --force is not allowed"
        Write-Error "Command: $Command"
        return $false
    }
    
    return $true
}

# ==============================================================================
# Main validation function - validates full command string
# ==============================================================================
function Test-BashCommand {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FullCommand
    )
    
    # Split by common separators: && || ; |
    $commands = $FullCommand -split '[;&|]{1,2}'
    
    foreach ($cmd in $commands) {
        if (-not (Test-SingleCommand -Command $cmd)) {
            return $false
        }
    }
    
    return $true
}

# ==============================================================================
# Export function for use in other scripts
# ==============================================================================
Export-ModuleMember -Function Test-BashCommand

# ==============================================================================
# If script is executed directly, validate input
# ==============================================================================
if ($MyInvocation.InvocationName -ne '.') {
    if ($args.Count -eq 0) {
        Write-Host "Usage: .\security.ps1 '<command to validate>'"
        Write-Host "Example: .\security.ps1 'git status && npm test'"
        exit 1
    }
    
    if (Test-BashCommand -FullCommand $args[0]) {
        Write-Host "✓ Command validated successfully" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "✗ Command validation failed" -ForegroundColor Red
        exit 1
    }
}
