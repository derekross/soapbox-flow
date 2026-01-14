# DevRel Workflow Example

A complete developer relations workflow using Soapbox Flow.

---

## Weekly DevRel Rhythm

| Day | Focus | Key Activities |
|-----|-------|----------------|
| Monday | Planning | Review metrics, set week goals, organize tasks |
| Tuesday | Deep Work | Code, documentation, technical content |
| Wednesday | Content | Publish blog, create social threads |
| Thursday | Community | Calls, AMAs, live sessions, support |
| Friday | Review | Reports, documentation, prep next week |

---

## Content Creation Flow

### 1. Research Phase

Ask Claude to research:

```
"Use the nostr-devrel skill to research what content would resonate
with the Nostr developer community this week"
```

Claude checks:
- Recent ecosystem developments
- Community discussions (#asknostr, #devstr)
- Competitor content
- Upcoming events

### 2. Writing Phase

```
"Use the content-research-writer skill to draft a technical blog post
about building a NIP-07 browser extension"
```

Claude generates:
- Hook and problem statement
- Step-by-step implementation
- Code examples
- Conclusion and resources

### 3. Review Phase

Save draft to your vault, then:

```
"Review this blog post for technical accuracy and developer appeal"
```

### 4. Publishing Phase

```bash
# Publish to website (your CMS process)
# ...

# Then publish to Nostr
./scripts/nostr/publish-article.sh nip-07-browser-extension
```

### 5. Promotion Phase

```
"Create a Twitter/Nostr thread promoting this blog post,
highlighting the key technical insights"
```

Post the thread, then broadcast:

```bash
# Ensure post reaches all relays
./scripts/nostr/broadcast-shakespeare.sh
```

---

## Community Engagement

### Morning Check (30 min)

```bash
# Check for mentions/questions
nak req -k 1 --search "@shakespeare" -l 20 wss://relay.ditto.pub

# Check GitHub notifications
gh api notifications | jq '.[].subject.title'

# Check GitLab issues
task +gitlab list
```

### Responding to Questions

When you find a question:

```
"Help me respond to this developer question about Nostr signing:
[paste the question]"
```

Claude uses nostr-devrel knowledge to draft a helpful response.

### Tracking Interactions

```bash
# Add community task
task add "Respond to @dev123 question about NIP-07" +community +nostr

# Track for follow-up
task add "Follow up with @dev123 on NIP-07 implementation" due:fri +community
```

---

## Workshop Preparation

### Planning a Workshop

```
"Use the nostr-devrel skill to create a workshop outline for
'Building Your First Nostr App with Shakespeare'"
```

Claude references `sample-content.md` for:
- Workshop structure templates
- Timing guides
- Hands-on exercise ideas

### Creating Materials

```
"Create a step-by-step tutorial document for the workshop,
suitable for developers new to Nostr"
```

### Event Promotion

```bash
# Create calendar event
khal new 2026-02-15 14:00 16:00 "Shakespeare Workshop" -l "Online"

# Create Nostr event (kind 31923)
# Use sample from nips-reference.md
```

---

## Ecosystem Tracking

### Staying Current

```
"What are the latest developments in the Nostr ecosystem
I should be aware of for DevRel?"
```

Claude checks:
- Recent NIP proposals
- New client releases
- Protocol discussions

### Updating Contacts

When you meet someone new:

```bash
# Add to contacts
khard new
# Fill in details

# Add to ecosystem-contacts.md
```

Then update the skill:

```
"Add this new contact to the ecosystem-contacts.md:
Name: Jane Smith
Focus: Lightning integration
npub: npub1..."
```

### Tracking Competitors

```
"Research what other Nostr projects are doing for developer outreach.
Summarize their recent content and community activities."
```

---

## Conference Preparation

### 2 Months Before

```bash
# Create project
task add "Bitcoin Conference 2026 Prep" project:conf2026

# Add sub-tasks
task add "Submit talk proposal" project:conf2026 due:2026-03-01 priority:H
task add "Book travel" project:conf2026 due:2026-03-15
task add "Prepare demo" project:conf2026 due:2026-04-01
```

### 1 Month Before

```
"Use the strategic-planning skill to create a detailed
conference preparation plan for Bitcoin Conference 2026"
```

### 1 Week Before

```
"Use the pptx skill to create a presentation for my talk:
'Decentralized Publishing with Shakespeare'"
```

### During Conference

```bash
# Quick contact capture
task add "Follow up: Met @satoshi at conf" +conf2026 +followup due:mon
```

### After Conference

```
"Generate a conference report including:
- Contacts made
- Conversations summary
- Follow-up actions
- Content ideas from the event"
```

---

## Metrics & Reporting

### Weekly Metrics

Track in your vault or spreadsheet:
- Blog post views
- GitHub stars/forks
- Nostr engagement (zaps, reposts)
- Community questions answered
- Workshop attendees

### Monthly Report

```
"Generate my monthly DevRel report including:
- Content published
- Community growth
- Key conversations
- Next month priorities"
```

### Quarterly Planning

```
"Use the strategic-planning skill to create Q2 DevRel goals
based on Q1 learnings and company objectives"
```

---

## Quick Reference: DevRel Commands

```bash
# Content
./scripts/nostr/publish-article.sh SLUG     # Publish blog to Nostr
./scripts/nostr/broadcast-shakespeare.sh    # Sync hashtag posts

# Community
nak req -k 1 --search "keyword" wss://relay  # Search Nostr
task +community list                          # Community tasks
khard show "Name"                             # Find contact

# Events
khal new DATE TIME "Event"                   # Add event
./scripts/nostr/broadcast-shakespeare-events.sh  # Sync events

# Reporting
python3 scripts/sync/weekly_report.py        # Weekly report
task project:devrel completed                 # Completed DevRel tasks
```

---

## Skills for DevRel

| Task | Skill to Use |
|------|--------------|
| Writing content | content-research-writer |
| Nostr knowledge | nostr-devrel |
| Presentations | pptx |
| Planning | strategic-planning |
| Scheduling | executive-assistant |
| Documentation | docx |

---

See also:
- [Content Creation](content-creation.md)
- [Daily Routine](daily-routine.md)
- [Nostr Integration](../docs/integrations/nostr.md)
