# /speckit.implement - Implement Single Task

Implement a specific task from the task list using the @Coder agent pattern.

## Instructions

1. This command delegates to the @Coder agent for implementation
2. Read `memory/claude-progress.md` for current state
3. Read `memory/feature_list.json` for the task to implement
4. Follow the incremental implementation pattern

## Usage

```
/speckit.implement T001
/speckit.implement "Add user authentication"
```

## Workflow

1. **Verify Environment**
   - Run `init.sh` or `init.ps1` if needed
   - Check 1-2 existing passing features still work

2. **Implement ONE Feature**
   - Find the specified task in `feature_list.json`
   - Implement all steps for that feature
   - Test and verify end-to-end

3. **Mark Complete**
   - Update `feature_list.json`: change `passes: false` to `passes: true`
   - Commit with descriptive message
   - Update `memory/claude-progress.md`

## Important

- Only implement ONE task per invocation
- Never modify feature descriptions or steps
- Always verify before marking complete
- Leave environment in clean state

## Hand-off

This command invokes the @Coder agent pattern. Refer to `.github/agents/coder.agent.md` for the full protocol.
