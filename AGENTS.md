# Agent Harness Framework

This file provides cross-agent instructions compatible with multiple AI assistants (Claude, Copilot, Cursor, etc.).

> Based on [Anthropic's "Effective Harnesses for Long-Running Agents"](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
> Integrated with [GitHub Spec Kit](https://github.com/github/spec-kit) SDD workflow

## The Long-Running Agent Problem

Agents working across many sessions face a core challenge: **each new session starts with no memory**. Without proper scaffolding, agents tend to:
- Try to do too much at once (one-shotting)
- Declare victory prematurely
- Leave the environment in a broken state
- Waste time figuring out what happened previously

## Solution: Spec Kit + Harness Integration

### Spec Kit Workflow (Planning Phase)
1. `/speckit.specify` - Creates specification + **auto-creates branch**
2. `/speckit.plan` - Creates implementation plan
3. `/speckit.tasks` - Generates task list
4. `/harness.generate` - Converts tasks to feature_list.json

### Harness Workflow (Implementation Phase)
5. `@Coder` - Implements features one at a time on Spec Kit branch
6. Repeat @Coder until all features pass
7. Create PR to merge to dev

## Branch Strategy

Branches are created by **Spec Kit**, not manually:

```
dev (integration branch)
 └── 001-user-authentication   ← /speckit.specify creates this
      └── All @Coder commits here
      └── PR to dev when complete
 └── 002-dashboard-widgets     ← Another /speckit.specify
      └── ...
```

## Critical Artifacts

| Artifact | Purpose |
|----------|---------|
| `specs/{branch}/spec.md` | Feature specification |
| `specs/{branch}/plan.md` | Implementation plan |
| `specs/{branch}/tasks.md` | Detailed task list |
| `memory/feature_list.json` | Source of truth - features with pass/fail |
| `memory/claude-progress.md` | Session notes - what happened, what's next |
| Git branch | All work isolated per specification |

## Agent Session Protocol

### Starting a Session
1. Run `git branch --show-current` to verify you're on Spec Kit branch
2. Read `memory/claude-progress.md` for context
3. Read `memory/feature_list.json` to see all work
4. Read `specs/{branch}/spec.md` for specification context
5. Run `init.sh` to start servers (if applicable)
6. Verify 1-2 passing features still work

### During a Session (TDD MANDATORY)

> ⚠️ **BLOCKING**: Do NOT write implementation code before the test exists and fails.

1. Pick ONE high-priority feature with `passes: false`
2. **TDD Step 1 (RED)**: Create a failing automated test in `tests/{feature}.spec.ts`
   - Run test to confirm it FAILS: `npx playwright test tests/{feature}.spec.ts`
   - If test passes without implementation, your test is wrong
3. **TDD Step 2 (GREEN)**: Implement ONLY enough code to pass the test
   - Run test to confirm it PASSES
   - Do not move on until test passes
4. **TDD Step 3 (REFACTOR)**: Clean up code, verify end-to-end
   - Run test again to ensure still passes
   - Browser verification for UI features
5. Update `feature_list.json` (ONLY the `passes` field)
6. Commit on the Spec Kit branch

### Ending a Session
1. Ensure all work is committed to Spec Kit branch
2. Push to remote
3. Update `memory/claude-progress.md` with:
   - What was accomplished
   - Issues discovered
   - What should happen next
   - Current progress (X/Y features passing)
4. Leave environment in working state

### Progress Update Triggers

Update `memory/claude-progress.md` **immediately** when:

| Trigger | Required? |
|---------|-----------|
| Feature completed and verified | ✅ Mandatory |
| Bug or issue discovered | ✅ Mandatory |
| Before ending session | ✅ Mandatory |
| After recovering from failure | ✅ Mandatory |
| Mid-session (context getting full) | Optional |

**Rule:** *"If you wouldn't remember it tomorrow, write it down now."*

## Feature List Rules

The `memory/feature_list.json` is sacred:
- ✅ Change `"passes": false` to `"passes": true` when verified
- ❌ NEVER remove features
- ❌ NEVER edit descriptions
- ❌ NEVER modify steps
- ❌ NEVER reorder features

## Failure Recovery

If the environment is broken:
1. Check git log for recent changes
2. Revert problematic commits: `git revert HEAD`
3. Fix the issue before continuing
4. Mark affected features as `passes: false`
5. Document in progress notes

## Core Principles

1. **One feature at a time** - Don't try to do too much
2. **Verify before implementing** - Check existing work first
3. **Leave clean state** - No half-finished work
4. **Document everything** - Next agent has zero memory
5. **Quality over speed** - Production-ready is the goal

## File Conventions

- Agent definitions: `.github/agents/*.agent.md`
- Prompt commands: `.github/prompts/*.prompt.md`
- Instructions: `.github/instructions/*.instructions.md`
- Feature tracking: `memory/feature_list.json`
- Progress notes: `memory/claude-progress.md`
- State files: `memory/state/*.json`
- Session logs: `memory/sessions/YYYY-MM-DD-HH-MM.md`
