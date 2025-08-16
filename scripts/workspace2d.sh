#!/usr/bin/env bash

if [ $# -ne 3 ]; then
    echo "Usage: workspace2d.sh <direction> <all> <sync>"
    exit 1
fi

matrix_size=8
# matrix_max=$((matrix_size ** 2))
max_screens=10
direction=$1
is_all=$2
is_sync=$3

function reload_waybar {
    # Waybar does signaling with pkill -SIG...
    # After we update our workspace we want to change our status on waybar.
    kill -SIGRTMIN+1 $(pgrep waybar)
}

# Get the x value of some workspace number `n`
function x_value {
    echo $(($1 % matrix_size))
}

# Get the y value of some workspace number `n`
function y_value {
    echo $(($1 / matrix_size))
}

function move_workspace {
    local direction="$1"
    local screen="$2"
    local workspace="$((($3 - 1) / max_screens))"
    local x_index
    local y_index
    x_index="$(x_value $workspace)"
    y_index="$(y_value $workspace)"

    case "$direction" in
        "left" | "right" | "move_left" | "move_right") hyprctl keyword animation "workspaces,1,1,default,slide"; ;;
        "up" | "down" | "move_up" | "move_down") hyprctl keyword animation "workspaces,1,1,default,slidevert"; ;;
    esac

    case "$direction" in
        "left" | "move_left") x_index=$(((x_index + matrix_size - 1) % matrix_size));  ;;
        "right" | "move_right") x_index=$(((x_index + 1) % matrix_size)) ;;
        "up" | "move_up") y_index=$(((y_index + matrix_size - 1) % matrix_size)) ;;
        "down" | "move_down") y_index=$(((y_index + 1) % matrix_size)) ;;
        "query") echo "($x_index,$y_index)"; exit ;;
    esac

    local workspace=$((max_screens * (y_index * matrix_size + x_index) + screen + 1))

    hyprctl dispatch focusmonitor "$screen"

    case "$direction" in
        "left" | "right" | "up" | "down") hyprctl dispatch workspace $workspace ;;
        "move_left" | "move_right" | "move_up" | "move_down") hyprctl dispatch movetoworkspace $workspace ;;
    esac

    hyprctl dispatch moveworkspacetomonitor $workspace "$screen"
}

original_monitor=$(hyprctl monitors -j | jq '.[] | select(.focused) | .id, .activeWorkspace.id')

move_workspace "$direction" $original_monitor

if [ "$is_all" = "all" ]; then
    all_ws=$(hyprctl monitors -j | jq '.[] | select(.focused | not) | .id, .activeWorkspace.id')
    direction_all=$direction

    # Normalize direction
    case "$direction" in
        "move_left") direction_all="left" ;;
        "move_right") direction_all="right" ;;
        "move_up") direction_all="up" ;;
        "move_down") direction_all="down" ;;
    esac

    set -- $all_ws

    while [ -n "$1" ]; do
        if [ "$is_sync" = "sync" ]; then
            move_workspace "$direction_all" "$1" "$(awk '{print $2}' <<< $original_monitor)"

        else
            move_workspace "$direction_all" "$1" "$2"
        fi
        shift 2
    done

    move_workspace "$direction_all" "$original_monitor"
fi

reload_waybar

