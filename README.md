# Claude AI Team 사용법 공유

<!-- TODO: tmux 6-pane 실행 화면 스크린샷 추가 (setup 후 `tmux attach -t team` 상태) -->

---

## 이게 뭔가요?

AI 에이전트 **6명(팀장·아키텍트·리서처·디자이너·개발자·QA)이 실제 팀처럼 협업**하는 환경을 내 컴퓨터에 세팅하는 방법입니다. 단일 AI에게 모든 걸 맡기는 대신 각 에이전트가 전문 영역에 집중하며, tmux를 통해 서로 메시지를 주고받습니다. 한 번 세팅해두면 복잡한 프로젝트도 에이전트들이 알아서 역할을 나눠 처리해줍니다.

**핵심 특징:**
- 각 에이전트는 독립적인 Claude Code CLI 인스턴스로 실행됩니다
- tmux를 통해 에이전트 간 실시간 메시지 전달이 가능합니다
- 역할 분리로 작업 품질과 효율이 동시에 향상됩니다

---

## 1. 사전 요구사항

> 전체 준비 시간: **약 15~20분** (계정 발급 포함)

### Step 1. Anthropic 계정 만들기 & API 키 발급 `약 5분`

Claude Code를 쓰려면 Anthropic API 키가 필요합니다.

1. [console.anthropic.com](https://console.anthropic.com) 에 접속합니다
2. **Sign Up**으로 계정을 만들고 이메일 인증을 완료합니다
3. 로그인 후 왼쪽 메뉴에서 **API Keys** 클릭
4. **+ Create Key** 버튼을 눌러 키를 생성합니다
5. 생성된 키(`sk-ant-...`)를 **반드시 복사해두세요** — 창을 닫으면 다시 볼 수 없습니다

```
발급된 API 키 예시:
sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

> 결제 정보를 등록해야 키가 활성화됩니다. **API 크레딧 기반 과금**이므로 쓴 만큼만 청구됩니다.

---

### Step 2. Claude Code CLI 설치 `약 3분`

터미널을 열고 아래 명령어를 실행하세요.

```bash
npm install -g @anthropic-ai/claude-code
```

> Node.js가 없다면 먼저 [nodejs.org](https://nodejs.org) 에서 LTS 버전을 설치하세요. (Node.js **18 이상** 필요)
>
> **Windows 사용자:** 직접 지원하지 않습니다. [WSL2](https://learn.microsoft.com/ko-kr/windows/wsl/install)를 설치한 뒤 Ubuntu 환경에서 진행하세요.

설치가 끝나면 API 키를 등록합니다:

```bash
claude
# 처음 실행 시 API 키 입력 화면이 나타납니다
# sk-ant-... 키를 붙여넣고 Enter
```

**정상 설치 확인:**
```
$ claude --version
claude-code/1.x.x
```

---

### Step 3. tmux 설치 `약 2분`

> **tmux가 뭔가요?** 터미널 화면을 여러 칸으로 나눠서 여러 프로그램을 동시에 실행할 수 있게 해주는 도구입니다. 에이전트마다 별도의 pane이 필요하기 때문에 사용합니다.

```bash
# macOS
# Homebrew가 없다면 먼저 설치:
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install tmux

# Ubuntu / Debian
sudo apt install tmux
```

**정상 설치 확인:**
```
$ tmux -V
tmux 3.3a        ← 3.0 이상이면 OK
```

---

## 2. 설치 방법 `약 5분`

```bash
# 1. 레포지토리 클론
git clone https://github.com/apple421/claude-ai-team ~/claude-ai-team
cd ~/claude-ai-team

# 2. 팀 세션 초기화 스크립트 실행
chmod +x setup-team.sh
./setup-team.sh
```

`setup-team.sh`는 `team`이라는 이름의 tmux 세션을 생성하고, 6개의 pane에 에이전트를 배치한 뒤 역할 파일을 로드합니다. 완료되면 자동으로 세션에 접속됩니다.

**편의 alias 등록 (권장)**

`~/.zshrc`에 아래를 추가하면 `team` / `toff` 명령으로 간편하게 시작·종료할 수 있습니다:

```bash
# 팀 시작 (세션 있으면 접속, 없으면 새로 생성) — 종료 시 터미널 자동 닫힘
alias team='{ tmux has-session -t team 2>/dev/null && tmux attach -t team || bash ~/claude-ai-team/setup-team.sh; }; exit'

# 팀 종료
alias toff='bash ~/team-stop.sh'
```

> 적용: `source ~/.zshrc`

> **`.tmux.conf` 자동 적용**: `setup-team.sh`가 레포의 `.tmux.conf`를 `~/.tmux.conf`로 복사합니다. 마우스 스크롤, pane 크기 자동 조정 등 편의 설정이 포함되어 있으며, tmux-resurrect 플러그인이 없어도 에러 없이 동작합니다.

**실행 결과 예시:**
```
[0/5] 사전 요구사항 확인...
  ✅ tmux 3.3a
  ✅ claude-code/1.x.x

[1/5] 유틸리티 스크립트 설치...
  ✅ team-send.sh, team-resize.sh → ~/

[2/5] CLAUDE.md 설정...
  ✅ CLAUDE.md 설정 완료

[3/5] TMUX 세션 & 레이아웃 구성...
  ✅ 레이아웃 구성 완료 (6 panes)

[4/5] Claude 병렬 실행 중...
  🤖 에이전트 6명 동시 실행 중...
  ✅ 전체 실행 완료

[5/5] 상태 확인...
  Pane 0 (쭌): ✅ 준비 완료
  Pane 1 (민준): ✅ 준비 완료
  Pane 2 (지훈): ✅ 준비 완료
  Pane 3 (수아): ✅ 준비 완료
  Pane 4 (서연): ✅ 준비 완료
  Pane 5 (태양): ✅ 준비 완료

🚀 완료! tmux attach -t team 으로 접속하세요
```

세션 접속:
```bash
tmux attach -t team
```

접속하면 아래와 같이 6개의 pane이 나뉜 화면이 보입니다:

```
┌─────────────────────┬──────────────────────┐
│  [0] 쭌 (팀장)     │  [1] 민준 (아키텍트) │
│                     ├──────────────────────┤
│                     │  [2] 지훈 (리서처)   │
│  Claude Code        ├──────────────────────┤
│  > ...              │  [3] 수아 (UI/UX)    │
│                     ├──────────────────────┤
│                     │  [4] 서연 (개발자)   │
│                     ├──────────────────────┤
│                     │  [5] 태양 (QA·리뷰어)│
└─────────────────────┴──────────────────────┘
  Ctrl+B → 방향키로 pane 이동 | Ctrl+B D로 세션 나가기
```

---

## 3. 팀 구성

| Pane | 이름 | 역할 |
|------|------|------|
| `team:0.0` | **쭌** (팀장) | 사용자 요청 수령, 팀원 배분, 결과 통합 및 보고 |
| `team:0.1` | **민준** (아키텍트) | 시스템 아키텍처 설계, 기술 스택 선정, API 설계 |
| `team:0.2` | **지훈** (리서처) | 기술 조사, 레퍼런스 수집, 트렌드 분석 |
| `team:0.3` | **수아** (UI/UX 디자이너) | 화면 설계, 컴포넌트 구조, 사용자 플로우 |
| `team:0.4` | **서연** (개발자) | 코드 구현, 버그 수정, PR 생성 |
| `team:0.5` | **태양** (QA·리뷰어) | 코드 리뷰, 테스트 설계 및 실행, 버그 리포트 |

> **쭌이 진입점입니다.** 사용자는 쭌(`team:0.0`)에게만 요청하면 됩니다. 쭌이 나머지 팀원에게 배분하고 결과를 취합해 보고합니다.

각 에이전트는 `~/.claude-roles/<이름>/CLAUDE.md`에 정의된 역할과 행동 지침을 따릅니다.

---

## 4. 사용법 예시

### 에이전트에게 메시지 보내기

에이전트 간 메시지 전달은 반드시 `~/team-send.sh` 스크립트를 사용합니다. `tmux send-keys`를 직접 쓰면 타이밍 문제로 메시지가 유실될 수 있습니다.

```bash
# 형식: ~/team-send.sh <pane> "메시지"

# 쭌(팀장)에게 작업 요청 — 일반적으로 여기서 시작
~/team-send.sh team:0.0 "로그인 화면 기능 기획부터 구현까지 진행해줘"

# 특정 팀원에게 직접 요청
~/team-send.sh team:0.2 "지훈, React Server Components 최신 트렌드 조사해줘"
~/team-send.sh team:0.1 "민준, 인증 시스템 아키텍처 설계해줘"
```

**지훈(리서처) 응답 예시:**
```
리서치 완료했습니다!

## React Server Components 트렌드 요약
- Next.js 14+에서 기본값으로 채택
- 서버에서 렌더링되므로 JS 번들 크기 감소
- 주요 기업(Vercel, Shopify) 프로덕션 적용 사례 증가
...

쭌, 리서치 완료: RSC는 2024년 기준 프로덕션 적용 급증 중
```

---

### 에이전트 간 협업 흐름 예시

```
1. 쭌(팀장)이 사용자 요청을 받아 태스크를 분해하고 각 팀원에게 배분
2. 지훈(리서처)이 기술 스택 조사 → 쭌에게 결과 전달
3. 민준(아키텍트)이 시스템 설계 → 쭌에게 결과 전달
4. 수아(디자이너)가 UI 설계 → 서연에게 핸드오프
5. 서연(개발자)이 구현 → 태양에게 테스트 요청
6. 태양(QA)이 검증 완료 → 쭌에게 완료 보고
7. 쭌이 결과를 취합해 사용자에게 최종 보고
```

**실제 에이전트 간 메시지 예시:**
```
[쭌] 수아야, 로그인 화면 와이어프레임 부탁해. 모바일 우선으로.
[수아] 알겠어! 완성되면 서연한테 바로 넘길게.
  ... (5분 후) ...
[수아] 서연, 와이어프레임 완성. /designs/login-v1.md 확인해봐.
[서연] 확인했어. 구현 시작할게. 태양, 테스트 케이스 미리 뽑아줄 수 있어?
```

---

### 팀원이 서로 메시지를 보내는 방법

각 에이전트의 `CLAUDE.md`에는 다음과 같은 패턴으로 보고가 정의되어 있습니다:

```bash
# 쭌에게 결과 보고 (팀원 → 팀장)
~/team-send.sh team:0.0 "쭌, 리서치 완료: [요약 내용]"

# 다른 팀원에게 전달 (예: 수아 → 서연)
~/team-send.sh team:0.4 "서연, 디자인 파일 넘길게: [내용]"
```

---

### Triple Crown — 기능 하나를 처음부터 끝까지 자동 실행

`triple-crown.sh`는 기능 이름 하나를 넘기면 **전략 수립 → 설계+조사 → 구현 → 검증 → 배포** 5단계를 자동으로 순서대로 실행합니다.

```bash
~/triple-crown.sh "로그인 화면"
```

실행 흐름:

```
Phase 1: 쭌 — /cso + /autoplan 으로 전략 수립
Phase 2: 민준(구조화) + 지훈(기술 조사) — 병렬 실행
Phase 3: 서연(TDD 구현) + 수아(UI 구현) — 병렬 실행
Phase 4: 태양(/review + /qa) + 민준(/gsd:validate-phase) — 병렬 실행
Phase 5: 쭌 — /ship 으로 배포
```

> 각 Phase 사이에 대기 시간이 있습니다. 복잡한 기능은 Phase별 완료를 확인하며 수동 진행을 권장합니다.

---

### 팀 상태 확인

```bash
~/team-status.sh
```

각 pane의 최근 출력 3줄을 한눈에 확인합니다. 에이전트가 응답 중인지, 멈춰있는지 빠르게 체크할 때 유용합니다.

---

## 5. GitHub Actions (CI/CD)

레포에는 세 가지 워크플로우가 포함되어 있습니다. Telegram 알림을 받으려면 레포 **Settings → Secrets**에 `TELEGRAM_BOT_TOKEN`과 `TELEGRAM_CHAT_ID`를 등록하세요.

| 워크플로우 | 트리거 | 역할 |
|-----------|--------|------|
| `ci.yml` | push / PR | `setup-team.sh`, `triple-crown.sh`, `team-status.sh` bash 문법 검사 + shellcheck |
| `conflict-check.yml` | PR → main | main 브랜치와 충돌 여부 자동 감지 |
| `daily-report.yml` | 매일 09:00 KST | 커밋 수, 열린 PR/이슈 현황을 Telegram으로 보고 |

Telegram 미사용 시 알림 step은 무시되며 나머지 검증은 정상 동작합니다.

---

## 6. 비용 안내

> API 크레딧 기반 과금 — 에이전트가 실제로 토큰을 소비할 때만 청구됩니다. 대기 중에는 비용이 발생하지 않습니다.

| 에이전트 | 사용 모델 | 비용 수준 |
|----------|-----------|-----------|
| 쭌 (팀장) | claude-sonnet-4-6 | 낮음 |
| **민준 (아키텍트)** | **claude-opus-4-6** | **높음 (Sonnet 대비 약 5배)** |
| 지훈 / 수아 / 서연 / 태양 | claude-sonnet-4-6 | 낮음 |

활발한 작업 기준 시간당 대략적 범위: Sonnet 에이전트 1명당 $0.05~0.5, Opus(민준) 혼자 $0.5~2 수준. 처음엔 가벼운 작업으로 테스트해보는 걸 권장합니다.

> 모델명은 Anthropic 업데이트에 따라 변경될 수 있습니다. 최신 모델명은 [console.anthropic.com](https://console.anthropic.com) 에서 확인하세요.

---

## 7. 자주 묻는 질문 (FAQ)

**Q. API 키를 잃어버렸어요.**
A. console.anthropic.com → API Keys에서 기존 키를 삭제하고 새로 발급받으세요.

**Q. `tmux: command not found` 에러가 납니다.**
A. Step 3의 tmux 설치 명령어를 다시 실행하세요. macOS라면 `brew`가 먼저 설치되어 있어야 합니다.

**Q. 세션에서 나가는 법을 모르겠어요.**
A. `Ctrl+B`를 누른 뒤 `D`를 누르면 세션을 종료하지 않고 빠져나옵니다. 나중에 `tmux attach -t team`으로 돌아올 수 있습니다.

**Q. `tmux send-keys`로 직접 메시지를 보내면 안 되나요?**
A. 타이밍 문제로 메시지가 중간에 잘리거나 유실될 수 있습니다. 반드시 `~/team-send.sh`를 사용하세요.

**Q. `roles/` 폴더 파일을 수정했는데 적용이 안 돼요.**
A. `setup-team.sh`를 다시 실행하세요. 역할 파일은 스크립트 실행 시 `~/.claude-roles/`에 복사됩니다.

**Q. API 키를 바꾸고 싶어요 (재등록 방법).**
A. 터미널에서 `claude` 를 실행한 뒤 `/config` 명령으로 API 키를 업데이트할 수 있습니다. 또는 `ANTHROPIC_API_KEY` 환경변수를 직접 설정해도 됩니다:
```bash
export ANTHROPIC_API_KEY="sk-ant-..."   # 현재 세션에만 적용
# 영구 적용은 ~/.zshrc 또는 ~/.bashrc에 위 줄 추가
```

**Q. `~/.claude/settings.json`이 없다는 에러가 납니다.**
A. 한 번이라도 `claude` 명령을 실행하면 자동 생성됩니다. 그 다음 `setup-team.sh`를 다시 실행하세요.

---

## 8. 참고

- 각 에이전트 역할 설정: `~/.claude-roles/<role>/CLAUDE.md` (예: `~/.claude-roles/jun/CLAUDE.md`)
- 역할 커스터마이징: [`roles/README.md`](roles/README.md)
- 5단계 자동 실행: `triple-crown.sh <기능명>`
- 팀 상태 확인: `team-status.sh`
- 일일 로그 템플릿: [`memory/TEMPLATE.md`](memory/TEMPLATE.md)
- CI/CD 워크플로우: [`.github/workflows/`](.github/workflows/)
- 팀 세션 종료: `tmux kill-session -t team`
- 문의 및 기여: Issues 탭을 활용해주세요
- GitHub: https://github.com/apple421/claude-ai-team
- Notion 공유 허브: https://www.notion.so/Claude-AI-Team-36e55f903abe8027a353e15649c4d676
- Notion 상세 페이지: https://www.notion.so/Claude-AI-Team-36e55f903abe81b29512f6cec5a70ce9
