import { useCallback, useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { PointsBreakdownList } from "./PointsBreakdownList";
import { PointsChips } from "./PointsChips";
import { MatchupScoreStrip, matchupToTeams } from "./MatchupScoreStrip";
import { KnockoutAdvancingBanner } from "./KnockoutAdvancingBanner";
import type { PredictedMatchup } from "./predictedMatchup";
import { api } from "../lib/api";
import { ROUND_LABELS } from "../lib/scoringLabels";
import { matchCardStatusClass, statusBadgeClass, statusLabel } from "../lib/matchStatus";
import { formatKickoffDateTimeLocal } from "../lib/matchTime";

export interface ScoreMatch {
  matchId: number | string;
  startsAt: string;
  calendarDate?: string | null;
  kickoffTimeLocal?: string | null;
  status: string;
  stage?: string;
  roundKey?: string | null;
  roundLabel?: string | null;
  groupName: string | null;
  homeTeamName: string;
  homeTeamLogoUrl?: string | null;
  awayTeamName: string;
  awayTeamLogoUrl?: string | null;
  homeScore: number | null;
  awayScore: number | null;
  predictedHomeScore: number | null;
  predictedAwayScore: number | null;
  predictedMatchup?: PredictedMatchup | null;
  officialMatchup?: PredictedMatchup | null;
  predictedAdvancing?: {
    teamName: string;
    teamLogoUrl?: string | null;
    viaPenalties: boolean;
  } | null;
  officialAdvancing?: {
    teamName: string;
    teamLogoUrl?: string | null;
    viaPenalties: boolean;
  } | null;
  nextRoundLabel?: string | null;
  points: number;
  breakdown: Record<string, number>;
}

export interface ExtraScore {
  sourceType: string;
  sourceId: number;
  section: "qualifiers" | "bonuses" | "phase1" | "other";
  title: string;
  description: string | null;
  points: number;
  breakdown: Record<string, number>;
  topScorerPick?: string | null;
  topScorerOfficial?: string | null;
  topScorerCorrect?: boolean | null;
  topAssisterPick?: string | null;
  topAssisterOfficial?: string | null;
  topAssisterCorrect?: boolean | null;
}

export interface UserScoresData {
  totalPoints: number;
  matchPointsTotal: number;
  extrasPointsTotal: number;
  totalsBySource: Record<string, number>;
  matches: ScoreMatch[];
  extras: ExtraScore[];
}

type FilterTab = "all" | "matches" | "extras";

function matchSubtitle(m: ScoreMatch): string {
  if (m.roundLabel) return m.roundLabel;
  if (m.roundKey && ROUND_LABELS[m.roundKey]) return ROUND_LABELS[m.roundKey];
  if (m.groupName) return `Grupo ${m.groupName}`;
  return m.stage === "KNOCKOUT" ? "Eliminatorias" : "Fase de grupos";
}

function MatchPointsCard({
  match,
  predictionLabel = "Tu predicción"
}: {
  match: ScoreMatch;
  predictionLabel?: string;
}) {
  const predictedTeams = match.predictedMatchup
    ? matchupToTeams(match.predictedMatchup)
    : {
        homeTeamName: match.homeTeamName,
        homeTeamLogoUrl: match.homeTeamLogoUrl,
        awayTeamName: match.awayTeamName,
        awayTeamLogoUrl: match.awayTeamLogoUrl
      };

  const officialTeams = match.officialMatchup
    ? matchupToTeams(match.officialMatchup)
    : {
        homeTeamName: match.homeTeamName,
        homeTeamLogoUrl: match.homeTeamLogoUrl,
        awayTeamName: match.awayTeamName,
        awayTeamLogoUrl: match.awayTeamLogoUrl
      };

  return (
    <article className={`user-points-card user-points-card--match match-card${matchCardStatusClass(match.status)}`}>
      <header className="user-points-card-head">
        <span className="user-points-card-total">+{match.points} pts</span>
      </header>

      {match.predictedHomeScore != null && (
        <MatchupScoreStrip
          className="matchup-score-strip--in-card"
          variant="prediction"
          label={predictionLabel}
          teams={predictedTeams}
          homeScore={match.predictedHomeScore}
          awayScore={match.predictedAwayScore}
        />
      )}

      <MatchupScoreStrip
        className="matchup-score-strip--in-card matchup-score-strip--official"
        variant="compact"
        label="Resultado real"
        teams={officialTeams}
        homeScore={match.homeScore}
        awayScore={match.awayScore}
      />

      {match.stage === "KNOCKOUT" && match.predictedAdvancing && (
        <KnockoutAdvancingBanner
          kind="prediction"
          compact
          teamName={match.predictedAdvancing.teamName}
          logoUrl={match.predictedAdvancing.teamLogoUrl}
          nextRoundLabel={match.nextRoundLabel ?? "siguiente ronda"}
          viaPenalties={match.predictedAdvancing.viaPenalties}
        />
      )}

      {match.stage === "KNOCKOUT" && match.officialAdvancing && (
        <KnockoutAdvancingBanner
          kind="official"
          compact
          teamName={match.officialAdvancing.teamName}
          logoUrl={match.officialAdvancing.teamLogoUrl}
          nextRoundLabel={match.nextRoundLabel ?? "siguiente ronda"}
          viaPenalties={match.officialAdvancing.viaPenalties}
        />
      )}

      <p className="user-points-card-meta">
        <span className={statusBadgeClass(match.status)}>{statusLabel(match.status)}</span>
        <span>{matchSubtitle(match)}</span>
        <span>
          {formatKickoffDateTimeLocal({
            calendar_date: match.calendarDate,
            kickoff_time_local: match.kickoffTimeLocal,
            starts_at: match.startsAt
          })}{" "}
          (hora sede)
        </span>
      </p>

      <div className="user-points-breakdown-block">
        <h4 className="user-points-breakdown-title">Desglose por categoría</h4>
        <PointsBreakdownList breakdown={match.breakdown} emptyLabel="Sin puntos en categorías" />
        <PointsChips breakdown={match.breakdown} totalPoints={match.points} />
      </div>
    </article>
  );
}

function ExtrasCompareRow({
  label,
  pick,
  official,
  correct
}: {
  label: string;
  pick?: string | null;
  official?: string | null;
  correct?: boolean | null;
}) {
  if (!pick?.trim() && !official?.trim()) return null;
  let status: { text: string; ok: boolean } | null = null;
  if (correct === true) status = { text: "✓ acertó", ok: true };
  else if (correct === false) status = { text: "✗ no acertó", ok: false };

  return (
    <div className="extras-compare-row">
      <span className="extras-compare-label">{label}</span>
      <span>
        Escribiste: <strong>{pick?.trim() || "— sin llenar —"}</strong>
      </span>
      <span>
        Real: <strong>{official?.trim() || "— por definir —"}</strong>
      </span>
      {status && (
        <span className={`badge ${status.ok ? "badge-live" : "badge-scheduled"}`}>{status.text}</span>
      )}
    </div>
  );
}

function ExtraPointsCard({ item }: { item: ExtraScore }) {
  const showExtrasCompare =
    item.sourceType === "BONUSES" &&
    Boolean(
      item.topScorerPick?.trim() ||
        item.topScorerOfficial?.trim() ||
        item.topAssisterPick?.trim() ||
        item.topAssisterOfficial?.trim()
    );

  return (
    <article className="user-points-card user-points-card--extra">
      <header className="user-points-card-head">
        <div>
          <h3 className="user-points-extra-title">{item.title}</h3>
          {item.description && <p className="user-points-extra-desc">{item.description}</p>}
        </div>
        <span className="user-points-card-total">+{item.points} pts</span>
      </header>

      {showExtrasCompare && (
        <div className="extras-pick-compare">
          <ExtrasCompareRow
            label="Goleador"
            pick={item.topScorerPick}
            official={item.topScorerOfficial}
            correct={item.topScorerCorrect}
          />
          <ExtrasCompareRow
            label="Máx. asistidor"
            pick={item.topAssisterPick}
            official={item.topAssisterOfficial}
            correct={item.topAssisterCorrect}
          />
        </div>
      )}

      <div className="user-points-breakdown-block">
        <h4 className="user-points-breakdown-title">Desglose por categoría</h4>
        <PointsBreakdownList breakdown={item.breakdown} />
        <PointsChips breakdown={item.breakdown} totalPoints={item.points} />
      </div>
    </article>
  );
}

export interface UserPointsDetailProps {
  /** Si se omite, carga los puntos del usuario autenticado. */
  userId?: number;
  /** Oculta el bloque de resumen (útil en modal compacto). */
  compact?: boolean;
}

export function UserPointsDetail({ userId, compact = false }: UserPointsDetailProps) {
  const [data, setData] = useState<UserScoresData | null>(null);
  const [loading, setLoading] = useState(true);
  const [tab, setTab] = useState<FilterTab>("all");
  const isOwnProfile = userId == null;
  const predictionLabel = isOwnProfile ? "Tu predicción" : "Predicción";

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const path =
        userId != null ? `/leaderboard/${userId}/scores` : "/predictions/me/scores";
      const res = await api<UserScoresData>(path);
      setData(res);
    } catch {
      setData(null);
    } finally {
      setLoading(false);
    }
  }, [userId]);

  useEffect(() => {
    load().catch(() => undefined);
  }, [load]);

  const filteredMatches = useMemo(() => {
    if (!data || tab === "extras") return [];
    return data.matches;
  }, [data, tab]);

  const filteredExtras = useMemo(() => {
    if (!data || tab === "matches") return [];
    return data.extras;
  }, [data, tab]);

  const hasContent =
    (data?.matches.length ?? 0) > 0 || (data?.extras.length ?? 0) > 0;

  return (
    <div className="user-points-detail">
      {!compact && (
        <div className="stats-row">
          <div className="stat-box">
            <div className="label">Total acumulado</div>
            <div className="value">{loading ? "…" : data?.totalPoints ?? 0}</div>
          </div>
          <div className="stat-box">
            <div className="label">Por partidos</div>
            <div className="value">{loading ? "…" : data?.matchPointsTotal ?? 0}</div>
          </div>
          <div className="stat-box">
            <div className="label">Clasificados, cuadro y bonos</div>
            <div className="value">{loading ? "…" : data?.extrasPointsTotal ?? 0}</div>
          </div>
          <div className="stat-box">
            <div className="label">Partidos puntuados</div>
            <div className="value">{loading ? "…" : data?.matches.length ?? 0}</div>
          </div>
        </div>
      )}

      <div className="user-points-tabs" role="tablist">
        {(
          [
            ["all", "Todo"],
            ["matches", "Partidos"],
            ["extras", "Clasificados y bonos"]
          ] as const
        ).map(([id, label]) => (
          <button
            key={id}
            type="button"
            role="tab"
            aria-selected={tab === id}
            className={`user-points-tab${tab === id ? " user-points-tab--active" : ""}`}
            onClick={() => setTab(id)}
          >
            {label}
          </button>
        ))}
      </div>

      {loading && (
        <div className="panel-card empty-state">
          <strong>{isOwnProfile ? "Cargando tus puntos…" : "Cargando puntos…"}</strong>
        </div>
      )}

      {!loading && !hasContent && (
        <div className="panel-card empty-state">
          <strong>
            {isOwnProfile ? "Aún no tienes puntos registrados" : "Sin puntos registrados aún"}
          </strong>
          {isOwnProfile && (
            <p style={{ marginTop: "0.5rem" }}>
              Haz predicciones en <Link to="/predictions?stage=KNOCKOUT">Partidos</Link> y, cuando el admin publique resultados,
              verás aquí el detalle de cada partido y cada categoría.
            </p>
          )}
        </div>
      )}

      {!loading && hasContent && (
        <>
          {(tab === "all" || tab === "matches") && filteredMatches.length > 0 && (
            <section className="user-points-section">
              {tab === "all" && <h2 className="user-points-section-title">Partidos</h2>}
              <div className="user-points-list">
                {filteredMatches.map((m) => (
                  <MatchPointsCard
                    key={m.matchId}
                    match={m}
                    predictionLabel={predictionLabel}
                  />
                ))}
              </div>
            </section>
          )}

          {(tab === "all" || tab === "extras") && filteredExtras.length > 0 && (
            <section className="user-points-section">
              {tab === "all" && <h2 className="user-points-section-title">Clasificados, cuadro y bonos Fase 1</h2>}
              <div className="user-points-list">
                {filteredExtras.map((item) => (
                  <ExtraPointsCard
                    key={`${item.sourceType}-${item.sourceId}`}
                    item={item}
                  />
                ))}
              </div>
            </section>
          )}

          {tab === "matches" && filteredMatches.length === 0 && (
            <div className="panel-card empty-state">
              <strong>Sin puntos por partidos aún</strong>
            </div>
          )}
          {tab === "extras" && filteredExtras.length === 0 && (
            <div className="panel-card empty-state">
              <strong>Sin puntos de clasificados, cuadro o bonos</strong>
              {isOwnProfile && (
                <p style={{ marginTop: "0.5rem" }}>
                  Completa el <Link to="/predictions/qualifiers">cuadro de 32</Link>,{" "}
                  <Link to="/predictions/bracket">eliminatorias</Link> (cuadro de premios) y{" "}
                  <Link to="/predictions/extras">goleador y asistidor</Link>.
                </p>
              )}
            </div>
          )}
        </>
      )}
    </div>
  );
}
