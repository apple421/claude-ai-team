#!/bin/bash
# Usage: team-send.sh <pane> <message>
# Example: team-send.sh team:0.1 "민준, 설계해줘"

PANE=$1
MSG=$2

tmux send-keys -t "$PANE" "$MSG"
sleep 0.3
tmux send-keys -t "$PANE" "" Enter
