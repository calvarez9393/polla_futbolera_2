# Polla Futbolera

Aplicación web full-stack para registrar usuarios, crear predicciones de fútbol, sincronizar datos reales desde API-Football y calcular puntajes automáticamente.

## Requisitos

- Node.js 22+
- Docker + Docker Compose

## Inicio rápido

1. Copiar variables:
   - `cp .env.example .env` (modo local)
   - o `cp .env.docker.example .env` (modo Docker)
2. Instalar dependencias:
   - `npm install`
3. Levantar PostgreSQL:
   - `docker compose up -d postgres`
4. Migrar y seed:
   - `npm --workspace backend run migrate`
   - `npm --workspace backend run seed`
5. Ejecutar apps con **hot reload**:
   - `npm run dev` → http://localhost:5173 (frontend) + http://localhost:4000 (API)

## Desarrollo con hot reload (Docker)

```bash
cp .env.docker.example .env   # DATABASE_URL con host postgres
docker compose down           # si antes usabas el stack de producción (:8080)
docker compose up --build
```

- Frontend: **http://localhost:5173** (Vite HMR — no uses :8080 en desarrollo)
- Backend: http://localhost:4000 (`tsx watch`)

Atajo: `npm run dev:docker`

## Docker producción local (sin hot reload)

- `docker compose -f docker-compose.prod.yml up --build` → http://localhost:8080

## Endpoints principales

- `POST /auth/register`
- `POST /auth/login`
- `GET /matches`
- `GET /standings`
- `POST /predictions`
- `GET /leaderboard`
- `POST /admin/sync-api`

## Scripts útiles

- Backend tests: `npm --workspace backend test`
- Build: `npm run build`
- **Carga demo (5 usuarios + predicciones J1–J3, sin resultados):** `npm --workspace backend run seed:demo-round1`  
  Login numérico: `900001` … `900005` / `pollademo` — tú cargas resultados en Admin.  
  `--matchday 1` solo una jornada; `--finalize` opcional para puntuar automático.
