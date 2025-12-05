---
agent: agent
description: Initialize a new project with the Agent Harness Framework
tools:
  - editFiles
  - search
---

# Initialize Project

Set up the Agent Harness Framework in this workspace.

## Instructions

1. **Read the constitution** at `memory/constitution.md` to understand project principles

2. **Check existing structure**:
   - Review what agents exist in `.github/agents/`
   - Review what prompts exist in `.github/prompts/`
   - Check for existing memory in `memory/`

3. **Customize for this project**:
   - Update `memory/constitution.md` with project-specific principles
   - Add project context to `memory/context/project-overview.md`
   - Configure any project-specific agents

4. **Verify setup**:
   - Ensure VS Code settings are correct in `.vscode/settings.json`
   - Check MCP configuration in `.vscode/mcp.json` if needed

## Output

Provide a summary of:
- Framework components initialized
- Any customizations needed
- Next steps for the user
