---
name: tdd-workflow
description: Enforces Test-Driven Development workflow with automated test-first validation. Use when implementing features, fixing bugs, running @Coder workflow, or when the user mentions TDD, testing, red-green-refactor, or verification gates. Ensures tests are written BEFORE implementation code.
---

# TDD Workflow Skill

Enforces the mandatory Test-Driven Development pattern for the Agent Harness Framework.

## TDD Gates (Non-Negotiable)

Every feature implementation MUST pass through these gates:

### Gate 1: RED (Before Implementation)

```
┌──────────────────────────────────────────────────────────────────┐
│  GATE 1: PRE-IMPLEMENTATION                                      │
├──────────────────────────────────────────────────────────────────┤
│  □ Create test file: tests/{feature}.spec.ts                    │
│  □ Run: npx playwright test tests/{feature}.spec.ts             │
│  □ Verify: Test FAILS                                           │
│  □ Update feature_list.json:                                    │
│    - "test_file": "tests/{feature}.spec.ts"                     │
│    - "test_fails_before": true                                  │
│                                                                  │
│  ⛔ CANNOT write implementation code until gate passes          │
└──────────────────────────────────────────────────────────────────┘
```

### Gate 2: GREEN (After Implementation)

```
┌──────────────────────────────────────────────────────────────────┐
│  GATE 2: POST-IMPLEMENTATION                                     │
├──────────────────────────────────────────────────────────────────┤
│  □ Run: npx playwright test tests/{feature}.spec.ts             │
│  □ Verify: Test PASSES                                          │
│  □ Update feature_list.json:                                    │
│    - "test_passes_after": true                                  │
│    - "passes": true                                             │
│                                                                  │
│  ⛔ CANNOT set passes:true without test_passes_after:true       │
└──────────────────────────────────────────────────────────────────┘
```

## Bug Fix Gate

Bugs MUST have regression tests:

```
┌──────────────────────────────────────────────────────────────────┐
│  🐛 BUG FIX GATE                                                 │
├──────────────────────────────────────────────────────────────────┤
│  □ Create: tests/issues/I{id}-{desc}.spec.ts                    │
│  □ Run test → verify FAILS (reproduces bug)                     │
│  □ Fix the bug                                                   │
│  □ Run test → verify PASSES                                      │
│  □ Update issues.json: status: "closed"                         │
│                                                                  │
│  ⛔ Cannot close bug without regression test                     │
└──────────────────────────────────────────────────────────────────┘
```

## Quick Commands

```bash
# Verify TDD gates (Bash)
./scripts/bash/verify-tdd-gates.sh

# Verify TDD gates (PowerShell)
.\scripts\powershell\verify-tdd-gates.ps1

# Run specific feature test
npx playwright test tests/{feature}.spec.ts

# Run all tests
npx playwright test
```

## Test Template

Use `templates/tests/feature.spec.template.ts` as starting point:

```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature: {feature_name}', () => {
  test('should {expected_behavior}', async ({ page }) => {
    // Arrange
    await page.goto('/');
    
    // Act
    // TODO: Implement action
    
    // Assert
    // TODO: Add assertion that will FAIL initially
    await expect(page.locator('[data-testid="result"]')).toBeVisible();
  });
});
```

## Common Mistakes

❌ Writing implementation before test exists
❌ Writing a test that passes without implementation (test is wrong)
❌ Skipping Gate 1 verification
❌ Setting `passes: true` without running test
❌ Closing bugs without regression tests

## Resources

- **scripts/verify-tdd-gates.sh** - Validates TDD compliance (Bash)
- **scripts/verify-tdd-gates.ps1** - Validates TDD compliance (PowerShell)
- **templates/tests/feature.spec.template.ts** - Test template
- **templates/tests/issue.spec.template.ts** - Bug regression test template
