-- Fecha y hora locales del partido (sede) para el calendario por día
ALTER TABLE matches ADD COLUMN IF NOT EXISTS calendar_date DATE;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS kickoff_time_local VARCHAR(5);

CREATE INDEX IF NOT EXISTS idx_matches_calendar_date ON matches (tournament_id, calendar_date);
