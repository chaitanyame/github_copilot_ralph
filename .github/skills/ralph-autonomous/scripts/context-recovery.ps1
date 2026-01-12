<#
.SYNOPSIS
    Automated context loading for Ralph sessions

.DESCRIPTION
    Loads previous session context for Ralph autonomous loop

.EXAMPLE
    .\context-recovery.ps1
#>

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item (Join-Path $ScriptDir "..\..")).FullName

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "🔄 Ralph Context Recovery"
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

Set-Location $ProjectRoot

# 1. Current branch
Write-Host ""
Write-Host "📌 Current Branch:"
$branch = git branch --show-current
Write-Host "   $branch"

# 2. Progress notes summary
Write-Host ""
Write-Host "📝 Progress Notes (last 20 lines):"
$progressPath = Join-Path $ProjectRoot "memory\claude-progress.md"
if (Test-Path $progressPath) {
    Get-Content $progressPath -Tail 20 | ForEach-Object { Write-Host "   $_" }
} else {
    Write-Host "   No progress notes found"
}

# 3. Feature status
Write-Host ""
Write-Host "📋 Feature Status:"
$featureListPath = Join-Path $ProjectRoot "memory\feature_list.json"
if (Test-Path $featureListPath) {
    $featureList = Get-Content $featureListPath -Raw | ConvertFrom-Json
    $total = $featureList.features.Count
    $passing = ($featureList.features | Where-Object { $_.passes -eq $true }).Count
    Write-Host "   $passing / $total features passing"
    
    Write-Host ""
    Write-Host "   Remaining (passes: false):"
    $featureList.features | Where-Object { $_.passes -eq $false } | ForEach-Object {
        Write-Host "   - F$($_.id): $($_.name)"
    }
} else {
    Write-Host "   Feature list not found"
}

# 4. Spec context
Write-Host ""
Write-Host "📄 Spec Context:"
$specDir = Join-Path $ProjectRoot "specs\$branch"
if (Test-Path $specDir) {
    $specPath = Join-Path $specDir "spec.md"
    if (Test-Path $specPath) {
        Write-Host "   Found: $specPath"
        Get-Content $specPath -TotalCount 10 | ForEach-Object { Write-Host "   $_" }
    }
} else {
    Write-Host "   No spec directory for branch: $branch"
}

# 5. Ralph state
Write-Host ""
Write-Host "🤖 Ralph State:"
$statePath = Join-Path $ProjectRoot "memory\.ralph\state.json"
if (Test-Path $statePath) {
    Get-Content $statePath | ForEach-Object { Write-Host "   $_" }
} else {
    Write-Host "   No previous state (fresh start)"
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "✅ Context recovery complete"
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
