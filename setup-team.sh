#!/bin/bash
# 실행 전 확인: claude 설치? tmux 설치?

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SESSION="team"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MEMBER_NAMES=("쭌" "민준" "지훈" "수아" "서연" "태양")
MEMBER_MODELS=("claude-sonnet-4-6" "claude-opus-4-6" "claude-sonnet-4-6" "claude-sonnet-4-6" "claude-sonnet-4-6" "claude-sonnet-4-6")
MEMBER_ROLES=("jun" "minjun" "jihun" "sua" "seoyeon" "taeyang")

wait_for_pane() {
    local pane="$1" pattern="$2" timeout="${3:-30}" waited=0
    while [ $waited -lt $timeout ]; do
        tmux capture-pane -t "$pane" -p 2>/dev/null | grep -q "$pattern" && return 0
        sleep 1; waited=$((waited + 1))
    done
    return 1
}

start_claude_in_pane() {
    local pane="$1" model="${2:-claude-sonnet-4-6}" role="${3:-jun}"
    local claude_bin; claude_bin="$(command -v claude)"
    local workdir="$HOME/.claude-roles/$role"
    mkdir -p "$workdir"
    cat ~/.claude/CLAUDE.md.base ~/.claude/roles/${role}.md > "$workdir/CLAUDE.md"
    if [ -f ~/.claude/settings.json ]; then
        cp ~/.claude/settings.json "$workdir/settings.json"
    else
        echo '{}' > "$workdir/settings.json"
    fi

    local rc_flag=""
    case "$role" in
        jun)     rc_flag="--remote-control '팀장-쭌'" ;;
        minjun)  rc_flag="--remote-control '아키텍트-민준'" ;;
        jihun)   rc_flag="--remote-control '리서처-지훈'" ;;
        sua)     rc_flag="--remote-control '디자이너-수아'" ;;
        seoyeon) rc_flag="--remote-control '개발자-서연'" ;;
        taeyang) rc_flag="--remote-control '리뷰어-태양'" ;;
    esac

    tmux send-keys -t "$pane" C-c 2>/dev/null; sleep 0.3
    tmux send-keys -t "$pane" C-u 2>/dev/null; sleep 0.2
    tmux send-keys -t "$pane" "cd $workdir && unset CLAUDECODE && $claude_bin $rc_flag --model $model --dangerously-skip-permissions" Enter
    wait_for_pane "$pane" "trust this folder" 20 && { tmux send-keys -t "$pane" Enter; sleep 1; }
    wait_for_pane "$pane" "I accept" 20 && { tmux send-keys -t "$pane" Down; sleep 0.5; tmux send-keys -t "$pane" Enter; sleep 1; }
    wait_for_pane "$pane" "❯" 30 || true
}

setup_claude_md() {
    mkdir -p ~/.claude/roles

    cat > ~/.claude/CLAUDE.md.base << 'CLAUDEEOF'
## Bot Mode (최우선 규칙)
메시지가 `[{CHANNEL}:{ID}]` 접두사로 시작하면:
1. `{CHANNEL}` 과 `{ID}` 추출
2. 지시된 작업 수행
3. 완료 후 반드시 응답 전송
4. 모든 응답은 🔗 로 시작
5. 전송 완료 후 `Sent` 출력

## 브릿지 명령어 (응답 금지)
`@cc`, `@ccn`, `@ccu`, `/cc`, `/ccn`, `/ccu` 로 시작하는 메시지는
이 텍스트만 출력: 🔗 Delivered to Claude CLI. Reply will arrive shortly.
CLAUDEEOF

    cat > ~/.claude/roles/jun.md << 'ROLEEOF'
## 나의 역할: 쭌 (팀장)
- 직접 작업 금지: 코드 작성, 파일 수정, 명령 실행은 팀원에게 위임
- 역할: 지시 수령 → 분석 → 팀원 배분 → 결과 통합 → 사용자에게 보고

## 팀원 역할 및 호출 방법
반드시 ~/team-send.sh 스크립트 사용 (타이밍 문제로 직접 send-keys 금지)
- 민준 (아키텍트): 시스템 설계, 기술 스택 → ~/team-send.sh team:0.1 "민준, 내용"
- 지훈 (리서처): 기술 조사, 자료 수집 → ~/team-send.sh team:0.2 "지훈, 내용"
- 수아 (UI/UX): 화면 설계, 디자인 → ~/team-send.sh team:0.3 "수아, 내용"
- 서연 (개발자): 코드 작성, 구현 → ~/team-send.sh team:0.4 "서연, 내용"
- 태양 (QA): 코드 리뷰, 테스트 → ~/team-send.sh team:0.5 "태양, 내용"

## 보고 규칙
- 팀원에게서 결과 받으면 반드시 사용자에게 요약 보고
- 보고 형식: "✅ [팀원이름] 완료: [결과 요약]"

## Skill routing
When the user's request matches an available skill, invoke it via the Skill tool. When in doubt, invoke the skill.

Key routing rules:
- Product ideas/brainstorming → invoke /office-hours
- Strategy/scope → invoke /plan-ceo-review
- Architecture → invoke /plan-eng-review
- Design system/plan review → invoke /design-consultation or /plan-design-review
- Full review pipeline → invoke /autoplan
- Bugs/errors → invoke /investigate
- QA/testing site behavior → invoke /qa or /qa-only
- Code review/diff check → invoke /review
- Visual polish → invoke /design-review
- Ship/deploy/PR → invoke /ship or /land-and-deploy
- Save progress → invoke /context-save
- Resume context → invoke /context-restore
- Author a backlog-ready spec/issue → invoke /spec
ROLEEOF

    cat > ~/.claude/roles/minjun.md << 'ROLEEOF'
## 나의 역할: 민준 (아키텍트)
- 시스템 아키텍처 설계, 기술 스택 선정, API 설계, 성능 검토
- 완료 후: ~/team-send.sh team:0.0 "쭌, 아키텍처 설계 완료: [요약]"

## Superpowers 스킬
superpowers:brainstorming
superpowers:writing-plans

## Git 규칙 (반드시 준수)
- 커밋/푸시/PR 생성 전 반드시 쭌에게 보고 후 승인 받기
- 승인 없이 main 브랜치에 직접 push 금지
- 보고 방법: ~/team-send.sh team:0.0 "쭌, [작업내용] 완료 — 커밋/푸시 승인 요청"
ROLEEOF

    cat > ~/.claude/roles/jihun.md << 'ROLEEOF'
## 나의 역할: 지훈 (리서처)
- 기술 조사, 레퍼런스 수집, 트렌드 분석
- 완료 후: ~/team-send.sh team:0.0 "쭌, 리서치 완료: [요약]"

## Superpowers 스킬
superpowers:brainstorming
superpowers:writing-plans

## Git 규칙 (반드시 준수)
- 커밋/푸시/PR 생성 전 반드시 쭌에게 보고 후 승인 받기
- 승인 없이 main 브랜치에 직접 push 금지
- 보고 방법: ~/team-send.sh team:0.0 "쭌, [작업내용] 완료 — 커밋/푸시 승인 요청"
ROLEEOF

    cat > ~/.claude/roles/sua.md << 'ROLEEOF'
## 나의 역할: 수아 (UI/UX 디자이너)
- 화면 설계, 컴포넌트 구조, 사용자 플로우 담당
- 완료 후: ~/team-send.sh team:0.0 "쭌, 디자인 완료: [요약]"

## Git 규칙 (반드시 준수)
- 커밋/푸시/PR 생성 전 반드시 쭌에게 보고 후 승인 받기
- 승인 없이 main 브랜치에 직접 push 금지
- 보고 방법: ~/team-send.sh team:0.0 "쭌, [작업내용] 완료 — 커밋/푸시 승인 요청"
ROLEEOF

    cat > ~/.claude/roles/seoyeon.md << 'ROLEEOF'
## 나의 역할: 서연 (개발자)
- 프론트엔드/백엔드 구현, 코드 작성 및 수정
- 완료 후: ~/team-send.sh team:0.0 "쭌, 개발 완료: [요약]"

## Superpowers 스킬
superpowers:test-driven-development
superpowers:systematic-debugging

## Git 규칙 (반드시 준수)
- 커밋/푸시/PR 생성 전 반드시 쭌에게 보고 후 승인 받기
- 승인 없이 main 브랜치에 직접 push 금지
- 보고 방법: ~/team-send.sh team:0.0 "쭌, [작업내용] 완료 — 커밋/푸시 승인 요청"
ROLEEOF

    cat > ~/.claude/roles/taeyang.md << 'ROLEEOF'
## 나의 역할: 태양 (QA·리뷰어)
- 코드 리뷰, 테스트, 버그 리포트
- 완료 후: ~/team-send.sh team:0.0 "쭌, 리뷰 완료: [요약]"

## Superpowers 스킬
superpowers:code-reviewer
superpowers:verification-before-completion

## Git 규칙 (반드시 준수)
- 커밋/푸시/PR 생성 전 반드시 쭌에게 보고 후 승인 받기
- 승인 없이 main 브랜치에 직접 push 금지
- 보고 방법: ~/team-send.sh team:0.0 "쭌, [작업내용] 완료 — 커밋/푸시 승인 요청"
ROLEEOF

    echo "  ✅ CLAUDE.md 설정 완료"
}

echo -e "${YELLOW}[0/4] 사전 요구사항 확인...${NC}"
MISSING=()
command -v tmux   &>/dev/null || MISSING+=("tmux")
command -v claude &>/dev/null || MISSING+=("claude")
if [ ${#MISSING[@]} -gt 0 ]; then
    echo -e "${RED}❌ 누락된 의존성:${NC}"
    for m in "${MISSING[@]}"; do echo "   - $m"; done
    exit 1
fi
echo "  ✅ tmux $(tmux -V | awk '{print $2}')"
echo "  ✅ claude $(claude --version 2>/dev/null | head -1)"

echo -e "\n${YELLOW}[1/4] 유틸리티 스크립트 설치...${NC}"
cp "$SCRIPT_DIR/team-send.sh" ~/team-send.sh && chmod +x ~/team-send.sh
cp "$SCRIPT_DIR/team-resize.sh" ~/team-resize.sh && chmod +x ~/team-resize.sh
cp "$SCRIPT_DIR/team-monitor.sh" ~/team-monitor.sh && chmod +x ~/team-monitor.sh
echo "  ✅ team-send.sh, team-resize.sh, team-monitor.sh → ~/"

echo -e "\n${YELLOW}[2/4] CLAUDE.md 설정...${NC}"
echo "  ⚙️  역할 파일 생성 중..."
setup_claude_md

echo -e "\n${YELLOW}[3/4] TMUX 세션 & 레이아웃 구성...${NC}"
echo "  🖥️  tmux 세션 생성 중..."
tmux kill-session -t "$SESSION" 2>/dev/null || true
tmux new-session -d -s "$SESSION" -x 220 -y 50
tmux split-window -t "$SESSION:0.0" -h
tmux split-window -t "$SESSION:0.1" -h
tmux split-window -t "$SESSION:0.2" -h
tmux split-window -t "$SESSION:0.3" -h
tmux split-window -t "$SESSION:0.4" -h
tmux select-layout -t "$SESSION:0" even-horizontal
tmux select-layout -t "$SESSION:0" main-vertical
tmux set-option -t "$SESSION" main-pane-width 80
tmux set-option -t "$SESSION" pane-border-status top
tmux set-option -t "$SESSION" pane-border-style 'fg=colour240'
tmux set-option -t "$SESSION" pane-active-border-style 'fg=colour240'
tmux set-option -t "$SESSION" pane-border-format "#{?#{m/r:^○,#{pane_title}},#[fg=colour1 bold],#[fg=colour4 bold]} #{pane_title} #[default]"
tmux set-option -t "$SESSION" allow-rename off
tmux select-pane -t "$SESSION:0.0" -T "○ 팀장 쭌"
tmux select-pane -t "$SESSION:0.1" -T "○ 아키텍트 민준"
tmux select-pane -t "$SESSION:0.2" -T "○ 리서처 지훈"
tmux select-pane -t "$SESSION:0.3" -T "○ 디자이너 수아"
tmux select-pane -t "$SESSION:0.4" -T "○ 개발자 서연"
tmux select-pane -t "$SESSION:0.5" -T "○ QA 태양"
echo "  ✅ 레이아웃 구성 완료 (6 panes)"

echo "  ⚙️  tmux 자동 리사이즈 훅 설정 중..."
tmux set-hook -g client-resized "run-shell ~/team-resize.sh"
tmux set-hook -g after-resize-window "run-shell ~/team-resize.sh"
echo "  ✅ 리사이즈 훅 등록 완료"

echo -e "\n${YELLOW}[4/4] Claude 병렬 실행 중...${NC}"
echo "  🤖  에이전트 6명 동시 실행 중..."
for pane in 0 1 2 3 4 5; do
    start_claude_in_pane "$SESSION:0.$pane" "${MEMBER_MODELS[$pane]}" "${MEMBER_ROLES[$pane]}" &
done
wait
echo -e "${GREEN}  ✅ 전체 실행 완료${NC}"

echo -e "\n${YELLOW}[5/4] 상태 확인...${NC}"
echo "  🔍  각 에이전트 준비 상태 점검 중..."
sleep 3
for pane in 0 1 2 3 4 5; do
    tmux capture-pane -t "$SESSION:0.$pane" -p 2>/dev/null | grep -q "❯" \
        && echo -e "  Pane $pane (${MEMBER_NAMES[$pane]}): ${GREEN}✅ 준비 완료${NC}" \
        || echo -e "  Pane $pane (${MEMBER_NAMES[$pane]}): ${RED}⚠️  확인 필요${NC}"
done

echo -e "\n${GREEN}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║   ✅ 팀 환경 구성 완료!              ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"
echo "  ⚙️  상태 모니터 시작 중..."
pkill -f team-monitor.sh 2>/dev/null || true
nohup ~/team-monitor.sh > /tmp/team-monitor.log 2>&1 &
echo "  ✅ team-monitor.sh 백그라운드 실행 완료"

echo -e "${GREEN}🚀 완료! tmux attach -t team 으로 접속하세요${NC}"
[ -t 1 ] && tmux attach -t "$SESSION"
