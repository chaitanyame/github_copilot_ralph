<#
.SYNOPSIS
    Validates TDD compliance for features

.DESCRIPTION
    Checks TDD Gate 1 (test fails before) and Gate 2 (test passes after) compliance

.EXAMPLE
    .\verify-tdd-gates.ps1
#>

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item (Join-Path $ScriptDir "..\..")).FullName
$FeatureListPath = Join-Path $ProjectRoot "memory\feature_list.json"

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "🧪 TDD Gate Verification"
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if (-not (Test-Path $FeatureListPath)) {
    Write-Host "❌ Feature list not found: $FeatureListPath" -ForegroundColor Red
    exit 1
}

$featureList = Get-Content $FeatureListPath -Raw | ConvertFrom-Json
$features = $featureList.features

if (-not $features -or $features.Count -eq 0) {
    Write-Host "⚠ No features found in feature list" -ForegroundColor Yellow
    exit 0
}

$gate1Violations = 0
$gate2Violations = 0
$total = 0

foreach ($feature in $features) {
    $total++
    
    Write-Host ""
    Write-Host "Feature $($feature.id): $($feature.name)"
    
    # Gate 1: Check if test exists for features being worked on
    if ($feature.passes -eq $false) {
        if (-not $feature.test_file) {
            Write-Host "  ⚠ Gate 1: No test file specified yet" -ForegroundColor Yellow
        }
        elseif ($feature.test_fails_before -ne $true) {
            Write-Host "  ❌ Gate 1 VIOLATION: test_fails_before not set" -ForegroundColor Red
            $gate1Violations++
        }
        else {
            Write-Host "  ✓ Gate 1: Test exists and failed before implementation" -ForegroundColor Green
        }
    }
    
    # Gate 2: Check if completed features have test verification
    if ($feature.passes -eq $true) {
        if ($feature.test_passes_after -ne $true) {
            Write-Host "  ❌ Gate 2 VIOLATION: passes=true but test_passes_after=false" -ForegroundColor Red
            $gate2Violations++
        }
        else {
            Write-Host "  ✓ Gate 2: Test verified passing" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "Summary: $total features checked"

if ($gate1Violations -gt 0 -or $gate2Violations -gt 0) {
    Write-Host "❌ Gate 1 Violations: $gate1Violations" -ForegroundColor Red
    Write-Host "❌ Gate 2 Violations: $gate2Violations" -ForegroundColor Red
    exit 1
}
else {
    Write-Host "✓ All TDD gates passed" -ForegroundColor Green
    exit 0
}
