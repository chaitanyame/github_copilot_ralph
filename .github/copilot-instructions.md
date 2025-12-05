# Agent Harness Framework - Global Copilot Instructions

This workspace uses the **Agent Harness Framework** for building long-lived autonomous agents within GitHub Copilot, based on [Anthropic's "Effective Harnesses for Long-Running Agents"](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents).

## Framework Overview

This framework solves the core challenge of long-running agents: **bridging context between sessions**. Each new session starts with no memory, so we use file-based artifacts to maintain continuity.

Key artifacts:
- **`memory/feature_list.json`** - Source of truth for all work (features with pass/fail status)
- **`memory/claude-progress.md`** - Session-to-session progress notes
- **`init.sh`** - Environment setup script (created by initializer)
- **Git commits** - Incremental progress with descriptive messages

## Two-Agent Pattern

1. **@Initializer** (Session 1) - Sets up foundation:
   - Creates comprehensive `feature_list.json`
   - Sets up project structure
   - Creates `init.sh` for environment setup
   - Makes initial git commit

2. **@Coder** (Sessions 2+) - Incremental progress:
   - Reads progress notes and feature list
   - Picks ONE feature to implement
   - Verifies, implements, and commits
   - Updates progress notes for next session

## Critical Principles

1. **One feature at a time** - Don't try to do too much in one session
2. **Verify before implementing** - Check existing features still work
3. **Feature list is sacred** - Only modify the `passes` field
4. **Leave clean state** - No half-finished work, all committed
5. **Document for the next agent** - They have zero memory

## Available Agents

| Agent | Purpose |
|-------|---------|
| `@Initializer` | First session setup (feature list, structure) |
| `@Coder` | Incremental feature implementation |
| `@Planner` | Strategic planning and task breakdown |
| `@Researcher` | Context gathering and analysis |
| `@Reviewer` | Code review and quality assurance |
| `@Orchestrator` | Multi-agent workflow coordination |

## Memory System

```
memory/
├── constitution.md      # Project principles (read before significant work)
├── feature_list.json    # Source of truth for all features
├── claude-progress.md   # Session-to-session notes
├── state/               # Agent checkpoints (JSON/MD)
├── context/             # Persisted knowledge
└── sessions/            # Session logs (audit trail)
```

## Getting Started

1. Use `@Initializer` for the first session
2. Use `@Coder` for subsequent sessions
3. Always read `memory/claude-progress.md` first
4. Always update progress notes before ending

## Custom Instructions

File-specific instructions in `.github/instructions/` are applied based on `applyTo` glob patterns.
