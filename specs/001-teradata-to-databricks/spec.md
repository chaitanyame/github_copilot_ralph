# Feature Specification: Teradata to Databricks SQL Migration POC

**Feature Branch**: `001-teradata-to-databricks`  
**Created**: 2025-12-04  
**Status**: Draft  
**Input**: User description: "POC for legacy code migration project that converts Teradata SQL files to Databricks SQL files using guidelines and patterns as context"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Single File Conversion (Priority: P1)

As a data engineer, I want to convert a single Teradata SQL file to Databricks SQL format so that I can validate the conversion logic works correctly before processing multiple files.

**Why this priority**: This is the foundational capability. Without reliable single-file conversion, batch processing is meaningless. This proves the core transformation logic works.

**Independent Test**: Can be fully tested by providing one Teradata SQL file and verifying the output is valid Databricks SQL that executes without syntax errors.

**Acceptance Scenarios**:

1. **Given** a Teradata SQL file with standard SELECT statements, **When** I run the converter, **Then** the output is syntactically valid Databricks SQL
2. **Given** a Teradata SQL file with Teradata-specific functions (e.g., QUALIFY, SAMPLE), **When** I run the converter, **Then** these are transformed to Databricks equivalents
3. **Given** a Teradata SQL file with data type declarations, **When** I run the converter, **Then** data types are mapped to Databricks equivalents

---

### User Story 2 - Context-Driven Conversion with Guidelines (Priority: P2)

As a data engineer, I want the converter to use a guidelines/patterns file as context so that conversions follow our organization's standards and handle edge cases consistently.

**Why this priority**: Guidelines ensure consistency across all conversions and encode institutional knowledge about how specific patterns should be handled.

**Independent Test**: Can be tested by providing a guidelines file and verifying that conversions match the specified patterns rather than generic defaults.

**Acceptance Scenarios**:

1. **Given** a guidelines file specifying table naming conventions, **When** I convert a SQL file, **Then** table references follow the specified naming pattern
2. **Given** a guidelines file with function mapping overrides, **When** I convert SQL with those functions, **Then** the custom mappings are applied
3. **Given** a guidelines file with schema migration rules, **When** I convert SQL, **Then** schema references are transformed according to the rules

---

### User Story 3 - Batch File Processing (Priority: P3)

As a data engineer, I want to convert multiple Teradata SQL files (e.g., 20 files) in a batch so that I can efficiently migrate an entire project's SQL codebase.

**Why this priority**: Batch processing enables practical use at scale, but it depends on reliable single-file conversion being proven first.

**Independent Test**: Can be tested by providing a directory of 20 SQL files and verifying all are converted with a summary report.

**Acceptance Scenarios**:

1. **Given** a directory containing 20 Teradata SQL files, **When** I run batch conversion, **Then** all 20 files are converted to Databricks SQL
2. **Given** batch conversion in progress, **When** one file fails, **Then** the process continues with remaining files and reports the failure
3. **Given** batch conversion completes, **When** I review the output, **Then** I receive a summary showing success/failure counts and any issues

---

### User Story 4 - Conversion Validation Report (Priority: P4)

As a data engineer, I want a validation report for each conversion so that I can identify potential issues that require manual review.

**Why this priority**: Automated conversion cannot handle all edge cases. A validation report helps engineers focus manual effort where it's needed.

**Independent Test**: Can be tested by converting files with known edge cases and verifying the report flags them appropriately.

**Acceptance Scenarios**:

1. **Given** a converted file, **When** conversion completes, **Then** a validation report lists any constructs that couldn't be automatically converted
2. **Given** a file with ambiguous syntax, **When** conversion completes, **Then** the report includes warnings with line numbers and suggested manual actions
3. **Given** batch conversion, **When** all files are processed, **Then** a consolidated report summarizes issues across all files

---

### Edge Cases

- What happens when a SQL file contains syntax errors in the source Teradata SQL?
- How does the system handle nested subqueries with Teradata-specific syntax?
- What happens when the guidelines file is missing or malformed?
- How does the system handle SQL files with mixed Teradata and ANSI SQL syntax?
- What happens when a Teradata function has no direct Databricks equivalent?
- How does the system handle very large SQL files (e.g., 10,000+ lines)?
- What happens when file encoding is non-UTF8?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST parse Teradata SQL files and identify Teradata-specific syntax elements
- **FR-002**: System MUST transform Teradata data types to Databricks equivalents (e.g., BYTEINT → TINYINT, DECIMAL → DECIMAL)
- **FR-003**: System MUST convert Teradata-specific functions to Databricks equivalents (e.g., QUALIFY → window functions with subquery, SAMPLE → TABLESAMPLE)
- **FR-004**: System MUST handle Teradata SET operations and translate to Databricks syntax
- **FR-005**: System MUST read and apply transformation rules from a guidelines/patterns context file
- **FR-006**: System MUST preserve SQL comments and formatting where possible
- **FR-007**: System MUST generate output files with `.sql` extension in a configurable output directory
- **FR-008**: System MUST provide progress feedback during batch processing
- **FR-009**: System MUST generate validation reports identifying unconvertible or ambiguous constructs
- **FR-010**: System MUST handle files that fail conversion gracefully without stopping batch processing
- **FR-011**: System MUST support common Teradata constructs: CREATE TABLE, CREATE VIEW, INSERT, UPDATE, DELETE, MERGE, stored procedures (basic), macros
- **FR-012**: System MUST log all transformation decisions for auditability

### Key Entities

- **SourceFile**: A Teradata SQL file to be converted; attributes include path, content, encoding, size
- **ConvertedFile**: The Databricks SQL output; attributes include path, content, conversion timestamp, source reference
- **GuidelinesContext**: Configuration file containing transformation rules, naming conventions, and custom mappings
- **ConversionResult**: Outcome of a single file conversion; includes status (success/partial/failed), warnings, errors, unconverted constructs
- **BatchReport**: Aggregate summary of batch conversion; includes file counts, overall status, consolidated warnings

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can convert a single Teradata SQL file to Databricks SQL in under 5 seconds for files up to 1000 lines
- **SC-002**: Batch conversion of 20 files completes in under 2 minutes
- **SC-003**: 80% of common Teradata SQL patterns are automatically converted without manual intervention
- **SC-004**: Converted SQL files execute in Databricks without syntax errors for 95% of test cases
- **SC-005**: Validation reports correctly identify 100% of unconvertible constructs requiring manual review
- **SC-006**: Users can understand and apply the conversion workflow within 15 minutes using provided documentation

## Assumptions

- Input files are valid Teradata SQL (may have logic errors but are syntactically correct)
- Guidelines file format will be documented and users will provide properly formatted files
- Target Databricks runtime is Databricks SQL or Databricks Runtime 13.0+
- Character encoding of input files is UTF-8 unless otherwise detected
- Users have basic familiarity with both Teradata and Databricks SQL dialects
