# Claude Progress Notes

This file bridges context between agent sessions. Each agent reads this at the start of their session and updates it at the end.

## Current Status

**Project**: Agent Harness Framework (Template Repository)
**Status**: Ready for use as template
**Features**: Template - not applicable

## What's Been Done

This is a **template repository** for building long-lived agents. It includes:

- ✅ Directory structure for agents, prompts, and memory
- ✅ Spec Kit prompts (`/speckit.*`) for spec-driven development
- ✅ Harness prompts (`/harness.*`) for session management
- ✅ Agent definitions (Initializer, Coder, Planner, Researcher, Reviewer, Orchestrator)
- ✅ Scripts for project setup (Bash and PowerShell)
- ✅ Templates for specs, plans, tasks, and feature lists
- ✅ VS Code configuration for Copilot integration

## How to Use This Template

1. **Create a new repo** from this template
2. **Run setup script**: `./scripts/bash/setup-project.sh` or `.\scripts\powershell\setup-project.ps1`
3. **Define your constitution**: `/speckit.constitution`
4. **Create specifications**: `/speckit.specify`
5. **Generate plan**: `/speckit.plan` → `/speckit.tasks` → `/harness.generate`
6. **Implement features**: `@Coder` for incremental sessions

## Quick Reference

| Command | Purpose |
|---------|---------|
| `/speckit.constitution` | Define project principles |
| `/speckit.specify` | Create feature spec |
| `/speckit.plan` | Create implementation plan |
| `/speckit.tasks` | Generate task list |
| `/harness.generate` | Convert to feature_list.json |
| `/harness.status` | View progress |
| `@Initializer` | Quick setup (alternative) |
| `@Coder` | Implement features |

---

## Session Log Format

When using this template for a real project, update this file with:

```markdown
### Session N - YYYY-MM-DD HH:MM

**Agent**: [agent name]
**Duration**: ~X minutes
**Features Completed**: X/Y

#### Accomplished
- [What was done]

#### Issues Found
- [Any bugs or problems discovered]

#### Next Steps
- [What the next agent should do]
```
