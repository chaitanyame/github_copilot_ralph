<!--
  ============================================================================
  SYNC IMPACT REPORT
  ============================================================================
  Version change: 0.0.0 (initial template) → 1.0.0
  
  Modified principles:
    - N/A (initial adoption)
  
  Added sections:
    - Core Principles (6 principles based on Claude Code harness patterns)
    - Environment Management (session scaffolding requirements)
    - Development Workflow (incremental progress discipline)
    - Governance (amendment procedure and compliance)
  
  Removed sections:
    - N/A (initial adoption)
  
  Templates requiring updates:
    - .specify/templates/plan-template.md ✅ (Constitution Check section compatible)
    - .specify/templates/spec-template.md ✅ (User Stories align with incremental progress)
    - .specify/templates/tasks-template.md ✅ (Phase structure supports clean state handoff)
  
  Follow-up TODOs:
    - None
  ============================================================================
-->

# Harness Framework Constitution

## Core Principles

### I. Initializer-Coder Pattern

Every complex task MUST begin with an initializer phase that sets up the environment before
incremental coding begins. The initializer agent:
- MUST create a comprehensive feature list expanding on the user's initial prompt
- MUST set up initial environment scaffolding (init.sh, progress tracking, git baseline)
- MUST NOT attempt to implement features—only prepare the foundation

**Rationale**: Agents attempting to one-shot complex applications inevitably run out of context
mid-implementation, leaving subsequent sessions with half-finished, undocumented work. Separating
initialization from implementation prevents this failure mode.

### II. Incremental Progress

Each coding session MUST work on exactly one feature at a time. Agents:
- MUST NOT attempt to implement multiple features in a single context window
- MUST complete, test, and commit each feature before moving to the next
- MUST update progress tracking after each feature completion

**Rationale**: Working on one feature at a time prevents context exhaustion and ensures each
feature receives proper attention. This discipline also makes it easier for subsequent sessions
to understand what has been done and what remains.

### III. Clean State Handoff

Every coding session MUST leave the environment in a mergeable state. This means:
- No half-implemented features in the codebase
- All code MUST compile/run without errors
- All tests MUST pass
- Progress MUST be committed to git with descriptive commit messages
- The progress file MUST be updated with a summary of work completed

**Rationale**: Each new context window starts with no memory of what came before. A clean state
ensures the next session can begin productive work immediately without first having to debug
or understand incomplete work from previous sessions.

### IV. Progress Tracking

Agents MUST maintain structured progress artifacts that bridge context windows:
- A `progress.md` file tracking completed work and next steps
- Git history with meaningful commit messages
- A feature list (JSON format preferred) with pass/fail status for each feature

**Rationale**: These artifacts replace the memory that agents lose between sessions. Git history
shows what code changed and why. The progress file provides high-level context. The feature list
shows overall completion status.

### V. Comprehensive Testing

Features MUST be verified end-to-end before being marked complete. Agents:
- MUST test features as a human user would, not just via unit tests
- MUST use appropriate testing tools (browser automation for web apps, CLI for command-line tools)
- MUST NOT mark features as complete without observing correct behavior

**Rationale**: Agents tend to mark features complete after making code changes, even when the
feature doesn't actually work. End-to-end testing catches bugs that aren't obvious from code
inspection alone.

### VI. Feature-Based Development

Work MUST be organized around discrete, testable features:
- Each feature MUST have a clear description and acceptance criteria
- Features MUST be tracked in a structured format (JSON preferred for immutability)
- Feature status MUST only be changed by editing the `passes` field, never by deletion

**Rationale**: A structured feature list prevents agents from declaring victory prematurely or
accidentally removing functionality. JSON format is less likely to be inappropriately modified
compared to prose or Markdown.

## Environment Management

Every project MUST include these session-bridging artifacts:

### Required Files

1. **`progress.md`** - Session log with:
   - Completed features since last checkpoint
   - Current feature in progress (if any)
   - Known issues or blockers
   - Next steps for the upcoming session

2. **`features.json`** - Comprehensive feature list with:
   - Category (functional, ui, integration, etc.)
   - Description of the feature
   - Acceptance steps
   - `passes: true|false` status

3. **`init.sh`** (or equivalent) - Environment setup script that:
   - Installs dependencies
   - Configures development environment
   - Runs initial tests to verify setup

### Git Discipline

- Initial commit MUST capture baseline scaffolding
- Each feature MUST be committed atomically
- Commit messages MUST describe what was done and why
- Agents MAY use `git revert` to recover from bad states

## Development Workflow

### Session Structure

Every coding session follows this workflow:

1. **Orient** - Review `progress.md` and `features.json` to understand current state
2. **Select** - Choose exactly one incomplete feature to work on
3. **Implement** - Write code for that single feature
4. **Test** - Verify the feature works end-to-end
5. **Commit** - Commit changes with descriptive message
6. **Update** - Mark feature as passing and update progress.md
7. **Repeat** - If context allows, select next feature; otherwise, end session

### Prohibited Behaviors

- Starting implementation without reviewing progress artifacts
- Working on multiple features simultaneously
- Declaring features complete without testing
- Leaving code in a broken state at session end
- Deleting or rewriting features in the feature list

## Governance

### Constitution Authority

This constitution supersedes all other development practices. When conflicts arise:
1. Constitution principles take precedence over convenience
2. Violations MUST be documented and justified in progress.md
3. Repeated violations require constitutional amendment

### Amendment Procedure

1. Propose change with rationale
2. Assess impact on existing workflows
3. Update version following semantic versioning:
   - MAJOR: Principle removal or incompatible redefinition
   - MINOR: New principle or significant expansion
   - PATCH: Clarification or wording improvements
4. Update all dependent templates
5. Document in Sync Impact Report

### Compliance Review

- All pull requests MUST verify compliance with constitution
- Automated checks SHOULD validate feature list integrity
- Periodic reviews SHOULD assess constitutional effectiveness

**Version**: 1.0.0 | **Ratified**: 2025-12-04 | **Last Amended**: 2025-12-04
