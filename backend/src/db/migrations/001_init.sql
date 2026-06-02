CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'USER',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS tournaments (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  external_id TEXT UNIQUE,
  season TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS groups (
  id BIGSERIAL PRIMARY KEY,
  tournament_id BIGINT REFERENCES tournaments(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  external_id TEXT UNIQUE
);

CREATE TABLE IF NOT EXISTS teams (
  id BIGSERIAL PRIMARY KEY,
  external_id TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  short_name TEXT,
  logo_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS matches (
  id BIGSERIAL PRIMARY KEY,
  external_id TEXT NOT NULL UNIQUE,
  tournament_id BIGINT REFERENCES tournaments(id),
  group_id BIGINT REFERENCES groups(id),
  stage TEXT NOT NULL DEFAULT 'GROUP',
  status TEXT NOT NULL DEFAULT 'NOT_STARTED',
  starts_at TIMESTAMPTZ NOT NULL,
  home_team_id BIGINT NOT NULL REFERENCES teams(id),
  away_team_id BIGINT NOT NULL REFERENCES teams(id),
  home_score INT,
  away_score INT,
  winner_team_id BIGINT REFERENCES teams(id),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS standings (
  id BIGSERIAL PRIMARY KEY,
  tournament_id BIGINT REFERENCES tournaments(id) ON DELETE CASCADE,
  group_id BIGINT REFERENCES groups(id) ON DELETE CASCADE,
  team_id BIGINT REFERENCES teams(id) ON DELETE CASCADE,
  rank INT NOT NULL,
  points INT NOT NULL,
  played INT NOT NULL,
  won INT NOT NULL,
  draw INT NOT NULL,
  lost INT NOT NULL,
  goals_for INT NOT NULL,
  goals_against INT NOT NULL,
  goal_diff INT NOT NULL,
  UNIQUE (group_id, team_id)
);

CREATE TABLE IF NOT EXISTS predictions (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  match_id BIGINT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  predicted_home_score INT NOT NULL,
  predicted_away_score INT NOT NULL,
  predicted_advancing_team_id BIGINT REFERENCES teams(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, match_id)
);

CREATE TABLE IF NOT EXISTS group_predictions (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  first_team_id BIGINT NOT NULL REFERENCES teams(id),
  second_team_id BIGINT NOT NULL REFERENCES teams(id),
  exact_order BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE (user_id, group_id)
);

CREATE TABLE IF NOT EXISTS bonus_predictions (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  champion_team_id BIGINT REFERENCES teams(id),
  top_scorer TEXT,
  best_defense_team_id BIGINT REFERENCES teams(id),
  best_player TEXT,
  UNIQUE (user_id)
);

CREATE TABLE IF NOT EXISTS scoring_rules (
  id BIGSERIAL PRIMARY KEY,
  exact_score_points INT NOT NULL DEFAULT 3,
  outcome_points INT NOT NULL DEFAULT 1,
  advancing_team_points INT NOT NULL DEFAULT 2,
  qualified_team_points INT NOT NULL DEFAULT 2,
  exact_group_order_points INT NOT NULL DEFAULT 3,
  champion_points INT NOT NULL DEFAULT 5,
  top_scorer_points INT NOT NULL DEFAULT 4,
  best_defense_points INT NOT NULL DEFAULT 4,
  best_player_points INT NOT NULL DEFAULT 4,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS prediction_scores (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  source_type TEXT NOT NULL,
  source_id BIGINT NOT NULL,
  points INT NOT NULL DEFAULT 0,
  breakdown JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, source_type, source_id)
);

CREATE TABLE IF NOT EXISTS sync_runs (
  id BIGSERIAL PRIMARY KEY,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at TIMESTAMPTZ,
  status TEXT NOT NULL,
  details JSONB NOT NULL DEFAULT '{}'::jsonb
);

INSERT INTO scoring_rules (id)
VALUES (1)
ON CONFLICT (id) DO NOTHING;
