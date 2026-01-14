# Configuration Templates

Ready-to-use configuration templates for Soapbox Flow tools.

## Usage

These templates contain placeholders that need to be replaced with your values:

| Placeholder | Replace With |
|-------------|--------------|
| `{{USER_EMAIL}}` | Your email address |
| `{{USER_NAME}}` | Your display name |
| `{{TIMEZONE}}` | Your timezone (e.g., America/Chicago) |
| `{{VAULT_PATH}}` | Path to your Obsidian vault |
| `{{GITLAB_TOKEN}}` | Your GitLab access token |
| `{{APP_PASSWORD}}` | Google app password |

## Quick Setup

The `configure.sh` script handles this automatically. For manual setup:

```bash
# Copy and customize Taskwarrior config
cp config/taskwarrior/taskrc.template ~/.taskrc
sed -i 's|{{USER_NAME}}|Your Name|g' ~/.taskrc

# Copy and customize khal config
mkdir -p ~/.config/khal
cp config/khal/config.template ~/.config/khal/config
sed -i 's|{{TIMEZONE}}|America/Chicago|g' ~/.config/khal/config
```

## Templates

### taskwarrior/taskrc.template

Taskwarrior configuration with:
- GitLab UDA fields for issue sync
- Optimized urgency coefficients
- Custom reports for daily/weekly views
- Dark color theme

### khal/config.template

Calendar configuration with:
- Multiple calendar support
- Locale settings for US format
- Integration with vdirsyncer paths

### khard/khard.conf.template

Contacts configuration with:
- Multiple address book support
- Search and display settings
- vCard 3.0 format

### vdirsyncer/config.template

Sync configuration with:
- Google Calendar setup
- Google Contacts setup
- Placeholder credentials

### claude/CLAUDE.md

Project-level Claude Code instructions for Soapbox Flow development.

## After Configuration

Test your setup:

```bash
# Test Taskwarrior
task add "Test task" +test
task list

# Test calendar
khal list today 7d

# Test contacts
khard list

# Test sync
vdirsyncer discover
vdirsyncer sync
```

## Security

- Templates contain placeholder values only
- Never commit files with real tokens
- Generated configs have 600 permissions
- Keep backups of working configs
