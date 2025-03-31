#!/bin/bash

# Check if domain name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain_name>"
    exit 1
fi

DOMAIN=$1
LAST_RECORD=""
FIRST_RUN=true
LAST_RUN_TIME=""

echo "Monitoring A record for $DOMAIN..."

while true; do
    # Clear the terminal
    clear

    # Show last run time if not first run
    if [ "$FIRST_RUN" = false ]; then
        echo "Domain: $DOMAIN Current A record: $CURRENT_RECORD"
        echo "Last check: $LAST_RUN_TIME"
    fi

    # Perform DNS lookup for A record, sort results for consistent comparison
    CURRENT_RECORD=$(dig +short A "$DOMAIN" | sort)
    CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')

    # Handle potential empty results from dig
    if [ -z "$CURRENT_RECORD" ]; then
        echo "$CURRENT_TIME: Could not resolve A record for $DOMAIN"
        CURRENT_RECORD="<unresolved>" # Use a placeholder to avoid false positives on next successful lookup
    fi

    # Check if the record has changed since the last check (and it's not the first run)
    if [ "$FIRST_RUN" = false ] && [ "$CURRENT_RECORD" != "$LAST_RECORD" ]; then
        echo "$CURRENT_TIME: A record for $DOMAIN changed!"
        echo "Previous: $LAST_RECORD"
        echo "Current:  $CURRENT_RECORD"
        # Play terminal bell as notification
        echo -e '\a'
        # Optional: If you have notify-send installed (common on Linux desktops),
        # you can uncomment the following lines for a desktop notification:
        if command -v notify-send &>/dev/null; then
            notify-send "DNS Change Detected" "A record for $DOMAIN changed:\nPrevious: $LAST_RECORD\nCurrent: $CURRENT_RECORD"
        fi
    elif [ "$FIRST_RUN" = true ]; then
        echo "$CURRENT_TIME: Initial A record for $DOMAIN: $CURRENT_RECORD"
        FIRST_RUN=false
    fi

    # Update the last known record and time
    LAST_RECORD="$CURRENT_RECORD"
    LAST_RUN_TIME="$CURRENT_TIME"

    # Wait for 60 seconds before the next check
    sleep 60
done
