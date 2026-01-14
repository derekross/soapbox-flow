# Troubleshooting Guide

Common issues and how to fix them.

---

## Installation Issues

### "Command not found" after installation

**Symptom:** Commands like `nak`, `khal`, `task` not found after running install.sh

**Solution:**
```bash
# Add local bin to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Or for zsh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### "Permission denied" running scripts

**Symptom:** `./install.sh: Permission denied`

**Solution:**
```bash
chmod +x install.sh configure.sh uninstall.sh
chmod +x scripts/**/*.sh
```

### nak installation fails

**Symptom:** nak binary download fails or wrong architecture

**Solution:**
```bash
# Check your architecture
uname -m

# Manual install with Go
go install github.com/fiatjaf/nak@latest

# Or download manually from GitHub releases
# https://github.com/fiatjaf/nak/releases
```

### Python package installation fails

**Symptom:** pip install errors for khal, khard, vdirsyncer (especially "externally-managed-environment" on Python 3.11+)

**Solution:**

The installer now handles this automatically by:
1. Trying system packages first (apt/dnf/pacman)
2. Using pipx for CLI tools (handles PEP 668 restrictions)
3. Creating a venv for sync script libraries

If you need to install manually:

```bash
# Option 1: Use pipx for CLI tools (recommended for Python 3.11+)
pipx install khal
pipx install khard
pipx install vdirsyncer

# Option 2: System packages
sudo apt install khal khard vdirsyncer  # Debian/Ubuntu
sudo dnf install khal khard vdirsyncer  # Fedora
sudo pacman -S khal khard vdirsyncer    # Arch

# Option 3: Use the venv created by the installer
./scripts/sync/venv/bin/pip install python-gitlab requests
```

### Obsidian installation fails on Fedora

**Symptom:** Flatpak not available

**Solution:**
```bash
# Install Flatpak first
sudo dnf install flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Then install Obsidian
flatpak install flathub md.obsidian.Obsidian
```

---

## Configuration Issues

### configure.sh can't find vault

**Symptom:** "Vault path not found" error

**Solution:**
1. Create the vault first in Obsidian
2. Enter the correct path (use full path, not `~`)
3. Or create manually: `mkdir -p ~/Vault`

### GitLab connection fails

**Symptom:** "401 Unauthorized" or "Could not verify connection"

**Causes & Solutions:**

1. **Token expired:**
   - Create new token at GitLab → Settings → Access Tokens

2. **Wrong URL:**
   - For gitlab.com: `https://gitlab.com`
   - For self-hosted: `https://your-gitlab.example.com` (no trailing slash)

3. **Insufficient permissions:**
   - Token needs `read_api` scope

4. **Test manually:**
   ```bash
   curl -H "PRIVATE-TOKEN: your-token" "https://gitlab.com/api/v4/user"
   ```

### GitHub connection fails

**Symptom:** API connection test fails

**Solution:**
```bash
# Test your token
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user

# Ensure token has correct scopes (repo, read:user)
```

### Calendar sync not working

**Symptom:** vdirsyncer errors, no events appearing

**Solutions:**

1. **Discover calendars first:**
   ```bash
   vdirsyncer discover
   ```

2. **Check config syntax:**
   ```bash
   cat ~/.config/vdirsyncer/config
   # Ensure proper INI format, no trailing whitespace
   ```

3. **Reset sync status:**
   ```bash
   rm -rf ~/.local/share/vdirsyncer/status/
   vdirsyncer discover
   vdirsyncer sync
   ```

4. **Enable debug mode:**
   ```bash
   vdirsyncer -vdebug sync 2>&1 | tee vdirsyncer-debug.log
   ```

---

## Skills Issues

### Skills not loading in Claude Code

**Symptom:** Claude doesn't recognize skills

**Solutions:**

1. **Check symlinks exist:**
   ```bash
   ls -la ~/.claude/skills/
   ```

2. **Verify symlinks point to correct location:**
   ```bash
   readlink -f ~/.claude/skills/nostr-devrel
   # Should point to soapbox-flow/skills/nostr-devrel
   ```

3. **Re-create symlinks:**
   ```bash
   # Remove broken symlinks
   find ~/.claude/skills -xtype l -delete

   # Re-run installer
   ./install.sh
   ```

4. **Check SKILL.md frontmatter:**
   ```bash
   head -5 ~/.claude/skills/nostr-devrel/SKILL.md
   # Should have valid YAML frontmatter
   ```

### Skills not being invoked

**Symptom:** Claude doesn't use the skill when expected

**Solution:**
- Be explicit: "Use the nostr-devrel skill to help me..."
- Check skill description matches your use case
- Skills are suggestions, not guarantees

---

## Script Issues

### Nostr scripts fail

**Symptom:** nak commands error out

**Solutions:**

1. **Check nak is installed:**
   ```bash
   which nak
   nak --version
   ```

2. **Test relay connectivity:**
   ```bash
   nak req -k 0 -l 1 wss://relay.damus.io
   ```

3. **Check jq is installed:**
   ```bash
   which jq
   jq --version
   ```

4. **Run with debug output:**
   ```bash
   bash -x scripts/nostr/broadcast-shakespeare.sh
   ```

### publish-article.sh fails

**Symptom:** Article publishing errors

**Solutions:**

1. **Check URL is accessible:**
   ```bash
   curl -I https://soapbox.pub/blog/your-slug
   ```

2. **Test with dry run (abort at confirmation):**
   ```bash
   ./scripts/nostr/publish-article.sh your-slug
   # Press 'n' when prompted to publish
   ```

3. **Check markdown output:**
   ```bash
   cat /tmp/article-your-slug.md
   ```

### Sync scripts fail

**Symptom:** Python errors running daily_sync.py

**Solutions:**

1. **Check .env exists:**
   ```bash
   ls -la scripts/sync/.env
   ```

2. **Install requirements:**
   ```bash
   cd scripts/sync
   pip3 install -r requirements.txt
   ```

3. **Run with verbose output:**
   ```bash
   ./scripts/sync/venv/bin/python3 scripts/sync/daily_sync.py --dry-run 2>&1 | tee sync-debug.log
   ```

---

## Taskwarrior Issues

### Tasks not syncing from GitLab

**Symptom:** GitLab issues not appearing in Taskwarrior

**Solutions:**

1. **Check GitLab config:**
   ```bash
   grep GITLAB scripts/sync/.env
   ```

2. **Test GitLab API:**
   ```bash
   curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "$GITLAB_URL/api/v4/projects/$PROJECT_ID/issues?state=opened"
   ```

3. **Run sync manually:**
   ```bash
   ./scripts/sync/venv/bin/python3 scripts/sync/gitlab_sync.py
   ```

### Duplicate tasks

**Symptom:** Same GitLab issue creates multiple tasks

**Solution:**
```bash
# Find duplicates
task +gitlab list

# Check gitlab_id
task 1 info | grep gitlab_id

# Remove duplicates
task +gitlab gitlab_id:12345 delete
```

### "Taskwarrior was built without GnuTLS"

**Symptom:** Sync features unavailable

**Solution:**
This is a warning, not an error. Local task management works fine. For sync features, install from official repos:
```bash
# Ubuntu/Debian
sudo apt install taskwarrior

# Fedora
sudo dnf install task

# macOS
brew install taskwarrior
```

---

## Calendar Issues (khal)

### "No calendars found"

**Symptom:** khal shows no events

**Solutions:**

1. **Check calendar directory exists:**
   ```bash
   ls ~/.local/share/khal/calendars/
   ```

2. **Verify config points to correct path:**
   ```bash
   grep path ~/.config/khal/config
   ```

3. **Create calendar directory:**
   ```bash
   mkdir -p ~/.local/share/khal/calendars/default/
   ```

### Events not showing after sync

**Symptom:** vdirsyncer succeeds but khal empty

**Solutions:**

1. **Check files were created:**
   ```bash
   ls ~/.local/share/khal/calendars/
   find ~/.local/share/khal -name "*.ics" | head
   ```

2. **Verify khal config matches vdirsyncer paths:**
   - vdirsyncer `path` must match khal `[[calendar]]` path

---

## OpenCode Sidebar Issues

### Plugin not appearing in Obsidian

**Symptom:** OpenCode Sidebar not in Community Plugins

**Solutions:**

1. **Check plugin files exist:**
   ```bash
   ls ~/Vault/.obsidian/plugins/opencode-sidebar/
   # Should have: main.js, manifest.json, styles.css
   ```

2. **Enable Community Plugins:**
   - Obsidian → Settings → Community Plugins → Turn on

3. **Restart Obsidian:**
   - Close completely and reopen

### "opencode not found"

**Symptom:** Plugin can't start OpenCode

**Solution:**
The plugin requires OpenCode CLI installed and in PATH:
```bash
# Check OpenCode is installed
which opencode
opencode --version
```

---

## Performance Issues

### Scripts running slowly

**Solutions:**

1. **Reduce relay list:**
   Edit scripts to use fewer relays

2. **Increase timeouts:**
   Add `timeout 30` before nak commands

3. **Run in background:**
   ```bash
   nohup ./scripts/sync/venv/bin/python3 scripts/sync/daily_sync.py &
   ```

### Large vault causing issues

**Solutions:**

1. **Exclude large folders from sync**
2. **Use specific paths in config**
3. **Archive old files periodically**

---

## Getting Help

### Collect debug information

```bash
# Run health check
./scripts/utils/health-check.sh > health-check-output.txt 2>&1

# System info
uname -a >> health-check-output.txt
echo "Python: $(python3 --version)" >> health-check-output.txt

# Config (redact tokens!)
cat ~/.config/soapbox-flow/config.env | sed 's/TOKEN=.*/TOKEN=REDACTED/' >> health-check-output.txt
```

### Where to get help

1. **GitHub Issues:** https://github.com/soapbox-pub/soapbox-flow/issues
2. **Nostr:** Post with #soapboxflow hashtag
3. **Documentation:** Check integration-specific guides

---

## Reset Everything

Nuclear option - start fresh:

```bash
# Run uninstaller
./uninstall.sh

# Remove all configs
rm -rf ~/.config/soapbox-flow
rm -rf ~/.config/khal
rm -rf ~/.config/khard
rm -rf ~/.config/vdirsyncer
rm ~/.taskrc

# Remove data (CAREFUL - this deletes tasks!)
rm -rf ~/.task
rm -rf ~/.local/share/khal
rm -rf ~/.local/share/khard
rm -rf ~/.local/share/vdirsyncer

# Re-run installer
./install.sh
./configure.sh
```

---

Still stuck? Open an issue with your health-check output and error messages.
