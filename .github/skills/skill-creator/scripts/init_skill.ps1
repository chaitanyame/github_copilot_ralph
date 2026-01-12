<#
.SYNOPSIS
    Skill Initializer - Creates a new skill from template (PowerShell wrapper)

.DESCRIPTION
    Wraps init_skill.py for Windows PowerShell users

.EXAMPLE
    .\init_skill.ps1 -SkillName "my-new-skill" -Path ".github\skills"

.EXAMPLE
    .\init_skill.ps1 api-helper -Path .github\skills
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$SkillName,
    
    [Parameter(Mandatory=$true)]
    [string]$Path
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "init_skill.py"

if (-not (Test-Path $PythonScript)) {
    Write-Error "Python script not found: $PythonScript"
    exit 1
}

# Check for Python
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command python3 -ErrorAction SilentlyContinue
}

if (-not $python) {
    Write-Error "Python not found. Please install Python 3."
    exit 1
}

# Run the Python script
& $python.Source $PythonScript $SkillName --path $Path
exit $LASTEXITCODE
