---
agent: agent
description: Execute an implementation plan
tools:
  - editFiles
  - search
  - usages
---

# Execute Plan

Execute an implementation plan step by step.

## User Input

$ARGUMENTS

## Instructions

Reference the @Implementer agent for execution methodology.

1. **Load plan**:
   - Check `memory/state/plan-*.md` for the relevant plan
   - Or use the plan provided in the user input

2. **Initialize state**:
   - Create `memory/state/execute-{task-id}.json` to track progress
   
   ```json
   {
     "task_id": "{task-id}",
     "plan_ref": "memory/state/plan-{task-id}.md",
     "status": "in-progress",
     "current_step": 1,
     "steps": []
   }
   ```

3. **Execute steps**:
   - Work through each step sequentially
   - Checkpoint after each step completion
   - Verify each step before moving on

4. **Handle issues**:
   - Document blockers in state file
   - Ask user for guidance if stuck
   - Update plan if approach needs change

5. **Complete**:
   - Mark state as completed
   - Summarize changes made
   - List any follow-up actions

## Output

Provide progress updates as you work through the plan.
