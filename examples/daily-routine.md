# Daily Routine Example

A complete daily workflow using Soapbox Flow tools.

---

## Morning Setup (8:00 AM)

### 1. Sync Everything

```bash
# Run the daily sync
./scripts/sync/venv/bin/python3 scripts/sync/daily_sync.py --sync-to-taskwarrior

# Or use the quick commands
vdirsyncer sync  # Calendar
task sync        # Taskwarrior (if using sync server)
```

### 2. Check Calendar

```bash
# Today's events
khal list today

# Full week view
khal list today 7d
```

Example output:
```
Today, 2026-01-14
  10:00-11:00 Team standup
  14:00-15:00 Product review
  16:00-16:30 1:1 with Alex

Tomorrow, 2026-01-15
  09:00-10:00 Sprint planning
```

### 3. Review Tasks

```bash
# Today's priority tasks
task today

# All pending tasks
task list

# GitLab issues
task +gitlab list
```

### 4. Plan the Day

Ask Claude to create your schedule:

```
"Create my schedule for today using my calendar and tasks"
```

Claude will use the executive-assistant skill to generate:

```markdown
# Daily Schedule — Tuesday, January 14, 2026

**Focus:** Deep dev work

---

### 8:00-10:00 — Community Engagement
- [ ] Review Nostr mentions
- [ ] Respond to GitHub issues

### 10:00-11:00 — Team Standup
Meeting: Team standup

### 11:00-12:00 — Code Review
- [ ] Review PR #456: Authentication refactor
- [ ] Respond to MR comments

...
```

---

## Working Session

### Starting a Task

```bash
# Start working on a task (tracks time)
task 5 start

# View active tasks
task active
```

### Taking Meeting Notes

During your 10:00 standup:

```
"Take notes on this meeting:
- Discussed Q1 roadmap
- Alex working on mobile app
- Blocker: need API documentation
- Action items: Derek to write docs by Friday"
```

Claude generates structured notes saved to your vault.

### Adding Tasks Throughout the Day

```bash
# Quick task add
task add "Review Alex's PR" +code due:today

# With project
task add "Write API docs" project:shakespeare due:friday priority:H

# From GitLab (automatic via sync)
# Issues appear after next sync
```

---

## Afternoon Focus

### Content Creation Block (2:00-4:00 PM)

Ask Claude to help with content:

```
"Use the content-research-writer skill to draft a blog post
about the new Shakespeare mobile features"
```

### Publishing to Nostr

```bash
# After blog post is live on your site
./scripts/nostr/publish-article.sh shakespeare-mobile-features

# Preview first
./scripts/nostr/publish-article.sh shakespeare-mobile-features --local
```

### Broadcast Updates

```bash
# Sync Shakespeare content across relays
./scripts/nostr/broadcast-shakespeare.sh

# Sync event announcements
./scripts/nostr/broadcast-shakespeare-events.sh
```

---

## End of Day (5:00 PM)

### 1. Complete Active Tasks

```bash
# Stop active task
task active
task 5 stop

# Mark completed tasks as done
task 5 done
task 12 done
```

### 2. Review What's Done

```bash
# Tasks completed today
task end:today completed

# Quick summary
task summary
```

### 3. Prepare Tomorrow

```bash
# What's due tomorrow
task due:tomorrow list

# Set priorities for tomorrow
task 8 modify priority:H
task 9 modify +tomorrow
```

### 4. Final Sync

```bash
# Sync everything
vdirsyncer sync
./scripts/sync/venv/bin/python3 scripts/sync/daily_sync.py
```

### 5. Generate EOD Summary

Ask Claude:

```
"Generate my end-of-day summary including:
- Tasks completed
- Progress on projects
- Tomorrow's priorities"
```

---

## Weekly Additions

### Monday: Week Planning

```bash
# Review the week
khal list today eow

# Tasks due this week
task due.before:eow list

# Generate weekly plan
./scripts/sync/venv/bin/python3 scripts/sync/weekly_report.py --dry-run
```

### Friday: Week Review

```bash
# Generate weekly report
./scripts/sync/venv/bin/python3 scripts/sync/weekly_report.py

# Review completed tasks
task end.after:today-7d completed

# Clean up done tasks
task +COMPLETED delete
```

---

## Quick Reference

| Time | Action | Command |
|------|--------|---------|
| 8:00 | Sync | `./scripts/sync/venv/bin/python3 scripts/sync/daily_sync.py --sync-to-taskwarrior` |
| 8:05 | Calendar | `khal list today 7d` |
| 8:10 | Tasks | `task today` |
| Throughout | Add task | `task add "Description" due:DATE` |
| Throughout | Start task | `task ID start` |
| Throughout | Complete task | `task ID done` |
| 17:00 | Review | `task end:today completed` |
| 17:05 | Tomorrow | `task due:tomorrow list` |
| 17:10 | Sync | `vdirsyncer sync` |

---

## Tips

1. **Batch similar work** - Group communications, coding, and writing
2. **Use task priorities** - H/M/L helps with urgency sorting
3. **Tag liberally** - Makes filtering easier (+code, +meeting, +docs)
4. **Review before adding** - Check if task already exists
5. **Trust the system** - Let sync scripts handle GitLab/calendar

---

See also:
- [DevRel Workflow](devrel-workflow.md)
- [Content Creation](content-creation.md)
