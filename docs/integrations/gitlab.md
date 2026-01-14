# GitLab Integration

Sync GitLab issues to Taskwarrior for unified task management.

## Overview

The GitLab integration:
- Pulls issues from specified GitLab projects
- Creates corresponding tasks in Taskwarrior
- Tracks GitLab metadata (issue ID, URL, project)
- Updates task status when issues change

## Prerequisites

- GitLab account (gitlab.com or self-hosted)
- Personal access token with `read_api` scope
- Taskwarrior installed and configured

## Setup

### 1. Create Access Token

1. Go to GitLab → User Settings → Access Tokens
   - GitLab.com: https://gitlab.com/-/user_settings/personal_access_tokens
   - Self-hosted: `https://your-gitlab.com/-/user_settings/personal_access_tokens`

2. Create a new token:
   - **Name:** Soapbox Flow (or any identifier)
   - **Expiration:** Set as needed (or no expiration)
   - **Scopes:** Select `read_api`

3. Copy the token immediately (it won't be shown again)

### 2. Find Project IDs

For each project you want to sync:

1. Go to the project in GitLab
2. Navigate to Settings → General
3. Find "Project ID" in the top section
4. Note the numeric ID (e.g., `12345678`)

### 3. Configure Soapbox Flow

Run the configuration wizard:

```bash
./configure.sh
```

When prompted:
- **GitLab URL:** `https://gitlab.com` (or your self-hosted URL)
- **GitLab token:** Paste your access token
- **Project IDs:** Comma-separated list (e.g., `123,456,789`)

Or manually edit `~/.config/soapbox-flow/config.env`:

```bash
GITLAB_URL="https://gitlab.com"
GITLAB_TOKEN="glpat-xxxxxxxxxxxxxxxxxxxx"
GITLAB_PROJECT_IDS="123,456,789"
```

And `scripts/sync/.env`:

```bash
GITLAB_URL=https://gitlab.com
GITLAB_TOKEN=glpat-xxxxxxxxxxxxxxxxxxxx
GITLAB_PROJECT_IDS=123,456,789
```

## Usage

### Sync Issues

Run the daily sync to pull GitLab issues:

```bash
# Full sync with Taskwarrior integration
./scripts/sync/venv/bin/python3 scripts/sync/daily_sync.py --sync-to-taskwarrior

# Dry run (preview without changes)
./scripts/sync/venv/bin/python3 scripts/sync/daily_sync.py --dry-run
```

### View GitLab Tasks

```bash
# List all GitLab-synced tasks
task +gitlab list

# List by project
task gitlab_project:shakespeare list

# View task details including GitLab URL
task 1 info
```

### Task Metadata

Synced tasks include custom attributes:

| Attribute | Description |
|-----------|-------------|
| `gitlab_id` | GitLab issue ID |
| `gitlab_url` | Direct link to issue |
| `gitlab_project` | Project name |
| `+gitlab` | Tag for filtering |

## Automation

### Cron Job

Set up automatic syncing:

```bash
# Edit crontab
crontab -e

# Add daily sync at 8 AM
0 8 * * * cd /path/to/soapbox-flow && ./scripts/sync/venv/bin/python3 scripts/sync/daily_sync.py --sync-to-taskwarrior >> /tmp/daily_sync.log 2>&1
```

### Systemd Timer

For more robust scheduling, see `scripts/sync/systemd/` for example service and timer files.

## Filtering Issues

### By Labels

To sync only specific labels, modify `scripts/sync/gitlab_sync.py`:

```python
# Add labels filter to the API call
issues = project.issues.list(labels=['priority::high', 'devrel'])
```

### By Assignee

Sync only issues assigned to you:

```python
issues = project.issues.list(assignee_username='your-username')
```

### By Milestone

Sync issues from a specific milestone:

```python
issues = project.issues.list(milestone='Q1 2026')
```

## Workflow Tips

### 1. Use Projects

Organize synced tasks by GitLab project:

```bash
# View tasks by project
task project:shakespeare list
task project:ditto list
```

### 2. Priority Mapping

Map GitLab labels to Taskwarrior priorities:

```bash
# Manually set priority on synced tasks
task +gitlab modify priority:H
```

### 3. Quick Access

Open GitLab issue from task:

```bash
# Get the URL
task 1 info | grep gitlab_url

# Or create an alias
alias gitlab-open='task $1 info | grep gitlab_url | cut -d" " -f2 | xargs xdg-open'
```

## Troubleshooting

### "401 Unauthorized"

- Token expired → Create new token
- Wrong token → Verify token in config
- Wrong URL → Check GitLab URL

### "404 Project Not Found"

- Invalid project ID → Verify project IDs
- No access → Check you have at least Reporter access
- Private project → Token needs appropriate permissions

### Tasks not syncing

1. Check the sync log:
   ```bash
   cat scripts/sync/gitlab_sync.log
   ```

2. Test API connection:
   ```bash
   curl -H "PRIVATE-TOKEN: your-token" "https://gitlab.com/api/v4/user"
   ```

3. Verify project access:
   ```bash
   curl -H "PRIVATE-TOKEN: your-token" "https://gitlab.com/api/v4/projects/PROJECT_ID"
   ```

### Duplicate tasks

The sync script tracks GitLab IDs to prevent duplicates. If you see duplicates:

1. Check `gitlab_id` on tasks
2. Remove duplicates: `task +gitlab +DUPLICATE delete`
3. Re-run sync

## Security

- **Token storage:** Tokens are stored in config files with `600` permissions
- **Don't commit tokens:** `.gitignore` excludes `.env` files
- **Rotate tokens:** Periodically create new tokens and revoke old ones
- **Minimal scopes:** Only `read_api` is needed for sync

---

For GitHub integration, see [github.md](github.md).
