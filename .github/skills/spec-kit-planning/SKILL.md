---
name: spec-kit-planning
description: Specification-Driven Development workflow for planning features using GitHub Spec Kit. Use when starting new features, creating specifications, running /speckit commands, or when the user mentions spec, specification, planning, or SDD workflow.
---

# Spec Kit Planning Skill

Standardizes the Specification-Driven Development workflow integrated with the Agent Harness Framework.

## Spec Kit Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│  SPEC KIT PLANNING PHASE                                        │
├─────────────────────────────────────────────────────────────────┤
│  1. /speckit.specify → Creates spec + auto-creates branch      │
│  2. /speckit.plan    → Creates implementation plan              │
│  3. /speckit.tasks   → Generates detailed task list             │
│  4. /harness.generate→ Converts tasks to feature_list.json     │
├─────────────────────────────────────────────────────────────────┤
│  IMPLEMENTATION PHASE (Ralph or @Coder)                         │
├─────────────────────────────────────────────────────────────────┤
│  5. Implement features one at a time (TDD mandatory)            │
│  6. Repeat until all features pass                              │
│  7. Create PR to merge Spec Kit branch to dev                   │
└─────────────────────────────────────────────────────────────────┘
```

## Branch Naming Convention

Branches are created by Spec Kit, NOT manually:

```
Format: {NNN}-{semantic-name}
Examples:
  001-user-authentication
  002-dashboard-widgets
  003-real-time-chat
```

## Directory Structure

```
specs/
├── 001-user-authentication/   ← Created by /speckit.specify
│   ├── spec.md               ← Feature specification
│   ├── plan.md               ← Implementation plan
│   └── tasks.md              ← Task breakdown
├── 002-dashboard-widgets/
│   └── ...
```

## Specification Template

Use `templates/docs/spec-template.md`:

```markdown
# Feature: {Feature Name}

## Overview
{1-2 sentence description}

## User Stories
- As a {role}, I want {feature} so that {benefit}

## Requirements
### Functional
- [ ] {Requirement 1}

### Non-Functional
- [ ] {Performance, security, etc.}

## Acceptance Criteria
- [ ] {Criterion 1}

## Technical Notes
{Implementation considerations}
```

## Plan Template

Use `templates/docs/plan-template.md`:

```markdown
# Implementation Plan: {Feature Name}

## Architecture
{High-level design}

## Components
1. {Component 1}
2. {Component 2}

## Dependencies
- {External dependencies}

## Risks
- {Potential issues}
```

## Tasks Template

Use `templates/docs/tasks-template.md`:

```markdown
# Tasks: {Feature Name}

## Phase 1: Setup
- [ ] Task 1.1
- [ ] Task 1.2

## Phase 2: Core Implementation
- [ ] Task 2.1

## Phase 3: Testing
- [ ] Task 3.1
```

## Creating Skills During Planning

When `/speckit.specify` detects a tech stack, create appropriate skills:

1. **Detect stack** from package.json, tsconfig.json, etc.
2. **Run skill-creator** for stack-specific skills:
   ```bash
   python .github/skills/skill-creator/scripts/init_skill.py {stack}-patterns --path .github/skills
   ```
3. **Document** skill usage in plan.md

## References

- **templates/docs/spec-template.md** - Specification template
- **templates/docs/plan-template.md** - Implementation plan template
- **templates/docs/tasks-template.md** - Task breakdown template
