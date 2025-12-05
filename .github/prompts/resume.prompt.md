---
agent: agent
description: Resume work from a saved checkpoint
tools:
  - search
  - editFiles
---

# Resume Work

Resume work from a previously saved checkpoint.

## User Input

$ARGUMENTS

## Instructions

1. **Find checkpoint**:
   - Check `memory/state/` for checkpoint files
   - Check `memory/sessions/` for session logs
   - Use most recent if not specified

2. **Load state**:
   - Read the checkpoint file
   - Understand what was being worked on
   - Review what was already completed

3. **Verify context**:
   - Check that files still exist as expected
   - Verify no conflicting changes occurred
   - Review any relevant context files

4. **Resume execution**:
   - Update checkpoint status to "in-progress"
   - Continue from where work left off
   - Follow the resume instructions in the checkpoint

5. **Update state**:
   - Track progress as you continue
   - Create new checkpoints as needed

## Output

1. Summary of the checkpoint being resumed
2. Current status and next steps
3. Progress updates as work continues
