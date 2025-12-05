# Git Branching Instructions

Apply these guidelines for all Git operations in this project.

## Branch Strategy

```
main (production)
  └── dev (integration)
       ├── feature/001-user-login
       ├── feature/002-dashboard
       ├── fix/003-login-bug
       └── refactor/004-auth-cleanup
```

## Branch Naming Convention

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feature/{id}-{short-name}` | `feature/001-user-login` |
| Bug Fix | `fix/{id}-{description}` | `fix/003-login-validation` |
| Refactor | `refactor/{id}-{description}` | `refactor/004-auth-cleanup` |
| Hotfix | `hotfix/{description}` | `hotfix/critical-security` |

## Workflow Per Feature

### 1. Start Feature
```bash
# Ensure you're on latest dev
git checkout dev
git pull origin dev

# Create feature branch
git checkout -b feature/{id}-{short-name}
```

### 2. During Development
```bash
# Commit frequently with meaningful messages
git add .
git commit -m "feat({id}): {description}"

# Push to remote (backup + visibility)
git push origin feature/{id}-{short-name}
```

### 3. Complete Feature
```bash
# Final commit
git add .
git commit -m "feat({id}): {feature name}

- Implemented {details}
- Added Playwright tests
- All tests passing

Closes #{id}"

# Push final changes
git push origin feature/{id}-{short-name}
```

### 4. Merge to Dev
```bash
# Option A: Create Pull Request (recommended)
gh pr create --base dev --title "feat({id}): {feature name}"

# Option B: Direct merge (if pre-approved)
git checkout dev
git merge feature/{id}-{short-name}
git push origin dev

# Clean up
git branch -d feature/{id}-{short-name}
git push origin --delete feature/{id}-{short-name}
```

## Commit Message Format

```
type(scope): subject

body (optional)

footer (optional)
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `test`: Adding tests
- `docs`: Documentation
- `chore`: Maintenance

### Examples
```bash
git commit -m "feat(001): add user login form"
git commit -m "fix(003): correct email validation regex"
git commit -m "test(001): add Playwright tests for login"
```

## Tracking Features to Branches

In `memory/claude-progress.md`, always note the branch:

```markdown
### Session 4 - 2024-12-04

**Feature**: #001 User Login
**Branch**: `feature/001-user-login`
**Status**: ✅ Complete
**PR**: #15 (merged)
```

## Recovery

### If branch is broken
```bash
# Abandon changes and start fresh
git checkout dev
git branch -D feature/{id}-{short-name}
git checkout -b feature/{id}-{short-name}
```

### If dev is broken
```bash
# Revert last merge
git checkout dev
git revert -m 1 HEAD
git push origin dev
```

## Rules

1. **Never commit directly to main or dev**
2. **One feature = One branch**
3. **Push before ending session** (backup)
4. **Include feature ID in branch name**
5. **Delete branches after merge**
