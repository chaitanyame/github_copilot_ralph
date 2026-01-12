# Agent Harness Framework

A production-ready template for building **long-lived autonomous agents** within VS Code GitHub Copilot, combining [Anthropic's "Effective Harnesses for Long-Running Agents"](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) with [GitHub Spec Kit](https://github.com/github/spec-kit) and [Agent Skills](https://agentskills.io/).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-Enabled-blue.svg)](https://agentskills.io/)

## ✨ Key Features

- **🔄 Session Continuity** - File-based artifacts bridge context between agent sessions
- **📋 Spec-Driven Development** - Planning → Specification → Implementation workflow
- **🤖 Autonomous Mode (Ralph)** - Unattended batch implementation with security validation
- **🧪 TDD Enforcement** - Mandatory test-first gates before implementation
- **🎯 Agent Skills** - Auto-activating capabilities based on context
- **🔒 Security Profiles** - 3-layer command validation for autonomous execution
- **📊 Progress Tracking** - Real-time feature completion dashboard

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
| `memory/issues.json` | Adhoc bugs, hotfixes, and requests |
| `.github/skills/` | Auto-activating agent capabilities |
| Git branches | Isolated work per specification (created by Spec Kit) |

## Quick Start

### 1. Use as Template

Click "Use this template" on GitHub, or clone directly:

```bash
git clone https://github.com/chaitanyame/github_copilot_harness_framework.git my-project
cd my-project
```

### 2. Planning Phase (Spec Kit)

Use Spec Kit workflow to create specifications and generate feature list:

```
/speckit.constitution    # Define project principles (optional)
/speckit.specify "Your feature description"
/speckit.plan "Tech stack details"   # OR just /speckit.plan for Q&A
/speckit.tasks
/harness.generate
```

**Tech Stack Selection** - Two modes:
- **Expert**: `/speckit.plan Use React + Vite + TailwindCSS` (you provide the stack)
- **Guided**: `/speckit.plan` (Q&A asks 3-5 questions, suggests stack)

This creates:
- Specification in `specs/{branch}/spec.md`
- Implementation plan in `specs/{branch}/plan.md` (includes tech stack)
- Task breakdown in `specs/{branch}/tasks.md`
- Feature tracking in `memory/feature_list.json`
- **Spec Kit branch** (e.g., `003-your-feature-name`)
- **Stack-specific skills** if needed

### 3. Implementation Phase (Choose Your Mode)

**Option A: Interactive Mode** - For complex features or when supervision needed

```
@Coder Continue implementing features
```

Manual invocation per feature. Good for:
- Debugging complex issues
- Ambiguous requirements
- Learning the codebase

**Option B: Autonomous Mode (Ralph)** - For unattended batch implementation

```bash
# Bash (Linux/Mac)
./scripts/bash/ralph.sh --max-iterations 50

# PowerShell (Windows)
.\scripts\powershell\ralph.ps1 -MaxIterations 50
```

Autonomous loop until all features pass. Good for:
- Overnight runs
- Well-defined feature lists
- Batch processing 10-50 features

### 4. Create Pull Request

Once all features pass:

```bash
git push origin {branch-name}
# Create PR: {branch-name} → dev
```

## Workflow Overview

```
┌──────────────────────────────────────────────────────────────┐
│              SPEC KIT (Planning Phase)                       │
├──────────────────────────────────────────────────────────────┤
│  /speckit.constitution → Define project principles (optional)│
│  /speckit.specify      → Creates spec + auto-creates branch  │
│  /speckit.plan         → User provides OR Q&A selects stack  │
│  /speckit.tasks        → Generates task breakdown            │
│  /harness.generate     → Converts to feature_list.json       │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│         TECH STACK SELECTION (During /speckit.plan)          │
├──────────────────────────────────────────────────────────────┤
│  Expert Mode               │  Guided Mode (stack-advisor)    │
│  • User provides stack     │  • Q&A asks 3-5 questions       │
│  • /speckit.plan React...  │  • Suggests appropriate stack   │
│  • Proceed immediately     │  • User confirms/modifies       │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│         IMPLEMENTATION (Choose Your Mode)                    │
├──────────────────────────────────────────────────────────────┤
│  Interactive (@Coder)          │  Autonomous (Ralph)         │
│  • Manual per feature          │  • External loop runner     │
│  • Human supervision           │  • Unattended execution     │
│  • Good for debugging          │  • Good for batch work      │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│              PR & MERGE TO DEV                               │
├──────────────────────────────────────────────────────────────┤
│  All features passing + tests green + git clean              │
└──────────────────────────────────────────────────────────────┘
```

## Agent Skills

Agent Skills are **portable, auto-activating capabilities** that work across VS Code, CLI, and coding agents. Skills load on-demand based on description matching.

### Available Skills

| Skill | Triggers On | Purpose |
|-------|-------------|---------|
| `stack-advisor` | what framework, unsure, tech stack | Q&A for new projects (3-5 questions) |
| `tech-stack-detection` | existing project, detect stack | Auto-detect installed tech |
| `tdd-workflow` | TDD, testing, red-green-refactor | Enforces TDD Gate 1/2 compliance |
| `ralph-autonomous` | Ralph, autonomous, unattended | 10-step autonomous process |
| `spec-kit-planning` | spec, specification, planning | SDD workflow patterns |
| `frontend-design` | dashboard, React, HTML/CSS | Production-grade UI design |
| `webapp-testing` | testing, Playwright, verify UI | Browser automation testing |
| `skill-creator` | create skill, new skill | Create new custom skills |

### Tech Stack Skills

| Skill | Scenario | What It Does |
|-------|----------|--------------|
| `stack-advisor` | New project, user unsure | Asks 3-5 questions, suggests stack |
| `tech-stack-detection` | Existing project | Auto-detects from config files |

### How Skills Auto-Activate

1. **Level 1**: Copilot reads skill `name` + `description` (~100 tokens each)
2. **Level 2**: When prompt matches description, full SKILL.md loads
3. **Level 3**: Scripts/references load only when explicitly referenced

Skills follow the [agentskills.io](https://agentskills.io/) open standard.

### Creating Custom Skills

```bash
# During /speckit.plan, create stack-specific skills
python .github/skills/skill-creator/scripts/init_skill.py my-skill --path .github/skills

# Or PowerShell
.\\.github\\skills\\skill-creator\\scripts\\init_skill.ps1 -Name my-skill -Path .github/skills
```

## Complete Example Workflow

**End-to-end: From idea to merged PR**

```bash
# 1. PLANNING PHASE (Spec Kit in VS Code)
/speckit.specify "Real-time chat with WebSocket support"
/speckit.plan      # Auto-detects: Node.js, TypeScript, React, Socket.io
/speckit.tasks
/harness.generate

# Result: Branch 003-real-time-chat created with feature_list.json
# + Any stack-specific skills created (e.g., socketio-patterns)

# 2. IMPLEMENTATION PHASE (Choose one)

# Option A: Interactive
@Coder  # Implement features one-by-one with supervision

# Option B: Autonomous
./scripts/bash/ralph.sh --max-iterations 30  # Overnight run

# 3. REVIEW & MERGE
git push origin 003-real-time-chat
# Create PR in GitHub: 003-real-time-chat → dev
# Review, approve, merge
```

**Result:** Feature fully implemented, tested, and merged without manual coding.

## TDD Enforcement

All feature implementation follows **mandatory Test-Driven Development**:

```
┌──────────────────────────────────────────────────────────────┐
│  GATE 1: PRE-IMPLEMENTATION (Before writing ANY code)       │
├──────────────────────────────────────────────────────────────┤
│  □ Create test: tests/{feature}.spec.ts                     │
│  □ Run: npx playwright test tests/{feature}.spec.ts         │
│  □ Verify: Test FAILS                                       │
│  □ Update feature_list.json: test_fails_before: true        │
│  ⛔ CANNOT write implementation code until gate passes       │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│  GATE 2: POST-IMPLEMENTATION (Before marking passes:true)   │
├──────────────────────────────────────────────────────────────┤
│  □ Run: npx playwright test tests/{feature}.spec.ts         │
│  □ Verify: Test PASSES                                      │
│  □ Update feature_list.json: test_passes_after: true        │
│  ⛔ CANNOT set passes:true without test_passes_after:true   │
└──────────────────────────────────────────────────────────────┘
```

**Validate TDD gates:**
```bash
# Bash
./scripts/bash/verify-tdd-gates.sh

# PowerShell
.\\.github\\skills\\tdd-workflow\\scripts\\verify-tdd-gates.ps1
```

## Two Implementation Modes

### Interactive Mode (@Coder)

Step-by-step implementation with human oversight:
- Reads progress notes to get context
- Implements ONE feature at a time
- Waits for human approval between features
- Tests before marking complete
- Leaves clean state for next session

**When to use:**
- Complex features requiring judgment
- Debugging or troubleshooting
- Ambiguous requirements
- Learning or exploring codebase

### Autonomous Mode (Ralph)

Continuous implementation until completion:
- Fresh Copilot CLI session per iteration
- Implements ONE feature following 10-step TDD process
- Auto-commits and updates progress
- Loops until all features pass or max iterations
- 3-layer security validation on all commands

**When to use:**
- Well-defined feature lists
- Overnight or unattended runs
- Batch processing 10-50 features
- Clear acceptance criteria

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
│   ├── skills/           # Auto-activating agent skills
│   │   ├── frontend-design/
│   │   ├── webapp-testing/
│   │   ├── skill-creator/
│   │   ├── tdd-workflow/
│   │   ├── ralph-autonomous/
│   │   ├── spec-kit-planning/
│   │   └── tech-stack-detection/
│   ├── prompts/          # Reusable prompt commands
│   ├── instructions/     # Context-specific instructions
│   └── copilot-instructions.md
├── .vscode/
│   ├── mcp.json          # MCP server configuration
│   └── settings.json     # VS Code settings (includes chat.useAgentSkills)
├── memory/
│   ├── constitution.md   # Project principles
│   ├── feature_list.json # Source of truth
│   ├── issues.json       # Adhoc issues and bugs
│   ├── claude-progress.md # Session notes
│   ├── state/            # Agent checkpoints
│   ├── context/          # Persisted knowledge
│   └── sessions/         # Session logs
├── scripts/
│   ├── bash/             # Unix scripts
│   │   ├── ralph.sh      # Autonomous loop runner
│   │   ├── check-prerequisites.sh
│   │   ├── new-session.sh
│   │   └── setup-project.sh
│   ├── powershell/       # Windows scripts
│   │   ├── ralph.ps1     # Autonomous loop runner
│   │   ├── check-prerequisites.ps1
│   │   ├── new-session.ps1
│   │   └── setup-project.ps1
│   ├── security.sh       # Command validation (Bash)
│   ├── security.ps1      # Command validation (PowerShell)
│   ├── install-dependencies.sh
│   └── install-dependencies.ps1
├── templates/            # Templates for new agents/prompts
├── tests/
│   └── issues/           # Issue regression tests
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

## Issue Tracking

Issues are for adhoc work discovered outside the normal Spec Kit workflow:

```
/harness.issue "Description of bug or request"
/harness.issues   # View all issues
```

### Issue Categories

| Category | TDD Required? | Description |
|----------|---------------|-------------|
| `bug` | ✅ Yes | Regression test mandatory |
| `hotfix` | Optional | Urgent fix |
| `enhancement` | Recommended | Improvement |
| `adhoc` | No | One-off task |

Bug fixes require regression tests in `tests/issues/I{id}-{description}.spec.ts`

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

### Auto-Install Dependencies

Ralph includes **automatic dependency installation** with interactive prompts:

```bash
# When dependencies are missing:
Missing dependencies detected: npm, node

Options:
  Y - Install all missing dependencies (default)
  n - Skip and exit
  s - Select which to install

Your choice [Y/n/s]:
```

Supported package managers:
- **npm/node** - via nvm or system install
- **Playwright** - via npx playwright install
- **GitHub CLI** - via brew/apt/choco
- **gh-copilot** - via gh extension install

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

### Adding New Skills

Create a skill during `/speckit.plan` or manually:

```bash
# Python
python .github/skills/skill-creator/scripts/init_skill.py my-skill --path .github/skills

# PowerShell
.\\.github\\skills\\skill-creator\\scripts\\init_skill.ps1 -Name my-skill -Path .github/skills
```

Skill structure:
```
.github/skills/my-skill/
├── SKILL.md           # Required: skill definition
├── scripts/           # Optional: automation scripts
├── references/        # Optional: documentation
└── assets/            # Optional: images, data
```

## VS Code Settings

Required settings in `.vscode/settings.json`:

```json
{
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  "chat.promptFiles": true,
  "chat.useAgentsMdFile": true,
  "chat.useNestedAgentsMdFiles": true,
  "chat.useAgentSkills": true,
  "github.copilot.chat.agent.runTasks": true
}
```

## Prerequisites

- **VS Code** with GitHub Copilot extension
- **GitHub CLI** (`gh`) for autonomous mode
- **gh-copilot extension** for Ralph: `gh extension install github/gh-copilot`
- **Node.js** (v18+) for Playwright testing
- **Git** for version control

## Based On

This framework implements patterns from:
- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Anthropic Skills Repository](https://github.com/anthropics/skills)
- [GitHub Spec Kit](https://github.com/github/spec-kit)
- [Agent Skills Open Standard](https://agentskills.io/)

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on how to submit pull requests, report issues, and request features.

Please note that this project is released with a [Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## License

MIT License - see [LICENSE](LICENSE) for details.
