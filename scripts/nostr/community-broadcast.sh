#!/bin/bash

# Broadcast the Nostr Developers community (kind 34550) event to relays
# Fetches from legacy Ditto relay and broadcasts to target relays

SOURCE_RELAY="wss://ditto.pub/relay"

# Community identifiers
COMMUNITY_PUBKEY="0461fcbecc4c3374439932d6b8f11269ccdb7cc973ad7a50ae362db135a474dd"
COMMUNITY_IDENTIFIER="nostr-developers-mbp9sz5o"

DEFAULT_TARGET_RELAYS=(
    "wss://relay.ditto.pub"
    "wss://relay.primal.net"
    "wss://nos.lol"
    "wss://relay.snort.social"
)

# Use provided relays or defaults
if [ $# -gt 0 ]; then
    TARGET_RELAYS=("$@")
else
    TARGET_RELAYS=("${DEFAULT_TARGET_RELAYS[@]}")
fi

echo "Fetching Nostr Developers community (kind 34550) event..."
echo "Source relay: $SOURCE_RELAY"
echo "Target relays: ${TARGET_RELAYS[*]}"
echo ""

# Fetch the community event from the source relay
EVENT=$(nak req -k 34550 -a "$COMMUNITY_PUBKEY" -t "d=$COMMUNITY_IDENTIFIER" "$SOURCE_RELAY" 2>/dev/null | head -1)

if [ -z "$EVENT" ]; then
    echo "Error: Could not fetch community event from $SOURCE_RELAY"
    exit 1
fi

EVENT_ID=$(echo "$EVENT" | jq -r '.id[:16]')
COMMUNITY_NAME=$(echo "$EVENT" | jq -r '.tags[] | select(.[0]=="name") | .[1] // empty')

echo "Found: $COMMUNITY_NAME [$EVENT_ID...]"
echo ""
echo "Broadcasting to target relays..."
echo ""

for relay in "${TARGET_RELAYS[@]}"; do
    echo -n "  $relay: "
    RESULT=$(echo "$EVENT" | nak event "$relay" 2>&1)
    if echo "$RESULT" | grep -q "success"; then
        echo "success"
    else
        # Extract failure reason if present
        REASON=$(echo "$RESULT" | grep -oP 'failed: \K.*' | head -1)
        echo "failed${REASON:+ ($REASON)}"
    fi
done

echo ""
echo "Done!"
