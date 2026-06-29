import { useEffect, useState } from "react";
import { TeamFlag } from "./TeamFlag";

export interface FullBracketTeam {
  teamId: number;
  name: string;
  logoUrl: string | null;
}

export interface FullBracketMatch {
  matchId: number;
  externalNum: number;
  roundKey: string;
  roundLabel: string;
  status: string;
  home: FullBracketTeam | null;
  away: FullBracketTeam | null;
  advancingTeamId: number | null;
  advancingTeamName: string | null;
  advancingViaPenalties: boolean;
  predictedHomeScore: number | null;
  predictedAwayScore: number | null;
}

export interface SavePredictionPayload {
  matchId: number;
  predictedHomeScore: number;
  predictedAwayScore: number;
  predictedAdvancingTeamId: number | null;
}

interface FullBracketTreeProps {
  matches: FullBracketMatch[];
  onSave?: (payload: SavePredictionPayload) => Promise<void>;
}

const ROUND_ORDER = ["R16", "R8", "R4", "SF", "TP3", "F"] as const;

const ROUND_TITLES: Record<string, string> = {
  R16: "Dieciseisavos",
  R8: "Octavos",
  R4: "Cuartos",
  SF: "Semifinal",
  TP3: "3.er puesto",
  F: "Final"
};

function ReadOnlySlot({
  team,
  score,
  isWinner
}: {
  team: FullBracketTeam | null;
  score: number | null;
  isWinner: boolean;
}) {
  return (
    <div className={`full-bracket-slot${isWinner ? " full-bracket-slot--win" : ""}${team ? "" : " full-bracket-slot--tbd"}`}>
      {team ? (
        <>
          <TeamFlag name={team.name} logoUrl={team.logoUrl} size="sm" />
          <span className="full-bracket-slot-name">{team.name}</span>
        </>
      ) : (
        <span className="full-bracket-slot-name full-bracket-slot-name--tbd">Por definir</span>
      )}
      <span className="full-bracket-slot-score">{score != null ? score : ""}</span>
    </div>
  );
}

function ReadOnlyCard({ match }: { match: FullBracketMatch }) {
  const homeWin = match.advancingTeamId != null && match.home?.teamId === match.advancingTeamId;
  const awayWin = match.advancingTeamId != null && match.away?.teamId === match.advancingTeamId;
  return (
    <article className="full-bracket-card">
      <header className="full-bracket-card-head">
        <span className="full-bracket-card-num">P{match.externalNum}</span>
        {match.advancingViaPenalties && <span className="full-bracket-card-pen">pen.</span>}
      </header>
      <ReadOnlySlot team={match.home} score={match.predictedHomeScore} isWinner={homeWin} />
      <ReadOnlySlot team={match.away} score={match.predictedAwayScore} isWinner={awayWin} />
    </article>
  );
}

function EditableCard({
  match,
  onSave
}: {
  match: FullBracketMatch;
  onSave: (payload: SavePredictionPayload) => Promise<void>;
}) {
  const initHome = match.predictedHomeScore != null ? String(match.predictedHomeScore) : "";
  const initAway = match.predictedAwayScore != null ? String(match.predictedAwayScore) : "";
  const [home, setHome] = useState(initHome);
  const [away, setAway] = useState(initAway);
  const [advancing, setAdvancing] = useState<number | null>(match.advancingTeamId);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  // Resincroniza el estado local cuando el cuadro se recarga (props nuevas tras guardar / cambios aguas arriba).
  useEffect(() => {
    setHome(match.predictedHomeScore != null ? String(match.predictedHomeScore) : "");
    setAway(match.predictedAwayScore != null ? String(match.predictedAwayScore) : "");
    setAdvancing(match.advancingTeamId);
    setError("");
  }, [match.matchId, match.predictedHomeScore, match.predictedAwayScore, match.advancingTeamId, match.home?.teamId, match.away?.teamId]);

  const bothTeams = match.home != null && match.away != null;
  if (!bothTeams) return <ReadOnlyCard match={match} />;

  // En el cuadro toda llave necesita un ganador que avance, también dieciseisavos.
  const requiresAdvancing = true;
  const hi = home === "" ? null : Number(home);
  const ai = away === "" ? null : Number(away);
  const scoresValid = hi != null && ai != null && Number.isInteger(hi) && Number.isInteger(ai) && hi >= 0 && ai >= 0;
  const isDraw = scoresValid && hi === ai;

  // Quién pasa: marcador decisivo lo define solo; empate usa la selección.
  const decisiveWinner = scoresValid && !isDraw ? (hi! > ai! ? match.home!.teamId : match.away!.teamId) : null;
  const effectiveAdvancing = isDraw ? advancing : decisiveWinner;
  const needAdvancing = requiresAdvancing && isDraw && effectiveAdvancing == null;

  const dirty =
    home !== initHome ||
    away !== initAway ||
    (isDraw && advancing !== match.advancingTeamId);
  const canSave = scoresValid && !needAdvancing && dirty && !saving;

  const homeWin = effectiveAdvancing != null && match.home!.teamId === effectiveAdvancing;
  const awayWin = effectiveAdvancing != null && match.away!.teamId === effectiveAdvancing;

  async function save() {
    if (!canSave) return;
    setSaving(true);
    setError("");
    try {
      await onSave({
        matchId: match.matchId,
        predictedHomeScore: hi!,
        predictedAwayScore: ai!,
        predictedAdvancingTeamId: isDraw ? advancing : null
      });
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setSaving(false);
    }
  }

  function slot(side: "home" | "away") {
    const team = side === "home" ? match.home! : match.away!;
    const value = side === "home" ? home : away;
    const setValue = side === "home" ? setHome : setAway;
    const isWinner = side === "home" ? homeWin : awayWin;
    return (
      <div className={`full-bracket-slot full-bracket-slot--edit${isWinner ? " full-bracket-slot--win" : ""}`}>
        <TeamFlag name={team.name} logoUrl={team.logoUrl} size="sm" />
        <span className="full-bracket-slot-name">{team.name}</span>
        <input
          className="full-bracket-score-input"
          type="number"
          min={0}
          max={99}
          value={value}
          onChange={(e) => setValue(e.target.value)}
          aria-label={`Goles ${team.name}`}
        />
      </div>
    );
  }

  return (
    <article className={`full-bracket-card full-bracket-card--edit${dirty ? " full-bracket-card--dirty" : ""}`}>
      <header className="full-bracket-card-head">
        <span className="full-bracket-card-num">P{match.externalNum}</span>
        {match.status === "FINISHED" && <span className="full-bracket-card-pen">jugado</span>}
      </header>
      {slot("home")}
      {slot("away")}
      {isDraw && requiresAdvancing && (
        <div className="full-bracket-pass">
          <span className="full-bracket-pass-label">Pasa:</span>
          <button
            type="button"
            className={`full-bracket-pass-btn${advancing === match.home!.teamId ? " is-active" : ""}`}
            onClick={() => setAdvancing(match.home!.teamId)}
          >
            {match.home!.name}
          </button>
          <button
            type="button"
            className={`full-bracket-pass-btn${advancing === match.away!.teamId ? " is-active" : ""}`}
            onClick={() => setAdvancing(match.away!.teamId)}
          >
            {match.away!.name}
          </button>
        </div>
      )}
      {dirty && (
        <button type="button" className="full-bracket-save" onClick={save} disabled={!canSave}>
          {saving ? "Guardando…" : needAdvancing ? "Elige quién pasa" : "Guardar"}
        </button>
      )}
      {error && <p className="full-bracket-card-error">{error}</p>}
    </article>
  );
}

export function FullBracketTree({ matches, onSave }: FullBracketTreeProps) {
  if (matches.length === 0) {
    return (
      <div className="panel-card empty-state">
        <strong>Sin cuadro eliminatorio</strong>
        <p style={{ marginTop: "0.5rem" }}>Este usuario aún no tiene predicciones de eliminatoria.</p>
      </div>
    );
  }

  const byRound = new Map<string, FullBracketMatch[]>();
  for (const m of matches) {
    if (!byRound.has(m.roundKey)) byRound.set(m.roundKey, []);
    byRound.get(m.roundKey)!.push(m);
  }
  for (const list of byRound.values()) list.sort((a, b) => a.externalNum - b.externalNum);

  const columns = ROUND_ORDER.filter((k) => byRound.has(k));

  return (
    <div className="full-bracket-wrap">
      <p className="admin-block-hint full-bracket-legend">
        Ramificación completa del cuadro simulado: cada columna es una ronda y el equipo resaltado es
        quien el usuario hace pasar.{" "}
        {onSave
          ? "Edita los goles de cada cruce; al guardar, las rondas siguientes se recalculan."
          : "Los números a la derecha son su marcador predicho."}
      </p>
      <div className="full-bracket-tree">
        {columns.map((roundKey) => (
          <div key={roundKey} className="full-bracket-col">
            <span className="full-bracket-col-title">{ROUND_TITLES[roundKey] ?? roundKey}</span>
            <div className="full-bracket-col-cards">
              {(byRound.get(roundKey) ?? []).map((m) =>
                onSave ? (
                  <EditableCard key={m.externalNum} match={m} onSave={onSave} />
                ) : (
                  <ReadOnlyCard key={m.externalNum} match={m} />
                )
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
