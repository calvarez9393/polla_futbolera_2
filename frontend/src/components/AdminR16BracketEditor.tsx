import { useCallback, useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { TeamFlag } from "./TeamFlag";
import { api } from "../lib/api";

interface TeamOption {
  teamId: number;
  name: string;
  logoUrl?: string | null;
  groupName: string | null;
}

interface BracketMatch {
  matchId: number;
  matchNumber: number;
  externalNum: number;
  label: string;
  homeSlotLabel: string;
  awaySlotLabel: string;
  octavosMatchNum?: number;
  home: { teamId: number; name: string; logoUrl?: string | null } | null;
  away: { teamId: number; name: string; logoUrl?: string | null } | null;
}

interface PairingDraft {
  matchId: number;
  homeTeamId: number | "";
  awayTeamId: number | "";
}

export function AdminR16BracketEditor({
  onMessage
}: {
  onMessage: (msg: string, isError: boolean) => void;
}) {
  const [matches, setMatches] = useState<BracketMatch[]>([]);
  const [teams, setTeams] = useState<TeamOption[]>([]);
  const [draft, setDraft] = useState<PairingDraft[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [autoFilling, setAutoFilling] = useState(false);
  const [hasKnockout, setHasKnockout] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await api<{
        matches: BracketMatch[];
        teams: TeamOption[];
        hasKnockout: boolean;
      }>("/admin/official/r16-bracket");
      setMatches(data.matches);
      setTeams(data.teams);
      setHasKnockout(data.hasKnockout);
      setDraft(
        data.matches.map((m) => ({
          matchId: m.matchId,
          homeTeamId: m.home?.teamId ?? "",
          awayTeamId: m.away?.teamId ?? ""
        }))
      );
    } catch (e) {
      onMessage((e as Error).message, true);
    } finally {
      setLoading(false);
    }
  }, [onMessage]);

  useEffect(() => {
    load().catch(() => undefined);
  }, [load]);

  function updateDraft(matchId: number, side: "home" | "away", teamId: number | "") {
    setDraft((prev) =>
      prev.map((p) =>
        p.matchId === matchId
          ? { ...p, [side === "home" ? "homeTeamId" : "awayTeamId"]: teamId }
          : p
      )
    );
  }

  async function save() {
    const pairings = draft
      .filter((p) => p.homeTeamId && p.awayTeamId)
      .map((p) => ({
        matchId: p.matchId,
        homeTeamId: Number(p.homeTeamId),
        awayTeamId: Number(p.awayTeamId)
      }));
    if (pairings.length !== 16) {
      onMessage("Completa los 16 cruces (local y visitante en cada partido)", true);
      return;
    }
    setSaving(true);
    try {
      const data = await api<{ matches: BracketMatch[] }>("/admin/official/r16-bracket", {
        method: "PUT",
        body: JSON.stringify({ pairings })
      });
      setMatches(data.matches);
      onMessage("Cuadro de dieciseisavos guardado", false);
    } catch (e) {
      onMessage((e as Error).message, true);
    } finally {
      setSaving(false);
    }
  }

  async function autoFromResults() {
    setAutoFilling(true);
    try {
      const data = await api<{
        matches: BracketMatch[];
        updated: number;
        total: number;
        missing: Array<{ matchNum: number; reason: string }>;
        qualifiers: {
          bestThirds: unknown[];
          thirdSlotsAssigned: number;
          finishedGroupMatches: number;
          groupsWithFullTable: number;
        };
      }>("/admin/official/r16-bracket/auto-from-results", { method: "POST" });
      if (data.matches) {
        setMatches(data.matches);
        setDraft(
          data.matches.map((m) => ({
            matchId: m.matchId,
            homeTeamId: m.home?.teamId ?? "",
            awayTeamId: m.away?.teamId ?? ""
          }))
        );
      }
      const miss =
        data.missing?.length > 0
          ? ` Pendientes: ${data.missing.map((m) => `P${m.matchNum}`).join(", ")}.`
          : "";
      onMessage(
        `Cuadro: ${data.updated}/${data.total ?? 16} cruces. ` +
          `Terceros en ranuras: ${data.qualifiers?.thirdSlotsAssigned ?? 0}/8. ` +
          `Grupos completos: ${data.qualifiers?.groupsWithFullTable ?? 0}/12.${miss}`,
        false
      );
    } catch (e) {
      onMessage((e as Error).message, true);
    } finally {
      setAutoFilling(false);
    }
  }

  if (loading) {
    return (
      <div className="panel-card empty-state">
        <strong>Cargando cuadro…</strong>
      </div>
    );
  }

  if (!hasKnockout) {
    return (
      <div className="panel-card empty-state">
        <strong>Importa primero el cuadro eliminatorio</strong>
        <p style={{ marginTop: "0.5rem" }}>
          En <Link to="/admin">Panel Admin</Link> → Importar cuadro eliminatorio.
        </p>
      </div>
    );
  }

  return (
    <section className="panel-card admin-r16-editor">
      <h2 style={{ fontSize: "1.1rem", marginBottom: "0.5rem" }}>Dieciseisavos — cuadro oficial</h2>
      <p className="admin-block-hint">
        Define los 16 cruces reales (32 equipos). Los participantes verán este cuadro en{" "}
        <Link to="/predictions/r16">Dieciseisavos</Link>. Puedes autocompletar desde las tablas de grupos
        finalizadas y ajustar manualmente.
      </p>
      <div style={{ display: "flex", flexWrap: "wrap", gap: "0.5rem", margin: "0.75rem 0" }}>
        <button type="button" className="btn btn-primary" disabled={autoFilling} onClick={autoFromResults}>
          {autoFilling ? "Generando…" : "Autocompletar desde resultados de grupos"}
        </button>
        <button type="button" className="btn btn-ghost" disabled={saving} onClick={save}>
          {saving ? "Guardando…" : "Guardar cuadro oficial"}
        </button>
      </div>

      <div className="r16-bracket-grid r16-bracket-grid--admin">
        {matches.map((m) => {
          const d = draft.find((p) => p.matchId === m.matchId);
          return (
            <article key={m.matchId} className="r16-bracket-match r16-bracket-match--edit">
              <header className="r16-bracket-match-header">
                <span className="r16-bracket-match-num">P{m.externalNum ?? m.matchNumber}</span>
                <span className="r16-bracket-match-label">{m.label}</span>
              </header>
              <p className="r16-bracket-slot-hint">
                {m.homeSlotLabel} vs {m.awaySlotLabel}
                {m.octavosMatchNum != null && ` · Octavos P${m.octavosMatchNum}`}
              </p>
              <div className="r16-bracket-selects">
                <label>
                  <span className="rule-field-label">Local</span>
                  <select
                    className="select"
                    value={d?.homeTeamId ?? ""}
                    onChange={(e) =>
                      updateDraft(m.matchId, "home", e.target.value ? Number(e.target.value) : "")
                    }
                  >
                    <option value="">—</option>
                    {teams.map((t) => (
                      <option key={`h-${m.matchId}-${t.teamId}`} value={t.teamId}>
                        {t.name} (Gr. {t.groupName})
                      </option>
                    ))}
                  </select>
                </label>
                <label>
                  <span className="rule-field-label">Visitante</span>
                  <select
                    className="select"
                    value={d?.awayTeamId ?? ""}
                    onChange={(e) =>
                      updateDraft(m.matchId, "away", e.target.value ? Number(e.target.value) : "")
                    }
                  >
                    <option value="">—</option>
                    {teams.map((t) => (
                      <option key={`a-${m.matchId}-${t.teamId}`} value={t.teamId}>
                        {t.name} (Gr. {t.groupName})
                      </option>
                    ))}
                  </select>
                </label>
              </div>
              {d?.homeTeamId && d.awayTeamId && (
                <div className="r16-bracket-preview">
                  {(() => {
                    const home = teams.find((t) => t.teamId === Number(d.homeTeamId));
                    const away = teams.find((t) => t.teamId === Number(d.awayTeamId));
                    return (
                      <>
                        {home && <TeamFlag name={home.name} logoUrl={home.logoUrl} size="sm" />}
                        <span>{home?.name ?? "?"}</span>
                        <span className="r16-bracket-vs">vs</span>
                        {away && <TeamFlag name={away.name} logoUrl={away.logoUrl} size="sm" />}
                        <span>{away?.name ?? "?"}</span>
                      </>
                    );
                  })()}
                </div>
              )}
            </article>
          );
        })}
      </div>
    </section>
  );
}
