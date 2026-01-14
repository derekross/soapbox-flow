#!/bin/bash

# Fetch NIP-52 (calendar) and NIP-53 (live activities) events
# with tag #ShakespeareWorkshop or title containing "Shakespeare Workshop"
# and broadcast them to relay.ditto.pub

SOURCE_RELAYS=(
    "wss://relay.primal.net"
    "wss://relay.noswhere.com"
    "wss://relay.damus.io"
    "wss://nos.lol"
)

TARGET_RELAY="wss://relay.ditto.pub"

# NIP-52: kind 31922 (date-based calendar), kind 31923 (time-based calendar)
# NIP-53: kind 30311 (live activities)
KINDS="-k 31922 -k 31923 -k 30311"

TEMP_DIR=$(mktemp -d)
EVENTS_FILE="$TEMP_DIR/events.jsonl"

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "Fetching NIP-52/NIP-53 calendar and live events..."
echo "Source relays: ${SOURCE_RELAYS[*]}"
echo "Target relay: $TARGET_RELAY"
echo ""

# Method 1: Fetch by hashtag #ShakespeareWorkshop (case variations)
echo "Searching by hashtag #ShakespeareWorkshop..."
nak req $KINDS -t t=ShakespeareWorkshop -l 100 "${SOURCE_RELAYS[@]}" 2>/dev/null >> "$EVENTS_FILE"
nak req $KINDS -t t=shakespeareworkshop -l 100 "${SOURCE_RELAYS[@]}" 2>/dev/null >> "$EVENTS_FILE"

# Method 2: Use NIP-50 search for title (relays that support it)
echo "Searching for 'Shakespeare Workshop' in content/title..."
nak req $KINDS --search "Shakespeare Workshop" -l 100 "${SOURCE_RELAYS[@]}" 2>/dev/null >> "$EVENTS_FILE"

# Method 3: Fetch recent events and filter locally by title tag
echo "Fetching recent events and filtering by title..."
nak req $KINDS -l 500 "${SOURCE_RELAYS[@]}" 2>/dev/null | \
    jq -c 'select(.tags[][] | test("Shakespeare Workshop"; "i"))' >> "$EVENTS_FILE" 2>/dev/null

# Deduplicate by event ID and broadcast
echo ""
echo "Deduplicating and broadcasting events..."

TOTAL=0
BROADCAST=0

if [ -s "$EVENTS_FILE" ]; then
    # Sort by ID and deduplicate
    sort -u "$EVENTS_FILE" | jq -sc 'unique_by(.id) | .[]' 2>/dev/null | while read -r event; do
        if [ -n "$event" ]; then
            TOTAL=$((TOTAL + 1))
            EVENT_ID=$(echo "$event" | jq -r '.id[:16]')
            TITLE=$(echo "$event" | jq -r '.tags[] | select(.[0]=="title") | .[1] // empty' 2>/dev/null | head -1)
            echo "Broadcasting: ${TITLE:-"(no title)"} [$EVENT_ID...]"
            if echo "$event" | nak event -q "$TARGET_RELAY" 2>/dev/null; then
                BROADCAST=$((BROADCAST + 1))
            fi
        fi
    done
fi

echo ""
echo "Done!"
