#!/bin/bash
# Evenly distribute the 5 team member panes in team:0 right column

tmux has-session -t team 2>/dev/null || exit 0

WIN_HEIGHT=$(tmux display-message -t team:0 -p "#{window_height}" 2>/dev/null)
[[ -z "$WIN_HEIGHT" ]] && exit 0

# 5 panes with 4 borders between them
AVAILABLE=$((WIN_HEIGHT - 4))
BASE=$((AVAILABLE / 5))

# Resize top-to-bottom except last pane (let it fill remaining space)
for i in 1 2 3 4; do
    tmux resize-pane -t team:0.$i -y $BASE 2>/dev/null
done
