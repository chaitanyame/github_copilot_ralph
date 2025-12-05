# /speckit.plan - Create Implementation Plan

Create an implementation plan from one or more specifications.

## Instructions

1. Read `memory/constitution.md` for project principles
2. Read all relevant specs in `specs/` directory
3. Create a plan in `specs/plan.md` that breaks down implementation

## Plan Template

```markdown
# Implementation Plan

## Specifications Covered
- [{spec-1}.spec.md](specs/{spec-1}.spec.md)
- [{spec-2}.spec.md](specs/{spec-2}.spec.md)

## Implementation Phases

### Phase 1: {Phase Name}
**Goal**: {What this phase achieves}
**Duration**: {Estimated sessions}

#### Tasks
1. {Task 1}
   - Depends on: {dependencies}
   - Complexity: {low/medium/high}
2. {Task 2}

### Phase 2: {Phase Name}
...

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| {Risk 1} | {L/M/H} | {L/M/H} | {Strategy} |

## Success Criteria
- [ ] {Criterion 1}
- [ ] {Criterion 2}

## Open Decisions
- {Decision 1}: {options}
```

## Output

Create `specs/plan.md` with the implementation plan
