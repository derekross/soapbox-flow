# Automation Scripts

Ready-to-use scripts for Nostr operations, sync workflows, and utilities.

## Directory Structure

```
scripts/
├── nostr/          # Nostr/nak operations
├── sync/           # Calendar, tasks, GitLab sync
└── utils/          # Utility scripts
```

## Requirements

Most scripts require:

- **nak** — Nostr Army Knife CLI
- **jq** — JSON processor
- **python3** — For sync scripts
- **taskwarrior** — For task sync

Install via `./install.sh` in the project root.

---

## Nostr Scripts

Located in `scripts/nostr/`. All scripts use [nak](https://github.com/fiatjaf/nak).

### publish-article.sh

Publish a blog post to Nostr as a NIP-23 long-form article.

```bash
# Publish from soapbox.pub
./scripts/nostr/publish-article.sh my-blog-post-slug

# Publish from local dev server
./scripts/nostr/publish-article.sh my-post --local
```

Features:
- Extracts metadata (title, summary, image) from HTML
- Converts to clean Markdown
- Publishes to multiple relays
- Prompts for nsec securely

### broadcast-*.sh

Sync events between relays by event kind.

```bash
# Broadcast hashtag posts (#shakespearediy)
./scripts/nostr/broadcast-shakespeare.sh

# Broadcast calendar/live events (NIP-52/53)
./scripts/nostr/broadcast-shakespeare-events.sh

# Broadcast app handlers (NIP-89, kind 31990)
./scripts/nostr/apps-broadcast.sh

# Broadcast git repositories (NIP-34, kind 30617)
./scripts/nostr/repositories-broadcast.sh

# Broadcast community events (kind 34550)
./scripts/nostr/community-broadcast.sh

# Broadcast custom NIPs (kind 30817)
./scripts/nostr/custom-nips-broadcast.sh
```

All broadcast scripts:
- Fetch from multiple source relays
- Deduplicate by event ID
- Broadcast to target relay(s)

---

## Sync Scripts

Located in `scripts/sync/`. Python scripts for productivity sync.

### Setup

The installer creates a virtual environment at `scripts/sync/venv/` automatically. If you need to set up manually:

```bash
cd scripts/sync

# Create virtual environment
python3 -m venv venv

# Install dependencies (no need to activate venv)
./venv/bin/pip install -r requirements.txt

# Configure
cp .env.example .env
# Edit .env with your credentials
```

### daily_sync.py

Comprehensive daily sync of calendar, GitLab issues, and tasks.

```bash
# Full sync with Taskwarrior integration
./scripts/sync/venv/bin/python3 scripts/sync/daily_sync.py --sync-to-taskwarrior

# Dry run (preview without saving)
./scripts/sync/venv/bin/python3 scripts/sync/daily_sync.py --dry-run
```

Outputs to: `~/Vault/Soapbox/Work/Tasks/YYYY-MM-DD-tasks.md`

### weekly_report.py

Generate weekly activity reports.

```bash
# Generate report
./scripts/sync/venv/bin/python3 scripts/sync/weekly_report.py

# Dry run
./scripts/sync/venv/bin/python3 scripts/sync/weekly_report.py --dry-run
```

Outputs to: `~/Vault/Soapbox/Work/Tasks/Reports/YYYY-WNN-report.md`

### gitlab_sync.py

Sync GitLab issues to local tasks.

```bash
./scripts/sync/venv/bin/python3 scripts/sync/gitlab_sync.py
```

Requires `GITLAB_TOKEN` and `GITLAB_PROJECT_IDS` in `.env`.

### taskwarrior_sync.py

Sync tasks between GitLab and Taskwarrior.

```bash
./scripts/sync/venv/bin/python3 scripts/sync/taskwarrior_sync.py
```

### calendar_sync.py

Sync calendar events via vdirsyncer.

```bash
./scripts/sync/venv/bin/python3 scripts/sync/calendar_sync.py
```

### Configuration

Copy `.env.example` to `.env` and fill in:

```bash
# GitLab
GITLAB_TOKEN=your_token_here
GITLAB_PROJECT_IDS=123,456,789

# Paths
VAULT_PATH=/home/user/Vault
TASKS_PATH=/home/user/Vault/Work/Tasks

# Optional
TIMEZONE=America/Chicago
```

---

## Utility Scripts

Located in `scripts/utils/`.

### health-check.sh

Verify all tools are installed and configured.

```bash
./scripts/utils/health-check.sh
```

### backup.sh

Backup configuration and data.

```bash
./scripts/utils/backup.sh
```

---

## Customization

Scripts use environment variables and config files for customization:

1. **Relay lists** — Edit the `SOURCE_RELAYS` and `TARGET_RELAY` arrays in bash scripts
2. **Output paths** — Set `VAULT_PATH` and `TASKS_PATH` in `.env`
3. **GitLab projects** — Set `GITLAB_PROJECT_IDS` in `.env`

## Adding New Scripts

1. Place in appropriate subdirectory (`nostr/`, `sync/`, `utils/`)
2. Make executable: `chmod +x scripts/category/myscript.sh`
3. Add documentation to this README
4. Use environment variables for configuration

---

See individual scripts for detailed usage and options.
