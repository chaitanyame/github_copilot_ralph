# /speckit.implement - Implement Single Task

Implement a specific task from the task list using the @Coder agent pattern.

## Instructions

1. This command delegates to the @Coder agent for implementation
2. Read `memory/claude-progress.md` for current state
3. Read `memory/feature_list.json` for the task to implement
4. Follow the incremental implementation pattern with **feature branching**

## Usage

```
/speckit.implement T001
/speckit.implement "Add user authentication"
```

## Workflow

1. **Create Feature Branch**
   ```bash
   git checkout dev && git pull origin dev
   git checkout -b feature/{id}-{short-name}
   ```

2. **Verify Environment**
   - Run `init.sh` or `init.ps1` if needed
   - Check 1-2 existing passing features still work

3. **Implement ONE Feature**
   - Find the specified task in `feature_list.json`
   - Implement all steps for that feature
   - Create Playwright tests in `tests/{feature}.spec.ts`
   - Test and verify end-to-end

4. **Commit and Push**
   ```bash
   git add .
   git commit -m "feat({id}): {feature name}"
   git push origin feature/{id}-{short-name}
   ```

5. **Mark Complete**
   - Update `feature_list.json`: change `passes: false` to `passes: true`
   - Update `memory/claude-progress.md` with branch name
   - Create PR or merge to dev

## Branch Naming

- `feature/{id}-{short-name}` - New features (e.g., `feature/001-user-login`)
- `fix/{id}-{description}` - Bug fixes
- `refactor/{id}-{description}` - Refactoring

## Important

- **Always work on a feature branch** - Never commit directly to dev/main
- Only implement ONE task per invocation
- Never modify feature descriptions or steps
- Always verify before marking complete
- Push branch before ending session

## Hand-off

This command invokes the @Coder agent pattern. Refer to `.github/agents/coder.agent.md` for the full protocol.
