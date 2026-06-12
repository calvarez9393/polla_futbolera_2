import { useEffect, useState } from "react";
import type { FormEvent } from "react";
import { Link } from "react-router-dom";
import { AdminSubnav } from "../components/AdminSubnav";
import { PageTitle, SectionTitle } from "../components/InfoModal";
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
  extrasOpenDate: string;
  extrasCloseDate: string;
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
    knockoutPredictionsCloseDate: "",
    extrasOpenDate: "",
    extrasCloseDate: ""
  });
  const [message, setMessage] = useState("");
  const [isError, setIsError] = useState(false);
  const [importing, setImporting] = useState(false);
  const [importingKo, setImportingKo] = useState(false);
  const [resetting, setResetting] = useState(false);

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
          knockoutPredictionsCloseDate: settings.knockoutPredictionsCloseDate,
          extrasOpenDate: settings.extrasOpenDate,
          extrasCloseDate: settings.extrasCloseDate
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

  async function resetCompetition() {
    const ok = window.confirm(
      "¿Reiniciar partidos y ranking?\n\n" +
        "Se borrarán TODAS las predicciones, puntos, bonos y resultados oficiales. " +
        "El ranking quedará en cero. Los usuarios y el calendario importado se mantienen.\n\n" +
        "Esta acción no se puede deshacer."
    );
    if (!ok) return;

    setResetting(true);
    setMessage("");
    try {
      const result = await api<{
        ok: boolean;
        message: string;
        predictionScores: number;
        predictions: number;
        matchesReset: number;
      }>("/admin/competition/reset", {
        method: "POST",
        body: JSON.stringify({ confirm: true })
      });
      setIsError(false);
      setMessage(
        `${result.message}. Puntos: ${result.predictionScores}, predicciones: ${result.predictions}, partidos: ${result.matchesReset}`
      );
    } catch (e) {
      setIsError(true);
      setMessage((e as Error).message);
    } finally {
      setResetting(false);
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
      <PageTitle
        helpTitle="Panel Admin"
        help={<p>Reglamento oficial Polla 2026 — dos fases, tabla general acumulada.</p>}
      >
        Panel Admin
      </PageTitle>

      {message && <div className={`alert ${isError ? "alert-error" : "alert-success"}`}>{message}</div>}

      <section className="panel-card" style={{ marginBottom: "1.25rem" }}>
        <SectionTitle
          title="Reglamento resumido"
          help={
            <ul style={{ paddingLeft: "1.1rem", lineHeight: 1.6 }}>
              <li>
                <strong>Fase 1</strong> (grupos + 16avos): ganador/empate +3, dif. +2, exacto +5; 24 clasificados × 4
                pts.
              </li>
              <li>
                <strong>Fase 2</strong> (octavos→final): puntos por avanzar y exacto según ronda; cuadro completo y
                premios especiales.
              </li>
              <li>Inscripción $50.000 COP; premios 60% / 25% / 15% (20 participantes).</li>
            </ul>
          }
        />
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

      <section className="panel-card admin-danger-zone" style={{ marginBottom: "1.25rem" }}>
        <SectionTitle
          title="Pruebas / reinicio"
          help={
            <p>
              Borra puntos, predicciones, clasificados simulados, bonos y marcadores de todos los partidos del torneo
              activo. Útil en entornos de prueba o producción mientras validan la app. No elimina usuarios ni el
              calendario importado; las eliminatorias vuelven a equipos TBD hasta que reimportes o asignes cruces.
            </p>
          }
        />
        <button
          type="button"
          className="btn btn-danger btn-block"
          disabled={resetting}
          onClick={resetCompetition}
        >
          {resetting ? "Reiniciando…" : "Reiniciar partidos y ranking"}
        </button>
      </section>

      <div className="admin-grid">
        <section className="panel-card">
          <SectionTitle
            title="Fase de grupos"
            help={<p>72 partidos · 48 equipos · 12 grupos (11–27 jun 2026).</p>}
          />
          <button type="button" className="btn btn-primary btn-block" onClick={importSchedule} disabled={importing}>
            {importing ? "Importando…" : "Importar grupos 2026"}
          </button>
        </section>

        <section className="panel-card">
          <SectionTitle
            title="Eliminatorias"
            help={<p>16 dieciseisavos + octavos + cuartos + semis + final + 3er puesto.</p>}
          />
          <button type="button" className="btn btn-primary btn-block" onClick={importKnockout} disabled={importingKo}>
            {importingKo ? "Importando…" : "Importar cuadro eliminatorio"}
          </button>
        </section>

        <section className="panel-card">
          <SectionTitle
            title="Cierre de predicciones"
            help={
              <>
                <p>
                  Ventana activa:{" "}
                  {settings.knockoutPredictionsOpenDate
                    ? formatCalendarDateYmd(settings.knockoutPredictionsOpenDate)
                    : "sin apertura"}
                  {settings.knockoutPredictionsCloseDate
                    ? ` – ${formatCalendarDateYmd(settings.knockoutPredictionsCloseDate)}`
                    : ""}
                  . Las eliminatorias usan estas fechas (no el calendario FIFA por ronda).
                </p>
                <p>
                  Si defines fecha de apertura, reemplaza el calendario FIFA. Cierre global opcional para todas las
                  predicciones eliminatorias.
                </p>
              </>
            }
          />
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
            <div className="field">
              <label className="rule-field-label">Goleador/asistidor desde</label>
              <input
                className="input"
                type="date"
                value={settings.extrasOpenDate}
                onChange={(e) => setSettings({ ...settings, extrasOpenDate: e.target.value })}
              />
              <span className="scoring-rule-hint">
                Desde cuándo los usuarios pueden llenar goleador y máximo asistidor. Vacío = sin restricción.
              </span>
            </div>
            <div className="field">
              <label className="rule-field-label">Goleador/asistidor hasta</label>
              <input
                className="input"
                type="date"
                value={settings.extrasCloseDate}
                onChange={(e) => setSettings({ ...settings, extrasCloseDate: e.target.value })}
              />
              <span className="scoring-rule-hint">
                Último día para llenarlos. Vacío = sin cierre.
              </span>
            </div>
            <button type="submit" className="btn btn-ghost btn-block">
              Guardar configuración
            </button>
          </form>
        </section>
      </div>

      <section className="panel-card scoring-rules-panel" style={{ marginTop: "1.25rem" }}>
        <SectionTitle
          title="Reglas de puntos"
          help={<p>Valores del reglamento oficial. Cada fila indica cuántos puntos suma ese acierto.</p>}
        />
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
