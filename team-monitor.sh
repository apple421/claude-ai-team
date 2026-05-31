#!/bin/bash
# team-monitor.sh — 2초마다 각 pane Claude 상태 감지 후 타이틀 업데이트
# ● 파란색 = 작업 중, ○ 빨간색 = 대기 중

NAMES=("팀장 쭌" "아키텍트 민준" "리서처 지훈" "디자이너 수아" "개발자 서연" "QA 태양")

while true; do
    tmux has-session -t team 2>/dev/null || exit 0

    for i in 0 1 2 3 4 5; do
        content=$(tmux capture-pane -t "team:0.$i" -p 2>/dev/null)
        tail5=$(echo "$content" | tail -5)

        # 단축키 바가 보이면 입력 대기 상태
        if echo "$tail5" | grep -q "for shortcuts\|bypass permissions\|accept edits"; then
            # ❯ 뒤에 텍스트가 있으면 타이핑 중, 없으면 완전 대기
            prompt=$(echo "$content" | tail -10 | grep "^❯" | tail -1 | sed 's/^❯//' | tr -d '[:space:]')
            if [ -z "$prompt" ]; then
                state="○"
            else
                state="●"
            fi
        else
            state="●"
        fi

        new_title="$state ${NAMES[$i]}"
        current=$(tmux display-message -t "team:0.$i" -p "#{pane_title}" 2>/dev/null)
        [ "$current" != "$new_title" ] && tmux select-pane -t "team:0.$i" -T "$new_title" 2>/dev/null
    done

    sleep 2
done
