-- Reglamento oficial Polla Mundialista 2026

ALTER TABLE matches ADD COLUMN IF NOT EXISTS round_key TEXT;

ALTER TABLE scoring_rules
  ADD COLUMN IF NOT EXISTS goal_diff_points INT NOT NULL DEFAULT 2,
  ADD COLUMN IF NOT EXISTS draw_points INT NOT NULL DEFAULT 3,
  ADD COLUMN IF NOT EXISTS r8_advance_points INT NOT NULL DEFAULT 8,
  ADD COLUMN IF NOT EXISTS r8_exact_points INT NOT NULL DEFAULT 5,
  ADD COLUMN IF NOT EXISTS r4_advance_points INT NOT NULL DEFAULT 12,
  ADD COLUMN IF NOT EXISTS r4_exact_points INT NOT NULL DEFAULT 7,
  ADD COLUMN IF NOT EXISTS sf_advance_points INT NOT NULL DEFAULT 18,
  ADD COLUMN IF NOT EXISTS sf_exact_points INT NOT NULL DEFAULT 10,
  ADD COLUMN IF NOT EXISTS final_advance_points INT NOT NULL DEFAULT 40,
  ADD COLUMN IF NOT EXISTS final_exact_points INT NOT NULL DEFAULT 15,
  ADD COLUMN IF NOT EXISTS semifinalist_points INT NOT NULL DEFAULT 10,
  ADD COLUMN IF NOT EXISTS semifinalist_max_points INT NOT NULL DEFAULT 40,
  ADD COLUMN IF NOT EXISTS finalist_points INT NOT NULL DEFAULT 20,
  ADD COLUMN IF NOT EXISTS finalist_max_points INT NOT NULL DEFAULT 40,
  ADD COLUMN IF NOT EXISTS runner_up_points INT NOT NULL DEFAULT 20,
  ADD COLUMN IF NOT EXISTS third_place_points INT NOT NULL DEFAULT 15,
  ADD COLUMN IF NOT EXISTS top_assister_points INT NOT NULL DEFAULT 20,
  ADD COLUMN IF NOT EXISTS group_master_bonus INT NOT NULL DEFAULT 5,
  ADD COLUMN IF NOT EXISTS expert_day_bonus INT NOT NULL DEFAULT 10,
  ADD COLUMN IF NOT EXISTS invicto_bonus INT NOT NULL DEFAULT 15;

UPDATE scoring_rules SET
  exact_score_points = 5,
  outcome_points = 3,
  goal_diff_points = 2,
  draw_points = 3,
  advancing_team_points = 8,
  qualified_team_points = 4,
  champion_points = 40,
  top_scorer_points = 25,
  runner_up_points = 20,
  third_place_points = 15,
  top_assister_points = 20,
  updated_at = NOW()
WHERE id = 1;

CREATE TABLE IF NOT EXISTS qualifier_predictions (
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  team_id BIGINT NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, team_id)
);

ALTER TABLE bonus_predictions
  ADD COLUMN IF NOT EXISTS runner_up_team_id BIGINT REFERENCES teams(id),
  ADD COLUMN IF NOT EXISTS third_place_team_id BIGINT REFERENCES teams(id),
  ADD COLUMN IF NOT EXISTS top_assister TEXT,
  ADD COLUMN IF NOT EXISTS semifinalist_team_ids BIGINT[] NOT NULL DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS finalist_team_ids BIGINT[] NOT NULL DEFAULT '{}';
