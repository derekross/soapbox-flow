#!/bin/bash

# Fetch kind 1 events with #shakespearediy hashtag from source relays
# and broadcast them to relay.ditto.pub

SOURCE_RELAYS=(
    "wss://relay.primal.net"
    "wss://relay.damus.io"
    "wss://nos.lol"
)

TARGET_RELAY="wss://relay.ditto.pub"

echo "Fetching kind 1 events with #shakespearediy from source relays..."
echo "Source relays: ${SOURCE_RELAYS[*]}"
echo "Target relay: $TARGET_RELAY"
echo ""

# Fetch events and broadcast each one to the target relay
# -k 1 = kind 1 (text notes)
# -t t=shakespearediy = hashtag filter (#t tag)
# -l 50 = limit to 50 events (adjust as needed)
nak req -k 1 -t t=shakespearediy -l 50 "${SOURCE_RELAYS[@]}" | while read -r event; do
    echo "Broadcasting event..."
    echo "$event" | nak event "$TARGET_RELAY"
done

echo ""
echo "Done!"
