#!/usr/bin/env python3
"""
Skill Initializer - Creates a new skill from template

Usage:
    init_skill.py <skill-name> --path <path>

Examples:
    init_skill.py my-new-skill --path .github/skills
    init_skill.py api-helper --path .github/skills
"""

import sys
import argparse
from pathlib import Path


SKILL_TEMPLATE = """---
name: {skill_name}
description: [TODO: Complete and informative explanation of what the skill does and when to use it. Include WHEN to use this skill - specific scenarios, file types, or tasks that trigger it.]
---

# {skill_title}

## Overview

[TODO: 1-2 sentences explaining what this skill enables]

## When to Use

[TODO: Specific triggers and scenarios - remember this is loaded AFTER triggering, so keep brief]

## Workflow

[TODO: Step-by-step procedures or decision trees]

## Resources

This skill includes:

### scripts/
Executable code that can be run directly.

### references/
Documentation loaded into context as needed.

### assets/
Templates and files used in output (not loaded into context).

---

**Delete unused directories.** Not every skill needs all resource types.
"""

EXAMPLE_SCRIPT = '''#!/usr/bin/env python3
"""
Example helper script for {skill_name}

Replace with actual implementation or delete if not needed.
"""

def main():
    print("Example script for {skill_name}")
    # TODO: Add actual script logic

if __name__ == "__main__":
    main()
'''

EXAMPLE_REFERENCE = """# Reference Documentation for {skill_title}

Replace with actual reference content or delete if not needed.

## When Reference Docs Are Useful

- Comprehensive API documentation
- Detailed workflow guides
- Complex multi-step processes
- Information too lengthy for main SKILL.md
"""

EXAMPLE_ASSET = """# Example Asset Placeholder

Replace with actual asset files (templates, images, fonts, etc.) or delete.

Asset files are used within output, not loaded into context.
"""


def title_case_skill_name(skill_name):
    """Convert hyphenated skill name to Title Case."""
    return ' '.join(word.capitalize() for word in skill_name.split('-'))


def init_skill(skill_name, path):
    """Initialize a new skill directory with template SKILL.md."""
    skill_dir = Path(path).resolve() / skill_name

    if skill_dir.exists():
        print(f"❌ Error: Skill directory already exists: {skill_dir}")
        return None

    try:
        skill_dir.mkdir(parents=True, exist_ok=False)
        print(f"✅ Created skill directory: {skill_dir}")
    except Exception as e:
        print(f"❌ Error creating directory: {e}")
        return None

    skill_title = title_case_skill_name(skill_name)
    
    # Create SKILL.md
    skill_content = SKILL_TEMPLATE.format(skill_name=skill_name, skill_title=skill_title)
    skill_md_path = skill_dir / 'SKILL.md'
    try:
        skill_md_path.write_text(skill_content)
        print("✅ Created SKILL.md")
    except Exception as e:
        print(f"❌ Error creating SKILL.md: {e}")
        return None

    # Create scripts/
    scripts_dir = skill_dir / 'scripts'
    scripts_dir.mkdir(exist_ok=True)
    example_script = scripts_dir / 'example.py'
    example_script.write_text(EXAMPLE_SCRIPT.format(skill_name=skill_name))
    print("✅ Created scripts/example.py")

    # Create references/
    references_dir = skill_dir / 'references'
    references_dir.mkdir(exist_ok=True)
    example_reference = references_dir / 'api_reference.md'
    example_reference.write_text(EXAMPLE_REFERENCE.format(skill_title=skill_title))
    print("✅ Created references/api_reference.md")

    # Create assets/
    assets_dir = skill_dir / 'assets'
    assets_dir.mkdir(exist_ok=True)
    example_asset = assets_dir / 'README.md'
    example_asset.write_text(EXAMPLE_ASSET)
    print("✅ Created assets/README.md")

    print(f"\n🎉 Skill '{skill_name}' initialized at: {skill_dir}")
    print("\nNext steps:")
    print("  1. Edit SKILL.md with your skill's instructions")
    print("  2. Add scripts, references, or assets as needed")
    print("  3. Delete unused directories")
    
    return skill_dir


def main():
    parser = argparse.ArgumentParser(description='Initialize a new skill from template')
    parser.add_argument('skill_name', help='Name of the skill (lowercase, hyphens)')
    parser.add_argument('--path', required=True, help='Directory where skill will be created')
    
    args = parser.parse_args()
    
    # Validate skill name
    if not args.skill_name.replace('-', '').isalnum():
        print("❌ Error: Skill name must be lowercase alphanumeric with hyphens")
        sys.exit(1)
    
    result = init_skill(args.skill_name, args.path)
    sys.exit(0 if result else 1)


if __name__ == "__main__":
    main()
