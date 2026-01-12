---
name: skill-creator
description: Guide for creating effective Agent Skills during Spec Kit planning. Use when users want to create a new skill, update an existing skill, or when running /speckit.specify to create tech-stack-specific skills. Extends Copilot's capabilities with specialized knowledge, workflows, or tool integrations.
license: Apache-2.0
---

# Skill Creator

This skill provides guidance for creating effective skills during the Spec Kit planning workflow.

## About Skills

Skills are modular, self-contained packages that extend Copilot's capabilities by providing specialized knowledge, workflows, and tools. Think of them as "onboarding guides" for specific domains or tasks.

### What Skills Provide

1. Specialized workflows - Multi-step procedures for specific domains
2. Tool integrations - Instructions for working with specific file formats or APIs
3. Domain expertise - Project-specific knowledge, schemas, business logic
4. Bundled resources - Scripts, references, and assets for complex and repetitive tasks

## Skill Anatomy

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/          - Executable code (Python/Bash/PowerShell)
    ├── references/       - Documentation loaded into context as needed
    └── assets/           - Files used in output (templates, icons, etc.)
```

## When to Create Skills (Spec Kit Integration)

During `/speckit.specify`, create skills when:

1. **Tech stack detected** → Create stack-specific testing/build skills
2. **Repeated workflows identified** → Encapsulate into reusable skill
3. **Domain expertise needed** → Document schemas, APIs, business logic
4. **TDD patterns required** → Create project-specific test templates

## Quick Start: Initialize a Skill

```bash
# Bash/Mac/Linux
python .github/skills/skill-creator/scripts/init_skill.py <skill-name> --path .github/skills

# PowerShell/Windows
python .github\skills\skill-creator\scripts\init_skill.py <skill-name> --path .github\skills
```

The script creates:
- SKILL.md with proper frontmatter and TODO placeholders
- Example `scripts/`, `references/`, and `assets/` directories
- Placeholder files to customize or delete

## Writing Effective Skills

### Frontmatter (Required)

```yaml
---
name: my-skill-name
description: Clear description of what the skill does AND when to use it. Include specific triggers like file types, commands, or task types.
---
```

**CRITICAL**: The `description` is the primary triggering mechanism. Include:
- What the skill does
- Specific triggers/contexts for when to use it
- Example scenarios

### Body Guidelines

- Keep under 500 lines (use references/ for detailed docs)
- Use imperative form ("Create", "Run", "Verify")
- Include concrete examples, not abstract explanations
- Reference scripts as black boxes: "Run `scripts/foo.py --help`"

## Core Principles

### Concise is Key

The context window is shared. Only add what Copilot doesn't already know. Challenge each piece: "Does this justify its token cost?"

### Progressive Disclosure

1. **Metadata** (~100 tokens) - Always in context
2. **SKILL.md body** (<5k tokens) - When skill triggers
3. **Bundled resources** - Only when referenced

### Degrees of Freedom

- **High freedom**: Text instructions for context-dependent decisions
- **Medium freedom**: Pseudocode/scripts with parameters
- **Low freedom**: Specific scripts for fragile/critical operations

## Spec Kit Skill Creation Workflow

1. **During /speckit.specify**:
   - Detect tech stack (Node.js, Python, etc.)
   - Identify repeated workflows
   - Run `init_skill.py` for each skill needed

2. **During /speckit.plan**:
   - Reference skills in implementation plan
   - Document skill dependencies

3. **During /speckit.tasks**:
   - Include skill usage in task descriptions
   - Mark which tasks trigger which skills

4. **During @Coder / Ralph**:
   - Skills auto-activate based on description matching
   - No explicit invocation needed

## Resources

- **scripts/init_skill.py** - Initialize new skill directories
- **scripts/init_skill.ps1** - PowerShell wrapper for Windows
