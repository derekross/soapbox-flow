# Skills Guide

Complete guide to using Claude Code skills included with Soapbox Flow.

## Overview

Skills are markdown files that give Claude domain-specific knowledge and workflows. When you work with Claude Code, it automatically loads relevant skills based on context.

## Installed Skills

| Skill | Purpose | Key Files |
|-------|---------|-----------|
| **executive-assistant** | Scheduling, tasks, admin work | 5 files |
| **nostr-devrel** | Nostr ecosystem DevRel | 4 files |
| **content-research-writer** | Content creation | 1 file |
| **planning-with-files** | Structured planning | 3 files |
| **docx** | Word documents | 1 file |
| **pptx** | PowerPoint presentations | 1 file |
| **xlsx** | Excel spreadsheets | 1 file |
| **strategic-planning** | Project planning | 1 file |

---

## executive-assistant

Your AI executive assistant for productivity and organization.

### When to Use

- Managing tasks and schedules
- Taking meeting notes
- Drafting emails
- Planning your day/week
- Tracking projects

### Files Included

| File | Purpose |
|------|---------|
| `SKILL.md` | Core instructions and workflows |
| `templates.md` | Email, meeting, and document templates |
| `checklists.md` | Daily, weekly, monthly operational checklists |
| `reference.md` | CLI cheatsheet for Taskwarrior, khal, khard |
| `schedule-template.md` | Time-block templates for daily planning |

### Example Prompts

```
"Create my schedule for today based on my tasks and calendar"

"Draft a follow-up email for yesterday's meeting with Alex"

"What tasks are due this week? Prioritize them for me"

"Take notes on this meeting: [paste transcript]"

"Generate my weekly report from completed tasks"
```

### Reference Commands

The skill knows these CLI tools:

```bash
task list                    # List tasks
task add "Task" due:tomorrow # Add task
khal list today 7d           # Show calendar
khard show "Alex"            # Find contact
```

---

## nostr-devrel

Comprehensive Nostr ecosystem knowledge for developer relations work.

### When to Use

- Writing about Nostr
- Creating workshops or tutorials
- Finding ecosystem contacts
- Understanding NIPs
- DevRel content creation

### Files Included

| File | Purpose |
|------|---------|
| `SKILL.md` | Core DevRel instructions and workflows |
| `ecosystem-contacts.md` | Key people, projects, npubs |
| `nips-reference.md` | NIP lookup table, nak commands |
| `sample-content.md` | Workshop scripts, social threads, objection handling |

### Example Prompts

```
"Help me write a workshop outline for Shakespeare"

"What's the npub for fiatjaf?"

"Explain NIP-23 long-form content"

"Draft a Twitter thread about why Nostr matters"

"Create a Reddit post for r/Bitcoin about Shakespeare"
```

### NIP Quick Reference

```
NIP-01: Basic protocol (events, signatures)
NIP-05: DNS verification (user@domain.com)
NIP-07: Browser signer (window.nostr)
NIP-19: Bech32 encoding (npub, nsec, note)
NIP-23: Long-form content (kind 30023)
NIP-57: Zaps (Lightning tips)
```

### nak Commands

```bash
nak decode npub1...          # Decode bech32
nak key generate             # Generate keypair
nak req -k 1 -l 10 wss://... # Query events
nak event --prompt-sec ...   # Publish event
```

---

## content-research-writer

Research and write high-quality content for various platforms.

### When to Use

- Writing blog posts
- Creating tutorials
- Reddit marketing posts
- Social media threads
- Technical documentation

### Content Types

| Type | Length | Structure |
|------|--------|-----------|
| Technical Blog | 1,000-2,500 words | Hook → Problem → Solution → Implementation → Conclusion |
| Thought Leadership | 800-1,500 words | Provocative opening → Thesis → Arguments → CTA |
| Reddit Post | 200-500 words | Context → Value prop → Features → CTA → Question |
| Tutorial | 2,000-4,000 words | Goal → Prerequisites → Steps → Troubleshooting |
| Social Thread | 7-12 posts | Hook → Context → Points → Summary → CTA |

### Example Prompts

```
"Write a blog post about building on Nostr for beginners"

"Create a Reddit post for r/selfhosted about Shakespeare"

"Draft a Twitter thread explaining decentralized identity"

"Research the Lightning Network ecosystem and summarize"

"Write a tutorial for setting up a Nostr relay"
```

### Writing Tips (from the skill)

- Lead with problems, not products
- Show, don't tell (demos > claims)
- Acknowledge limitations honestly
- Include working code examples
- Use conversational but technical tone

---

## planning-with-files

Structured planning using persistent markdown files.

### When to Use

- Starting complex projects
- Multi-step task planning
- Research with documentation
- Progress tracking

### Files Included

| File | Purpose |
|------|---------|
| `SKILL.md` | Planning methodology |
| `examples.md` | Example plan structures |
| `reference.md` | File naming conventions |

### Example Prompts

```
"Create a plan for implementing user authentication"

"Set up a planning file for the conference preparation"

"Track progress on the API migration project"

"Document our research on competitor features"
```

### Plan File Structure

```markdown
# Project: [Name]

## Objective
What we're trying to accomplish

## Current Status
- [x] Completed items
- [ ] Pending items

## Research
Notes and findings

## Next Steps
Immediate actions

## Open Questions
Things to resolve
```

---

## docx / pptx / xlsx

Microsoft Office document creation skills.

### When to Use

- **docx**: Reports, proposals, contracts, documentation
- **pptx**: Presentations, pitch decks, conference talks
- **xlsx**: Budgets, data analysis, tracking spreadsheets

### Example Prompts

```
# Word documents
"Create a project proposal document for the new feature"
"Generate a meeting minutes template"

# PowerPoint
"Create a presentation for the Bitcoin conference"
"Build a pitch deck for Shakespeare"

# Excel
"Create a budget spreadsheet for Q1"
"Make a project tracking spreadsheet"
```

---

## strategic-planning

Project and campaign planning skill.

### When to Use

- Conference preparation
- Product launch planning
- Marketing campaigns
- Quarterly planning

### Example Prompts

```
"Create a strategic plan for Bitcoin Conference 2026"

"Plan the Shakespeare launch campaign"

"Develop a Q1 content strategy"

"Map out the community growth initiative"
```

---

## Using Skills Effectively

### Be Explicit

If Claude doesn't automatically use a skill, invoke it directly:

```
"Use the nostr-devrel skill to help me write this workshop"

"Reference the executive-assistant templates for this email"
```

### Combine Skills

Skills work together:

```
"Use the content-research-writer skill to draft a blog post,
then format it for Nostr publishing using nostr-devrel knowledge"
```

### Access Supplementary Files

Reference specific files:

```
"Check ecosystem-contacts.md for Alex Gleason's npub"

"Use the schedule-template.md format for my daily plan"
```

---

## Customizing Skills

### Add Your Own Data

Edit supplementary files to add your own:
- Contacts in `ecosystem-contacts.md`
- Templates in `templates.md`
- Checklists in `checklists.md`

### Create New Skills

1. Create directory: `~/.claude/skills/my-skill/`
2. Add `SKILL.md` with frontmatter:

```markdown
---
name: my-skill
description: What this skill does
---

# My Skill

Instructions for Claude...
```

3. Add supplementary `.md` files as needed

---

## Troubleshooting

### Skills not loading

```bash
# Verify symlinks
ls -la ~/.claude/skills/

# Check skill files exist
cat ~/.claude/skills/nostr-devrel/SKILL.md | head -10
```

### Skill not being used

- Be more explicit in your prompt
- Mention the skill by name
- Reference specific supplementary files

### Wrong information from skill

- Skills are guides, not guarantees
- Verify critical information
- Update supplementary files with corrections

---

See also:
- [Configuration Guide](configuration.md)
- [Scripts Guide](scripts-guide.md)
