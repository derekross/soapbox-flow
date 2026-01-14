# GitHub Integration

Sync GitHub issues and pull requests with your local workflow.

## Overview

The GitHub integration allows you to:
- Sync issues to Taskwarrior
- Track pull request status
- Link tasks to GitHub URLs

## Prerequisites

- GitHub account
- Personal access token with appropriate scopes
- Taskwarrior installed and configured

## Setup

### 1. Create Personal Access Token

1. Go to GitHub → Settings → Developer settings → Personal access tokens
   - Direct link: https://github.com/settings/tokens

2. Click "Generate new token" (classic)

3. Configure the token:
   - **Note:** Soapbox Flow (or any identifier)
   - **Expiration:** Set as needed
   - **Scopes:** Select:
     - `repo` (Full control of private repositories)
     - `read:user` (Read user profile data)
     - For public repos only: `public_repo` instead of `repo`

4. Click "Generate token"

5. Copy the token immediately (it won't be shown again)

### 2. Configure Soapbox Flow

Run the configuration wizard:

```bash
./configure.sh
```

When prompted for GitHub, enter your token.

Or manually edit `~/.config/soapbox-flow/config.env`:

```bash
GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
```

And `scripts/sync/.env`:

```bash
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
GITHUB_REPOS=owner/repo1,owner/repo2
```

### 3. Test Connection

```bash
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user
```

You should see your user profile JSON.

## Usage

### Sync Issues

The sync scripts can pull GitHub issues:

```bash
python3 scripts/sync/daily_sync.py --sync-to-taskwarrior
```

### View GitHub Tasks

```bash
# List all GitHub-synced tasks
task +github list

# List by repository
task github_repo:soapbox-pub/shakespeare list
```

### Task Metadata

Synced tasks include:

| Attribute | Description |
|-----------|-------------|
| `github_id` | GitHub issue number |
| `github_url` | Direct link to issue |
| `github_repo` | Repository name |
| `+github` | Tag for filtering |

## API Usage Examples

### List Issues

```bash
# List open issues for a repo
curl -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/OWNER/REPO/issues?state=open"
```

### List Your Issues

```bash
# Issues assigned to you
curl -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/issues?filter=assigned"
```

### List Pull Requests

```bash
# Open PRs for a repo
curl -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/OWNER/REPO/pulls?state=open"
```

### Get Notifications

```bash
curl -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/notifications"
```

## GitHub CLI Alternative

For more complex operations, consider using the [GitHub CLI](https://cli.github.com/):

```bash
# Install
brew install gh  # macOS
sudo apt install gh  # Ubuntu

# Authenticate
gh auth login

# List issues
gh issue list --repo owner/repo

# Create issue
gh issue create --title "Bug" --body "Description"

# View PR
gh pr view 123
```

## Workflow Integration

### Daily Sync

Add to your daily routine:

```bash
# Morning sync
python3 scripts/sync/daily_sync.py --sync-to-taskwarrior

# View today's GitHub tasks
task +github due:today list
```

### PR Review Workflow

1. Get assigned PRs:
   ```bash
   gh pr list --search "review-requested:@me"
   ```

2. Add as task:
   ```bash
   task add "Review PR #123: Feature X" +github +review
   ```

3. Complete when merged:
   ```bash
   task +github +review done
   ```

## Filtering Options

### By Labels

```bash
# Only sync high-priority issues
curl -H "Authorization: token $TOKEN" \
  "https://api.github.com/repos/OWNER/REPO/issues?labels=priority:high"
```

### By Milestone

```bash
# Issues in a specific milestone
curl -H "Authorization: token $TOKEN" \
  "https://api.github.com/repos/OWNER/REPO/issues?milestone=1"
```

### By Assignee

```bash
# Your issues only
curl -H "Authorization: token $TOKEN" \
  "https://api.github.com/repos/OWNER/REPO/issues?assignee=YOUR_USERNAME"
```

## Rate Limits

GitHub API has rate limits:
- **Authenticated:** 5,000 requests/hour
- **Unauthenticated:** 60 requests/hour

Check your rate limit:
```bash
curl -H "Authorization: token $TOKEN" \
  "https://api.github.com/rate_limit"
```

## Security Best Practices

1. **Minimal scopes:** Only request permissions you need
2. **Token rotation:** Create new tokens periodically
3. **Don't commit tokens:** Use environment variables
4. **Use fine-grained tokens:** For more control (beta feature)

### Fine-Grained Tokens (Recommended)

GitHub now offers fine-grained personal access tokens:
1. Go to Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. Select specific repositories
3. Choose minimal permissions needed

## Troubleshooting

### "Bad credentials"

- Token expired → Create new token
- Wrong token → Verify in config
- Token revoked → Check GitHub settings

### "Not Found" for private repos

- Need `repo` scope, not just `public_repo`
- Verify you have access to the repository

### Rate limit exceeded

```bash
# Check when limit resets
curl -I -H "Authorization: token $TOKEN" https://api.github.com/users/octocat
# Look for X-RateLimit-Reset header
```

### SSL Certificate errors

```bash
# Usually indicates network/proxy issues
# Try without proxy or check corporate firewall
```

## Comparison: GitHub vs GitLab

| Feature | GitHub | GitLab |
|---------|--------|--------|
| Token creation | Settings → Developer settings | Settings → Access Tokens |
| API base URL | api.github.com | gitlab.com/api/v4 |
| Auth header | `Authorization: token X` | `PRIVATE-TOKEN: X` |
| Issue kind | "issue" | "issue" |
| Merge request | "pull request" | "merge request" |

---

For GitLab integration, see [gitlab.md](gitlab.md).
