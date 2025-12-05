# /speckit.tasks - Generate Task List

Convert the implementation plan into a detailed task list ready for execution.

## Instructions

1. Read `memory/constitution.md` for project principles
2. Read `specs/plan.md` for the implementation plan
3. Generate `specs/tasks.md` with detailed, actionable tasks

## Task List Template

```markdown
# Task List

Generated from: [plan.md](specs/plan.md)
Date: {YYYY-MM-DD}

## Overview
- **Total Tasks**: {count}
- **Estimated Sessions**: {count}

## Task Categories

### Category: {Category Name}

#### Task 1: {Task Title}
- **ID**: T001
- **Priority**: {P1/P2/P3}
- **Complexity**: {Low/Medium/High}
- **Depends On**: {task IDs or "None"}
- **Estimated Effort**: {1-3 sessions}

**Description**:
{Detailed description of what needs to be done}

**Acceptance Criteria**:
- [ ] {Criterion 1}
- [ ] {Criterion 2}

**Files to Modify/Create**:
- `path/to/file1.ts`
- `path/to/file2.ts`

**Testing Notes**:
{How to verify this task is complete}

---

#### Task 2: {Task Title}
...

## Dependency Graph

```
T001 ─┬─> T002 ─> T004
      └─> T003 ─┘
```

## Suggested Order
1. T001 - {title}
2. T003 - {title}
3. T002 - {title}
...
```

## Next Step

After creating tasks.md, use `/harness.generate` to convert to `feature_list.json` for the @Coder agent.
