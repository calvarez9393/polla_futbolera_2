CREATE TABLE IF NOT EXISTS app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO app_settings (key, value) VALUES
  ('tournament_name', 'Mundial FIFA 2026'),
  ('tournament_season', '2026'),
  ('prediction_lock_hours_before', '24'),
  ('data_source', 'manual')
ON CONFLICT (key) DO NOTHING;

ALTER TABLE matches
  ADD COLUMN IF NOT EXISTS round_label TEXT,
  ADD COLUMN IF NOT EXISTS matchday INT,
  ADD COLUMN IF NOT EXISTS prediction_lock_at TIMESTAMPTZ;

ALTER TABLE matches ALTER COLUMN external_id DROP NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS matches_external_id_unique
  ON matches (external_id) WHERE external_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS matches_starts_at_idx ON matches (starts_at);
CREATE INDEX IF NOT EXISTS matches_stage_idx ON matches (stage);
