---
agent: agent
description: Create an implementation plan for a task
tools:
  - search
  - usages
---

# Create Plan

Create a structured implementation plan for a task.

## User Input

$ARGUMENTS

## Instructions

Reference the @Planner agent for detailed planning methodology.

1. **Gather context**:
   - Check for existing specification in `memory/state/spec-*.md`
   - Review project conventions in `memory/constitution.md`
   - Search codebase for relevant patterns

2. **Create plan**:

   ```markdown
   # Plan: {Task Title}

   ## Overview
   Brief description of what will be accomplished

   ## Prerequisites
   - [ ] Prerequisite 1
   - [ ] Prerequisite 2

   ## Steps

   ### Step 1: {Title}
   - **Description**: What will be done
   - **Files**: Affected files
   - **Estimated effort**: Low/Medium/High
   - **Verification**: How to verify completion

   ### Step 2: {Title}
   ...

   ## Risks
   - **Risk 1**: Mitigation strategy
   - **Risk 2**: Mitigation strategy

   ## Success Criteria
   - [ ] Criterion 1
   - [ ] Criterion 2
   ```

3. **Save plan**:
   - Save to `memory/state/plan-{task-id}.md`

## Next Steps

After plan is approved, hand off to @Implementer to execute.
