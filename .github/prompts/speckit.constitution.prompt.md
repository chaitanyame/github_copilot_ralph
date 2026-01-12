# /speckit.constitution - Create Project Constitution

Create or update a project constitution that defines the core **principles, values, and quality standards** for this project.

## IMPORTANT: Scope Boundaries

✅ **Constitution defines:**
- Project vision and goals
- Design philosophy and aesthetic values
- Quality standards and acceptance criteria
- Development principles (TDD, accessibility, performance)
- Documentation requirements

❌ **Constitution does NOT decide:**
- Specific technologies (React, Vue, Python, etc.)
- Libraries or frameworks
- File structure or architecture
- These are decided during `/speckit.plan` after analyzing requirements

## Instructions

1. Ask the user about their project vision and design philosophy
2. Create a `memory/constitution.md` file with:
   - **Project Vision**: What this project aims to achieve
   - **Design Philosophy**: Aesthetic values, inspiration, style guidelines
   - **Core Principles**: Guiding values for all decisions
   - **Quality Standards**: Performance, accessibility, testing requirements
   - **Development Principles**: TDD mandatory, code review, documentation
   - **Acceptance Criteria**: What must pass before work is considered done

3. If a constitution already exists, review and update it based on any new context

## Output Format

```markdown
# {Project Name} Constitution

## Vision
{Clear statement of project goals}

## Design Philosophy
{Aesthetic values, inspiration sources, style guidelines}
{e.g., "Minimalist Apple aesthetic", "Bold and colorful", "Corporate professional"}

## Core Principles
1. {Principle 1 - e.g., "TDD mandatory"}
2. {Principle 2 - e.g., "Mobile-first responsive design"}
3. {Principle 3 - e.g., "Performance is non-negotiable"}
...

## Quality Standards
- Lighthouse Performance > {target}
- Lighthouse Accessibility > {target}
- WCAG {level} compliant
- {other measurable standards}

## Development Principles
- Test-Driven Development (write test first, then implement)
- {other development practices}

## Acceptance Criteria
- [ ] All tests pass
- [ ] Meets performance targets
- [ ] Accessibility validated
- [ ] Documentation complete
```

## Next Steps

After constitution is created, guide the user:

> Constitution created! Your project principles are now defined.
>
> Next: Use `/speckit.specify "feature description"` to create your first feature specification.
> The tech stack will be determined during `/speckit.plan` based on your requirements.

## Important

The constitution is a living document that guides all agents. Read it before significant work.
