# /harness.status - Check Feature Progress

Display the current status of all features and recent progress.

## Instructions

1. Read `memory/feature_list.json` to get all features
2. Read `memory/claude-progress.md` for recent activity
3. Display a summary dashboard

## Output Format

```markdown
# Feature Progress Dashboard

## Summary
- **Total Features**: {count}
- **Passing**: {count} ({percentage}%)
- **Remaining**: {count}
- **Last Session**: {date from progress notes}

## Feature Status

| # | Feature | Priority | Status |
|---|---------|----------|--------|
| 1 | {name} | {priority} | ✅ Passing |
| 2 | {name} | {priority} | ❌ Not Started |
| 3 | {name} | {priority} | 🔄 In Progress |

## Recent Activity
{Last 3-5 entries from claude-progress.md}

## Suggested Next
Based on priority and dependencies, consider:
1. **{Feature Name}** - {reason}

## Quick Commands
- `/speckit.implement {id}` - Implement specific feature
- `/harness.verify` - Verify passing features
- `@Coder` - Start implementation session
```

## Usage

```
/harness.status
```
