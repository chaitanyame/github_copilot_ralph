# Ralph State Directory

This directory contains runtime state for the Ralph autonomous loop runner.

## Files

### `state.json`
Tracks the current iteration and last processed feature, enabling resume capability after interruption.

**Schema:**
```json
{
  "iteration": 0,
  "started_at": "2026-01-11T10:30:00Z",
  "last_feature": "feature-id",
  "updated_at": "2026-01-11T10:35:00Z"
}
```

## Usage

### Resume after interruption
```bash
# Bash
./scripts/bash/ralph.sh --resume

# PowerShell
.\scripts\powershell\ralph.ps1 -Resume
```

### Reset state and start fresh
```bash
# Bash
./scripts/bash/ralph.sh --reset

# PowerShell
.\scripts\powershell\ralph.ps1 -Reset
```

### Manually reset
```bash
rm memory/.ralph/state.json
```

## Notes

- State is auto-created on first run
- Updated after each iteration
- Git-ignored to avoid conflicts
- Safe to delete (will recreate on next run)
