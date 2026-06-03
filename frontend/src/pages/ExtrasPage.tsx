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
  const [message, setMessage] = useState("");
  const [isError, setIsError] = useState(false);

  const load = useCallback(async () => {
    const res = await api<{
      teams: Team[];
      picks: BonusPicks;
      earnedPoints: number | null;
      earnedBreakdown: Record<string, number> | null;
    }>("/predictions/me/bonuses");
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

  useEffect(() => {
    load().catch(() => undefined);
    const refresh = () => {
      if (document.visibilityState === "visible") load().catch(() => undefined);
    };
    document.addEventListener("visibilitychange", refresh);
    return () => document.removeEventListener("visibilitychange", refresh);
  }, [load]);

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

        <div className="field">
          <label>Goleador del mundial (25 pts)</label>
          <input
            className="input"
            value={picks.topScorer ?? ""}
            onChange={(e) => setPicks((p) => ({ ...p, topScorer: e.target.value }))}
            placeholder="Nombre del jugador"
          />
        </div>
        <div className="field">
          <label>Máximo asistidor (20 pts)</label>
          <input
            className="input"
            value={picks.topAssister ?? ""}
            onChange={(e) => setPicks((p) => ({ ...p, topAssister: e.target.value }))}
            placeholder="Nombre del jugador"
          />
        </div>

        <button type="submit" className="btn btn-primary btn-block" style={{ marginTop: "1rem" }}>
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
