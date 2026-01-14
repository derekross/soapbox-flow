# Scripts Guide

Detailed guide to all automation scripts included with Soapbox Flow.

## Overview

Scripts are organized into three categories:

| Directory | Purpose | Language |
|-----------|---------|----------|
| `scripts/nostr/` | Nostr operations | Bash + nak |
| `scripts/sync/` | Data synchronization | Python |
| `scripts/utils/` | Utilities | Bash |

---

## Nostr Scripts

All Nostr scripts use [nak](https://github.com/fiatjaf/nak) (Nostr Army Knife).

### publish-article.sh

**Purpose:** Publish blog posts to Nostr as NIP-23 long-form articles.

**Usage:**
```bash
# From production URL
./scripts/nostr/publish-article.sh my-blog-slug

# From local dev server
./scripts/nostr/publish-article.sh my-post --local

# From full URL
./scripts/nostr/publish-article.sh https://example.com/blog/article
```

**What it does:**
1. Fetches HTML from the URL
2. Extracts metadata (title, summary, image, date)
3. Converts HTML to clean Markdown
4. Shows preview and asks for confirmation
5. Prompts for your nsec (securely)
6. Publishes to multiple relays

**Relays:** relay.primal.net, relay.damus.io, relay.ditto.pub, nos.lol, relay.snort.social

**Output:**
- Event published to Nostr
- Markdown saved to `/tmp/article-SLUG.md`

---

### broadcast-shakespeare.sh

**Purpose:** Sync #shakespearediy hashtag posts between relays.

**Usage:**
```bash
./scripts/nostr/broadcast-shakespeare.sh
```

**What it does:**
1. Queries source relays for kind 1 events with #shakespearediy
2. Broadcasts each event to target relay

**Customization:**
Edit the script to change:
- `SOURCE_RELAYS` - Where to fetch from
- `TARGET_RELAY` - Where to broadcast to
- Hashtag filter (`-t t=shakespearediy`)

---

### broadcast-shakespeare-events.sh

**Purpose:** Sync Shakespeare Workshop calendar events and live activities.

**Usage:**
```bash
./scripts/nostr/broadcast-shakespeare-events.sh
```

**Event kinds:**
- 31922 - Date-based calendar events (NIP-52)
- 31923 - Time-based calendar events (NIP-52)
- 30311 - Live activities (NIP-53)

**What it does:**
1. Searches by hashtag #ShakespeareWorkshop
2. Uses NIP-50 search where supported
3. Filters by title tag
4. Deduplicates by event ID
5. Broadcasts unique events to target

---

### apps-broadcast.sh

**Purpose:** Sync NIP-89 app handler events between relays.

**Usage:**
```bash
./scripts/nostr/apps-broadcast.sh
```

**Event kind:** 31990 (App handlers)

**Use case:** Ensure app registrations are available on your relay.

---

### repositories-broadcast.sh

**Purpose:** Sync NIP-34 git repository announcements.

**Usage:**
```bash
./scripts/nostr/repositories-broadcast.sh
```

**Event kind:** 30617 (Repository announcements)

**Use case:** Sync git repos from gitworkshop.dev, ngit, etc.

---

### community-broadcast.sh

**Purpose:** Broadcast community events to multiple relays.

**Usage:**
```bash
# Default relays
./scripts/nostr/community-broadcast.sh

# Custom relays
./scripts/nostr/community-broadcast.sh wss://relay1.com wss://relay2.com
```

**Event kind:** 34550 (Communities)

---

### custom-nips-broadcast.sh

**Purpose:** Sync custom NIP proposal events.

**Usage:**
```bash
./scripts/nostr/custom-nips-broadcast.sh
```

**Event kind:** 30817

---

## Sync Scripts

Python scripts for synchronizing tasks, calendar, and data.

### Setup

```bash
cd scripts/sync

# Create virtual environment (optional but recommended)
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure
cp .env.example .env
vim .env  # Add your tokens and paths
```

### Configuration (.env)

```bash
# GitLab
GITLAB_URL=https://gitlab.com
GITLAB_TOKEN=glpat-xxxxxxxxxxxx
GITLAB_PROJECT_IDS=123,456,789

# Paths
VAULT_PATH=/home/user/Vault
TASKS_PATH=/home/user/Vault/Work/Tasks
SCHEDULE_PATH=/home/user/Vault/Work/Schedule

# Options
TIMEZONE=America/Chicago
```

---

### daily_sync.py

**Purpose:** Comprehensive daily sync of all data sources.

**Usage:**
```bash
# Full sync with Taskwarrior integration
python3 scripts/sync/daily_sync.py --sync-to-taskwarrior

# Preview without making changes
python3 scripts/sync/daily_sync.py --dry-run

# Skip calendar sync
python3 scripts/sync/daily_sync.py --no-calendar
```

**What it does:**
1. Syncs calendar via vdirsyncer
2. Fetches GitLab issues from configured projects
3. Optionally syncs to Taskwarrior
4. Generates daily task markdown file

**Output file:** `$TASKS_PATH/YYYY-MM-DD-tasks.md`

**Example output:**
```markdown
# Tasks for 2026-01-14

## GitLab Issues

### shakespeare (Project)
- [ ] #123: Fix mobile layout (High)
- [ ] #124: Add dark mode (Medium)

### ditto (Project)
- [ ] #456: Performance optimization

## Calendar

- 10:00-11:00: Team standup
- 14:00-15:00: Product review

## Taskwarrior

- [H] Review PR for authentication
- [M] Update documentation
```

---

### weekly_report.py

**Purpose:** Generate weekly activity reports.

**Usage:**
```bash
# Generate report
python3 scripts/sync/weekly_report.py

# Preview without saving
python3 scripts/sync/weekly_report.py --dry-run
```

**Output file:** `$TASKS_PATH/Reports/YYYY-WNN-report.md`

**What it includes:**
- Tasks completed this week
- GitLab issues closed
- Commits made
- Time tracking summary
- Next week priorities

---

### gitlab_sync.py

**Purpose:** Sync GitLab issues to local storage.

**Usage:**
```bash
python3 scripts/sync/gitlab_sync.py
```

**What it does:**
1. Connects to GitLab API
2. Fetches open issues from configured projects
3. Stores issue data locally
4. Returns data for other scripts to use

---

### taskwarrior_sync.py

**Purpose:** Bidirectional sync between GitLab and Taskwarrior.

**Usage:**
```bash
python3 scripts/sync/taskwarrior_sync.py
```

**What it does:**
1. Imports GitLab issues as Taskwarrior tasks
2. Tags tasks with `+gitlab`
3. Stores GitLab metadata in UDA fields
4. Prevents duplicates using gitlab_id

---

### calendar_sync.py

**Purpose:** Wrapper for vdirsyncer calendar sync.

**Usage:**
```bash
python3 scripts/sync/calendar_sync.py
```

**What it does:**
1. Runs `vdirsyncer sync`
2. Handles errors gracefully
3. Logs sync results

---

## Utility Scripts

### health-check.sh

**Purpose:** Verify all tools are installed and configured.

**Usage:**
```bash
./scripts/utils/health-check.sh
```

**Checks:**
- Installed tools (nak, task, khal, khard, etc.)
- Configuration files exist
- Claude skills are linked
- API connections work
- Relay connectivity

**Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Soapbox Flow Health Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Installed Tools
─────────────────────────────────────────────
✓ nak: v0.7.6
✓ taskwarrior: 2.6.2
✓ khal: 0.11.2
...

Summary
─────────────────────────────────────────────
All checks passed!
```

---

## Creating Custom Scripts

### Nostr Script Template

```bash
#!/bin/bash

# Description of what this script does

SOURCE_RELAYS=(
    "wss://relay.damus.io"
    "wss://relay.primal.net"
    "wss://nos.lol"
)

TARGET_RELAY="wss://relay.ditto.pub"

echo "Fetching events..."

nak req -k KIND -l 100 "${SOURCE_RELAYS[@]}" | while read -r event; do
    echo "$event" | nak event "$TARGET_RELAY"
done

echo "Done!"
```

### Python Script Template

```python
#!/usr/bin/env python3

import os
import argparse
from dotenv import load_dotenv

load_dotenv()

def main():
    parser = argparse.ArgumentParser(description='My sync script')
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()

    gitlab_token = os.getenv('GITLAB_TOKEN')

    if args.dry_run:
        print("Dry run mode - no changes will be made")

    # Your logic here

if __name__ == '__main__':
    main()
```

---

## Automation

### Cron Jobs

```bash
# Edit crontab
crontab -e

# Daily sync at 8 AM
0 8 * * * cd /path/to/soapbox-flow && python3 scripts/sync/daily_sync.py --sync-to-taskwarrior >> /tmp/daily_sync.log 2>&1

# Weekly report on Fridays at 5 PM
0 17 * * 5 cd /path/to/soapbox-flow && python3 scripts/sync/weekly_report.py >> /tmp/weekly_report.log 2>&1

# Calendar sync every 15 minutes
*/15 * * * * vdirsyncer sync >> /tmp/vdirsyncer.log 2>&1
```

### Systemd Timers

See `scripts/sync/systemd/` for example service and timer files.

---

## Troubleshooting

### Script permission denied
```bash
chmod +x scripts/**/*.sh
chmod +x scripts/**/*.py
```

### Python import errors
```bash
cd scripts/sync
pip install -r requirements.txt
```

### nak not found
```bash
export PATH="$HOME/go/bin:$PATH"
# Or reinstall: go install github.com/fiatjaf/nak@latest
```

### Dry run everything first
```bash
python3 scripts/sync/daily_sync.py --dry-run
```

---

See also:
- [Getting Started](getting-started.md)
- [Configuration Guide](configuration.md)
- [Nostr Integration](integrations/nostr.md)
