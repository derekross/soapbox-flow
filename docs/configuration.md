# Configuration Guide

Complete reference for all Soapbox Flow configuration options.

## Configuration Files

| File | Purpose |
|------|---------|
| `~/.config/soapbox-flow/config.env` | Main Soapbox Flow settings |
| `~/.taskrc` | Taskwarrior configuration |
| `~/.config/khal/config` | Calendar settings |
| `~/.config/khard/khard.conf` | Contacts settings |
| `~/.config/vdirsyncer/config` | Calendar/contacts sync |
| `scripts/sync/.env` | Sync scripts settings |

---

## Main Configuration

**Location:** `~/.config/soapbox-flow/config.env`

This file is created by `./configure.sh` and stores your primary settings.

### User Information

```bash
# Your display name
USER_NAME="Derek Ross"

# Your email address
USER_EMAIL="derek@example.com"

# Your timezone (IANA format)
TIMEZONE="America/Chicago"
```

### Directory Paths

```bash
# Obsidian vault location
VAULT_PATH="/home/user/Vault"

# Where daily task reports are saved
TASKS_PATH="/home/user/Vault/Work/Tasks"

# Where daily schedules are saved
SCHEDULE_PATH="/home/user/Vault/Work/Schedule"
```

### GitLab Settings

```bash
# GitLab instance URL
GITLAB_URL="https://gitlab.com"

# Personal access token (read_api scope)
GITLAB_TOKEN="glpat-xxxxxxxxxxxxxxxxxxxx"

# Project IDs to sync (comma-separated)
GITLAB_PROJECT_IDS="12345,67890,11111"
```

### GitHub Settings

```bash
# Personal access token
GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
```

### Nostr Settings

```bash
# Your public key
NOSTR_NPUB="npub1..."

# Preferred relays (comma-separated)
NOSTR_RELAYS="wss://relay.damus.io,wss://relay.primal.net,wss://nos.lol"
```

---

## Taskwarrior Configuration

**Location:** `~/.taskrc`

### Default Configuration

```ini
# Data location
data.location=~/.task

# Color theme
include /usr/share/taskwarrior/dark-256.theme

# Date formats
dateformat=Y-M-D
dateformat.report=Y-M-D
dateformat.annotation=Y-M-D
```

### GitLab Custom Attributes

These User Defined Attributes (UDAs) store GitLab metadata:

```ini
# GitLab issue ID
uda.gitlab_id.type=numeric
uda.gitlab_id.label=GitLab ID

# Direct link to GitLab issue
uda.gitlab_url.type=string
uda.gitlab_url.label=GitLab URL

# GitLab project name
uda.gitlab_project.type=string
uda.gitlab_project.label=GitLab Project
```

### Urgency Tuning

Customize how tasks are prioritized:

```ini
# Boost tasks tagged 'next'
urgency.user.tag.next.coefficient=15.0

# Boost tasks tagged 'today'
urgency.user.tag.today.coefficient=10.0

# Reduce urgency of waiting tasks
urgency.waiting.coefficient=-3.0

# Boost tasks with approaching due dates
urgency.due.coefficient=12.0
```

### Custom Reports

```ini
# Daily report showing today's tasks
report.today.description=Tasks due today
report.today.columns=id,priority,project,description,due
report.today.filter=status:pending due:today
report.today.sort=urgency-

# Weekly report
report.week.description=Tasks due this week
report.week.columns=id,priority,project,description,due
report.week.filter=status:pending due.before:eow
report.week.sort=due+,urgency-
```

---

## Calendar Configuration (khal)

**Location:** `~/.config/khal/config`

### Basic Configuration

```ini
[calendars]

# Local calendar
[[local]]
path = ~/.local/share/khal/calendars/local/
color = dark green
readonly = False

# Synced calendar (from vdirsyncer)
[[synced]]
path = ~/.local/share/khal/calendars/synced/
color = dark blue
readonly = False

[default]
# Default calendar for new events
default_calendar = local

# Highlight today
highlight_event_days = True

[locale]
# Time and date formats
timeformat = %H:%M
dateformat = %Y-%m-%d
longdateformat = %Y-%m-%d %A
datetimeformat = %Y-%m-%d %H:%M
longdatetimeformat = %Y-%m-%d %H:%M %A

# Week starts on Monday (0) or Sunday (6)
firstweekday = 0

# Timezone
local_timezone = America/Chicago
default_timezone = America/Chicago

[view]
# Show events from the past
event_view_past_events = 2

# Always show weekday names
frame = True
```

### Multiple Calendars

```ini
[calendars]

[[personal]]
path = ~/.local/share/khal/calendars/personal/
color = dark green

[[work]]
path = ~/.local/share/khal/calendars/work/
color = dark blue

[[family]]
path = ~/.local/share/khal/calendars/family/
color = dark magenta
readonly = True
```

---

## Contacts Configuration (khard)

**Location:** `~/.config/khard/khard.conf`

```ini
[addressbooks]

[[personal]]
path = ~/.local/share/khard/contacts/personal/

[[work]]
path = ~/.local/share/khard/contacts/work/

[general]
# Default addressbook for new contacts
default_addressbook = personal

# Editor for editing contacts
editor = vim

# Merge editor
merge_editor = vimdiff

[contact table]
# Fields to display in list view
display = first_name
group_by_addressbook = yes
reverse = no
show_nicknames = no
show_uids = no
sort = first_name

[vcard]
# vCard version (3.0 or 4.0)
preferred_version = 3.0

# Search in these fields
search_in_source_files = yes
skip_unparsable = no
```

---

## Sync Configuration (vdirsyncer)

**Location:** `~/.config/vdirsyncer/config`

### Google Calendar

```ini
[general]
status_path = "~/.local/share/vdirsyncer/status/"

[pair google_calendar]
a = "google_local"
b = "google_remote"
collections = ["from a", "from b"]
metadata = ["color"]

[storage google_local]
type = "filesystem"
path = "~/.local/share/khal/calendars/"
fileext = ".ics"

[storage google_remote]
type = "caldav"
url = "https://www.google.com/calendar/dav/YOUR_EMAIL/events/"
username = "YOUR_EMAIL"
password = "YOUR_APP_PASSWORD"
```

### Nextcloud

```ini
[pair nextcloud_calendar]
a = "nextcloud_local"
b = "nextcloud_remote"
collections = ["from a", "from b"]

[storage nextcloud_local]
type = "filesystem"
path = "~/.local/share/khal/calendars/"
fileext = ".ics"

[storage nextcloud_remote]
type = "caldav"
url = "https://your-nextcloud.com/remote.php/dav/calendars/USERNAME/"
username = "USERNAME"
password = "PASSWORD"
```

### Contacts Sync

```ini
[pair google_contacts]
a = "contacts_local"
b = "contacts_remote"
collections = ["from a", "from b"]

[storage contacts_local]
type = "filesystem"
path = "~/.local/share/khard/contacts/"
fileext = ".vcf"

[storage contacts_remote]
type = "carddav"
url = "https://www.googleapis.com/carddav/v1/principals/YOUR_EMAIL/lists/default/"
username = "YOUR_EMAIL"
password = "YOUR_APP_PASSWORD"
```

---

## Sync Scripts Configuration

**Location:** `scripts/sync/.env`

```bash
# GitLab Configuration
GITLAB_URL=https://gitlab.com
GITLAB_TOKEN=glpat-xxxxxxxxxxxxxxxxxxxx
GITLAB_PROJECT_IDS=12345,67890

# Output Paths
VAULT_PATH=/home/user/Vault
TASKS_PATH=/home/user/Vault/Work/Tasks
SCHEDULE_PATH=/home/user/Vault/Work/Schedule

# Timezone
TIMEZONE=America/Chicago

# Optional: GitHub
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx

# Optional: Sync behavior
SYNC_CLOSED_ISSUES=false
SYNC_DAYS_BACK=30
```

---

## Environment Variables

These can be set in your shell profile (`~/.bashrc`, `~/.zshrc`):

```bash
# Add local bin to PATH (for pip-installed tools)
export PATH="$HOME/.local/bin:$PATH"

# Default editor
export EDITOR=vim

# Taskwarrior data location (optional override)
export TASKDATA="$HOME/.task"

# Nostr relay (used by some scripts)
export NOSTR_RELAY="wss://relay.damus.io"
```

---

## Relay Configuration

For Nostr scripts, relays are configured in individual scripts or the main config.

### Common Relay Sets

**High-traffic public relays:**
```bash
RELAYS=(
    "wss://relay.damus.io"
    "wss://relay.primal.net"
    "wss://nos.lol"
)
```

**With search support:**
```bash
SEARCH_RELAYS=(
    "wss://relay.ditto.pub"
    "wss://relay.nostr.band"
)
```

**Personal relay:**
```bash
PERSONAL_RELAY="wss://nostr-relay.yourdomain.com"
```

---

## Reconfiguring

To reconfigure Soapbox Flow:

```bash
# Re-run the wizard
./configure.sh

# Or edit configs directly
vim ~/.config/soapbox-flow/config.env
vim scripts/sync/.env
```

To reset to defaults:

```bash
# Remove config and re-run
rm -rf ~/.config/soapbox-flow
./configure.sh
```

---

## Security Notes

1. **File permissions:** Config files with tokens are created with `600` permissions
2. **Never commit tokens:** `.gitignore` excludes `.env` files
3. **Use app passwords:** For Google, use app-specific passwords
4. **Rotate tokens:** Periodically create new tokens and revoke old ones
5. **Minimal scopes:** Request only necessary permissions

---

See also:
- [Getting Started](getting-started.md)
- [Troubleshooting](troubleshooting.md)
- [Integration Guides](integrations/)
