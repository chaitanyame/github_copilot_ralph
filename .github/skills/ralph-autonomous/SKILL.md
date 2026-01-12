---
name: ralph-autonomous
description: Autonomous coding patterns for unattended feature implementation using Ralph loop runner. Use when running Ralph autonomous loop, implementing features without supervision, handling long-running agent sessions, or when context mentions Ralph, autonomous, unattended, or batch implementation.
---

# Ralph Autonomous Skill

Encapsulates the 10-step autonomous coding process for the Ralph loop runner.

## Context Recovery (Every Session Start)

Fresh context protocol - MANDATORY before any work:

```bash
# 1. Verify branch
git branch --show-current

# 2. Read progress notes
cat memory/claude-progress.md

# 3. Read feature list
cat memory/feature_list.json

# 4. Read spec context
cat specs/{branch}/spec.md

# 5. Verify 1-2 passing features still work
npx playwright test tests/{passing-feature}.spec.ts
```

## 10-Step Autonomous Process

```
┌─────────────────────────────────────────────────────────────────┐
│  RALPH 10-STEP AUTONOMOUS LOOP                                  │
├─────────────────────────────────────────────────────────────────┤
│  1. ORIENT    - Load context from memory/ files                 │
│  2. VERIFY    - Regression check on previous work               │
│  3. CHOOSE    - Select next feature with passes: false          │
│  4. TEST FIRST- Create failing test (TDD Gate 1)                │
│  5. IMPLEMENT - Write minimal code to pass test                 │
│  6. VERIFY    - Run test to confirm pass (TDD Gate 2)           │
│  7. UPDATE    - Mark feature passes: true in feature_list.json  │
│  8. COMMIT    - Git commit with descriptive message             │
│  9. PROGRESS  - Update claude-progress.md                       │
│  10. SIGNAL   - Output completion status                        │
└─────────────────────────────────────────────────────────────────┘
```

## Completion Signals

Output these signals for the external loop runner to detect:

| Signal | Meaning |
|--------|---------|
| `FEATURE_COMPLETE: {id}` | Feature done, continue to next |
| `ALL_FEATURES_COMPLETE` | All features pass, stop loop |
| `FEATURE_BLOCKED: {reason}` | Cannot proceed, needs human intervention |
| `ENVIRONMENT_ERROR: {error}` | System issue, stop and report |

## State Management

Ralph maintains state in `memory/.ralph/state.json`:

```json
{
  "last_completed_feature": "F003",
  "iteration_count": 5,
  "last_run": "2026-01-11T10:30:00Z",
  "status": "in_progress",
  "blocked_features": []
}
```

Use for resume capability after interruption.

## Progress Update Triggers

Update `memory/claude-progress.md` IMMEDIATELY when:

| Trigger | Required? |
|---------|-----------|
| Feature completed and verified | ✅ Mandatory |
| Bug or issue discovered | ✅ Mandatory |
| Before ending session | ✅ Mandatory |
| After recovering from failure | ✅ Mandatory |

**Rule:** *"If you wouldn't remember it tomorrow, write it down now."*

## Feature List Rules

The `memory/feature_list.json` is sacred:

✅ Change `passes: false` to `passes: true` when verified
❌ NEVER remove features
❌ NEVER edit descriptions
❌ NEVER modify steps
❌ NEVER reorder features

## Failure Recovery

If environment is broken:

1. Check git log for recent changes
2. Revert problematic commits: `git revert HEAD`
3. Fix the issue before continuing
4. Mark affected features as `passes: false`
5. Document in progress notes

## Resources

- **scripts/context-recovery.sh** - Automated context loading (Bash)
- **scripts/context-recovery.ps1** - Automated context loading (PowerShell)
