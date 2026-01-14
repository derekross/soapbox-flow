# Soapbox Flow

An AI-powered productivity suite that integrates tasks, calendar, git workflows, and Nostr—with Claude skills that understand your work context.

## What is this?

Soapbox Flow brings together the tools developers and DevRel professionals use daily:

- **Task Management** — Taskwarrior integration with GitLab/GitHub sync
- **Calendar & Contacts** — khal/khard with Google Calendar support
- **Nostr Integration** — Publish, broadcast, and manage your Nostr presence
- **Claude Skills** — Pre-built AI skills for content creation, DevRel, and productivity
- **Automation Scripts** — Ready-to-use scripts for common workflows

## Quick Start

```bash
# Clone the repository
git clone https://github.com/soapbox-pub/soapbox-flow.git
cd soapbox-flow

# Run the installer (installs dependencies)
./install.sh

# Configure your integrations
./configure.sh
```

## What Gets Installed

| Tool | Purpose |
|------|---------|
| [nak](https://github.com/fiatjaf/nak) | Nostr Army Knife CLI |
| [Taskwarrior](https://taskwarrior.org/) | Task management |
| [khal](https://khal.readthedocs.io/) | Calendar |
| [khard](https://khard.readthedocs.io/) | Contacts |
| [vdirsyncer](https://vdirsyncer.pimutils.org/) | CalDAV/CardDAV sync |

## Directory Structure

```
soapbox-flow/
├── skills/          # Claude Code skills
├── scripts/         # Automation scripts
├── config/          # Configuration templates
├── docs/            # Documentation
└── examples/        # Example workflows
```

## Skills

Pre-built Claude Code skills for common workflows:

| Skill | Description |
|-------|-------------|
| **executive-assistant** | Task management, scheduling, meeting notes |
| **nostr-devrel** | Nostr ecosystem DevRel toolkit |
| **content-research-writer** | Blog posts, tutorials, social content |
| **planning-with-files** | Structured planning with markdown files |
| **docx/pptx/xlsx** | Microsoft Office document creation |
| **strategic-planning** | Project and campaign planning |

### Installing Skills

```bash
# Symlink all skills to Claude Code
ln -s $(pwd)/skills/* ~/.claude/skills/

# Or copy specific skills
cp -r skills/nostr-devrel ~/.claude/skills/
```

## Scripts

### Nostr Scripts

```bash
# Publish a blog post to Nostr (NIP-23)
./scripts/nostr/publish-article.sh my-blog-post

# Broadcast events between relays
./scripts/nostr/broadcast-events.sh

# Lookup NIP-05 identifier
./scripts/nostr/lookup-nip05.sh alex@gleasonator.dev
```

### Sync Scripts

```bash
# Run daily sync (calendar + GitLab + tasks)
python3 scripts/sync/daily-sync.py

# Generate weekly report
python3 scripts/sync/weekly-report.py
```

## Configuration

After running `./configure.sh`, your configuration files are stored in:

- `~/.taskrc` — Taskwarrior config
- `~/.config/khal/config` — Calendar config
- `~/.config/khard/khard.conf` — Contacts config
- `~/.config/vdirsyncer/config` — Sync config

See [docs/configuration.md](docs/configuration.md) for detailed options.

## Integrations

### GitLab

Sync GitLab issues to Taskwarrior:

1. Create a personal access token at GitLab → Settings → Access Tokens
2. Run `./configure.sh` and enter your token
3. Issues appear as tasks with `+gitlab` tag

### GitHub

Similar to GitLab—create a token and configure during setup.

### Google Calendar

1. Create OAuth credentials in Google Cloud Console
2. Run `./configure.sh` and authorize
3. Events sync bidirectionally with khal

### Nostr

1. Import or generate your nsec during setup
2. Configure preferred relays
3. Use scripts to publish and broadcast

## Requirements

- **OS:** Linux (Ubuntu 20.04+, Debian 11+, Fedora 35+, Arch) or macOS 12+
- **Python:** 3.8+
- **Claude Code:** For AI skills functionality

## Documentation

- [Getting Started](docs/getting-started.md)
- [Configuration Guide](docs/configuration.md)
- [Skills Guide](docs/skills-guide.md)
- [Scripts Guide](docs/scripts-guide.md)
- [Troubleshooting](docs/troubleshooting.md)

### Integration Guides

- [GitLab Setup](docs/integrations/gitlab.md)
- [GitHub Setup](docs/integrations/github.md)
- [Google Calendar Setup](docs/integrations/google-calendar.md)
- [Nostr Setup](docs/integrations/nostr.md)

## Roadmap

- **Phase 1** (Current): Scripts + installer for technical users
- **Phase 2**: CLI tool (`soapbox-flow sync`, `soapbox-flow tasks`, etc.)
- **Phase 3**: GUI application for all users

See [plan.md](plan.md) for detailed roadmap.

## Contributing

Contributions welcome! Please read the contributing guidelines before submitting PRs.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Links

- **Soapbox:** https://soapbox.pub
- **Nostr:** Follow us at `npub1...`
- **Issues:** https://github.com/soapbox-pub/soapbox-flow/issues

---

Built with love by [Soapbox](https://soapbox.pub) for the Nostr community.
