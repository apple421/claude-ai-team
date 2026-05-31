# Claude AI Team — 프로젝트 로그

> 작성일: 2026-05-31  
> 목적: AI 멀티에이전트 팀 구축 및 친구 공유용 배포 프로젝트 완료 기록

---

## 완료된 작업

### 1. tmux 레이아웃 자동화
- **문제**: 터미널 창 크기 변경 시 pane 비율이 틀어짐
- **해결**: `~/team-resize.sh` + tmux hooks (`client-resized`, `after-resize-window`)
- **결과**: iTerm 드래그 리사이즈 시 pane 5개 자동 균등 분배

### 2. 팀원 명령 자동 실행
- **문제**: `tmux send-keys "text" Enter` 실행 시 Enter가 먼저 눌려 명령 미실행
- **해결**: `~/team-send.sh` — 텍스트 전송 후 0.3s 딜레이, 그 다음 Enter
- **결과**: `~/team-send.sh team:0.1 "민준, 내용"` 으로 완전 자동화

### 3. 팀원 워크스페이스 수정
- 수아(pane3): `~/.claude-roles/jihun` → `~/.claude-roles/sua` 재시작
- 서연(pane4): `~/.claude-roles/sua` → `~/.claude-roles/seoyeon` 재시작

### 4. Git 승인 규칙 추가
- 모든 팀원 CLAUDE.md에 추가:
  - 커밋/푸시/PR 전 쭌에게 보고 및 승인 필수
  - main 브랜치 직접 push 금지

### 5. GitHub 배포 (`apple421/claude-ai-team`)
- README.md 전면 재작성 (팀 구조, 사용법, FAQ 포함)
- roles/ 디렉토리에 6명 역할 CLAUDE.md 동기화
- setup-team.sh: team-send.sh, team-resize.sh 자동 설치 포함

### 6. Notion 정리 (API 자동화)
- **마일스톤**: M1·M2 → ✅ 완료, M3 → 🔄 진행 중
- **팀원 표**: 지훈, 서연, 수아 행 내용 수정
- **태양 행**: Notion UI에서 수동 추가 (API 제한으로 table_row 프로그래밍 추가 불가)
- **상위 페이지**: 🚀 시작하기 (GitHub 링크, 설치 명령), 👥 팀 구성 섹션 추가

---

## 파일 구조

```
~/claude-ai-team/
├── setup-team.sh        # 팀 환경 일괄 설치 스크립트
├── team-send.sh         # 팀원 pane에 명령 전송 (타이밍 보정)
├── team-resize.sh       # 터미널 리사이즈 시 pane 균등 분배
├── README.md            # 사용법 가이드
├── PROJECT-LOG.md       # 이 파일
└── roles/
    ├── jun.md           # 쭌 (팀장)
    ├── minjun.md        # 민준 (아키텍트)
    ├── jihun.md         # 지훈 (리서처)
    ├── sua.md           # 수아 (UI/UX 디자이너)
    ├── seoyeon.md       # 서연 (개발자)
    └── taeyang.md       # 태양 (QA·리뷰어)

~/.claude-roles/         # 각 에이전트 실행 디렉토리
├── jun/CLAUDE.md
├── minjun/CLAUDE.md
├── jihun/CLAUDE.md
├── sua/CLAUDE.md
├── seoyeon/CLAUDE.md
└── taeyang/CLAUDE.md

~/team-send.sh           # 심볼릭 아님, 복사본
~/team-resize.sh         # 심볼릭 아님, 복사본
~/.tmux.conf             # mouse on, aggressive-resize, hooks 설정
```

---

## 팀 구성 및 호출 방법

| pane | 이름 | 역할 | 호출 |
|------|------|------|------|
| 0 | 쭌 | 팀장 (진입점) | 사용자 직접 입력 |
| 1 | 민준 | 아키텍트 | `~/team-send.sh team:0.1 "민준, 내용"` |
| 2 | 지훈 | 리서처 | `~/team-send.sh team:0.2 "지훈, 내용"` |
| 3 | 수아 | UI/UX 디자이너 | `~/team-send.sh team:0.3 "수아, 내용"` |
| 4 | 서연 | 개발자 | `~/team-send.sh team:0.4 "서연, 내용"` |
| 5 | 태양 | QA·리뷰어 | `~/team-send.sh team:0.5 "태양, 내용"` |

---

## 공유 링크

- **GitHub**: https://github.com/apple421/claude-ai-team
- **Notion**: https://www.notion.so/Claude-AI-Team-36e55f903abe8027a353e15649c4d676
- **설치 명령**: `git clone https://github.com/apple421/claude-ai-team && cd claude-ai-team && bash setup-team.sh`

---

## 알려진 제한사항

- Notion API로 `table` 블록에 행 추가 불가 (`invalid_request_url`) → Notion UI에서 수동 추가 필요
- tmux 팀 세션 재시작 시 `bash ~/claude-ai-team/setup-team.sh` 재실행 필요
- Rate limit 발생 시 쭌이 Telegram으로 사용자에게 보고
