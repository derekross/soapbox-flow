# Getting Started with Soapbox Flow

Get up and running with Soapbox Flow in minutes.

## Prerequisites

- **Operating System:** Linux (Ubuntu 20.04+, Debian 11+, Fedora 35+, Arch) or macOS 12+
- **Python:** 3.8 or newer
- **Terminal:** Basic command-line familiarity

## Quick Install

```bash
# Clone the repository
git clone https://github.com/soapbox-pub/soapbox-flow.git
cd soapbox-flow

# Run the installer
./install.sh

# Configure integrations
./configure.sh
```

## What Gets Installed

The installer will set up:

| Tool | Purpose |
|------|---------|
| **nak** | Nostr Army Knife - CLI for Nostr operations |
| **Taskwarrior** | Powerful command-line task management |
| **khal** | Calendar application for the terminal |
| **khard** | Contact management for the terminal |
| **vdirsyncer** | Sync calendars and contacts with CalDAV |
| **Obsidian** | Note-taking and knowledge management |

## Post-Installation

### 1. Verify Installation

```bash
# Check installed tools
nak --version
task --version
khal --version
```

### 2. Configure Integrations

Run the configuration wizard:

```bash
./configure.sh
```

This will guide you through setting up:
- User information
- GitLab/GitHub tokens
- Nostr identity
- Calendar sync
- Directory paths

### 3. Enable Obsidian Plugin

1. Open Obsidian
2. Go to Settings → Community Plugins
3. Enable "OpenCode Sidebar"
4. Click the OpenCode icon in the sidebar

### 4. Try It Out

```bash
# List your tasks
task list

# See your calendar
khal list today 7d

# Generate a daily task report
python3 scripts/sync/daily_sync.py --dry-run
```

## Directory Structure

After installation, your setup will look like:

```
~/
├── .claude/skills/          # Claude Code skills (symlinked)
├── .config/
│   ├── soapbox-flow/        # Soapbox Flow config
│   ├── khal/                # Calendar config
│   ├── khard/               # Contacts config
│   └── vdirsyncer/          # Sync config
├── .task/                   # Taskwarrior data
└── Vault/                   # Your Obsidian vault
    └── Work/
        ├── Tasks/           # Generated task reports
        └── Schedule/        # Generated schedules
```

## Using Claude Skills

The installed skills enhance Claude Code with domain knowledge:

```bash
# Start Claude Code
claude

# Claude now has access to skills like:
# - executive-assistant (scheduling, tasks)
# - nostr-devrel (Nostr ecosystem knowledge)
# - content-research-writer (blog posts, tutorials)
```

## Common Commands

### Tasks

```bash
task add "My new task"           # Add a task
task list                        # List all tasks
task 1 done                      # Complete task 1
task project:work list           # List tasks by project
```

### Calendar

```bash
khal list today                  # Today's events
khal list today 7d               # Next 7 days
khal new tomorrow 10:00 11:00 "Meeting"  # Add event
```

### Nostr

```bash
# Publish article to Nostr
./scripts/nostr/publish-article.sh my-blog-slug

# Broadcast events between relays
./scripts/nostr/broadcast-shakespeare.sh
```

### Sync

```bash
# Run daily sync
python3 scripts/sync/daily_sync.py --sync-to-taskwarrior

# Generate weekly report
python3 scripts/sync/weekly_report.py
```

## Next Steps

1. **Read the Configuration Guide** - [configuration.md](configuration.md)
2. **Set up GitLab sync** - [integrations/gitlab.md](integrations/gitlab.md)
3. **Configure Google Calendar** - [integrations/google-calendar.md](integrations/google-calendar.md)
4. **Explore the scripts** - [../scripts/README.md](../scripts/README.md)

## Troubleshooting

### Command not found

If a command isn't found, ensure it's in your PATH:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"
```

### Permission denied

Make sure scripts are executable:

```bash
chmod +x install.sh configure.sh
chmod +x scripts/**/*.sh
```

### Skills not loading

Verify symlinks are correct:

```bash
ls -la ~/.claude/skills/
```

Re-run the installer if needed:

```bash
./install.sh
```

---

Need help? Check [troubleshooting.md](troubleshooting.md) or open an issue on GitHub.
