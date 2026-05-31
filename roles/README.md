# 역할 커스터마이징 가이드

`roles/` 폴더는 각 에이전트의 성격, 담당 업무, 보고 방식을 정의합니다.

## 파일 구조

```
roles/
├── jun_CLAUDE.md       ← 쭌 (팀장)
├── minjun_CLAUDE.md    ← 민준 (아키텍트)
├── jihun_CLAUDE.md     ← 지훈 (리서처)
├── sua_CLAUDE.md       ← 수아 (UI/UX 디자이너)
├── seoyeon_CLAUDE.md   ← 서연 (개발자)
└── taeyang_CLAUDE.md   ← 태양 (QA·리뷰어)
```

## 적용 방법

파일을 수정한 뒤 `setup-team.sh`를 다시 실행하면 변경사항이 반영됩니다.

```bash
./setup-team.sh
```

> `setup-team.sh`는 이 파일들을 `~/.claude-roles/<role>/CLAUDE.md`로 복사하여 각 에이전트에 로드합니다.

## 역할 파일 구조 예시

```markdown
## 나의 역할: [이름] ([직책])
- 담당 업무 설명
- 완료 후: ~/team-send.sh team:0.0 "쭌, [작업] 완료: [요약]"

## 행동 규칙
- 규칙 1
- 규칙 2
```

## 팀원 pane 번호 참고

| Pane | 역할 파일 | 이름 |
|------|-----------|------|
| `team:0.0` | jun_CLAUDE.md | 쭌 (팀장) |
| `team:0.1` | minjun_CLAUDE.md | 민준 (아키텍트) |
| `team:0.2` | jihun_CLAUDE.md | 지훈 (리서처) |
| `team:0.3` | sua_CLAUDE.md | 수아 (디자이너) |
| `team:0.4` | seoyeon_CLAUDE.md | 서연 (개발자) |
| `team:0.5` | taeyang_CLAUDE.md | 태양 (QA·리뷰어) |
