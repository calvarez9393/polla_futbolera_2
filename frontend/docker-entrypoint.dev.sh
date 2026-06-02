#!/bin/sh
set -e

echo "Installing frontend dependencies..."
npm install

echo "Starting Vite dev server with HMR..."
exec npm run dev -- --host 0.0.0.0 --port 5173
