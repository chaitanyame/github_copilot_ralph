#!/bin/bash
# init.sh - Environment setup for Teradata to Databricks SQL Migration POC
# Per Constitution Principle I: Initializer-Coder Pattern

set -e

echo "=========================================="
echo "Teradata to Databricks Migration POC Setup"
echo "=========================================="

# Check Python version
echo "Checking Python installation..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "✓ Found $PYTHON_VERSION"
else
    echo "✗ Python 3 not found. Please install Python 3.9+"
    exit 1
fi

# Create virtual environment if not exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo "✓ Virtual environment created"
else
    echo "✓ Virtual environment already exists"
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate || source venv/Scripts/activate

# Install dependencies
echo "Installing dependencies..."
pip install --upgrade pip
pip install sqlglot>=20.0.0
pip install pytest>=7.0.0
pip install pyyaml>=6.0
pip install click>=8.0.0
pip install rich>=13.0.0

echo "✓ Dependencies installed"

# Create project structure
echo "Creating project structure..."
mkdir -p src/teradata_converter
mkdir -p src/teradata_converter/transformers
mkdir -p src/teradata_converter/parsers
mkdir -p src/teradata_converter/validators
mkdir -p src/teradata_converter/cli
mkdir -p tests/unit
mkdir -p tests/integration
mkdir -p tests/fixtures/input
mkdir -p tests/fixtures/expected
mkdir -p tests/fixtures/guidelines
mkdir -p output
mkdir -p docs

# Create __init__.py files
touch src/__init__.py
touch src/teradata_converter/__init__.py
touch src/teradata_converter/transformers/__init__.py
touch src/teradata_converter/parsers/__init__.py
touch src/teradata_converter/validators/__init__.py
touch src/teradata_converter/cli/__init__.py
touch tests/__init__.py
touch tests/unit/__init__.py
touch tests/integration/__init__.py

echo "✓ Project structure created"

# Verify setup
echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Project Structure:"
echo "  src/teradata_converter/   - Main source code"
echo "  tests/                    - Test files"
echo "  tests/fixtures/           - Test input/expected files"
echo "  output/                   - Conversion output"
echo "  docs/                     - Documentation"
echo ""
echo "To activate the environment:"
echo "  source venv/bin/activate  (Linux/Mac)"
echo "  venv\\Scripts\\activate     (Windows)"
echo ""
echo "To run tests:"
echo "  pytest tests/"
echo ""
echo "Next: Start implementing Feature F001 (Parse Teradata SQL)"
