#!/usr/bin/env python3
"""
Calendar Sync

Fetches calendar events from khal/vdirsyncer.
"""

import re
import subprocess


def fetch_calendar_events():
    """Fetch today's calendar events using khal."""
    try:
        # Sync calendar first
        subprocess.run(["vdirsyncer", "sync"], capture_output=True, timeout=60)

        # Get today's events
        result = subprocess.run(
            ["khal", "list", "today", "today"],
            capture_output=True,
            text=True,
            timeout=30
        )

        if result.returncode != 0:
            return []

        events = []
        seen_events = set()

        # Pattern for event lines: "HH:MM-HH:MM" or "HH:MM" at start
        time_pattern = re.compile(r'^\d{1,2}:\d{2}(-\d{1,2}:\d{2})?')

        # Words/phrases to filter out - case insensitive
        skip_patterns = ['birthday', 'bday', 'do better', 'garbage pickup']

        for line in result.stdout.strip().split('\n'):
            line = line.strip()
            if not line:
                continue

            # Only include lines that start with a time pattern
            if not time_pattern.match(line):
                continue

            # Skip filtered items
            if any(pattern in line.lower() for pattern in skip_patterns):
                continue

            # Extract just the time and event name (before :: description)
            if ' :: ' in line:
                line = line.split(' :: ')[0]

            # Deduplicate events (same event from multiple calendars)
            event_key = line.strip()
            if event_key in seen_events:
                continue
            seen_events.add(event_key)

            events.append(line)

        return events
    except Exception as e:
        print(f"  Warning: Could not fetch calendar events: {e}")
        return []


def main():
    """Run calendar sync standalone."""
    print("Syncing and fetching calendar events...")
    events = fetch_calendar_events()
    print(f"Found {len(events)} events today:\n")
    for event in events:
        print(f"  - {event}")


if __name__ == "__main__":
    main()
