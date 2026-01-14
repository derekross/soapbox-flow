# Claude Code Skills

Pre-built skills for Claude Code that enhance AI assistance for developer workflows.

## Installation

### Option 1: Symlink All Skills

```bash
# From the soapbox-flow directory
for skill in skills/*/; do
    ln -sf "$(pwd)/$skill" ~/.claude/skills/
done
```

### Option 2: Symlink Specific Skills

```bash
# Symlink only the skills you want
ln -sf $(pwd)/skills/nostr-devrel ~/.claude/skills/
ln -sf $(pwd)/skills/executive-assistant ~/.claude/skills/
```

### Option 3: Copy Skills

```bash
# Copy skills (won't get updates)
cp -r skills/* ~/.claude/skills/
```

## Available Skills

### Core Productivity

| Skill | Description | Files |
|-------|-------------|-------|
| **executive-assistant** | Task management, scheduling, meeting notes, email drafts | SKILL.md, templates.md, checklists.md, reference.md, schedule-template.md |
| **planning-with-files** | Structured planning with persistent markdown files | SKILL.md, examples.md, reference.md |
| **strategic-planning** | Project planning, campaign strategies, roadmaps | SKILL.md |

### Content & DevRel

| Skill | Description | Files |
|-------|-------------|-------|
| **nostr-devrel** | Nostr ecosystem DevRel toolkit | SKILL.md, ecosystem-contacts.md, nips-reference.md, sample-content.md |
| **content-research-writer** | Blog posts, tutorials, social threads, Reddit posts | SKILL.md |

### Document Creation

| Skill | Description | Files |
|-------|-------------|-------|
| **docx** | Microsoft Word documents | SKILL.md |
| **pptx** | PowerPoint presentations | SKILL.md |
| **xlsx** | Excel spreadsheets | SKILL.md |

## Skill Structure

Each skill contains:

```
skill-name/
├── SKILL.md           # Main skill definition (required)
├── templates.md       # Ready-to-use templates (optional)
├── reference.md       # Quick reference docs (optional)
└── examples.md        # Example usage (optional)
```

The `SKILL.md` file contains:
- Frontmatter with name and description
- When to use the skill
- Detailed instructions
- References to supplementary files

## Usage

Once installed, Claude Code automatically loads skills based on context. You can also invoke skills directly:

```
Use the nostr-devrel skill to help me write a workshop outline.
```

Or reference specific resources:

```
Check the nips-reference.md for the event kind number.
```

## Customization

Skills are markdown files—feel free to customize them:

1. Copy the skill to your own directory
2. Modify the SKILL.md and supplementary files
3. Add your own templates, contacts, references

## Creating New Skills

1. Create a new directory: `mkdir ~/.claude/skills/my-skill`
2. Create `SKILL.md` with frontmatter:

```markdown
---
name: my-skill
description: What this skill does
---

# My Skill

Instructions for Claude...
```

3. Add supplementary files as needed
4. Test by asking Claude to use the skill

## Troubleshooting

**Skills not loading?**
- Check that files are in `~/.claude/skills/`
- Verify SKILL.md has valid frontmatter
- Restart Claude Code

**Symlinks not working?**
- Use absolute paths: `ln -sf /full/path/to/skill ~/.claude/skills/`
- Check permissions: `ls -la ~/.claude/skills/`

---

See individual skill directories for detailed documentation.
