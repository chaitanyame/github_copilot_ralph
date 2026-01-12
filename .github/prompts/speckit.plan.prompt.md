# /speckit.plan - Create Implementation Plan

Create an implementation plan for the current feature specification.

> **Note**: This command runs on the feature branch created by `/speckit.specify`

## Prerequisites

- Must be on a feature branch (e.g., `003-real-time-chat`)
- Specification must exist at `specs/{branch-name}/spec.md`

## Instructions

### Step 1: Verify Branch and Read Spec

1. Verify you're on the correct feature branch:
   ```bash
   git branch --show-current
   # Should return something like: 003-real-time-chat
   ```

2. Read `memory/constitution.md` for project principles

3. Read the specification:
   ```bash
   BRANCH=$(git branch --show-current)
   cat specs/$BRANCH/spec.md
   ```

### Step 2: Determine Tech Stack (Two Modes)

Check if user provided tech stack in the command arguments.

#### Mode A: Expert Mode (User Provided Tech Stack)

If user runs `/speckit.plan` WITH tech stack details like:
```
/speckit.plan Use React 18 + Vite + TailwindCSS + Playwright for testing
```

→ **Proceed directly to Step 3** using the provided stack.

#### Mode B: Guided Mode (No Tech Stack Provided)

If user runs `/speckit.plan` WITHOUT tech stack details:
```
/speckit.plan
```

→ **Activate the `stack-advisor` skill** and run the Q&A flow:

1. Ask Question 1: Project Type (web app, API, CLI, etc.)
2. Ask Question 2: Project Scale (prototype, medium, large)
3. Ask Question 3: Key Requirements (real-time, SEO, performance, etc.)
4. Ask Question 4: Team Preference (beginner-friendly, modern, cutting-edge) - optional
5. Ask Question 5: Constraints (must use X, avoid Y) - optional

Based on answers, recommend a tech stack using the decision matrix in `.github/skills/stack-advisor/SKILL.md`.

Present the recommendation and ask for confirmation:
```
Recommended: Next.js + TypeScript + TailwindCSS + Playwright

Proceed with this stack? (Y/n/modify)
```

Once confirmed → Proceed to Step 3.

#### Mode C: Existing Project (Auto-Detect)

For **existing projects** with established code, detect the stack:

```bash
# Bash/Mac/Linux
./.github/skills/tech-stack-detection/scripts/detect-stack.sh

# PowerShell/Windows
.\.github\skills\tech-stack-detection\scripts\detect-stack.ps1
```

Present detected stack and ask for confirmation before proceeding.

### Step 3: Create Stack-Specific Skills (If Needed)

Based on the confirmed tech stack, create relevant skills if they don't exist:

| Detected | Create Skill |
|----------|--------------|
| React | `react-patterns` |
| Next.js | `nextjs-patterns` |
| Vue | `vue-patterns` |
| Node.js API | `api-patterns` |
| Python | `python-patterns` |

```bash
# Check if skill exists
ls .github/skills/{stack}-patterns 2>/dev/null

# Create if missing
python .github/skills/skill-creator/scripts/init_skill.py {stack}-patterns --path .github/skills
```

Edit the generated `SKILL.md` with project-specific patterns, conventions, and examples.

### Step 4: Create the Implementation Plan

Create `specs/{branch-name}/plan.md` using the template below.

## Plan Template

```markdown
# Implementation Plan

**Feature Branch**: {branch-name}
**Specification**: [spec.md](spec.md)
**Created**: {YYYY-MM-DD}

## Tech Stack

| Category | Technology |
|----------|------------|
| Language | {TypeScript, Python, etc.} |
| Framework | {React, Next.js, etc.} |
| Testing | {Playwright, Jest, etc.} |
| Build | {Vite, Webpack, etc.} |

**Skills Used**: {list of .github/skills/* that apply}

## Specifications Covered
- [spec.md](spec.md)

## Implementation Phases

### Phase 1: {Phase Name}
**Goal**: {What this phase achieves}
**Duration**: {Estimated sessions}

#### Tasks
1. {Task 1}
   - Depends on: {dependencies}
   - Complexity: {low/medium/high}
2. {Task 2}

### Phase 2: {Phase Name}
...

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| {Risk 1} | {L/M/H} | {L/M/H} | {Strategy} |

## Success Criteria
- [ ] {Criterion 1}
- [ ] {Criterion 2}

## Open Decisions
- {Decision 1}: {options}
```

## Output

After running this command:
1. ✅ Tech stack detected
2. ✅ Stack-specific skills created (if needed)
3. ✅ Implementation plan created: `specs/{branch-name}/plan.md`

Report to user:
```
Tech Stack Detected:
  Language: TypeScript
  Framework: React, Vite
  Testing: Playwright
  
Skills: Using frontend-design, webapp-testing, tdd-workflow
Created: .github/skills/react-patterns/ (new)

Plan created: specs/003-real-time-chat/plan.md

Next step: /speckit.tasks
```

## Next Step

Run `/speckit.tasks` to convert plan into actionable tasks.
