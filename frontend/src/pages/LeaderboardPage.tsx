import { useEffect, useState } from "react";
import { api } from "../lib/api";
import { getUser } from "../lib/auth";
import { Modal } from "../components/Modal";
import { PageTitle } from "../components/InfoModal";
import { UserPointsDetail } from "../components/UserPointsDetail";

interface LeaderRow {
  user_id: number;
  email: string;
  display_name?: string | null;
  amount_paid?: number;
  total_points: number;
}

interface ViewPlayer {
  userId: number;
  name: string;
}

const fmt = new Intl.NumberFormat("es-CO", {
  style: "currency",
  currency: "COP",
  maximumFractionDigits: 0
});

function playerName(row: LeaderRow): string {
  const name = row.display_name?.trim();
  return name || row.email;
}

function rankClass(index: number): string {
  if (index === 0) return " leaderboard-rank--gold";
  if (index === 1) return " leaderboard-rank--silver";
  if (index === 2) return " leaderboard-rank--bronze";
  return "";
}

export function LeaderboardPage() {
  const [rows, setRows] = useState<LeaderRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [viewPlayer, setViewPlayer] = useState<ViewPlayer | null>(null);
  const me = getUser();

  useEffect(() => {
    api<LeaderRow[]>("/leaderboard")
      .then(setRows)
      .catch(() => setRows([]))
      .finally(() => setLoading(false));
  }, []);

  const totalRecaudo = rows.reduce((sum, r) => sum + Number(r.amount_paid ?? 0), 0);
  const premio = totalRecaudo * 0.7;
  const primero = premio * 0.5;
  const segundo = premio * 0.3;
  const tercero = premio * 0.2;

  return (
    <>
      <PageTitle helpTitle="Cómo funciona el ranking" help={
        <>
          <p>
            Tabla general por puntos acumulados. En empate se desempata por: marcadores exactos, clasificados
            acertados, equipos que avanzaron en eliminatorias y puntos en semifinal y final.
          </p>
          <p>
            Pulsa <strong>Ver</strong> en cualquier jugador para ver partido a partido cómo sumó sus puntos.
          </p>
        </>
      }>
        Ranking
      </PageTitle>

      {!loading && premio > 0 && (
        <section className="prize-pool" aria-label="Premios del torneo">
          <article className="prize-card prize-card--pool">
            <div className="prize-card-icon prize-card-icon--pool" aria-hidden>
              <svg
                viewBox="0 0 24 24"
                width="22"
                height="22"
                fill="none"
                stroke="currentColor"
                strokeWidth={1.75}
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <path d="M7 4h10v5a5 5 0 0 1-10 0V4Z" />
                <path d="M17 5h2.5a1 1 0 0 1 1 1v1a3 3 0 0 1-3 3M7 5H4.5a1 1 0 0 0-1 1v1a3 3 0 0 0 3 3" />
                <path d="M9.4 14.3 9 18h6l-.4-3.7M8 21h8M12 18v3" />
              </svg>
            </div>
            <div className="prize-card-content">
              <p className="prize-card-eyebrow">Bote a repartir</p>
              <p className="prize-card-amount prize-card-amount--pool">{fmt.format(premio)}</p>
            </div>
          </article>

          <div className="prize-podium">
            <article className="prize-card prize-card--place prize-card--gold">
              <div className="prize-card-icon prize-card-icon--gold" aria-hidden>
                <span>1</span>
              </div>
              <div className="prize-card-content">
                <p className="prize-card-eyebrow">Primer lugar</p>
                <p className="prize-card-amount">{fmt.format(primero)}</p>
                <span className="prize-card-chip">50% del bote</span>
              </div>
            </article>

            <article className="prize-card prize-card--place prize-card--silver">
              <div className="prize-card-icon prize-card-icon--silver" aria-hidden>
                <span>2</span>
              </div>
              <div className="prize-card-content">
                <p className="prize-card-eyebrow">Segundo lugar</p>
                <p className="prize-card-amount">{fmt.format(segundo)}</p>
                <span className="prize-card-chip">30% del bote</span>
              </div>
            </article>

            <article className="prize-card prize-card--place prize-card--bronze">
              <div className="prize-card-icon prize-card-icon--bronze" aria-hidden>
                <span>3</span>
              </div>
              <div className="prize-card-content">
                <p className="prize-card-eyebrow">Tercer lugar</p>
                <p className="prize-card-amount">{fmt.format(tercero)}</p>
                <span className="prize-card-chip">20% del bote</span>
              </div>
            </article>
          </div>
        </section>
      )}

      <div className="panel-card leaderboard-panel">
        {loading ? (
          <div className="empty-state">
            <strong>Cargando…</strong>
          </div>
        ) : rows.length === 0 ? (
          <div className="empty-state">
            <strong>Sin puntuaciones aún</strong>
          </div>
        ) : (
          <>
            <div className="leaderboard-head" aria-hidden="true">
              <span className="leaderboard-head-pos">Pos.</span>
              <span>Jugador</span>
              <span className="leaderboard-head-pts">Puntos</span>
              <span />
            </div>
            <ol className="leaderboard-list">
            {rows.map((row, index) => {
              const name = playerName(row);
              const isMe = Number(row.user_id) === me?.id;
              return (
                <li
                  key={row.user_id}
                  className={`leaderboard-row${isMe ? " leaderboard-row--me" : ""}`}
                >
                  <span className={`leaderboard-rank${rankClass(index)}`}>{index + 1}</span>
                  <span className="leaderboard-name">
                    {name}
                    {isMe && <span className="leaderboard-you">Tú</span>}
                  </span>
                  <span className="leaderboard-points">{row.total_points}</span>
                  <button
                    type="button"
                    className="btn-ghost leaderboard-view-btn"
                    onClick={() => setViewPlayer({ userId: row.user_id, name })}
                  >
                    Ver
                  </button>
                </li>
              );
            })}
            </ol>
          </>
        )}
      </div>

      <Modal
        title={viewPlayer ? `Puntos de ${viewPlayer.name}` : ""}
        open={viewPlayer != null}
        onClose={() => setViewPlayer(null)}
        wide
      >
        {viewPlayer && <UserPointsDetail userId={viewPlayer.userId} compact />}
      </Modal>
    </>
  );
}
