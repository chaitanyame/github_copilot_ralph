# Agent Harness Framework

This file provides cross-agent instructions compatible with multiple AI assistants (Claude, Copilot, Cursor, etc.).

> Based on [Anthropic's "Effective Harnesses for Long-Running Agents"](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)

## The Long-Running Agent Problem

Agents working across many sessions face a core challenge: **each new session starts with no memory**. Without proper scaffolding, agents tend to:
- Try to do too much at once (one-shotting)
- Declare victory prematurely
- Leave the environment in a broken state
- Waste time figuring out what happened previously

## Solution: Two-Agent Pattern

### 1. Initializer Agent (Session 1)
Sets up the foundation:
- Creates `memory/feature_list.json` with all features/tasks
- Sets up project structure
- Creates `init.sh` for environment setup
- Makes initial git commit
- Documents everything for future agents

### 2. Coder Agent (Sessions 2+)
Makes incremental progress:
- Reads progress notes to get bearings
- Verifies existing features still work
- Picks ONE feature to implement
- Tests and verifies before marking complete
- Commits progress and updates notes

## Critical Artifacts

| Artifact | Purpose |
|----------|---------|
| `memory/feature_list.json` | Source of truth - all features with pass/fail status |
| `memory/claude-progress.md` | Session notes - what happened, what's next |
| `init.sh` | Environment setup script |
| Git history | Incremental progress, ability to revert |

## Agent Session Protocol

### Starting a Session
1. Run `pwd` to see working directory
2. Read `memory/claude-progress.md` for context
3. Read `memory/feature_list.json` to see all work
4. Check `git log --oneline -20` for recent changes
5. Run `init.sh` to start servers (if applicable)
6. Verify 1-2 passing features still work

### During a Session
1. Pick ONE high-priority feature with `passes: false`
2. Implement the feature completely
3. Test and verify end-to-end
4. Update `feature_list.json` (ONLY the `passes` field)
5. Commit with descriptive message

### Ending a Session
1. Ensure all work is committed
2. Update `memory/claude-progress.md` with:
   - What was accomplished
   - Issues discovered
   - What should happen next
   - Current progress (X/Y features passing)
3. Leave environment in working state

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
