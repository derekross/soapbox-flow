# Nostr Integration

Set up your Nostr identity and start publishing content to the decentralized social network.

## Overview

Soapbox Flow includes scripts for:
- Publishing long-form articles (NIP-23)
- Broadcasting events between relays
- Managing your Nostr presence

## Prerequisites

- **nak** - Nostr Army Knife CLI (installed by `./install.sh`)
- **nsec** - Your Nostr secret key

## Getting Your Keys

### Option 1: Generate New Keys

During `./configure.sh`, choose "Generate new keypair":

```bash
./configure.sh
# When prompted, choose option 2 to generate new keys
```

Or generate manually with nak:

```bash
# Generate new keypair
nak key generate

# Output:
# nsec1abc...  (SECRET - never share!)
# npub1xyz...  (PUBLIC - safe to share)
```

**IMPORTANT:** Save your nsec securely in a password manager. It cannot be recovered if lost.

### Option 2: Use Existing Keys

If you already have a Nostr identity:

1. Get your nsec from your current client/signer
2. Enter it when scripts prompt for it
3. Or derive npub from nsec: `nak key public nsec1...`

## Configuration

Your Nostr configuration is stored in `~/.config/soapbox-flow/config.env`:

```bash
NOSTR_NPUB="npub1..."
NOSTR_RELAYS="wss://relay.damus.io,wss://relay.primal.net,wss://nos.lol"
```

### Relay Configuration

Default relays:
- `wss://relay.damus.io` - High-traffic public relay
- `wss://relay.primal.net` - Primal ecosystem
- `wss://nos.lol` - Reliable fallback
- `wss://relay.ditto.pub` - Ditto/Soapbox relay with search

Add or modify relays in the config or directly in scripts.

## Publishing Content

### Long-Form Articles (NIP-23)

Publish blog posts to Nostr:

```bash
# Publish from soapbox.pub
./scripts/nostr/publish-article.sh my-blog-slug

# Publish from local dev server
./scripts/nostr/publish-article.sh my-post --local

# Publish from any URL
./scripts/nostr/publish-article.sh https://example.com/blog/my-article
```

The script will:
1. Fetch the article HTML
2. Extract metadata (title, summary, image)
3. Convert to Markdown
4. Prompt for your nsec
5. Publish to configured relays

### Text Notes

Post simple text notes:

```bash
# Using nak directly
nak event --prompt-sec -k 1 -c "Hello Nostr!" wss://relay.damus.io
```

## Broadcasting Events

Sync events between relays:

```bash
# Broadcast hashtag posts
./scripts/nostr/broadcast-shakespeare.sh

# Broadcast calendar events
./scripts/nostr/broadcast-shakespeare-events.sh

# Broadcast app handlers (NIP-89)
./scripts/nostr/apps-broadcast.sh

# Broadcast git repositories (NIP-34)
./scripts/nostr/repositories-broadcast.sh
```

### Custom Broadcast

Query and broadcast any event type:

```bash
# Fetch events
nak req -k 1 -t t=myhashtag -l 50 wss://relay.damus.io wss://nos.lol

# Broadcast to another relay
nak req -k 1 -t t=myhashtag -l 50 wss://relay.damus.io | \
  while read event; do
    echo "$event" | nak event wss://relay.ditto.pub
  done
```

## Common Operations

### Lookup NIP-05

Find someone's npub from their NIP-05:

```bash
# Format: user@domain.com
curl -s "https://domain.com/.well-known/nostr.json?name=user" | jq

# Convert hex to npub
nak encode npub <hex-pubkey>
```

### Decode Nostr Entities

```bash
nak decode npub1...    # Decode public key
nak decode note1...    # Decode note ID
nak decode nevent1...  # Decode event with relay hints
nak decode nprofile1...  # Decode profile with relay hints
```

### Query Events

```bash
# Get someone's profile
nak req -k 0 -a <hex-pubkey> wss://relay.damus.io

# Get recent posts
nak req -k 1 -a <hex-pubkey> -l 10 wss://relay.damus.io

# Get long-form articles
nak req -k 30023 -a <hex-pubkey> wss://relay.damus.io

# Search (NIP-50, relay must support)
nak req -k 1 --search "keyword" wss://relay.ditto.pub
```

## Security Best Practices

1. **Never hardcode your nsec** - Always use `--prompt-sec`
2. **Use a signer app** - Amber (Android), Alby (browser extension)
3. **Backup your nsec** - Store in a password manager
4. **Don't reuse keys** - Consider separate keys for different purposes
5. **Verify before broadcasting** - Use `--dry-run` when available

## NIP Reference

Common NIPs you'll work with:

| NIP | Kind | Description |
|-----|------|-------------|
| 01 | 0, 1 | Profile metadata, text notes |
| 23 | 30023 | Long-form articles |
| 52 | 31922, 31923 | Calendar events |
| 53 | 30311 | Live activities |
| 89 | 31990 | App handlers |

See `skills/nostr-devrel/nips-reference.md` for a complete reference.

## Troubleshooting

### "nak: command not found"

```bash
# Check if installed
which nak

# Install manually
go install github.com/fiatjaf/nak@latest

# Or re-run installer
./install.sh
```

### Events not appearing

1. Check relay is online
2. Verify event was accepted: look for "success" message
3. Try different relay
4. Check if relay requires auth (NIP-42)

### Wrong key / signature invalid

1. Verify you're using the correct nsec
2. Check nsec format starts with `nsec1`
3. Don't include quotes around the key

---

For more nak commands, see the [skills/nostr-devrel/nips-reference.md](../../skills/nostr-devrel/nips-reference.md).
