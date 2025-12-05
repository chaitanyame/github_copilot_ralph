---
agent: agent
description: Review completed implementation
tools:
  - search
  - usages
---

# Review Implementation

Review code changes for quality and correctness.

## User Input

$ARGUMENTS

## Instructions

Reference the @Reviewer agent for review methodology.

1. **Gather context**:
   - Find the relevant plan in `memory/state/`
   - Understand what was supposed to be built
   - Review project conventions

2. **Identify changes**:
   - Search for recently modified files
   - Or review files specified in user input

3. **Perform review**:
   
   Check each file for:
   - [ ] Correctness - Does it work as intended?
   - [ ] Quality - Is the code clean and readable?
   - [ ] Conventions - Does it follow project standards?
   - [ ] Security - Are there any security concerns?
   - [ ] Tests - Is test coverage adequate?

4. **Create review report**:

   ```markdown
   # Review: {Task Title}

   ## Summary
   Overall: ✅ Approved / ⚠️ Changes Needed / ❌ Revision Required

   ## Files Reviewed
   - file1 - notes
   - file2 - notes

   ## Issues Found

   ### Critical
   - Issue description (file:line)

   ### Major
   - Issue description (file:line)

   ### Minor
   - Suggestion (file:line)

   ## Recommendation
   Approve / Request specific changes
   ```

## Output

Provide the review report with clear, actionable feedback.
