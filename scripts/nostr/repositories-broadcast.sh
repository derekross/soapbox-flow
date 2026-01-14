#!/bin/bash

# Fetch kind 30617 (NIP-34 repository announcements) events from source relays
# and broadcast them to relay.ditto.pub

SOURCE_RELAYS=(
    "wss://relay.damus.io"
    "wss://relay.primal.net"
    "wss://nos.lol"
)

TARGET_RELAY="wss://relay.ditto.pub"

TEMP_DIR=$(mktemp -d)
EVENTS_FILE="$TEMP_DIR/events.jsonl"

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "Fetching kind 30617 (NIP-34 repository announcements) events..."
echo "Source relays: ${SOURCE_RELAYS[*]}"
echo "Target relay: $TARGET_RELAY"
echo ""

# Fetch all kind 30617 events from source relays
echo "Querying relays..."
nak req -k 30617 -l 500 "${SOURCE_RELAYS[@]}" 2>/dev/null >> "$EVENTS_FILE"

# Count and deduplicate
if [ ! -s "$EVENTS_FILE" ]; then
    echo "No events found."
    exit 0
fi

# Deduplicate by event ID
UNIQUE_EVENTS=$(sort -u "$EVENTS_FILE" | jq -sc 'unique_by(.id)')
TOTAL=$(echo "$UNIQUE_EVENTS" | jq 'length')

echo "Found $TOTAL unique repository events"
echo ""
echo "Broadcasting to $TARGET_RELAY..."
echo ""

BROADCAST=0

echo "$UNIQUE_EVENTS" | jq -c '.[]' | while read -r event; do
    if [ -n "$event" ]; then
        EVENT_ID=$(echo "$event" | jq -r '.id[:16]')
        # Get the 'd' tag value (repo identifier)
        REPO_ID=$(echo "$event" | jq -r '.tags[] | select(.[0]=="d") | .[1] // empty' 2>/dev/null | head -1)
        # Get the name tag if available
        REPO_NAME=$(echo "$event" | jq -r '.tags[] | select(.[0]=="name") | .[1] // empty' 2>/dev/null | head -1)

        DISPLAY="${REPO_NAME:-${REPO_ID:-"(unknown)"}}"

        echo "Broadcasting: $DISPLAY [$EVENT_ID...]"
        if echo "$event" | nak event -q "$TARGET_RELAY" 2>/dev/null; then
            BROADCAST=$((BROADCAST + 1))
        fi
    fi
done

echo ""
echo "Done!"
