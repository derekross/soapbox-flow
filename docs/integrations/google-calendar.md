# Google Calendar Integration

Sync your Google Calendar with khal for terminal-based calendar management.

## Overview

This integration uses:
- **vdirsyncer** - Syncs calendars via CalDAV/Google API
- **khal** - Terminal calendar application

## Prerequisites

- Google account
- Python 3.8+
- vdirsyncer and khal installed (`./install.sh`)

## Setup

Google Calendar requires OAuth authentication, which is more complex than simple token-based auth.

### Option 1: Google CalDAV (Simpler)

Google supports CalDAV access with app passwords.

#### 1. Enable 2-Factor Authentication

1. Go to https://myaccount.google.com/security
2. Enable 2-Step Verification if not already enabled

#### 2. Create App Password

1. Go to https://myaccount.google.com/apppasswords
2. Select app: "Other (Custom name)"
3. Enter: "Soapbox Flow" or "vdirsyncer"
4. Click "Generate"
5. Copy the 16-character password

#### 3. Configure vdirsyncer

Edit `~/.config/vdirsyncer/config`:

```ini
[general]
status_path = "~/.local/share/vdirsyncer/status/"

[pair google_calendar]
a = "google_calendar_local"
b = "google_calendar_remote"
collections = ["from a", "from b"]
metadata = ["color"]

[storage google_calendar_local]
type = "filesystem"
path = "~/.local/share/khal/calendars/"
fileext = ".ics"

[storage google_calendar_remote]
type = "caldav"
url = "https://www.google.com/calendar/dav/your-email@gmail.com/events/"
username = "your-email@gmail.com"
password = "your-app-password"
```

Replace:
- `your-email@gmail.com` with your Google email
- `your-app-password` with the 16-character app password

#### 4. Configure khal

Edit `~/.config/khal/config`:

```ini
[calendars]

[[google]]
path = ~/.local/share/khal/calendars/
color = dark blue
readonly = False

[default]
default_calendar = google

[locale]
timeformat = %H:%M
dateformat = %Y-%m-%d
longdateformat = %Y-%m-%d
datetimeformat = %Y-%m-%d %H:%M
longdatetimeformat = %Y-%m-%d %H:%M
```

#### 5. Initial Sync

```bash
# Discover calendars
vdirsyncer discover google_calendar

# Initial sync
vdirsyncer sync google_calendar
```

### Option 2: Google OAuth (More Secure)

For full OAuth support, use the `google` storage type.

#### 1. Create Google Cloud Project

1. Go to https://console.cloud.google.com
2. Create a new project
3. Enable "Google Calendar API"
4. Create OAuth 2.0 credentials:
   - Application type: Desktop app
   - Download the JSON file

#### 2. Configure vdirsyncer

```ini
[storage google_calendar_remote]
type = "google_calendar"
token_file = "~/.config/vdirsyncer/google_token"
client_id = "your-client-id.apps.googleusercontent.com"
client_secret = "your-client-secret"
```

#### 3. Authenticate

```bash
vdirsyncer discover google_calendar
# Browser will open for OAuth consent
```

## Usage

### View Calendar

```bash
# Today's events
khal list today

# Next 7 days
khal list today 7d

# Specific date
khal list 2026-01-20

# This week
khal list today eow

# Interactive view
khal interactive
```

### Add Events

```bash
# Event with time
khal new 2026-01-20 14:00 15:00 "Team meeting"

# All-day event
khal new 2026-01-20 "Conference Day"

# With location
khal new tomorrow 10:00 11:00 "Coffee" -l "Starbucks"

# Multi-day
khal new 2026-01-20 2026-01-22 "Bitcoin Conference"
```

### Sync Changes

```bash
# Sync all calendars
vdirsyncer sync

# Sync specific pair
vdirsyncer sync google_calendar
```

## Automation

### Cron Sync

```bash
# Sync every 15 minutes
*/15 * * * * vdirsyncer sync >> /tmp/vdirsyncer.log 2>&1
```

### Pre-command Hook

Add to your shell config (`.bashrc` / `.zshrc`):

```bash
# Auto-sync before viewing calendar
alias khal='vdirsyncer sync && khal'
```

## Multiple Calendars

### Sync Multiple Google Calendars

```ini
[pair google_personal]
a = "personal_local"
b = "personal_remote"
collections = ["from a", "from b"]

[storage personal_local]
type = "filesystem"
path = "~/.local/share/khal/calendars/personal/"
fileext = ".ics"

[storage personal_remote]
type = "caldav"
url = "https://www.google.com/calendar/dav/your-email@gmail.com/events/"
username = "your-email@gmail.com"
password = "your-app-password"

[pair google_work]
a = "work_local"
b = "work_remote"
collections = ["from a", "from b"]

[storage work_local]
type = "filesystem"
path = "~/.local/share/khal/calendars/work/"
fileext = ".ics"

[storage work_remote]
type = "caldav"
url = "https://www.google.com/calendar/dav/work-email@company.com/events/"
username = "work-email@company.com"
password = "work-app-password"
```

### khal Config for Multiple Calendars

```ini
[calendars]

[[personal]]
path = ~/.local/share/khal/calendars/personal/
color = dark green

[[work]]
path = ~/.local/share/khal/calendars/work/
color = dark blue

[default]
default_calendar = personal
```

## Troubleshooting

### "Authentication failed"

- App password expired → Create new app password
- Wrong credentials → Verify email and password
- 2FA not enabled → Enable 2-Step Verification first

### "Calendar not found"

- Wrong URL → Verify calendar ID in URL
- Calendar not shared → Check calendar sharing settings
- Hidden calendar → Make calendar visible in Google Calendar

### Sync conflicts

```bash
# Force sync (local wins)
vdirsyncer sync --force-delete

# Reset and resync
rm -rf ~/.local/share/vdirsyncer/status/
vdirsyncer discover
vdirsyncer sync
```

### Events not appearing

1. Check sync completed:
   ```bash
   vdirsyncer sync 2>&1 | tail
   ```

2. Verify calendar files exist:
   ```bash
   ls ~/.local/share/khal/calendars/
   ```

3. Check khal config points to correct path

### "SSL certificate error"

```bash
# Temporarily disable SSL verification (not recommended for production)
# Add to storage config:
verify_ssl = false
```

## Integration with Daily Sync

The `daily_sync.py` script uses khal to include calendar events in your daily task report:

```bash
# Generates schedule including calendar
python3 scripts/sync/daily_sync.py
```

Output includes today's calendar events in markdown format.

---

For other calendar providers (Nextcloud, iCloud), adjust the CalDAV URL accordingly.
