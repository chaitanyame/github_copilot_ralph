<#
.SYNOPSIS
    Detects project technology stack

.DESCRIPTION
    Analyzes project files to detect language, frameworks, testing tools, and build systems

.PARAMETER ProjectRoot
    Path to the project root (default: current directory)

.EXAMPLE
    .\detect-stack.ps1
    .\detect-stack.ps1 -ProjectRoot "C:\Projects\MyApp"
#>

param(
    [string]$ProjectRoot = "."
)

Set-Location $ProjectRoot

# Initialize detection
$result = @{
    language = ""
    runtime = ""
    package_manager = ""
    frameworks = @()
    testing = @()
    build_tools = @()
    detected_files = @()
}

# Node.js / TypeScript detection
if (Test-Path "package.json") {
    $result.detected_files += "package.json"
    $result.runtime = "node"
    $result.language = "javascript"
    
    if (Test-Path "tsconfig.json") {
        $result.detected_files += "tsconfig.json"
        $result.language = "typescript"
    }
    
    # Package manager detection
    if (Test-Path "package-lock.json") {
        $result.package_manager = "npm"
        $result.detected_files += "package-lock.json"
    }
    elseif (Test-Path "yarn.lock") {
        $result.package_manager = "yarn"
        $result.detected_files += "yarn.lock"
    }
    elseif (Test-Path "pnpm-lock.yaml") {
        $result.package_manager = "pnpm"
        $result.detected_files += "pnpm-lock.yaml"
    }
    elseif (Test-Path "bun.lockb") {
        $result.package_manager = "bun"
        $result.detected_files += "bun.lockb"
    }
    
    # Framework detection from package.json
    $packageJson = Get-Content "package.json" -Raw
    if ($packageJson -match '"react"') { $result.frameworks += "react" }
    if ($packageJson -match '"vue"') { $result.frameworks += "vue" }
    if ($packageJson -match '"svelte"') { $result.frameworks += "svelte" }
}

# Framework detection from config files
if (Test-Path "next.config.js" -or (Test-Path "next.config.mjs") -or (Test-Path "next.config.ts")) {
    $result.frameworks += "next.js"
    $result.detected_files += "next.config.*"
}
if (Test-Path "vite.config.ts" -or (Test-Path "vite.config.js")) {
    $result.frameworks += "vite"
    $result.detected_files += "vite.config.*"
}
if (Test-Path "nuxt.config.ts") {
    $result.frameworks += "nuxt"
    $result.detected_files += "nuxt.config.ts"
}
if (Test-Path "angular.json") {
    $result.frameworks += "angular"
    $result.detected_files += "angular.json"
}

# Testing framework detection
if (Test-Path "playwright.config.ts" -or (Test-Path "playwright.config.js")) {
    $result.testing += "playwright"
    $result.detected_files += "playwright.config.*"
}
if (Test-Path "jest.config.js" -or (Test-Path "jest.config.ts")) {
    $result.testing += "jest"
    $result.detected_files += "jest.config.*"
}
if (Test-Path "vitest.config.ts") {
    $result.testing += "vitest"
    $result.detected_files += "vitest.config.ts"
}
if (Test-Path "cypress.config.js" -or (Test-Path "cypress.config.ts")) {
    $result.testing += "cypress"
    $result.detected_files += "cypress.config.*"
}

# Build tool detection
if (Test-Path "webpack.config.js") {
    $result.build_tools += "webpack"
    $result.detected_files += "webpack.config.js"
}

# Python detection
if ((Test-Path "pyproject.toml") -or (Test-Path "setup.py") -or (Test-Path "requirements.txt")) {
    $result.language = "python"
    $result.runtime = "python"
    
    if (Test-Path "pyproject.toml") { $result.detected_files += "pyproject.toml" }
    if (Test-Path "setup.py") { $result.detected_files += "setup.py" }
    if (Test-Path "requirements.txt") {
        $result.detected_files += "requirements.txt"
        $result.package_manager = "pip"
    }
    if (Test-Path "Pipfile") {
        $result.detected_files += "Pipfile"
        $result.package_manager = "pipenv"
    }
    if (Test-Path "poetry.lock") {
        $result.detected_files += "poetry.lock"
        $result.package_manager = "poetry"
    }
    if (Test-Path "pytest.ini") {
        $result.testing += "pytest"
        $result.detected_files += "pytest.ini"
    }
}

# Output JSON
$result | ConvertTo-Json -Depth 3
