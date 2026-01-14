# Soapbox Flow Project Instructions

Project-level instructions for Claude Code when working on Soapbox Flow.

## Project Overview

Soapbox Flow is an AI-powered productivity suite that integrates:
- Task management (Taskwarrior)
- Calendar/contacts (khal, khard, vdirsyncer)
- Nostr operations (nak scripts)
- Git workflows (GitLab, GitHub)
- Claude Code skills

## Code Style

### Shell Scripts

- Use `#!/bin/bash` shebang
- Include descriptive header comments
- Use `set -e` for error handling
- Define colors and print functions consistently
- Quote variables: `"$VAR"` not `$VAR`
- Use arrays for relay lists: `RELAYS=(...)`

### Python Scripts

- Python 3.8+ compatible
- Use type hints where practical
- Load config from `.env` files
- Include `--dry-run` option for destructive operations
- Use `argparse` for CLI arguments
- Handle errors gracefully with user-friendly messages

### Documentation

- Markdown format
- Include code examples
- Use tables for reference data
- Link to related docs
- Keep troubleshooting sections updated

## Directory Structure

```
soapbox-flow/
├── install.sh          # Main installer
├── configure.sh        # Setup wizard
├── uninstall.sh        # Removal script
├── docs/               # Documentation
├── scripts/            # Automation scripts
│   ├── nostr/          # nak-based scripts
│   ├── sync/           # Python sync scripts
│   └── utils/          # Utilities
├── skills/             # Claude Code skills
├── config/             # Config templates
└── examples/           # Workflow examples
```

## Key Files

- `plan.md` - Project roadmap and task tracking
- `scripts/sync/.env` - Sync script configuration
- `~/.config/soapbox-flow/config.env` - User configuration

## Testing

Before committing:
1. Test on clean system if possible
2. Run `./scripts/utils/health-check.sh`
3. Verify scripts work with `--dry-run`
4. Check docs render correctly

## Common Tasks

### Adding a New Script

1. Create in appropriate `scripts/` subdirectory
2. Add executable permission
3. Document in `scripts/README.md`
4. Add to relevant docs

### Adding a New Skill

1. Create directory in `skills/`
2. Add `SKILL.md` with frontmatter
3. Add supplementary files as needed
4. Document in `skills/README.md`

### Updating Install Process

1. Modify `install.sh`
2. Update `configure.sh` if needed
3. Test on fresh system
4. Update `docs/getting-started.md`

## Nostr Specifics

- Always use `--prompt-sec` for nsec input
- Never hardcode keys in scripts
- Default relays: damus, primal, nos.lol, ditto
- Use nak for all Nostr operations
- Reference NIPs by number (e.g., NIP-23)

## Dependencies

Core tools (installed by install.sh):
- nak
- taskwarrior
- khal, khard, vdirsyncer
- jq
- python3

Python packages (scripts/sync/requirements.txt):
- python-gitlab
- requests

## Phase Status

Currently in Phase 1 (Scripts + Installer).

Phase 2 (CLI Tool) will use Go with:
- cobra for CLI framework
- bubbletea for TUI

Phase 3 (GUI) will use Tauri (Rust + Web).

## Questions to Consider

When making changes:
1. Does this work on both Linux and macOS?
2. Is the error handling user-friendly?
3. Are secrets handled securely?
4. Is the documentation updated?
5. Does it follow existing patterns?
