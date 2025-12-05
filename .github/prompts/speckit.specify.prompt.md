# /speckit.specify - Create Feature Specification

Create a detailed specification for a new feature or component.

## Instructions

1. Read `memory/constitution.md` first to understand project principles
2. Gather requirements from user through clarifying questions if needed
3. Create a specification file in `specs/{feature-name}.spec.md`

## Specification Template

```markdown
# {Feature Name} Specification

## Overview
{Brief description of what this feature does}

## User Stories
- As a {user type}, I want {goal} so that {benefit}

## Requirements

### Functional Requirements
1. {Requirement 1}
2. {Requirement 2}

### Non-Functional Requirements
- **Performance**: {expectations}
- **Security**: {considerations}
- **Accessibility**: {requirements}

## Technical Design

### Architecture
{How this fits into the overall system}

### Data Model
{Any data structures or schemas}

### API/Interface
{Public interfaces this feature exposes}

### Dependencies
{What this feature depends on}

## Acceptance Criteria
- [ ] {Criterion 1}
- [ ] {Criterion 2}

## Edge Cases
- {Edge case 1}: {how to handle}
- {Edge case 2}: {how to handle}

## Testing Strategy
{How this feature should be tested}

## Open Questions
- {Question 1}
- {Question 2}
```

## Output

Create the spec file and confirm location: `specs/{feature-name}.spec.md`
