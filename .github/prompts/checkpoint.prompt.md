---
agent: agent
description: Save current agent state for later resumption
tools:
  - editFiles
---

# Checkpoint State

Save the current work state to memory for later resumption.

## User Input

$ARGUMENTS

## Instructions

1. **Gather current state**:
   - What task is being worked on?
   - What has been completed?
   - What is the current step?
   - What are the next steps?

2. **Create checkpoint**:

   Save to `memory/state/checkpoint-{timestamp}.json`:
   
   ```json
   {
     "timestamp": "{ISO timestamp}",
     "task": "{task description}",
     "status": "paused",
     "completed": [
       "Step 1 description",
       "Step 2 description"
     ],
     "current": "Current step description",
     "remaining": [
       "Next step 1",
       "Next step 2"
     ],
     "context": {
       "files_modified": [],
       "decisions_made": [],
       "notes": ""
     },
     "resume_instructions": "Clear instructions for resuming this work"
   }
   ```

3. **Create session log**:

   Save to `memory/sessions/{date}-checkpoint.md`:
   
   ```markdown
   # Session Checkpoint
   Date: {timestamp}
   
   ## Task
   {description}
   
   ## Progress
   {what was done}
   
   ## To Resume
   {how to continue}
   ```

## Output

Confirm the checkpoint was saved and provide resume instructions.
