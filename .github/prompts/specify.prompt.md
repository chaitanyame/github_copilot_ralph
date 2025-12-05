---
agent: agent
description: Create a specification for a new feature or task
tools:
  - search
  - fetch
---

# Create Specification

Create a detailed specification for a feature or task.

## User Input

$ARGUMENTS

## Instructions

1. **Understand the request**:
   - What is the user trying to accomplish?
   - What are the success criteria?
   - What constraints exist?

2. **Research context**:
   - Check `memory/context/` for relevant project knowledge
   - Search codebase for related patterns
   - Identify affected systems

3. **Create specification**:
   
   ```markdown
   # Specification: {Title}
   
   ## Overview
   Brief description of what will be built
   
   ## Background
   Why this is needed, context
   
   ## Requirements
   
   ### Functional Requirements
   - FR1: Description
   - FR2: Description
   
   ### Non-Functional Requirements
   - NFR1: Description (performance, security, etc.)
   
   ## Success Criteria
   - [ ] Criterion 1
   - [ ] Criterion 2
   
   ## Scope
   
   ### In Scope
   - Item 1
   - Item 2
   
   ### Out of Scope
   - Item 1
   
   ## Technical Considerations
   - Consideration 1
   - Consideration 2
   
   ## Open Questions
   - Question 1
   - Question 2
   ```

4. **Save specification**:
   - Save to `memory/state/spec-{task-id}.md`

## Next Steps

After specification is approved, hand off to @Planner to create an implementation plan.
