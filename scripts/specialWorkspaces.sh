#!/usr/bin/env bash
# Usage: toggle_special_workspace.sh <workspace_name> <app_command>
# Opens a special workspace for an app

workspace_name="$1"
app_command="$2"

# Check if we're already on that special workspace
current_ws=$(hyprctl activeworkspace -j | jq -r '.name')

if [[ "$current_ws" == "special:$workspace_name" ]]; then
    # Already there → toggle off (go back)
    hyprctl dispatch togglespecialworkspace "$workspace_name"
    exit 0
fi

# Check if the app is already running
if ! pgrep -x "$app_command" >/dev/null; then
    # Launch the app on the special workspace
    hyprctl dispatch exec "[workspace special:$workspace_name silent] $app_command"
else
    # Just toggle to it
    hyprctl dispatch togglespecialworkspace "$workspace_name"
fi

