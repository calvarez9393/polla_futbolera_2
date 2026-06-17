-- Revisión manual de goleador y máximo asistidor del torneo.
-- El admin marca quién acertó (la gente escribe el nombre de formas distintas),
-- así que el puntaje deja de depender de un match de texto exacto.
-- NULL = sin revisar, TRUE = acertó, FALSE = no acertó.

ALTER TABLE bonus_predictions
  ADD COLUMN IF NOT EXISTS top_scorer_correct BOOLEAN,
  ADD COLUMN IF NOT EXISTS top_assister_correct BOOLEAN;
