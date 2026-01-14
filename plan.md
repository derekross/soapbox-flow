# Soapbox Flow - Project Plan

An AI-powered productivity suite that integrates tasks, calendar, git workflows, and Nostr—with Claude skills that understand your work context.

---

## Vision

**For:** Developers, DevRel professionals, and eventually non-technical users
**Core Value:** Skills + Automation + Integrated Workflow + AI Tools
**Product:** Public Soapbox product

**Elevator Pitch:**
> Your AI-powered command center for developer productivity. Integrate tasks, calendar, git, and Nostr with Claude skills that actually understand your workflow.

---

## Phases Overview

| Phase | Target Audience | Deliverable | Timeframe |
|-------|-----------------|-------------|-----------|
| 1 | Technical users | Scripts + Installer | Near-term |
| 2 | Technical users | CLI Tool | Medium-term |
| 3 | Everyone | GUI Application | Longer-term |

---

## Phase 1: Technical MVP

### Goals
- [ ] One-command installation of all dependencies
- [ ] Interactive configuration wizard
- [ ] Pre-configured Claude skills
- [ ] Working automation scripts
- [ ] Comprehensive documentation

### Directory Structure

```
soapbox-flow/
├── plan.md                    # This file
├── README.md                  # Project overview, quick start
├── LICENSE                    # MIT or similar
├── install.sh                 # Main installer script
├── configure.sh               # Interactive setup wizard
├── uninstall.sh               # Clean removal
│
├── skills/                    # Claude Code skills
│   ├── README.md              # How to install skills
│   ├── content-research-writer/
│   │   └── SKILL.md
│   ├── executive-assistant/
│   │   ├── SKILL.md
│   │   ├── templates.md
│   │   ├── checklists.md
│   │   ├── reference.md
│   │   └── schedule-template.md
│   ├── nostr-devrel/
│   │   ├── SKILL.md
│   │   ├── ecosystem-contacts.md
│   │   ├── nips-reference.md
│   │   └── sample-content.md
│   ├── planning-with-files/
│   │   ├── SKILL.md
│   │   ├── examples.md
│   │   └── reference.md
│   ├── docx/
│   │   └── SKILL.md
│   ├── pptx/
│   │   └── SKILL.md
│   ├── xlsx/
│   │   └── SKILL.md
│   └── strategic-planning/
│       └── SKILL.md
│
├── scripts/                   # Automation scripts
│   ├── README.md              # Script documentation
│   ├── nostr/                 # Nostr/nak scripts
│   │   ├── broadcast-events.sh
│   │   ├── publish-article.sh
│   │   ├── sync-relays.sh
│   │   └── lookup-nip05.sh
│   ├── sync/                  # Sync automation
│   │   ├── daily-sync.py
│   │   ├── weekly-report.py
│   │   └── gitlab-tasks.py
│   └── utils/                 # Utility scripts
│       ├── backup.sh
│       └── health-check.sh
│
├── config/                    # Configuration templates
│   ├── README.md              # Configuration guide
│   ├── taskwarrior/
│   │   └── taskrc.template
│   ├── khal/
│   │   └── config.template
│   ├── khard/
│   │   └── khard.conf.template
│   ├── vdirsyncer/
│   │   └── config.template
│   └── claude/
│       └── settings.template
│
├── docs/                      # Documentation
│   ├── getting-started.md
│   ├── configuration.md
│   ├── skills-guide.md
│   ├── scripts-guide.md
│   ├── integrations/
│   │   ├── gitlab.md
│   │   ├── github.md
│   │   ├── google-calendar.md
│   │   └── nostr.md
│   └── troubleshooting.md
│
└── examples/                  # Example workflows
    ├── devrel-workflow.md
    ├── content-creation.md
    └── daily-routine.md
```

### Task Breakdown

#### 1.1 Project Setup
- [x] Create project directory
- [x] Create plan.md
- [ ] Initialize git repository
- [ ] Create README.md with project overview
- [ ] Add LICENSE file
- [ ] Create .gitignore

#### 1.2 Skills Migration
- [ ] Copy skills from derek-claude-skills repo
- [ ] Review and clean up each skill
- [ ] Add skills/README.md with installation instructions
- [ ] Test skills work when symlinked to ~/.claude/skills/

#### 1.3 Scripts Migration & Organization
- [ ] Copy nak-scripts to scripts/nostr/
- [ ] Copy daily_sync.py and weekly_report.py to scripts/sync/
- [ ] Generalize scripts (remove hardcoded paths)
- [ ] Add configuration file support to scripts
- [ ] Add scripts/README.md with documentation
- [ ] Test scripts work from new location

#### 1.4 Installer Script (install.sh)
- [ ] Detect operating system (Linux distro, macOS)
- [ ] Check for existing installations
- [ ] Install system dependencies:
  - [ ] nak (from GitHub releases)
  - [ ] taskwarrior (apt/brew)
  - [ ] khal (pip)
  - [ ] khard (pip)
  - [ ] vdirsyncer (pip)
  - [ ] jq (apt/brew)
  - [ ] python3 + pip
- [ ] Create directory structure
- [ ] Symlink skills to ~/.claude/skills/
- [ ] Make scripts executable
- [ ] Print success message with next steps

#### 1.5 Configuration Wizard (configure.sh)
- [ ] Interactive prompts for:
  - [ ] User name and email
  - [ ] Nostr identity (nsec/npub or generate new)
  - [ ] GitLab token and project IDs
  - [ ] GitHub token (optional)
  - [ ] Google Calendar credentials
  - [ ] Preferred relays
  - [ ] Vault/notes directory location
- [ ] Generate configuration files from templates
- [ ] Test connections (GitLab API, calendar sync, relay ping)
- [ ] Create initial task in Taskwarrior
- [ ] Print configuration summary

#### 1.6 Configuration Templates
- [ ] Create taskrc.template
- [ ] Create khal config.template
- [ ] Create khard.conf.template
- [ ] Create vdirsyncer config.template
- [ ] Create claude settings.template
- [ ] Document template variables

#### 1.7 Documentation
- [ ] Write getting-started.md (quick start guide)
- [ ] Write configuration.md (detailed config options)
- [ ] Write skills-guide.md (how to use each skill)
- [ ] Write scripts-guide.md (what each script does)
- [ ] Write integration guides:
  - [ ] GitLab setup
  - [ ] GitHub setup
  - [ ] Google Calendar setup
  - [ ] Nostr identity setup
- [ ] Write troubleshooting.md (common issues)

#### 1.8 Testing & Polish
- [ ] Test fresh install on clean Linux system
- [ ] Test fresh install on macOS
- [ ] Fix any issues found
- [ ] Add uninstall.sh script
- [ ] Add health-check.sh script
- [ ] Create example workflow documentation

#### 1.9 Release
- [ ] Final README polish
- [ ] Create GitHub repository
- [ ] Push initial release
- [ ] Write announcement blog post
- [ ] Share on Nostr

---

## Phase 2: CLI Tool

### Goals
- [ ] Single binary distribution
- [ ] Subcommand interface
- [ ] Cross-platform (Linux, macOS, Windows)
- [ ] Homebrew/apt/scoop installation

### Technology Choice
**Recommended: Go**
- Single binary, no runtime dependencies
- Good CLI libraries (cobra, bubbletea)
- Familiar ecosystem (nak is Go)
- Cross-compilation built-in

### Command Structure

```bash
soapbox-flow init              # First-time setup wizard
soapbox-flow config            # View/edit configuration
soapbox-flow config set <key> <value>

soapbox-flow sync              # Run all syncs
soapbox-flow sync calendar     # Sync calendar only
soapbox-flow sync tasks        # Sync GitLab tasks
soapbox-flow sync contacts     # Sync contacts

soapbox-flow tasks             # List tasks
soapbox-flow tasks add <desc>  # Add task
soapbox-flow tasks done <id>   # Complete task

soapbox-flow schedule          # Show today's schedule
soapbox-flow schedule generate # Generate daily schedule

soapbox-flow nostr publish <file>   # Publish to Nostr
soapbox-flow nostr broadcast <kind> # Broadcast events
soapbox-flow nostr lookup <nip05>   # Lookup NIP-05

soapbox-flow status            # Dashboard view
soapbox-flow doctor            # Check system health

soapbox-flow upgrade           # Self-update
```

### Task Breakdown

#### 2.1 Project Setup
- [ ] Initialize Go module
- [ ] Set up project structure
- [ ] Add cobra for CLI framework
- [ ] Add bubbletea for TUI elements
- [ ] Set up CI/CD for cross-compilation

#### 2.2 Core Commands
- [ ] Implement `init` command
- [ ] Implement `config` command
- [ ] Implement `sync` command
- [ ] Implement `tasks` command
- [ ] Implement `schedule` command
- [ ] Implement `nostr` command
- [ ] Implement `status` command
- [ ] Implement `doctor` command

#### 2.3 Distribution
- [ ] Set up GoReleaser
- [ ] Create Homebrew formula
- [ ] Create apt repository
- [ ] Create scoop manifest
- [ ] Write installation docs for each platform

---

## Phase 3: GUI Application

### Goals
- [ ] Desktop application for all platforms
- [ ] Visual setup wizard
- [ ] OAuth integration flows
- [ ] Real-time sync status
- [ ] Non-technical user friendly

### Technology Choice
**Recommended: Tauri (Rust + Web)**
- Small binary size (~10MB vs Electron's ~150MB)
- Native performance
- Web frontend (familiar tech)
- Good security model

**Alternative: Wails (Go + Web)**
- Go backend matches Phase 2 CLI
- Smaller ecosystem than Tauri
- Easier if team knows Go

### Features

#### Setup Wizard
- Welcome screen with feature overview
- Platform detection
- Dependency installation (with progress)
- Account connections:
  - GitLab OAuth
  - GitHub OAuth
  - Google Calendar OAuth
  - Nostr key import/generate
- Configuration review
- Test connections
- Success screen

#### Main Dashboard
- Today's schedule overview
- Task list with quick actions
- Calendar preview
- Sync status indicators
- Quick publish to Nostr
- Recent activity feed

#### Settings Panel
- Account management
- Relay configuration
- Sync frequency settings
- Notification preferences
- Theme (light/dark)
- Skill management

#### Nostr Panel
- Identity management
- Publish content
- Broadcast events
- Relay status
- Following/followers

### Task Breakdown

#### 3.1 Project Setup
- [ ] Initialize Tauri project
- [ ] Set up frontend framework (Svelte/React/Vue)
- [ ] Design UI mockups
- [ ] Set up build pipeline

#### 3.2 Setup Wizard
- [ ] Welcome flow
- [ ] Dependency installer
- [ ] OAuth flows
- [ ] Nostr key management
- [ ] Configuration storage

#### 3.3 Main Application
- [ ] Dashboard view
- [ ] Task management
- [ ] Calendar integration
- [ ] Nostr publishing
- [ ] Settings panel

#### 3.4 Distribution
- [ ] macOS signing and notarization
- [ ] Windows code signing
- [ ] Linux packages (AppImage, deb, rpm)
- [ ] Auto-update mechanism
- [ ] Website with downloads

---

## Technical Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    User Interface Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐   │
│  │   Scripts   │  │     CLI     │  │    GUI (Desktop)    │   │
│  │   (Bash)    │  │    (Go)     │  │  (Tauri/Rust+Web)   │   │
│  └─────────────┘  └─────────────┘  └─────────────────────┘   │
├──────────────────────────────────────────────────────────────┤
│                      Core Engine                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │  Tasks   │ │ Calendar │ │   Git    │ │      Nostr       │ │
│  │(taskwar) │ │  (khal)  │ │(GitLab/  │ │   (nak/relays)   │ │
│  │          │ │          │ │ GitHub)  │ │                  │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────────────┘ │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │ Contacts │ │  Sync    │ │  Media   │ │  Claude Skills   │ │
│  │ (khard)  │ │(vdirsync)│ │(Blossom) │ │   (Markdown)     │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────────────┘ │
├──────────────────────────────────────────────────────────────┤
│                    Storage Layer                              │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐  │
│  │  Config Files  │  │   Local DB     │  │  Vault/Notes   │  │
│  │ (~/.config/)   │  │   (SQLite)     │  │  (Markdown)    │  │
│  └────────────────┘  └────────────────┘  └────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

---

## Integrations

### Required
| Integration | Purpose | Setup Complexity |
|-------------|---------|------------------|
| Taskwarrior | Task management | Low (local) |
| khal/khard | Calendar/contacts | Medium (vdirsyncer) |
| nak | Nostr operations | Low (binary) |
| Claude Code | AI assistance | Low (API key) |

### Optional
| Integration | Purpose | Setup Complexity |
|-------------|---------|------------------|
| GitLab | Issue sync, MR tracking | Medium (token) |
| GitHub | Issue sync, PR tracking | Medium (token) |
| Google Calendar | Calendar sync | Medium (OAuth) |
| Blossom | Media storage | Low (server URL) |

---

## Success Metrics

### Phase 1
- [ ] Clean install works on fresh Ubuntu 22.04+
- [ ] Clean install works on macOS 12+
- [ ] All scripts run without modification
- [ ] Skills work when symlinked
- [ ] Documentation is complete and accurate
- [ ] At least 5 external users try it

### Phase 2
- [ ] Single binary installs and runs
- [ ] All Phase 1 functionality available via CLI
- [ ] Available via Homebrew and apt
- [ ] <10MB binary size
- [ ] <100ms startup time

### Phase 3
- [ ] GUI installs on all platforms
- [ ] OAuth flows work smoothly
- [ ] Non-technical tester can set up successfully
- [ ] <50MB installer size
- [ ] Professional, polished UI

---

## Open Questions

1. **Naming:** Is "Soapbox Flow" the right name?
2. **Licensing:** MIT? Apache 2.0? Something else?
3. **Monetization:** Free? Freemium? Part of Soapbox subscription?
4. **Scope:** Should this include Nostr client features or stay productivity-focused?
5. **Mobile:** Should Phase 3 include mobile apps?

---

## Current Status

**Phase:** 1 - Technical MVP
**Current Task:** 1.1 Project Setup
**Last Updated:** 2026-01-14

---

## Next Actions

1. Initialize git repository
2. Create README.md
3. Copy skills from derek-claude-skills
4. Copy and organize scripts
5. Start on install.sh

---

_This plan will be updated as the project progresses._
