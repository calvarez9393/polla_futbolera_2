-- Equipos del cuadro predicho del usuario al guardar (no se sobrescriben con resultados oficiales).
ALTER TABLE predictions
  ADD COLUMN IF NOT EXISTS bracket_home_team_id BIGINT REFERENCES teams(id),
  ADD COLUMN IF NOT EXISTS bracket_away_team_id BIGINT REFERENCES teams(id);
