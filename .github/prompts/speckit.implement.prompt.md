# /speckit.implement - Implement Single Task

Implement a specific task from the feature list using the @Coder agent pattern.

> **Note**: This command runs on the feature branch created by `/speckit.specify`
> All implementation happens on the Spec Kit feature branch (e.g., `003-real-time-chat`)

## Prerequisites

- Must be on a Spec Kit feature branch (e.g., `003-real-time-chat`)
- Feature list must exist at `memory/feature_list.json`

## Instructions

1. Verify you're on the correct feature branch:
   ```bash
   BRANCH=$(git branch --show-current)
   echo "Implementing on branch: $BRANCH"
   ```

2. This command delegates to the @Coder agent for implementation
3. Read `memory/claude-progress.md` for current state
4. Read `memory/feature_list.json` for the task to implement

## Usage

```
/speckit.implement T001
/speckit.implement "Add user authentication"
```

## Workflow

1. **Verify On Feature Branch**
   ```bash
   # Should return something like: 003-real-time-chat
   git branch --show-current
   ```

2. **Verify Environment**
   - Run `init.sh` or `init.ps1` if needed
   - Check 1-2 existing passing features still work

3. **Implement ONE Feature (TDD)**
   - Find the specified task in `feature_list.json`
   - **RED**: Create failing Playwright test in `tests/{feature}.spec.ts`
   - **GREEN**: Implement the feature to make the test pass
   - **REFACTOR**: Clean up and verify end-to-end

4. **Commit On Feature Branch**
   ```bash
   git add .
   git commit -m "feat({task-id}): {feature name}"
   git push origin $(git branch --show-current)
   ```

5. **Mark Complete**
   - Update `feature_list.json`: change `passes: false` to `passes: true`
   - Update `memory/claude-progress.md` with progress

## Branch Strategy

```
dev (main development)
 └── 001-user-authentication (Spec Kit feature branch)
      └── All implementation commits here
      └── PR to dev when ALL features pass
 └── 002-dashboard-widgets (another feature)
      └── ...
```

**Important**: No sub-branches! All work for a specification happens on the Spec Kit branch.

## Completion

When ALL features in `feature_list.json` pass:
1. Push all changes to the feature branch
2. Create PR from `{NNN}-{feature-name}` → `dev`
3. Document in PR what was implemented

## Hand-off

This command invokes the @Coder agent pattern. Refer to `.github/agents/coder.agent.md` for the full protocol.
