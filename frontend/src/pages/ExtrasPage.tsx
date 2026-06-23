import { useCallback, useEffect, useState } from "react";
import type { FormEvent } from "react";
import { Link } from "react-router-dom";
import { PageTitle, SectionTitle } from "../components/InfoModal";
import { PredictionsSubnav } from "../components/PredictionsSubnav";
import { PointsChips } from "../components/PointsChips";
import { TeamFlag } from "../components/TeamFlag";
import { api } from "../lib/api";

interface Team {
  id: number;
  name: string;
  logoUrl?: string | null;
}

interface BonusPicks {
  championTeamId: number | null;
  runnerUpTeamId: number | null;
  thirdPlaceTeamId: number | null;
  semifinalistTeamIds: number[];
  finalistTeamIds: number[];
  topScorer: string | null;
  topAssister: string | null;
}

interface ExtrasWindow {
  openDate: string | null;
  closeDate: string | null;
  open: boolean;
}

interface QualTeam {
  id: number;
  name: string;
  logoUrl?: string | null;
  groupName: string;
}

interface QualRow {
  rank: number;
  teamId: number;
  team?: QualTeam;
  qualifies: boolean;
  isThird: boolean;
}

interface QualGroup {
  groupId: number;
  groupName: string;
  rows: QualRow[];
}

interface QualThird {
  teamId: number;
  groupName: string;
  team?: QualTeam;
}

interface QualifiersData {
  predictedMatches: number;
  expectedGroupMatches: number;
  groups: QualGroup[];
  bestThirds: QualThird[];
}

function extrasWindowLabel(w: ExtrasWindow): string {
  if (w.openDate && w.closeDate) return `Plazo: del ${w.openDate} al ${w.closeDate}`;
  if (w.openDate) return `Se pueden llenar desde el ${w.openDate}`;
  if (w.closeDate) return `Se pueden llenar hasta el ${w.closeDate}`;
  return "";
}

function teamName(teams: Team[], id: number | null): string {
  if (id == null) return "—";
  return teams.find((t) => t.id === id)?.name ?? `Equipo ${id}`;
}

export function ExtrasPage() {
  const [teams, setTeams] = useState<Team[]>([]);
  const [picks, setPicks] = useState<BonusPicks>({
    championTeamId: null,
    runnerUpTeamId: null,
    thirdPlaceTeamId: null,
    semifinalistTeamIds: [],
    finalistTeamIds: [],
    topScorer: "",
    topAssister: ""
  });
  const [earnedPoints, setEarnedPoints] = useState<number | null>(null);
  const [earnedBreakdown, setEarnedBreakdown] = useState<Record<string, number> | null>(null);
  const [extrasWindow, setExtrasWindow] = useState<ExtrasWindow | null>(null);
  const [qualifiers, setQualifiers] = useState<QualifiersData | null>(null);
  const [message, setMessage] = useState("");
  const [isError, setIsError] = useState(false);

  const load = useCallback(async () => {
    const res = await api<{
      teams: Team[];
      picks: BonusPicks;
      earnedPoints: number | null;
      earnedBreakdown: Record<string, number> | null;
      extrasWindow?: ExtrasWindow;
    }>("/predictions/me/bonuses");
    setExtrasWindow(res.extrasWindow ?? null);
    setTeams(res.teams);
    setPicks({
      championTeamId: res.picks.championTeamId ?? null,
      runnerUpTeamId: res.picks.runnerUpTeamId ?? null,
      thirdPlaceTeamId: res.picks.thirdPlaceTeamId ?? null,
      semifinalistTeamIds: res.picks.semifinalistTeamIds ?? [],
      finalistTeamIds: res.picks.finalistTeamIds ?? [],
      topScorer: res.picks.topScorer ?? "",
      topAssister: res.picks.topAssister ?? ""
    });
    setEarnedPoints(res.earnedPoints);
    setEarnedBreakdown(res.earnedBreakdown);
  }, []);

  const loadQualifiers = useCallback(async () => {
    const res = await api<QualifiersData>("/predictions/me/qualifiers");
    setQualifiers(res);
  }, []);

  useEffect(() => {
    load().catch(() => undefined);
    loadQualifiers().catch(() => undefined);
    const refresh = () => {
      if (document.visibilityState === "visible") {
        load().catch(() => undefined);
        loadQualifiers().catch(() => undefined);
      }
    };
    document.addEventListener("visibilitychange", refresh);
    return () => document.removeEventListener("visibilitychange", refresh);
  }, [load, loadQualifiers]);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    try {
      await api("/predictions/me/bonuses", {
        method: "PUT",
        body: JSON.stringify({
          topScorer: picks.topScorer?.trim() || null,
          topAssister: picks.topAssister?.trim() || null
        })
      });
      setIsError(false);
      setMessage("Premios especiales guardados");
      await load();
    } catch (err) {
      setIsError(true);
      setMessage((err as Error).message);
    }
  }

  return (
    <>
      <PageTitle
        helpTitle="Cuadro y premios — Fase 2"
        help={
          <p>
            El <strong>cuadro</strong> (semifinalistas, finalistas, campeón, subcampeón y tercero) se arma solo con los
            resultados que guardas en <Link to="/predictions/bracket">Eliminatorias</Link> desde octavos hasta la final.
            Aquí solo indicas goleador y máximo asistidor.
          </p>
        }
      >
        Cuadro y premios — Fase 2
      </PageTitle>

      <PredictionsSubnav />

      {earnedPoints != null && (
        <div className="panel-card" style={{ marginBottom: "1rem" }}>
          <PointsChips breakdown={earnedBreakdown} totalPoints={earnedPoints} />
        </div>
      )}

      {qualifiers && (
        <section className="panel-card" style={{ marginBottom: "1rem" }}>
          <SectionTitle
            title="Tu fase de grupos — quiénes clasifican"
            help={
              <p>
                Equipos que, según tus marcadores de grupos, pasan a la siguiente fase: 1° y 2° de cada grupo y los 8
                mejores terceros. Ajusta tus marcadores en <Link to="/predictions">Partidos</Link>.
              </p>
            }
          />
          <p className="admin-block-hint" style={{ marginTop: 0 }}>
            Según tus marcadores de grupos ({qualifiers.predictedMatches}/{qualifiers.expectedGroupMatches} partidos).{" "}
            <Link to="/predictions/qualifiers">Ver cuadro completo de 32</Link>
          </p>

          <div className="extras-qualifiers-grid">
            {qualifiers.groups.map((g) => {
              const advancing = g.rows.filter((r) => r.qualifies);
              return (
                <div key={g.groupId} className="extras-qualifier-group">
                  <h3>Grupo {g.groupName}</h3>
                  {advancing.length === 0 ? (
                    <p className="admin-block-hint" style={{ margin: 0 }}>Sin marcadores aún</p>
                  ) : (
                    <ul className="extras-qualifier-teams">
                      {advancing.map((r) => (
                        <li key={r.teamId}>
                          <span className="extras-qualifier-rank">{r.rank}°</span>
                          {r.team && <TeamFlag name={r.team.name} logoUrl={r.team.logoUrl} size="sm" />}
                          <span>{r.team?.name ?? `Equipo ${r.teamId}`}</span>
                        </li>
                      ))}
                    </ul>
                  )}
                </div>
              );
            })}
          </div>

          {qualifiers.bestThirds.length > 0 && (
            <>
              <h3 style={{ fontSize: "0.95rem", margin: "1rem 0 0.5rem" }}>8 mejores terceros</h3>
              <ol className="best-thirds-list">
                {qualifiers.bestThirds.map((t, i) => (
                  <li key={t.teamId}>
                    <span className="best-thirds-rank">{i + 1}.</span>
                    {t.team && <TeamFlag name={t.team.name} logoUrl={t.team.logoUrl} size="sm" />}
                    <span>
                      {t.team?.name ?? `Equipo ${t.teamId}`} — Grupo {t.groupName}
                    </span>
                  </li>
                ))}
              </ol>
            </>
          )}
        </section>
      )}

      <section className="panel-card" style={{ marginBottom: "1rem" }}>
        <SectionTitle
          title="Tu cuadro (desde Eliminatorias)"
          help={
            <p>
              Completa o actualiza predicciones en <Link to="/predictions/bracket">Eliminatorias</Link> y vuelve aquí
              para ver el resumen.
            </p>
          }
        />

        <dl className="bonus-derived-list">
          <div>
            <dt>Semifinalistas</dt>
            <dd>
              {picks.semifinalistTeamIds.length === 0 ? (
                "—"
              ) : (
                <ul className="bonus-derived-teams">
                  {picks.semifinalistTeamIds.map((id) => (
                    <li key={id}>
                      <TeamFlag name={teamName(teams, id)} logoUrl={teams.find((t) => t.id === id)?.logoUrl} size="sm" />
                      {teamName(teams, id)}
                    </li>
                  ))}
                </ul>
              )}
            </dd>
          </div>
          <div>
            <dt>Finalistas</dt>
            <dd>
              {picks.finalistTeamIds.length === 0 ? (
                "—"
              ) : (
                <ul className="bonus-derived-teams">
                  {picks.finalistTeamIds.map((id) => (
                    <li key={id}>
                      <TeamFlag name={teamName(teams, id)} logoUrl={teams.find((t) => t.id === id)?.logoUrl} size="sm" />
                      {teamName(teams, id)}
                    </li>
                  ))}
                </ul>
              )}
            </dd>
          </div>
          <div>
            <dt>Campeón</dt>
            <dd>
              {picks.championTeamId ? (
                <>
                  <TeamFlag
                    name={teamName(teams, picks.championTeamId)}
                    logoUrl={teams.find((t) => t.id === picks.championTeamId)?.logoUrl}
                    size="sm"
                  />
                  {teamName(teams, picks.championTeamId)}
                </>
              ) : (
                "—"
              )}
            </dd>
          </div>
          <div>
            <dt>Subcampeón</dt>
            <dd>
              {picks.runnerUpTeamId ? (
                <>
                  <TeamFlag
                    name={teamName(teams, picks.runnerUpTeamId)}
                    logoUrl={teams.find((t) => t.id === picks.runnerUpTeamId)?.logoUrl}
                    size="sm"
                  />
                  {teamName(teams, picks.runnerUpTeamId)}
                </>
              ) : (
                "—"
              )}
            </dd>
          </div>
          <div>
            <dt>Tercer puesto</dt>
            <dd>
              {picks.thirdPlaceTeamId ? (
                <>
                  <TeamFlag
                    name={teamName(teams, picks.thirdPlaceTeamId)}
                    logoUrl={teams.find((t) => t.id === picks.thirdPlaceTeamId)?.logoUrl}
                    size="sm"
                  />
                  {teamName(teams, picks.thirdPlaceTeamId)}
                </>
              ) : (
                "—"
              )}
            </dd>
          </div>
        </dl>
      </section>

      <form className="panel-card" onSubmit={onSubmit}>
        <h2 style={{ fontSize: "1rem", marginBottom: "0.75rem" }}>Premios especiales</h2>

        {extrasWindow && extrasWindowLabel(extrasWindow) && (
          <p className="admin-block-hint" style={{ marginBottom: "0.75rem" }}>
            {extrasWindowLabel(extrasWindow)}
            {!extrasWindow.open && <strong> — plazo cerrado</strong>}
          </p>
        )}

        <div className="field">
          <label>Goleador del mundial (25 pts)</label>
          <input
            className="input"
            value={picks.topScorer ?? ""}
            onChange={(e) => setPicks((p) => ({ ...p, topScorer: e.target.value }))}
            placeholder="Nombre del jugador"
            disabled={extrasWindow ? !extrasWindow.open : false}
          />
        </div>
        <div className="field">
          <label>Máximo asistidor (20 pts)</label>
          <input
            className="input"
            value={picks.topAssister ?? ""}
            onChange={(e) => setPicks((p) => ({ ...p, topAssister: e.target.value }))}
            placeholder="Nombre del jugador"
            disabled={extrasWindow ? !extrasWindow.open : false}
          />
        </div>

        <button
          type="submit"
          className="btn btn-primary btn-block"
          style={{ marginTop: "1rem" }}
          disabled={extrasWindow ? !extrasWindow.open : false}
        >
          Guardar premios especiales
        </button>
      </form>

      {message && (
        <div className={`alert ${isError ? "alert-error" : "alert-success"}`} style={{ marginTop: "1rem" }}>
          {message}
        </div>
      )}
    </>
  );
}
