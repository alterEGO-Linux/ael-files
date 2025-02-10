#!/usr/bin/env bash
# :----------------------------------------------------------------------- INFO
# :[/hypr/scripts/kb_monitor.sh]
# :author        : alterEGO Linux
# :created       : 2025-02-05 11:54:36 UTC
# :updated       : 2025-02-05 11:54:42 UTC
# :description   : Monitor changes in keyboard layout and send notification.

get_current_layout() {
    hyprctl devices -j | jq -r '.keyboards[] | select((.main | type) == "boolean" and .main == true) | .active_keymap'
}

LAST_LAYOUT=""

while true; do
    # :Get the current layout
    CURRENT_LAYOUT="$(get_current_layout)"

    # :Check if the layout has changed
    if [[ -n "$CURRENT_LAYOUT" ]] && [[ "$CURRENT_LAYOUT" != "$LAST_LAYOUT" ]]; then
        # :Update the last layout
        LAST_LAYOUT="$CURRENT_LAYOUT"

        # Send notification
        dunstify -r 9999 "Keyboard Layout" "Current: $CURRENT_LAYOUT"
    fi

    sleep 0.5
done
