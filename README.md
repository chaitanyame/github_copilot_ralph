# Teradata to Databricks SQL Migration POC

A proof-of-concept tool for converting Teradata SQL files to Databricks SQL format using configurable guidelines and patterns.

## Quick Start

```bash
# Setup environment
./init.sh

# Activate virtual environment
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate     # Windows

# Convert a single file
python -m teradata_converter convert input.sql -o output/

# Convert with guidelines
python -m teradata_converter convert input.sql -o output/ -g guidelines.json

# Batch convert a directory
python -m teradata_converter batch input_dir/ -o output/ -g guidelines.json
```

## Project Structure

```
├── src/teradata_converter/     # Main source code
│   ├── parsers/                # SQL parsing logic
│   ├── transformers/           # Transformation rules
│   ├── validators/             # Output validation
│   └── cli/                    # Command-line interface
├── tests/                      # Test suite
│   ├── unit/                   # Unit tests
│   ├── integration/            # Integration tests
│   └── fixtures/               # Test data
├── features.json               # Feature tracking (Constitution Principle VI)
├── progress.md                 # Session progress log (Constitution Principle IV)
└── init.sh                     # Environment setup
```

## Constitution Compliance

This project follows the Harness Framework Constitution for long-running agent sessions:

- **I. Initializer-Coder Pattern**: Environment setup separated from implementation
- **II. Incremental Progress**: One feature at a time
- **III. Clean State Handoff**: Always leave code in mergeable state
- **IV. Progress Tracking**: Session log in progress.md
- **V. Comprehensive Testing**: End-to-end testing before marking complete
- **VI. Feature-Based Development**: Tracked in features.json

## Features

See `features.json` for the complete feature list with pass/fail status.

## Guidelines Format

```json
{
  "naming": {
    "schema_mappings": {
      "old_schema": "new_catalog.new_schema"
    },
    "table_prefix": "",
    "case_transform": "lower"
  },
  "functions": {
    "custom_mappings": {
      "MY_UDF": "my_databricks_udf"
    }
  },
  "types": {
    "overrides": {
      "CHAR": "STRING"
    }
  }
}
```

## License

Internal POC - Not for distribution
