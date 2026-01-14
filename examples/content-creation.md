# Content Creation Workflow

End-to-end workflow for creating and publishing content with Soapbox Flow.

---

## Content Types Overview

| Type | Time to Create | Distribution |
|------|----------------|--------------|
| Blog Post (Technical) | 2-4 hours | Website → Nostr → Social |
| Blog Post (Thought Leadership) | 1-2 hours | Website → Nostr → Social |
| Tutorial | 4-8 hours | Website → Nostr → GitHub |
| Social Thread | 30-60 min | Nostr → Twitter |
| Reddit Post | 30-60 min | Reddit |
| Newsletter | 1-2 hours | Email → Nostr |

---

## Blog Post Workflow

### Step 1: Ideation

Ask Claude for ideas:

```
"Use the nostr-devrel skill to suggest 5 blog post ideas
that would resonate with developers interested in Nostr"
```

Or check your content backlog:

```bash
task project:content +idea list
```

### Step 2: Research

```
"Research the topic of NIP-07 browser extensions.
Gather information about:
- How it works
- Existing implementations
- Common pain points
- Best practices"
```

### Step 3: Outline

```
"Create a detailed outline for a technical blog post titled
'Building a NIP-07 Browser Signer from Scratch'"
```

Claude generates:

```markdown
# Building a NIP-07 Browser Signer from Scratch

## Hook (2 paragraphs)
- Why browser signing matters
- What we'll build

## Prerequisites
- JavaScript/TypeScript knowledge
- Basic Nostr understanding
- Browser extension basics

## Part 1: Understanding NIP-07
- What NIP-07 defines
- The window.nostr interface
- Security considerations

## Part 2: Project Setup
- Extension manifest
- Directory structure
- Dependencies

## Part 3: Core Implementation
- Key storage
- Signing events
- Permission handling

## Part 4: Testing
- Manual testing
- Integration with clients

## Conclusion
- Recap
- Next steps
- Resources
```

### Step 4: First Draft

```
"Write the first draft of this blog post following the outline.
Use a conversational but technical tone.
Include code examples for each implementation step."
```

### Step 5: Code Examples

Ensure all code examples work:

```
"Review the code examples in this blog post.
Check for errors and improve clarity."
```

### Step 6: Edit & Polish

```
"Edit this draft for:
- Clarity and flow
- Technical accuracy
- Engaging opening
- Strong conclusion
- SEO optimization"
```

### Step 7: Publish to Website

Use your CMS/publishing workflow. If using Soapbox blog:

```bash
# Preview locally
cd soapbox-website
npm run dev

# Deploy
npm run deploy
```

### Step 8: Publish to Nostr

```bash
# Publish the article
./scripts/nostr/publish-article.sh nip-07-browser-signer

# Confirm publication
# Enter your nsec when prompted
```

### Step 9: Social Promotion

```
"Create a Twitter/Nostr thread promoting this blog post.
5-7 tweets highlighting key insights and linking to the full article."
```

Post manually or use a client.

### Step 10: Track & Engage

```bash
# Add follow-up task
task add "Respond to blog comments on NIP-07 post" due:tomorrow +content

# Monitor mentions
nak req -k 1 --search "NIP-07 browser" -l 20 wss://relay.ditto.pub
```

---

## Social Thread Workflow

### Quick Thread Creation

```
"Create a Nostr thread explaining why decentralized identity matters.
7 posts, each with a clear point.
Include a hook, 5 main points, and a call to action."
```

### Thread Structure

```markdown
1. 🧵 Hook tweet (standalone value, makes people want to read more)

2. Context: Why this matters now

3. Point 1: [First key insight]

4. Point 2: [Second key insight]

5. Point 3: [Third key insight]

6. Point 4: [Fourth key insight with example]

7. Summary + CTA: [Recap and what to do next]
```

### Posting

Post via your preferred client (Damus, Primal, Amethyst, etc.)

Or use nak for the first post:

```bash
nak event --prompt-sec -k 1 \
  -c "🧵 Thread: Why decentralized identity matters...

1/" \
  wss://relay.damus.io wss://relay.primal.net
```

---

## Reddit Post Workflow

### Research the Subreddit

```
"What are the rules and culture of r/Bitcoin and r/CryptoCurrency?
What type of posts perform well there?"
```

### Draft the Post

```
"Use the content-research-writer skill to create a Reddit post
for r/Bitcoin about Shakespeare and decentralized publishing.
Follow Reddit norms - not salesy, provide value."
```

### Reddit Post Template

```markdown
**Title:** I built a tool that lets you publish websites to Nostr [Open Source]

Hey r/Bitcoin,

I've been working on [brief context] and wanted to share.

**The Problem:**
[2-3 sentences about the problem]

**The Solution:**
[What you built and why it's different]

**Key Features:**
- Feature 1
- Feature 2
- Feature 3

**Try it:**
[Link to demo or repo]

**Looking for feedback on:**
- Specific question 1
- Specific question 2

Happy to answer any questions!

---
*Disclosure: I work on this project*
```

### Post & Engage

1. Post during peak hours (generally 9-11 AM EST)
2. Respond to every comment
3. Don't be defensive about criticism
4. Thank people for feedback

```bash
# Track engagement
task add "Check Reddit post responses" due:today+4h +content +reddit
```

---

## Tutorial Workflow

### Planning

```
"Create a tutorial plan for 'Building Your First Nostr App'.
Include:
- Learning objectives
- Prerequisites
- Estimated time per section
- Code samples needed"
```

### Tutorial Structure

```markdown
# Building Your First Nostr App

## What You'll Build
[Screenshot or demo link]

## Prerequisites
- [ ] Node.js 18+
- [ ] Basic JavaScript knowledge
- [ ] A Nostr keypair (we'll create one)

## Time Required
~2 hours

---

## Step 1: Project Setup (15 min)
### Create the Project
### Install Dependencies
### Verify Setup

## Step 2: Connect to Relays (20 min)
### Understanding Relays
### Writing the Connection Code
### Testing the Connection

## Step 3: Fetch Events (25 min)
### Query Syntax
### Parsing Events
### Displaying Data

## Step 4: Publish Events (30 min)
### Creating Events
### Signing Events
### Publishing and Verifying

## Step 5: Build the UI (30 min)
### Simple HTML Interface
### Connecting the Pieces
### Final Testing

---

## Troubleshooting
[Common issues and solutions]

## Next Steps
[Where to go from here]

## Resources
[Links to docs, repos, communities]
```

### Writing

```
"Write Step 3 of this tutorial with detailed explanations
and working code examples."
```

### Testing

Actually run through the tutorial yourself to verify:
1. All commands work
2. Code examples are copy-pasteable
3. Expected output matches
4. Troubleshooting covers common issues

### Publishing

Same as blog post workflow - website, then Nostr, then social.

---

## Content Calendar

### Weekly Schedule

| Day | Content Type | Platform |
|-----|--------------|----------|
| Monday | Plan week's content | Internal |
| Tuesday | Write blog draft | Internal |
| Wednesday | Publish blog | Website + Nostr |
| Thursday | Social threads | Nostr + Twitter |
| Friday | Community content | Reddit, HN |

### Tracking in Taskwarrior

```bash
# Add content tasks
task add "Write NIP-07 blog post" project:content due:wed priority:H
task add "Create promo thread" project:content due:wed +social
task add "Post to Reddit" project:content due:fri +reddit

# View content pipeline
task project:content list
```

---

## Quick Commands

```bash
# Publish article to Nostr
./scripts/nostr/publish-article.sh SLUG

# Broadcast posts to more relays
./scripts/nostr/broadcast-shakespeare.sh

# Check Nostr engagement
nak req -k 7 -t e=EVENT_ID wss://relay.damus.io  # Reactions
nak req -k 6 -t e=EVENT_ID wss://relay.damus.io  # Reposts

# Track content tasks
task project:content list
task +content due:week list
```

---

## Skills Reference

| Content Task | Skill |
|--------------|-------|
| Blog writing | content-research-writer |
| Nostr specifics | nostr-devrel |
| Presentations | pptx |
| Documentation | docx |
| Planning | planning-with-files |

---

## Tips for Great Content

1. **Lead with value** - What does the reader learn?
2. **Show, don't tell** - Demos and code > claims
3. **Be honest** - Acknowledge limitations
4. **Make it actionable** - Clear next steps
5. **Engage after publishing** - Respond to comments
6. **Iterate based on feedback** - Update content

---

See also:
- [DevRel Workflow](devrel-workflow.md)
- [Daily Routine](daily-routine.md)
- [Nostr Integration](../docs/integrations/nostr.md)
