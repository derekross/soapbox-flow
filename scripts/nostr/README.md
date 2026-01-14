# Nostr Scripts

Shell scripts for Nostr operations using [nak](https://github.com/fiatjaf/nak).

## Requirements

- `nak` — Nostr Army Knife CLI
- `jq` — JSON processor
- `python3` — For publish-article.sh HTML conversion
- `curl` — For fetching web content

## Scripts

### publish-article.sh

Publish a blog post to Nostr as a NIP-23 long-form article (kind 30023).

```bash
# Publish from production site
./publish-article.sh shakespeare-mobile-development

# Publish from local dev server
./publish-article.sh my-post --local

# Publish from full URL
./publish-article.sh https://soapbox.pub/blog/my-article
```

**Features:**
- Extracts metadata from Open Graph and JSON-LD
- Converts HTML to clean Markdown
- Adds cover image and footer
- Publishes to multiple relays
- Prompts securely for nsec

**Relays:** relay.primal.net, relay.damus.io, relay.ditto.pub, nos.lol, relay.snort.social

### broadcast-shakespeare.sh

Fetch and broadcast kind 1 text notes with `#shakespearediy` hashtag.

```bash
./broadcast-shakespeare.sh
```

### broadcast-shakespeare-events.sh

Fetch and broadcast NIP-52 calendar events and NIP-53 live activities related to Shakespeare Workshop.

```bash
./broadcast-shakespeare-events.sh
```

**Event kinds:** 31922 (date calendar), 31923 (time calendar), 30311 (live activities)

### apps-broadcast.sh

Fetch and broadcast NIP-89 app handler events (kind 31990).

```bash
./apps-broadcast.sh
```

### repositories-broadcast.sh

Fetch and broadcast NIP-34 repository announcement events (kind 30617).

```bash
./repositories-broadcast.sh
```

### community-broadcast.sh

Broadcast community events (kind 34550) to multiple relays.

```bash
# Broadcast to default relays
./community-broadcast.sh

# Broadcast to specific relays
./community-broadcast.sh wss://relay.example.com wss://another.relay
```

### custom-nips-broadcast.sh

Fetch and broadcast custom NIP events (kind 30817).

```bash
./custom-nips-broadcast.sh
```

## Configuration

### Relay Lists

All broadcast scripts have configurable relay arrays at the top:

```bash
SOURCE_RELAYS=(
    "wss://relay.primal.net"
    "wss://relay.damus.io"
    "wss://nos.lol"
)

TARGET_RELAY="wss://relay.ditto.pub"
```

Edit these to customize source and target relays.

### Common Patterns

**Fetch events:**
```bash
nak req -k <kind> -l <limit> "${SOURCE_RELAYS[@]}"
```

**Filter by hashtag:**
```bash
nak req -k 1 -t t=hashtag "${SOURCE_RELAYS[@]}"
```

**Filter by author:**
```bash
nak req -k 1 -a <hex-pubkey> "${SOURCE_RELAYS[@]}"
```

**Broadcast event:**
```bash
echo "$event" | nak event "$TARGET_RELAY"
```

## Event Kinds Reference

| Kind | NIP | Description |
|------|-----|-------------|
| 1 | 01 | Text note |
| 30023 | 23 | Long-form article |
| 30311 | 53 | Live activity |
| 30617 | 34 | Repository announcement |
| 30817 | — | Custom NIP |
| 31922 | 52 | Date-based calendar |
| 31923 | 52 | Time-based calendar |
| 31990 | 89 | App handler |
| 34550 | 72 | Community |

## Troubleshooting

**"nak: command not found"**
- Install nak: `go install github.com/fiatjaf/nak@latest`
- Or use installer: `./install.sh`

**"jq: command not found"**
- Install jq: `apt install jq` or `brew install jq`

**Events not broadcasting**
- Check relay is online: `curl -I <relay-url>`
- Try different target relay
- Check event is valid JSON

**nsec prompt not appearing**
- Scripts use `--prompt-sec` flag
- Enter nsec when prompted (input hidden)
- Never hardcode nsec in scripts
