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

# Start app if not already up
active=$(hyprctl workspaces -j | jq --arg NAME "special:$workspace_name" '[.[] | select(.name == $NAME)] | length')
if $active -eq 0; then
  $app_command &
fi

hyprctl dispatch togglespecialworkspace "$workspace_name"
