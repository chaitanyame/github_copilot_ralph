#!/bin/bash
# detect-stack.sh - Detects project technology stack
# Usage: ./detect-stack.sh [project-root]

PROJECT_ROOT="${1:-.}"
cd "$PROJECT_ROOT" || exit 1

# Initialize detection
LANGUAGE=""
RUNTIME=""
PACKAGE_MANAGER=""
FRAMEWORKS=()
TESTING=()
BUILD_TOOLS=()
DETECTED_FILES=()

# Helper function to add to array
add_framework() { FRAMEWORKS+=("$1"); }
add_testing() { TESTING+=("$1"); }
add_build() { BUILD_TOOLS+=("$1"); }
add_detected() { DETECTED_FILES+=("$1"); }

# Node.js / TypeScript detection
if [ -f "package.json" ]; then
    add_detected "package.json"
    RUNTIME="node"
    LANGUAGE="javascript"
    
    if [ -f "tsconfig.json" ]; then
        add_detected "tsconfig.json"
        LANGUAGE="typescript"
    fi
    
    # Package manager detection
    if [ -f "package-lock.json" ]; then
        PACKAGE_MANAGER="npm"
        add_detected "package-lock.json"
    elif [ -f "yarn.lock" ]; then
        PACKAGE_MANAGER="yarn"
        add_detected "yarn.lock"
    elif [ -f "pnpm-lock.yaml" ]; then
        PACKAGE_MANAGER="pnpm"
        add_detected "pnpm-lock.yaml"
    elif [ -f "bun.lockb" ]; then
        PACKAGE_MANAGER="bun"
        add_detected "bun.lockb"
    fi
fi

# Framework detection
[ -f "next.config.js" ] || [ -f "next.config.mjs" ] || [ -f "next.config.ts" ] && add_framework "next.js" && add_detected "next.config.*"
[ -f "vite.config.ts" ] || [ -f "vite.config.js" ] && add_framework "vite" && add_detected "vite.config.*"
[ -f "nuxt.config.ts" ] && add_framework "nuxt" && add_detected "nuxt.config.ts"
[ -f "astro.config.mjs" ] && add_framework "astro" && add_detected "astro.config.mjs"
[ -f "svelte.config.js" ] && add_framework "sveltekit" && add_detected "svelte.config.js"
[ -f "angular.json" ] && add_framework "angular" && add_detected "angular.json"

# React detection (from package.json)
if [ -f "package.json" ]; then
    grep -q '"react"' package.json 2>/dev/null && add_framework "react"
    grep -q '"vue"' package.json 2>/dev/null && add_framework "vue"
    grep -q '"svelte"' package.json 2>/dev/null && add_framework "svelte"
fi

# Testing framework detection
[ -f "playwright.config.ts" ] || [ -f "playwright.config.js" ] && add_testing "playwright" && add_detected "playwright.config.*"
[ -f "jest.config.js" ] || [ -f "jest.config.ts" ] && add_testing "jest" && add_detected "jest.config.*"
[ -f "vitest.config.ts" ] && add_testing "vitest" && add_detected "vitest.config.ts"
[ -f "cypress.config.js" ] || [ -f "cypress.config.ts" ] && add_testing "cypress" && add_detected "cypress.config.*"

# Build tool detection
[ -f "webpack.config.js" ] && add_build "webpack" && add_detected "webpack.config.js"
[ -f "rollup.config.js" ] && add_build "rollup" && add_detected "rollup.config.js"
[ -f "esbuild.config.js" ] && add_build "esbuild" && add_detected "esbuild.config.js"

# Python detection
if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
    LANGUAGE="python"
    RUNTIME="python"
    [ -f "pyproject.toml" ] && add_detected "pyproject.toml"
    [ -f "setup.py" ] && add_detected "setup.py"
    [ -f "requirements.txt" ] && add_detected "requirements.txt" && PACKAGE_MANAGER="pip"
    [ -f "Pipfile" ] && add_detected "Pipfile" && PACKAGE_MANAGER="pipenv"
    [ -f "poetry.lock" ] && add_detected "poetry.lock" && PACKAGE_MANAGER="poetry"
    [ -f "pytest.ini" ] && add_testing "pytest" && add_detected "pytest.ini"
fi

# Output JSON
echo "{"
echo "  \"language\": \"$LANGUAGE\","
echo "  \"runtime\": \"$RUNTIME\","
echo "  \"package_manager\": \"$PACKAGE_MANAGER\","
echo "  \"frameworks\": [$(IFS=,; echo "\"${FRAMEWORKS[*]}\"" | sed 's/,/", "/g')],"
echo "  \"testing\": [$(IFS=,; echo "\"${TESTING[*]}\"" | sed 's/,/", "/g')],"
echo "  \"build_tools\": [$(IFS=,; echo "\"${BUILD_TOOLS[*]}\"" | sed 's/,/", "/g')],"
echo "  \"detected_files\": [$(IFS=,; echo "\"${DETECTED_FILES[*]}\"" | sed 's/,/", "/g')]"
echo "}"
