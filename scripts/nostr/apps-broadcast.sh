#!/bin/bash

# Fetch kind 31990 (NIP-89 app handlers) events from source relays
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

echo "Fetching kind 31990 (NIP-89 app handlers) events..."
echo "Source relays: ${SOURCE_RELAYS[*]}"
echo "Target relay: $TARGET_RELAY"
echo ""

# Fetch all kind 31990 events from source relays
echo "Querying relays..."
nak req -k 31990 -l 500 "${SOURCE_RELAYS[@]}" 2>/dev/null >> "$EVENTS_FILE"

# Count and deduplicate
if [ ! -s "$EVENTS_FILE" ]; then
    echo "No events found."
    exit 0
fi

# Deduplicate by event ID
UNIQUE_EVENTS=$(sort -u "$EVENTS_FILE" | jq -sc 'unique_by(.id)')
TOTAL=$(echo "$UNIQUE_EVENTS" | jq 'length')

echo "Found $TOTAL unique app handler events"
echo ""
echo "Broadcasting to $TARGET_RELAY..."
echo ""

BROADCAST=0

echo "$UNIQUE_EVENTS" | jq -c '.[]' | while read -r event; do
    if [ -n "$event" ]; then
        EVENT_ID=$(echo "$event" | jq -r '.id[:16]')
        # Get the 'd' tag value (app identifier)
        APP_ID=$(echo "$event" | jq -r '.tags[] | select(.[0]=="d") | .[1] // empty' 2>/dev/null | head -1)
        # Try to get app name from content (usually JSON with name field)
        APP_NAME=$(echo "$event" | jq -r '.content' 2>/dev/null | jq -r '.name // empty' 2>/dev/null)

        DISPLAY="${APP_NAME:-${APP_ID:-"(unknown)"}}"

        echo "Broadcasting: $DISPLAY [$EVENT_ID...]"
        if echo "$event" | nak event -q "$TARGET_RELAY" 2>/dev/null; then
            BROADCAST=$((BROADCAST + 1))
        fi
    fi
done

echo ""
echo "Done!"
