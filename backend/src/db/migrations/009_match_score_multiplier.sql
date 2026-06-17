-- Factor multiplicador de puntos por partido: multiplica los puntos de todos los
-- usuarios que predijeron ese partido. 1 = sin cambio (comportamiento por defecto).
ALTER TABLE matches
  ADD COLUMN IF NOT EXISTS score_multiplier NUMERIC(5,2) NOT NULL DEFAULT 1;
