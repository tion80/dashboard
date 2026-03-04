# Locus AI Chat — 하이브리드 기획서

## Context
QuickAdd에 AI 봇을 하이브리드로 통합. 모드 전환이 아니라, 기존 캡처 플로우에 AI를 자연스럽게 녹인다. 두 가지 진입점: (1) 피드에서 바로 AI에게 말하기, (2) 아이템 상세에서 해당 맥락으로 AI 심화.

## Mem.ai 참고
| Mem 패턴 | Locus 적용 |
|---------|-----------|
| Agentic Chat — 대화로 CRUD | Phase 2: 채팅으로 할일/아이디어 생성 |
| Zero-friction — AI가 자동 분류 | 기존 looksActionable + Phase 2 자동 제안 |
| Deep Search — 의미 기반 | Phase 2: query_tasks 자연어 |
| Web Clipper — URL → 노트 | Phase 3: fetch_url + save_research |
| Side Panel Chat | **상세 패널 내 AI Chat** |

**차별화**: Mem은 노트 중심, Locus는 **태스크+아이디어+퀘스트** 통합. PWA로 설치 불필요. 자체 호스팅.

---

## 하이브리드 UX 설계

### 진입점 1: 피드 레벨 AI 버튼

```
┌─────────────────────────┐
│ Locus                   │
├─────────────────────────┤
│ ── 오늘 ──              │
│ ☐ API 연동 구현          │  ← 캡처 아이템
│ 💡 AI 에이전트 아키텍처   │
│                         │
│    나: 오늘 뭐부터 해야해? │  ← AI 메시지 (오른쪽)
│ 🤖 ASAP 버킷에 3개가... │  ← 봇 응답 (왼쪽)
│                         │
├─────────────────────────┤
│ [epic] [quest]          │
│ [입력창              ]  │
│ [✓ 할일] [💡 아이디어] [🤖] │  ← 세 번째 버튼
└─────────────────────────┘
```

- **[🤖] 버튼**: 입력 텍스트를 AI에게 전송
- 응답이 **같은 피드**에 나타남 (캡처 아이템과 섞임)
- 모드 전환 없음 — 할일/아이디어/AI가 같은 레벨의 액션
- Enter키는 기존처럼 looksActionable로 할일/아이디어 자동 선택
- AI 버튼은 명시적 클릭만 (실수 방지)

**AI 메시지 스타일:**
- 유저 메시지: 오른쪽 정렬, 액센트 배경, 라운드 버블
- 봇 메시지: 왼쪽 정렬, 🤖 아이콘, 카드 스타일
- 캡처 아이템(☐/💡)과 시각적으로 구분되지만 같은 타임라인

### 진입점 2: 상세 패널 AI Chat

```
┌─────────── Detail Pane ──┐
│ 할일 상세            ✕   │
├─────────────────────────┤
│ 제목: API 연동 구현       │
│ 노트: REST vs GraphQL... │
│ 에픽: [AI]              │
│ 퀘스트: [백엔드 구축]    │
│                         │
│ ── AI 대화 ──           │
│ 🤖 이 태스크를 더 구체화  │
│    해드릴까요?           │
│                         │
│ 나: 서브태스크로 나눠줘   │
│                         │
│ 🤖 1. API 설계 문서 작성  │
│    2. 엔드포인트 구현     │
│    3. 테스트 작성        │
│    [✓ 서브태스크로 추가]  │  ← 인라인 액션
│                         │
│ [입력창          ] [전송] │
├─────────────────────────┤
│ [✓ 완료] [🗑 삭제]       │
└─────────────────────────┘
```

- 상세 패널 하단에 **[🤖 AI에게 물어보기]** 버튼
- 누르면 패널 내에 채팅 영역이 펼쳐짐
- **맥락 자동 주입**: 해당 아이템의 제목/노트/에픽/퀘스트
- 봇이 "이 태스크를 분석/구체화/리서치" 가능
- Phase 2에서 **인라인 액션** (서브태스크 추가, 노트 업데이트 등)

### 대화 흐름 예시

**피드에서 자유 질문:**
```
나: 이번주 VD 에픽 진행상황 정리해줘
🤖 VD 에픽 미완료 태스크 5개:
   - 레벨 디자인 프로토타입 (ASAP)
   - 적 AI 패턴 구현 (Schedule)
   ...
   진행률: 12/17 완료 (71%)
```

**상세에서 아이디어 심화:**
```
[💡 "AI 에이전트 아키텍처" 상세뷰]

나: 이거 더 파줘
🤖 관련 자료를 조사했습니다:
   - ReAct 패턴: 추론+행동 루프
   - Tool Use: 외부 API 호출
   - Memory: 대화 맥락 유지

   [💡 아이디어로 저장] [📝 노트에 추가]
```

**상세에서 태스크 구체화:**
```
[☐ "API 연동 구현" 상세뷰]

🤖 이 할일에 대해 도와드릴까요?
나: 이거 어떻게 접근하면 좋을까
🤖 추천 접근 방법:
   1. API 스펙 정의 (OpenAPI)
   2. 인증 방식 결정 (JWT vs API Key)
   3. 엔드포인트 구현
   4. 에러 핸들링

   [✓ 서브태스크로 추가]
```

---

## Phase 1: 기본 AI Chat (MVP)

### 범위
- 피드 [🤖] 버튼 + 상세 패널 [🤖 AI에게 물어보기]
- Claude 기본 대화 (컨텍스트/액션 없음)
- 대화 기록 Supabase 저장

### DB
```sql
CREATE TABLE chat_messages (
  id          BIGINT PRIMARY KEY,
  session_id  TEXT NOT NULL,
  role        TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content     TEXT NOT NULL,
  context_type TEXT DEFAULT NULL,  -- null | 'task' | 'idea'
  context_id  BIGINT DEFAULT NULL, -- 연결된 아이템 ID
  created_at  TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_chat_session ON chat_messages(session_id, created_at);
```

- `context_type` + `context_id`: 상세 패널에서 시작된 대화가 어떤 아이템 맥락인지 추적

### Edge Function: `supabase/functions/chat/index.ts`
- `ANTHROPIC_API_KEY`로 Claude API 호출
- `messages.slice(-20)` 비용 제어
- 모델: `claude-sonnet-4-20250514`, max_tokens: 1024
- 시스템 프롬프트:
  ```
  You are Locus, Junction의 생산성 비서.
  한국어로 응답. 모바일이라 간결하게.
  마크다운은 **굵게**, 리스트 정도만.
  ```

### UI 변경 (mobile_quickAdd.html)

**1) 피드 액션 버튼에 AI 추가:**
```html
<div class="action-buttons">
  <button id="addBtn">✓ 할일</button>
  <button id="ideaBtn">💡 아이디어</button>
  <button id="aiBtn">🤖</button>  <!-- 새로 -->
</div>
```
- [🤖] 버튼 스타일: 좁은 정사각 형태 (아이콘만)
- 입력 있을 때만 활성화

**2) 피드에 AI 메시지 렌더링:**
- `chat-user` 클래스: 오른쪽 정렬, 액센트 배경
- `chat-bot` 클래스: 왼쪽 정렬, 🤖 아이콘, 카드 배경
- 타이핑 인디케이터 (•••)

**3) 상세 패널에 AI 섹션:**
- 기존 actions 위에 [🤖 AI에게 물어보기] 버튼
- 누르면 패널 내에 채팅 영역 + 입력창 펼쳐짐
- 해당 아이템 정보를 시스템 프롬프트에 주입

**4) 대화 기록:**
- 피드 AI: 글로벌 세션 (localStorage에 session_id)
- 상세 AI: 아이템별 세션 (context_type + context_id로 구분)
- Supabase에서 로드 (크로스 디바이스)

### Phase 1에서 안 하는 것
- Tool Use (태스크/아이디어 자동 생성)
- 컨텍스트 주입 (퀘스트/태스크 목록)
- SSE 스트리밍
- URL 분석

---

## Phase 2: 컨텍스트 인식 + 액션

### 목표
봇이 내 데이터를 알고, 직접 행동할 수 있게.

### Tool Use

| Tool | 설명 | 트리거 예시 |
|------|------|------------|
| `create_task` | 할일 생성 | "API 연동 할일 추가해줘" |
| `create_idea` | 아이디어 저장 | "이 내용 아이디어로 저장" |
| `update_note` | 노트 업데이트 | "이 할일 노트에 추가해줘" |
| `add_subtasks` | 서브태스크 추가 | "서브태스크로 나눠줘" |
| `query_tasks` | 태스크 조회 | "이번주 할 일 뭐야?" |
| `query_quests` | 퀘스트 조회 | "VD 진행상황 알려줘" |

### 컨텍스트 주입
- 피드 AI: `buildContext()` → 퀘스트 + 미완료 태스크 + 최근 아이디어
- 상세 AI: 해당 아이템 전체 데이터 (제목, 노트, 에픽, 퀘스트, 서브태스크)

### SSE 스트리밍
- Edge Function → `text/event-stream`
- 봇 버블 실시간 렌더링

### 인라인 액션 버튼
봇 응답에 실행 가능한 버튼:
```
🤖 서브태스크로 나눴습니다:
1. API 설계 문서 작성
2. 엔드포인트 구현
3. 테스트 작성
[✓ 서브태스크로 추가]  ← 클릭하면 실제 추가
```

### 자동 제안 (Mem 스타일)
- 상세 패널 진입 시 봇이 먼저 말 걸기:
  - 할일: "이 태스크를 구체화해드릴까요?"
  - 아이디어: "이 아이디어를 더 탐구해볼까요?"
  - URL 아이디어: "이 링크를 요약해드릴까요?"

---

## Phase 3: URL 리서치 + 딥다이브

### 새 Tool

| Tool | 설명 |
|------|------|
| `fetch_url` | URL 가져와서 요약 (8000자 제한) |
| `deep_dive` | 웹 검색으로 주제 조사 (Brave Search API) |
| `save_research` | 리서치 → 아이디어+노트로 저장 |

### UX
- 피드에서 URL 입력 + [🤖] → 자동 요약
- 상세에서 아이디어 "더 파줘" → 웹 리서치
- 결과를 [💡 저장] [📝 노트에 추가] 인라인 액션

### 비용 관리
- 콘텐츠 8000자 제한
- Tool 루프 최대 5회
- 일일 토큰 추적 → 10만 초과 경고

---

## 기술 구조

### 변경 파일
- `mobile_quickAdd.html` — UI + 클라이언트 로직
- `supabase/functions/chat/index.ts` — 새 Edge Function

### 단계별 의존성
```
Phase 1
  ├── chat_messages 테이블 (context_type/context_id 포함)
  ├── chat Edge Function (기본 Claude 호출)
  ├── 피드 [🤖] 버튼 + AI 메시지 렌더링
  └── 상세 패널 AI Chat 영역
        │
Phase 2  ← Phase 1 위에
  ├── Tool Use (create_task, query_tasks 등)
  ├── 컨텍스트 주입 (buildContext + 아이템 데이터)
  ├── SSE 스트리밍
  ├── 인라인 액션 버튼
  └── 자동 제안
        │
Phase 3  ← Phase 2 위에
  ├── fetch_url, deep_dive, save_research
  ├── Brave Search API
  └── 토큰 비용 추적
```

### 배포 체크리스트

**Phase 1:**
1. `chat_messages` 테이블 생성 (SQL)
2. `supabase secrets set ANTHROPIC_API_KEY=sk-ant-...`
3. `supabase functions deploy chat`
4. `mobile_quickAdd.html` 업데이트 + push

**Phase 2:**
1. `ALTER TABLE chat_messages ADD COLUMN metadata JSONB`
2. `supabase secrets set SUPABASE_SERVICE_ROLE_KEY=...`
3. Edge Function 재배포

**Phase 3:**
1. `supabase secrets set BRAVE_SEARCH_API_KEY=...`
2. Edge Function 재배포

### 비용 예상
- Claude Sonnet: ~$0.025/호출
- 하루 20회 = ~$15/월
- Supabase Edge Function: 무료 티어 충분

---

## 향후 확장
- **Voice Mode**: 브라우저 SpeechRecognition → 음성 캡처
- **모드 통합**: 단일 입력 → AI가 의도 판단 → 자동 분류
- **대시보드 연동**: dashboard.html Side Panel Chat
- **Heads Up**: 캘린더 전에 관련 맥락 자동 서피싱

## 참고 자료
- [Mem 2.0](https://get.mem.ai/blog/introducing-mem-2-0)
- [Mem AI 리뷰](https://lovable.dev/guides/what-is-mem-ai)
- [Mem Product Hunt](https://www.producthunt.com/products/mem-2-0)
