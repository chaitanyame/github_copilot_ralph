# Ralph - Autonomous loop runner for GitHub Copilot CLI (PowerShell)
# Implements continuous feature implementation until all features pass

[CmdletBinding()]
param(
    [int]$MaxIterations = 50,
    [ValidateSet("locked", "safe", "dev")]
    [string]$Profile = "safe",
    [switch]$Once,
    [switch]$Resume,
    [switch]$Reset,
    [switch]$Help
)

# ==============================================================================
# Configuration
# ==============================================================================
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item (Join-Path $ScriptDir "..\..")).FullName
$SecurityScript = Join-Path $ProjectRoot "scripts\security.ps1"

# Import security layer
. $SecurityScript

# Paths
$FeatureListPath = Join-Path $ProjectRoot "memory\feature_list.json"
$ProgressFilePath = Join-Path $ProjectRoot "memory\claude-progress.md"
$StateFilePath = Join-Path $ProjectRoot "memory\.ralph\state.json"
$PromptFilePath = Join-Path $ProjectRoot "prompts\coder-autonomous.txt"

# Configuration
$AutoContinueDelay = 3

# ==============================================================================
# Utility Functions
# ==============================================================================
function Write-Log {
    param([string]$Message, [string]$Level = "Info")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
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
    
    Write-Host "[$timestamp] $prefix $Message" -ForegroundColor $color
}

# ==============================================================================
# Prerequisites Check
# ==============================================================================
function Test-Prerequisites {
    Write-Log "Checking prerequisites..."
    
    # Check for gh CLI
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Log "GitHub CLI (gh) not found. Install from https://cli.github.com/" -Level Error
        exit 1
    }
    
    # Check for gh copilot extension
    try {
        $null = gh copilot --version 2>&1
    } catch {
        Write-Log "GitHub Copilot CLI extension not found." -Level Error
        Write-Log "Install with: gh extension install github/gh-copilot" -Level Error
        exit 1
    }
    
    # Check for feature list
    if (-not (Test-Path $FeatureListPath)) {
        Write-Log "Feature list not found: $FeatureListPath" -Level Error
        exit 1
    }
    
    # Check for prompt template
    if (-not (Test-Path $PromptFilePath)) {
        Write-Log "Prompt template not found: $PromptFilePath" -Level Error
        Write-Log "Please create prompts\coder-autonomous.txt" -Level Warning
        exit 1
    }
    
    Write-Log "All prerequisites met" -Level Success
}

# ==============================================================================
# State Management
# ==============================================================================
function Initialize-State {
    $stateDir = Split-Path -Parent $StateFilePath
    if (-not (Test-Path $stateDir)) {
        New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
    }
    
    if (Test-Path $StateFilePath) {
        Write-Log "Resuming from previous state"
        $state = Get-Content $StateFilePath -Raw | ConvertFrom-Json
        return $state.iteration
    } else {
        Write-Log "Initializing new state"
        $state = @{
            iteration = 0
            started_at = (Get-Date -Format "o")
            last_feature = $null
        }
        $state | ConvertTo-Json | Set-Content $StateFilePath
        return 0
    }
}

function Update-State {
    param(
        [int]$Iteration,
        [string]$LastFeature
    )
    
    $state = @{
        iteration = $Iteration
        last_feature = $LastFeature
        updated_at = (Get-Date -Format "o")
    }
    
    if (Test-Path $StateFilePath) {
        $existing = Get-Content $StateFilePath -Raw | ConvertFrom-Json
        if ($existing.started_at) {
            $state.started_at = $existing.started_at
        }
    }
    
    $state | ConvertTo-Json | Set-Content $StateFilePath
}

# ==============================================================================
# Feature Management
# ==============================================================================
function Get-FeatureStats {
    $featureList = Get-Content $FeatureListPath -Raw | ConvertFrom-Json
    $total = $featureList.features.Count
    $passing = ($featureList.features | Where-Object { $_.passes -eq $true }).Count
    $failing = $total - $passing
    
    return "$passing/$total passing ($failing remaining)"
}

function Get-NextFeature {
    $featureList = Get-Content $FeatureListPath -Raw | ConvertFrom-Json
    $nextFeature = $featureList.features | Where-Object { $_.passes -eq $false } | Select-Object -First 1
    return $nextFeature.id
}

function Test-AllFeaturesPassing {
    $featureList = Get-Content $FeatureListPath -Raw | ConvertFrom-Json
    $failing = ($featureList.features | Where-Object { $_.passes -eq $false }).Count
    return $failing -eq 0
}

# ==============================================================================
# Rate Limit Handling
# ==============================================================================
function Get-RateLimitDelay {
    param([string]$Response)
    
    if ($Response -match "rate limit") {
        # Default to 60 seconds if can't parse
        $delay = 60
        
        # Try to extract minutes
        if ($Response -match "resets? in (\d+) minutes?") {
            $minutes = [int]$Matches[1]
            $delay = $minutes * 60
        }
        
        # Clamp to max 1 hour
        if ($delay -gt 3600) {
            $delay = 3600
        }
        
        return $delay
    }
    
    return 0
}

# ==============================================================================
# Git Operations
# ==============================================================================
function Test-CleanState {
    $status = git status --porcelain
    return [string]::IsNullOrWhiteSpace($status)
}

function Invoke-CommitIfNeeded {
    param([string]$FeatureId)
    
    if (Test-CleanState) {
        Write-Log "No changes to commit"
        return
    }
    
    $commitMsg = "ralph: Implement feature $FeatureId"
    git add -A
    git commit -m $commitMsg
    Write-Log "Committed: $commitMsg" -Level Success
}

# ==============================================================================
# Copilot Execution
# ==============================================================================
function Invoke-CopilotIteration {
    param(
        [int]$Iteration,
        [string]$FeatureId
    )
    
    Write-Log "Running Copilot for feature: $FeatureId"
    
    # Build context prompt
    $contextPrompt = @"
# AUTONOMOUS CODING SESSION - ITERATION $Iteration

You are in AUTONOMOUS mode. This is a FRESH context - you have no memory of previous sessions.

## Current Feature
Feature ID: $FeatureId

## Context Files to Read
1. memory/feature_list.json - All features and their status
2. memory/claude-progress.md - Notes from previous sessions
3. Feature specification (if exists)

## Your Task
Implement ONLY feature $FeatureId following the 10-step autonomous coding process.
See prompts/coder-autonomous.txt for full instructions.

## Output Requirements
After completing the feature, output EXACTLY ONE of:
- FEATURE_DONE - Feature is complete and verified
- FEATURE_BLOCKED: <reason> - Cannot proceed
- COMPLETE - ALL features pass and git is clean
"@
    
    # Run gh copilot
    $outputFile = "$env:TEMP\ralph-copilot-output-$Iteration.txt"
    
    try {
        gh copilot suggest --target shell $contextPrompt > $outputFile 2>&1
        $output = Get-Content $outputFile -Raw
        
        Write-Log "Copilot iteration completed" -Level Success
        Write-Host $output
        
        # Check for completion signals
        if ($output -match "FEATURE_DONE") {
            Write-Log "Feature marked done" -Level Success
            return 0
        } elseif ($output -match "COMPLETE") {
            Write-Log "All features complete!" -Level Success
            return 2
        } elseif ($output -match "FEATURE_BLOCKED") {
            Write-Log "Feature blocked" -Level Error
            $output -match "FEATURE_BLOCKED.*" | Write-Host
            return 1
        }
    } catch {
        Write-Log "Copilot execution failed" -Level Error
        Get-Content $outputFile -Raw | Write-Host
        
        $output = Get-Content $outputFile -Raw
        
        # Check for rate limiting
        if ($output -match "rate limit") {
            $delay = Get-RateLimitDelay -Response $output
            Write-Log "Rate limited. Waiting $delay seconds..." -Level Warning
            Start-Sleep -Seconds $delay
            return 3  # Signal to retry
        }
        
        return 1
    }
    
    return 0
}

# ==============================================================================
# Main Loop
# ==============================================================================
function Start-MainLoop {
    param([int]$StartIteration)
    
    Write-Log "Starting autonomous loop (max $MaxIterations iterations)"
    Write-Log "Feature list: $FeatureListPath"
    Write-Log "Security profile: $Profile"
    
    for ($i = $StartIteration; $i -lt $MaxIterations; $i++) {
        Write-Host ""
        Write-Log "========================================="
        Write-Log "ITERATION $($i + 1)/$MaxIterations"
        Write-Log "========================================="
        
        # Get current stats
        $stats = Get-FeatureStats
        Write-Log "Progress: $stats"
        
        # Check if all features pass
        if (Test-AllFeaturesPassing) {
            Write-Log "All features passing!" -Level Success
            
            # Verify git is clean
            if (Test-CleanState) {
                Write-Log "Git working tree is clean" -Level Success
                Write-Log "🎉 AUTONOMOUS SESSION COMPLETE! 🎉" -Level Success
                exit 0
            } else {
                Write-Log "Working tree has uncommitted changes. Commit manually." -Level Warning
                exit 1
            }
        }
        
        # Get next feature
        $nextFeature = Get-NextFeature
        if ([string]::IsNullOrWhiteSpace($nextFeature)) {
            Write-Log "No next feature found but features are still failing" -Level Error
            exit 1
        }
        
        Write-Log "Next feature: $nextFeature"
        
        # Run Copilot
        $result = Invoke-CopilotIteration -Iteration $i -FeatureId $nextFeature
        
        # Handle result
        switch ($result) {
            0 {  # Feature done
                Update-State -Iteration $i -LastFeature $nextFeature
                Invoke-CommitIfNeeded -FeatureId $nextFeature
                Write-Log "Continuing in ${AutoContinueDelay}s..."
                Start-Sleep -Seconds $AutoContinueDelay
            }
            1 {  # Error
                Write-Log "Iteration failed. Stopping." -Level Error
                Update-State -Iteration $i -LastFeature $nextFeature
                exit 1
            }
            2 {  # Complete
                Write-Log "Session complete!" -Level Success
                exit 0
            }
            3 {  # Rate limited, retry
                Write-Log "Retrying iteration..."
                continue
            }
        }
    }
    
    Write-Log "Reached maximum iterations ($MaxIterations)" -Level Warning
    Write-Log "Progress: $(Get-FeatureStats)"
    Write-Log "Run again to continue or increase -MaxIterations"
}

# ==============================================================================
# Main Execution
# ==============================================================================

if ($Help) {
    @"
Ralph - Autonomous loop runner for GitHub Copilot CLI

USAGE:
    .\ralph.ps1 [OPTIONS]

OPTIONS:
    -MaxIterations N    Maximum iterations (default: 50)
    -Profile PROFILE    Security profile: locked, safe, dev (default: safe)
    -Once               Run single iteration (for testing)
    -Resume             Resume from saved state
    -Reset              Reset state and start fresh
    -Help               Show this help message

EXAMPLES:
    .\ralph.ps1
    .\ralph.ps1 -MaxIterations 100
    .\ralph.ps1 -Profile locked
    .\ralph.ps1 -Once
    .\ralph.ps1 -Resume
"@
    exit 0
}

Set-Location $ProjectRoot

Test-Prerequisites

if ($Reset) {
    Write-Log "Resetting state..."
    if (Test-Path $StateFilePath) {
        Remove-Item $StateFilePath -Force
    }
}

$startIteration = Initialize-State

if ($Once) {
    Write-Log "Running single iteration (test mode)"
    $MaxIterations = $startIteration + 1
}

Start-MainLoop -StartIteration $startIteration
