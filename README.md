# Agent Harness Framework

A template repository for building **long-lived autonomous agents** within VS Code GitHub Copilot, based on [Anthropic's "Effective Harnesses for Long-Running Agents"](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents).

## The Problem

AI agents face a fundamental challenge: **each new context window starts with no memory**. Without proper scaffolding:
- Agents try to do too much at once
- They declare victory prematurely  
- Work gets left in broken states
- Time is wasted re-discovering context

## The Solution

This framework provides file-based artifacts that bridge context between sessions:

| Artifact | Purpose |
|----------|---------|
| `memory/feature_list.json` | Source of truth - all features with pass/fail tracking |
| `memory/claude-progress.md` | Session notes - what happened, what's next |
| `init.sh` / `init.ps1` | Environment setup script |
| Git history | Incremental progress with rollback capability |

## Quick Start

### 1. Use as Template

Click "Use this template" on GitHub, or clone directly:

```bash
git clone https://github.com/anthropics/agent-harness-framework.git my-project
cd my-project
```

### 2. Initialize Your Project

In VS Code with GitHub Copilot, invoke the Initializer agent:

```
@Initializer Set up a [describe your project]
```

The Initializer will:
- Create `memory/feature_list.json` with all features
- Set up project structure
- Create `init.sh` for environment setup
- Make the initial git commit

### 3. Implement Features

Use the Coder agent for subsequent sessions:

```
@Coder Continue implementing features
```

The Coder will:
- Read progress notes to get context
- Pick one feature to implement
- Test and verify
- Commit and update progress

## Two-Agent Pattern

### Initializer (Session 1)

Sets up the foundation for all future work:
- Creates comprehensive feature list
- Establishes project structure
- Documents everything for future agents

### Coder (Sessions 2+)

Makes incremental progress:
- Reads previous session notes
- Implements ONE feature at a time
- Tests before marking complete
- Leaves clean state for next session

## Autonomous Mode (Ralph)

For unattended implementation, use the **Ralph autonomous loop runner**:

```bash
# Bash
./scripts/bash/ralph.sh --max-iterations 50

# PowerShell
.\scripts\powershell\ralph.ps1 -MaxIterations 50
```

**How it works:**
1. Reads `feature_list.json` and selects next feature with `passes: false`
2. Invokes Copilot CLI with autonomous coding prompt
3. Agent implements ONE feature following 10-step TDD process
4. Commits changes and updates progress
5. Repeats until all features pass or max iterations reached

**Security:** All bash commands are validated through 3-layer defense:
- ✅ Allowlist (only safe commands permitted)
- ✅ Deny list (dangerous patterns blocked)
- ✅ Context validation (e.g., `rm -rf` only for safe patterns)

**Options:**
```bash
--max-iterations N    # Maximum loops (default: 50)
--profile PROFILE     # Security: locked, safe, dev (default: safe)
--once                # Single iteration (for testing)
--resume              # Resume from saved state
--reset               # Reset state and start fresh
```

See [Autonomous Mode Guide](#autonomous-mode-guide) for details.

## Directory Structure

```
├── .github/
│   ├── agents/           # Agent definitions
│   │   ├── initializer.agent.md
│   │   ├── coder.agent.md
│   │   ├── planner.agent.md
│   │   ├── researcher.agent.md
│   │   ├── reviewer.agent.md
│   │   └── orchestrator.agent.md
│   ├── prompts/          # Reusable prompt commands
│   ├── instructions/     # Context-specific instructions
│   └── copilot-instructions.md
├── .vscode/
│   ├── mcp.json          # MCP server configuration
│   └── settings.json     # VS Code settings
├── memory/
│   ├── constitution.md   # Project principles
│   ├── feature_list.json # Source of truth
│   ├── issues.json       # Adhoc issues and bugs
│   ├── claude-progress.md # Session notes
│   ├── state/            # Agent checkpoints
│   ├── context/          # Persisted knowledge
│   └── sessions/         # Session logs
├── templates/            # Templates for new agents/prompts
├── AGENTS.md             # Cross-agent instructions
├── init.sh               # Setup script (Unix)
├── init.ps1              # Setup script (Windows)
└── README.md
```

## Critical Rules

### Feature List is Sacred

`memory/feature_list.json` is the single source of truth:
- ✅ Change `"passes": false` → `"passes": true` when verified
- ❌ NEVER remove features
- ❌ NEVER edit descriptions  
- ❌ NEVER modify steps
- ❌ NEVER reorder features

### One Feature at a Time

Each session should focus on ONE feature:
1. Pick highest priority with `passes: false`
2. Implement completely
3. Test and verify
4. Commit and document

### Leave Clean State

Before ending any session:
- All work committed
- Progress notes updated
- No broken features
- Ready for next agent

## Available Agents

| Agent | Purpose | Use When |
|-------|---------|----------|
| `@Initializer` | First session setup | Starting new project |
| `@Coder` | Feature implementation | Continuing development |
| `@Planner` | Task breakdown | Complex planning needed |
| `@Researcher` | Context gathering | Need to understand codebase |
| `@Reviewer` | Quality assurance | Review completed work |
| `@Orchestrator` | Multi-agent coordination | Complex multi-step workflows |

## Workflows

### Spec-Driven Development (Recommended)

Use this workflow for new projects or features:

```
/speckit.constitution  →  Define project principles
       ↓
/speckit.specify      →  Create feature specifications
       ↓
/speckit.plan         →  Create implementation plan
       ↓
/speckit.tasks        →  Generate detailed task list
       ↓
/harness.generate     →  Convert to feature_list.json
       ↓
@Coder                →  Implement incrementally
```

### Quick Start Workflow

Use this for simpler projects:

```
@Initializer          →  Set up everything at once
       ↓
@Coder                →  Implement features
```

## Prompt Commands

### Spec Kit Commands

| Command | Purpose |
|---------|---------|
| `/speckit.constitution` | Create project principles and standards |
| `/speckit.specify` | Create detailed feature specification |
| `/speckit.plan` | Create implementation plan from specs |
| `/speckit.tasks` | Generate actionable task list |
| `/speckit.implement` | Implement a specific task |

### Harness Commands

| Command | Purpose |
|---------|---------|
| `/harness.generate` | Convert tasks.md to feature_list.json |
| `/harness.status` | View progress dashboard |
| `/harness.verify` | Verify passing features |
| `/harness.checkpoint` | Save session state |
| `/harness.resume` | Resume from checkpoint |
| `/harness.issue` | Add adhoc bug, hotfix, or request |
| `/harness.issues` | View issue tracking dashboard |

## Autonomous Mode Guide

### When to Use Autonomous Mode

**Use autonomous mode (Ralph) when:**
- ✅ Feature list is well-defined with clear acceptance criteria
- ✅ Running overnight or unattended
- ✅ Batch processing multiple features
- ✅ All features follow similar patterns

**Use interactive mode (@Coder) when:**
- ❌ Requirements are ambiguous
- ❌ Need to debug complex issues
- ❌ Features require human judgment
- ❌ Learning or exploring the codebase

### Prerequisites

1. **Install GitHub Copilot CLI:**
```bash
gh extension install github/gh-copilot
```

2. **Verify installation:**
```bash
gh copilot --version
```

3. **Create feature list:**
```
@Initializer Set up [your project]
```

### Running Autonomous Loop

**Basic usage:**
```bash
# Bash (Linux/Mac)
./scripts/bash/ralph.sh

# PowerShell (Windows)
.\scripts\powershell\ralph.ps1
```

**Advanced usage:**
```bash
# Run up to 100 iterations
./scripts/bash/ralph.sh --max-iterations 100

# Use restrictive security profile
./scripts/bash/ralph.sh --profile locked

# Test single iteration
./scripts/bash/ralph.sh --once

# Resume interrupted session
./scripts/bash/ralph.sh --resume

# Reset and start fresh
./scripts/bash/ralph.sh --reset
```

### Security Profiles

| Profile | Allows | Use Case |
|---------|--------|----------|
| `locked` | File operations only | Maximum safety |
| `safe` (default) | git, npm, npx, playwright | Normal development |
| `dev` | Broader shell access | Advanced use |

**All profiles block:**
- `rm -rf` (except node_modules, .git)
- `git push --force`
- Pipe to shell (`curl ... \| sh`)
- System commands (dd, mkfs, fdisk)

### Monitoring Progress

**Check status:**
```bash
# View progress notes
cat memory/claude-progress.md

# Check feature stats
jq '[.features[] | select(.passes == true)] | length' memory/feature_list.json

# View state
cat memory/.ralph/state.json
```

**Watch in real-time:**
```bash
# Bash
tail -f memory/claude-progress.md

# PowerShell
Get-Content memory\claude-progress.md -Wait
```

### Stopping and Resuming

**Stop gracefully:** Press `Ctrl+C` (state is saved after each iteration)

**Resume:** Run with `--resume` flag
```bash
./scripts/bash/ralph.sh --resume
```

**Reset state:**
```bash
./scripts/bash/ralph.sh --reset
```

### Completion Criteria

Ralph exits with success when:
1. ✅ All features in `feature_list.json` have `passes: true`
2. ✅ All TDD gates pass (`test_fails_before` and `test_passes_after`)
3. ✅ Git working tree is clean (no uncommitted changes)

### Troubleshooting

**Issue:** Rate limited
- **Solution:** Ralph auto-detects and waits. Clamps max wait to 1 hour.

**Issue:** Feature blocked
- **Solution:** Agent outputs `FEATURE_BLOCKED: reason`. Fix manually and resume.

**Issue:** Loop stuck on same feature
- **Solution:** Check `memory/claude-progress.md` for errors. Fix issue, mark feature `passes: false`, and resume.

**Issue:** Security rejection
- **Solution:** Command not in allowlist. Either add to `scripts/security.sh` or perform manually.

## Customization

### Adding New Agents

Create a file in `.github/agents/`:

```markdown
---
name: MyAgent
description: What this agent does
tools:
  - editFiles
  - search
---

# My Agent

Instructions for the agent...
```

### Adding New Prompts

Create a file in `.github/prompts/`:

```markdown
---
agent: agent
description: What this prompt does
---

# My Prompt

Prompt content...
```

## Based On

This framework implements patterns from:
- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Anthropic Quickstart: Autonomous Coding](https://github.com/anthropics/claude-quickstarts/tree/main/autonomous-coding)

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on how to submit pull requests, report issues, and request features.

Please note that this project is released with a [Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## License

MIT License - see [LICENSE](LICENSE) for details.
