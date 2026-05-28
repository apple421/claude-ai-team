# Claude AI Team 사용법 공유

---

## 이게 뭔가요?

AI한테 혼자 다 시키면 한계가 있습니다. 이 프로젝트는 **PM·리서처·디자이너·개발자·QA 역할을 맡은 AI 에이전트 5명이 실제 팀처럼 협업**하는 환경을 내 컴퓨터에 세팅하는 방법입니다. 한 번 세팅해두면 복잡한 프로젝트도 에이전트들이 알아서 역할을 나눠 처리해줍니다.

---

## 1. 개요 — AI 멀티에이전트 팀이란?

Claude AI 멀티에이전트 팀은 **서로 다른 역할을 가진 AI 에이전트들이 협업**하여 복잡한 프로젝트를 분담 처리하는 시스템입니다.

단일 AI에게 모든 작업을 맡기는 대신, 각 에이전트가 자신의 전문 영역에 집중합니다. 에이전트들은 tmux 세션을 통해 서로 메시지를 주고받으며, 인간 팀처럼 유기적으로 협력합니다.

**핵심 특징:**
- 각 에이전트는 독립적인 Claude Code CLI 인스턴스로 실행됩니다
- tmux를 통해 에이전트 간 실시간 메시지 전달이 가능합니다
- 역할 분리로 작업 품질과 효율이 동시에 향상됩니다

---

## 2. 사전 요구사항

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

> Node.js가 없다면 먼저 [nodejs.org](https://nodejs.org) 에서 LTS 버전을 설치하세요.

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

> **tmux가 뭔가요?** 터미널 화면을 여러 칸으로 나눠서 여러 프로그램을 동시에 실행할 수 있게 해주는 도구입니다. 에이전트마다 별도의 창이 필요하기 때문에 사용합니다.

```bash
# macOS
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

## 3. 설치 방법 `약 5분`

```bash
# 1. 레포지토리 클론
git clone <repo-url> ~/claude-ai-team
cd ~/claude-ai-team

# 2. 팀 세션 초기화 스크립트 실행
chmod +x setup-team.sh
./setup-team.sh
```

`setup-team.sh`는 `team`이라는 이름의 tmux 세션을 생성하고, 각 창(window)에 에이전트를 배치한 뒤 역할 파일을 로드합니다.

**실행 결과 예시:**
```
[+] Creating tmux session 'team'...
[+] Starting 민준 (PM)      → team:0
[+] Starting 지훈 (리서처)  → team:1
[+] Starting 수아 (디자이너) → team:2
[+] Starting 서연 (개발자)  → team:3
[+] Starting 태양 (QA)      → team:4
[✓] Team is ready! Run: tmux attach -t team
```

세션 접속:
```bash
tmux attach -t team
```

접속하면 아래와 같이 5개의 창이 나뉜 화면이 보입니다:

```
┌─────────────────────────────────────────────────┐
│  [0] 민준(PM)  │  [1] 지훈(리서처)              │
│                │                                 │
│  Claude Code   │  Claude Code                    │
│  > ...         │  > ...                          │
├────────────────┼────────────────┬────────────────┤
│  [2] 수아      │  [3] 서연      │  [4] 태양(QA)  │
│  (디자이너)    │  (개발자)      │                │
│  Claude Code   │  Claude Code   │  Claude Code   │
│  > ...         │  > ...         │  > ...         │
└────────────────┴────────────────┴────────────────┘
  Ctrl+B → 숫자키로 창 전환 | Ctrl+B D로 세션 나가기
```

---

## 4. 팀 구성

| 창(Pane) | 이름 | 역할 |
|----------|------|------|
| `team:0` | **민준** (PM) | 프로젝트 전체 조율, 작업 분배, 타임라인 관리 |
| `team:1` | **지훈** (리서처) | 기술 조사, 레퍼런스 수집, 트렌드 분석 |
| `team:2` | **수아** (디자이너) | UI/UX 설계, 와이어프레임, 디자인 시스템 |
| `team:3` | **서연** (개발자) | 실제 코드 구현, 버그 수정, 코드 리뷰 |
| `team:4` | **태양** (QA) | 테스트 설계 및 실행, 품질 검증, 버그 리포트 |

각 에이전트는 `~/.claude-roles/<이름>/CLAUDE.md`에 정의된 역할과 행동 지침을 따릅니다.

---

## 5. 사용법 예시

### 에이전트에게 직접 메시지 보내기

```bash
# 민준(PM)에게 작업 요청
tmux send-keys -t team:0.0 "새 기능 기획안 작성해줘" Enter

# 지훈(리서처)에게 조사 요청
tmux send-keys -t team:1.0 "React Server Components 최신 트렌드 조사해줘" Enter
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
1. 민준(PM)이 전체 태스크를 분해하여 각 에이전트에 배분
2. 지훈(리서처)이 기술 스택 조사 → 민준에게 결과 전달
3. 수아(디자이너)가 UI 설계 → 서연에게 핸드오프
4. 서연(개발자)이 구현 → 태양에게 테스트 요청
5. 태양(QA)이 검증 완료 → 민준에게 완료 보고
```

**실제 에이전트 간 메시지 예시:**
```
[민준] 수아야, 로그인 화면 와이어프레임 부탁해. 모바일 우선으로.
[수아] 알겠어! 완성되면 서연한테 바로 넘길게.
  ... (5분 후) ...
[수아] 서연, 와이어프레임 완성. /designs/login-v1.md 확인해봐.
[서연] 확인했어. 구현 시작할게. 태양, 테스트 케이스 미리 뽑아줄 수 있어?
```

---

### 에이전트가 서로 메시지를 보내는 방법

에이전트 CLAUDE.md 내 다음 패턴을 사용합니다:

```bash
tmux send-keys -t team:0.0 "쭌, 리서치 완료: [요약 내용]" Enter
```

---

## 자주 묻는 질문 (FAQ)

**Q. API 키를 잃어버렸어요.**
A. console.anthropic.com → API Keys에서 기존 키를 삭제하고 새로 발급받으세요.

**Q. `tmux: command not found` 에러가 납니다.**
A. Step 3의 tmux 설치 명령어를 다시 실행하세요. macOS라면 `brew`가 먼저 설치되어 있어야 합니다.

**Q. 세션에서 나가는 법을 모르겠어요.**
A. `Ctrl+B`를 누른 뒤 `D`를 누르면 세션을 종료하지 않고 빠져나옵니다. 나중에 `tmux attach -t team`으로 돌아올 수 있습니다.

---

## 참고

- 각 에이전트 역할 설정: `~/.claude-roles/<이름>/CLAUDE.md`
- 팀 세션 종료: `tmux kill-session -t team`
- 문의 및 기여: Issues 탭을 활용해주세요
- GitHub: https://github.com/apple421/claude-ai-team
