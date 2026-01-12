---
name: tech-stack-detection
description: Auto-detects technology stack from existing project files (package.json, tsconfig, etc.). Use ONLY for existing projects with established code to discover what's already installed. For NEW projects where tech stack hasn't been decided, use stack-advisor skill instead.
---

# Tech Stack Detection Skill

Automatically detects project technology stack from configuration files for **existing projects**.

> **⚠️ For Existing Projects Only**
> 
> This skill scans project files to detect what's already installed.
> For **new projects** where you need to choose a tech stack, use the `stack-advisor` skill instead.

## When to Use

| Scenario | Use This Skill? |
|----------|-----------------|
| Existing project with code | ✅ Yes - detect installed stack |
| New project, user knows stack | ❌ No - user provides to /speckit.plan |
| New project, user unsure | ❌ No - use `stack-advisor` Q&A |

## Detection Patterns

### Node.js / TypeScript

| File | Indicates |
|------|-----------|
| `package.json` | Node.js project |
| `tsconfig.json` | TypeScript |
| `package-lock.json` | npm |
| `yarn.lock` | Yarn |
| `pnpm-lock.yaml` | pnpm |
| `bun.lockb` | Bun |

### Testing Frameworks

| File | Framework |
|------|-----------|
| `playwright.config.ts` | Playwright |
| `playwright.config.js` | Playwright |
| `jest.config.js` | Jest |
| `jest.config.ts` | Jest |
| `vitest.config.ts` | Vitest |
| `cypress.config.js` | Cypress |

### Build Tools / Frameworks

| File | Framework |
|------|-----------|
| `vite.config.ts` | Vite |
| `next.config.js` | Next.js |
| `nuxt.config.ts` | Nuxt |
| `astro.config.mjs` | Astro |
| `svelte.config.js` | SvelteKit |
| `angular.json` | Angular |
| `webpack.config.js` | Webpack |

### Python

| File | Indicates |
|------|-----------|
| `pyproject.toml` | Modern Python |
| `setup.py` | Python package |
| `requirements.txt` | pip dependencies |
| `Pipfile` | pipenv |
| `poetry.lock` | Poetry |
| `pytest.ini` | pytest |

### Other Languages

| File | Language/Framework |
|------|-------------------|
| `Cargo.toml` | Rust |
| `go.mod` | Go |
| `Gemfile` | Ruby |
| `composer.json` | PHP |
| `pom.xml` | Java Maven |
| `build.gradle` | Java Gradle |

## Quick Detection Commands

```bash
# Bash - Run detection script
./.github/skills/tech-stack-detection/scripts/detect-stack.sh

# PowerShell - Run detection script
.\.github\skills\tech-stack-detection\scripts\detect-stack.ps1
```

## Output Format

Scripts output JSON:

```json
{
  "language": "typescript",
  "runtime": "node",
  "package_manager": "npm",
  "frameworks": ["next.js", "react"],
  "testing": ["playwright", "jest"],
  "build_tools": ["webpack"],
  "detected_files": [
    "package.json",
    "tsconfig.json",
    "playwright.config.ts"
  ]
}
```

## Skill Creation Based on Stack

After detection, create appropriate skills:

```bash
# For React + TypeScript project
python .github/skills/skill-creator/scripts/init_skill.py react-patterns --path .github/skills

# For Next.js project
python .github/skills/skill-creator/scripts/init_skill.py nextjs-patterns --path .github/skills
```

## Resources

- **scripts/detect-stack.sh** - Stack detection (Bash)
- **scripts/detect-stack.ps1** - Stack detection (PowerShell)
