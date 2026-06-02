import { useEffect, useState } from "react";
import type { FormEvent } from "react";
import { Link } from "react-router-dom";
import { AdminSubnav } from "../components/AdminSubnav";
import { api } from "../lib/api";
import { formatCalendarDateYmd } from "../lib/matchTime";
import {
  mergeScoringRulesFromApi,
  SCORING_RULE_SECTIONS,
  scoringRulesPayload
} from "../lib/scoringRuleDefinitions";

interface TournamentSettings {
  tournamentName: string;
  predictionLockHoursBefore: number;
  knockoutPredictionsOpenDate: string;
  knockoutPredictionsCloseDate: string;
  knockoutFixtureDefaults?: { openDate: string; closeDate: string };
}

export function AdminPage() {
  const [rules, setRules] = useState<Record<string, number>>(() =>
    mergeScoringRulesFromApi({})
  );
  const [settings, setSettings] = useState<TournamentSettings>({
    tournamentName: "Mundial FIFA 2026",
    predictionLockHoursBefore: 24,
    knockoutPredictionsOpenDate: "",
    knockoutPredictionsCloseDate: ""
  });
  const [message, setMessage] = useState("");
  const [isError, setIsError] = useState(false);
  const [importing, setImporting] = useState(false);
  const [importingKo, setImportingKo] = useState(false);

  useEffect(() => {
    api<Record<string, unknown>>("/admin/scoring-rules")
      .then((r) => setRules(mergeScoringRulesFromApi(r)))
      .catch(() => undefined);
    api<TournamentSettings>("/admin/settings/tournament").then(setSettings).catch(() => undefined);
  }, []);

  async function onSaveRules(event: FormEvent) {
    event.preventDefault();
    try {
      const saved = await api<Record<string, unknown>>("/admin/scoring-rules", {
        method: "PUT",
        body: JSON.stringify(scoringRulesPayload(rules))
      });
      setRules(mergeScoringRulesFromApi(saved));
      setIsError(false);
      setMessage("Reglas de puntos guardadas");
    } catch (e) {
      setIsError(true);
      setMessage((e as Error).message);
    }
  }

  async function onSaveSettings(event: FormEvent) {
    event.preventDefault();
    try {
      await api("/admin/settings/tournament", {
        method: "PUT",
        body: JSON.stringify({
          tournamentName: settings.tournamentName,
          predictionLockHoursBefore: settings.predictionLockHoursBefore,
          knockoutPredictionsOpenDate: settings.knockoutPredictionsOpenDate,
          knockoutPredictionsCloseDate: settings.knockoutPredictionsCloseDate
        })
      });
      const refreshed = await api<TournamentSettings>("/admin/settings/tournament");
      setSettings(refreshed);
      setIsError(false);
      setMessage("Configuración del torneo guardada");
    } catch (e) {
      setIsError(true);
      setMessage((e as Error).message);
    }
  }

  async function importSchedule() {
    setImporting(true);
    setMessage("");
    try {
      const result = await api<{ teams: number; groups: number; matches: number }>(
        "/admin/matches/import-worldcup-2026",
        { method: "POST" }
      );
      setIsError(false);
      setMessage(`Grupos: ${result.matches} partidos, ${result.groups} grupos, ${result.teams} equipos`);
    } catch (e) {
      setIsError(true);
      setMessage((e as Error).message);
    } finally {
      setImporting(false);
    }
  }

  async function importKnockout() {
    setImportingKo(true);
    setMessage("");
    try {
      const result = await api<{ matches: number }>("/admin/matches/import-worldcup-2026-knockout", {
        method: "POST"
      });
      setIsError(false);
      setMessage(`Eliminatorias: ${result.matches} partidos (16avos → final)`);
    } catch (e) {
      setIsError(true);
      setMessage((e as Error).message);
    } finally {
      setImportingKo(false);
    }
  }

  return (
    <>
      <AdminSubnav />
      <h1 className="page-title">Panel Admin</h1>
      <p className="page-subtitle">Reglamento oficial Polla 2026 — dos fases, tabla general acumulada.</p>

      {message && <div className={`alert ${isError ? "alert-error" : "alert-success"}`}>{message}</div>}

      <section className="panel-card" style={{ marginBottom: "1.25rem" }}>
        <h2 style={{ fontSize: "1.25rem", marginBottom: "0.5rem" }}>Reglamento resumido</h2>
        <ul className="admin-block-hint" style={{ paddingLeft: "1.1rem", lineHeight: 1.6 }}>
          <li>
            <strong>Fase 1</strong> (grupos + 16avos): ganador/empate +3, dif. +2, exacto +5; 24 clasificados × 4 pts.
          </li>
          <li>
            <strong>Fase 2</strong> (octavos→final): puntos por avanzar y exacto según ronda; cuadro completo y premios
            especiales.
          </li>
          <li>Inscripción $50.000 COP; premios 60% / 25% / 15% (20 participantes).</li>
        </ul>
      </section>

      <section className="panel-card" style={{ marginBottom: "1.25rem" }}>
        <h2 style={{ fontSize: "1.25rem", marginBottom: "0.5rem" }}>Operación diaria</h2>
        <div style={{ display: "flex", flexWrap: "wrap", gap: "0.75rem" }}>
          <Link to="/admin/users" className="btn btn-ghost">
            Usuarios
          </Link>
          <Link to="/admin/calendar" className="btn btn-primary">
            Calendario y resultados
          </Link>
          <Link to="/admin/official" className="btn btn-ghost">
            Oficiales y bonos
          </Link>
        </div>
      </section>

      <div className="admin-grid">
        <section className="panel-card">
          <h2 style={{ fontSize: "1.25rem", marginBottom: "0.75rem" }}>Fase de grupos</h2>
          <p className="admin-block-hint">72 partidos · 48 equipos · 12 grupos (11–27 jun 2026).</p>
          <button type="button" className="btn btn-primary btn-block" onClick={importSchedule} disabled={importing}>
            {importing ? "Importando…" : "Importar grupos 2026"}
          </button>
        </section>

        <section className="panel-card">
          <h2 style={{ fontSize: "1.25rem", marginBottom: "0.75rem" }}>Eliminatorias</h2>
          <p className="admin-block-hint">
            16 dieciseisavos + octavos + cuartos + semis + final + 3er puesto.
          </p>
          <button type="button" className="btn btn-primary btn-block" onClick={importKnockout} disabled={importingKo}>
            {importingKo ? "Importando…" : "Importar cuadro eliminatorio"}
          </button>
        </section>

        <section className="panel-card">
          <h2 style={{ fontSize: "1.25rem", marginBottom: "1rem" }}>Cierre de predicciones</h2>
          {(settings.knockoutPredictionsOpenDate || settings.knockoutPredictionsCloseDate) && (
            <p className="admin-block-hint" style={{ marginTop: 0, marginBottom: "1rem" }}>
              Ventana activa en el sistema:{" "}
              {settings.knockoutPredictionsOpenDate
                ? formatCalendarDateYmd(settings.knockoutPredictionsOpenDate)
                : "sin apertura"}
              {settings.knockoutPredictionsCloseDate
                ? ` – ${formatCalendarDateYmd(settings.knockoutPredictionsCloseDate)}`
                : ""}
              . Las eliminatorias usan estas fechas (no el calendario FIFA por ronda).
            </p>
          )}
          <form onSubmit={onSaveSettings}>
            <div className="field">
              <label className="rule-field-label">Nombre del torneo</label>
              <input
                className="input"
                value={settings.tournamentName}
                onChange={(e) => setSettings({ ...settings, tournamentName: e.target.value })}
              />
            </div>
            <div className="field">
              <label className="rule-field-label">Horas antes del partido</label>
              <input
                className="input"
                type="number"
                min={0}
                max={168}
                value={settings.predictionLockHoursBefore}
                onChange={(e) => setSettings({ ...settings, predictionLockHoursBefore: Number(e.target.value) })}
              />
            </div>
            <div className="field">
              <label className="rule-field-label">Habilitar eliminatorias desde</label>
              <input
                className="input"
                type="date"
                value={settings.knockoutPredictionsOpenDate}
                onChange={(e) =>
                  setSettings({ ...settings, knockoutPredictionsOpenDate: e.target.value })
                }
              />
              <span className="scoring-rule-hint">
                Si defines una fecha, reemplaza el calendario FIFA por ronda para todas las eliminatorias.
                Vacío = calendario FIFA automático. Sugerido:{" "}
                {settings.knockoutFixtureDefaults?.openDate ?? "2026-06-28"}.
              </span>
            </div>
            <div className="field">
              <label className="rule-field-label">Cerrar eliminatorias el</label>
              <input
                className="input"
                type="date"
                value={settings.knockoutPredictionsCloseDate}
                onChange={(e) =>
                  setSettings({ ...settings, knockoutPredictionsCloseDate: e.target.value })
                }
              />
              <span className="scoring-rule-hint">
                Opcional. Cierre global de todas las predicciones eliminatorias. Sugerido:{" "}
                {settings.knockoutFixtureDefaults?.closeDate ?? "2026-07-19"}.
              </span>
            </div>
            <button type="submit" className="btn btn-ghost btn-block">
              Guardar configuración
            </button>
          </form>
        </section>
      </div>

      <section className="panel-card scoring-rules-panel" style={{ marginTop: "1.25rem" }}>
        <h2 style={{ fontSize: "1.25rem", marginBottom: "0.35rem" }}>Reglas de puntos</h2>
        <p className="admin-block-hint" style={{ marginBottom: "1.25rem" }}>
          Valores del reglamento oficial. Cada fila indica cuántos puntos suma ese acierto.
        </p>
        <form onSubmit={onSaveRules}>
          {SCORING_RULE_SECTIONS.map((section) => (
            <div key={section.title} className="scoring-rules-section">
              <h3 className="scoring-rules-section-title">{section.title}</h3>
              {section.description && (
                <p className="scoring-rules-section-desc">{section.description}</p>
              )}
              <div className="rules-grid">
                {section.fields.map((field) => (
                  <div className="field scoring-rule-field" key={field.key}>
                    <label className="rule-field-label" htmlFor={`rule-${field.key}`}>
                      {field.label}
                    </label>
                    {field.hint && <span className="scoring-rule-hint">{field.hint}</span>}
                    <input
                      id={`rule-${field.key}`}
                      className="input"
                      type="number"
                      min={0}
                      value={rules[field.key] ?? 0}
                      onChange={(e) =>
                        setRules({ ...rules, [field.key]: Number(e.target.value) })
                      }
                    />
                  </div>
                ))}
              </div>
            </div>
          ))}
          <button type="submit" className="btn btn-primary btn-block" style={{ marginTop: "1.5rem" }}>
            Guardar reglas de puntos
          </button>
        </form>
      </section>
    </>
  );
}
