# Docker

## Preparación

1. Copiar `.env.docker.example` a `.env`.
2. Completar `API_FOOTBALL_KEY` y demás variables.

## Comandos

- Producción / integrado (nginx + build):
  - `docker compose up --build`
- **Desarrollo con hot reload** (recomendado al programar):
  - `npm run dev:docker`
  - o `docker compose -f docker-compose.dev.yml up --build`
- Dev **sin Docker** (solo Node en tu máquina):
  - `docker compose -f docker-compose.dev.yml up -d postgres` (solo DB)
  - `npm run dev` (backend `tsx watch` + frontend Vite HMR)
- Solo DB:
  - `docker compose up -d postgres`
- Reset total:
  - `docker compose down -v`

## Puertos

| Modo | Frontend | Backend | DB |
|------|----------|---------|-----|
| Producción | http://localhost:8080 | http://localhost:4000 | 5432 |
| Dev (hot reload) | http://localhost:5173 | http://localhost:4000 | 5432 |

En dev, los cambios en `backend/src` y `frontend/src` se recargan solos (sin reconstruir imagen).

## Pruebas en la red local (varios dispositivos)

1. Obtén la IP de tu PC en la Wi‑Fi: `hostname -I` (la primera suele ser `192.168.x.x`).
2. En `.env`, añade esa IP a CORS y (opcional) HMR:
   ```env
   CORS_ORIGIN=http://localhost:5173,http://192.168.1.50:5173
   VITE_HMR_HOST=192.168.1.50
   ```
3. Reinicia: `docker compose up --build`
4. Comparte con los testers: **http://192.168.1.50:5173** (no uses `localhost` en el celular de otro).
5. Misma red Wi‑Fi; si no carga, abre el firewall: `sudo ufw allow 5173/tcp` (y `4000` si acceden directo a la API).

Con Docker dev, `VITE_API_URL=/api` hace que el navegador llame a la API por el mismo host (tu IP:5173), así que no hace falta exponer el puerto 4000 a los testers.

## Hot reload

- **Backend:** `tsx watch src/server.ts` reinicia la API al guardar archivos `.ts`.
- **Frontend:** Vite HMR actualiza React al instante en el navegador.
- **Docker:** monta el código con volúmenes; `CHOKIDAR_USEPOLLING=true` detecta cambios dentro del contenedor.

Variables útiles en `.env` para dev local:

```env
CORS_ORIGIN=http://localhost:5173
DATABASE_URL=postgresql://polla:polla_secret@localhost:5432/polla_futbolera
VITE_API_URL=http://localhost:4000
```

## Arranque backend

El contenedor backend ejecuta:

1. `node dist/scripts/migrate.js`
2. `node dist/server.js`

Esto garantiza esquema actualizado antes de iniciar la API.
