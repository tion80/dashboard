-- 주간 노트 테이블
CREATE TABLE IF NOT EXISTS weekly_notes (
  week_key TEXT PRIMARY KEY,        -- 'YYYY-MM-DD' (주간 시작일)
  content TEXT NOT NULL DEFAULT '',  -- 마크다운 문자열
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 액션 로그 테이블
CREATE TABLE IF NOT EXISTS action_log (
  id BIGSERIAL PRIMARY KEY,
  ts TEXT NOT NULL,                  -- 로컬 ISO 타임스탬프
  action TEXT NOT NULL,              -- '완료', '이동', '삭제' 등
  task_id BIGINT,                    -- 태스크 ID (nullable)
  title TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_action_log_ts ON action_log (ts);

-- ideas 테이블에 quest_id 컬럼 추가
ALTER TABLE ideas ADD COLUMN IF NOT EXISTS quest_id TEXT;

-- quests 테이블에 starred 컬럼 추가 (없을 경우)
ALTER TABLE quests ADD COLUMN IF NOT EXISTS starred BOOLEAN DEFAULT false;

-- meeting_notes 테이블에 아이디어/퀘스트 연결 컬럼 추가
ALTER TABLE meeting_notes ADD COLUMN IF NOT EXISTS linked_idea_ids TEXT[] DEFAULT '{}';
ALTER TABLE meeting_notes ADD COLUMN IF NOT EXISTS linked_quest_ids TEXT[] DEFAULT '{}';

-- meeting_notes 테이블에 아젠다 연결 컬럼 추가
ALTER TABLE meeting_notes ADD COLUMN IF NOT EXISTS agenda_task_ids TEXT[] DEFAULT '{}';
ALTER TABLE meeting_notes ADD COLUMN IF NOT EXISTS agenda_idea_ids TEXT[] DEFAULT '{}';
ALTER TABLE meeting_notes ADD COLUMN IF NOT EXISTS agenda_quest_ids TEXT[] DEFAULT '{}';

-- 에픽 테이블
CREATE TABLE IF NOT EXISTS epics (
  key TEXT PRIMARY KEY,
  label TEXT NOT NULL DEFAULT '',
  color TEXT NOT NULL DEFAULT '#6B7280',
  bg TEXT NOT NULL DEFAULT '#F3F4F6'
);

-- 기본 에픽 데이터 삽입 (이미 있으면 무시)
INSERT INTO epics (key, label, color, bg) VALUES
  ('VD', 'VOID DIVER', '#7C3AED', '#EDE9FE'),
  ('CQ', 'CQ', '#D97706', '#FEF3C7'),
  ('AI', 'AI', '#2563EB', '#DBEAFE'),
  ('BIZ', 'BIZ', '#DC2626', '#FEE2E2'),
  ('TEAM', 'TEAM', '#059669', '#D1FAE5'),
  ('PERSONAL', 'PERSONAL', '#6B7280', '#F3F4F6')
ON CONFLICT (key) DO NOTHING;

-- 연체 카운트 테이블
CREATE TABLE IF NOT EXISTS overdue_counts (
  task_id TEXT PRIMARY KEY,
  count INTEGER NOT NULL DEFAULT 0,
  last_counted_date TEXT NOT NULL
);
