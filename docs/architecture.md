# Arquitectura MVP

## Stack

- Backend: Node.js + Express + TypeScript + JWT.
- Frontend: React + Vite + React Router.
- DB: PostgreSQL.
- Sync: `node-cron` + API-Football.

## Flujo principal

1. El backend sincroniza datos de equipos, fixtures y standings desde API-Football.
2. Los datos se guardan localmente en PostgreSQL para minimizar llamadas externas.
3. Usuarios autenticados crean predicciones antes del inicio de cada partido.
4. Al cerrar partidos, el servicio de scoring calcula puntos de forma idempotente.
5. El leaderboard se genera agregando `prediction_scores`.

## Seguridad

- Password hashing con `bcrypt`.
- JWT firmado con `JWT_SECRET`.
- Middleware por rol para endpoints de administración.
- API key de proveedor solo en backend.
