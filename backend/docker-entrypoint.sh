#!/bin/sh
set -e

echo "Running migrations..."
node dist/scripts/migrate.js

echo "Running seed..."
node dist/scripts/seed.js

echo "Starting backend..."
exec node dist/server.js
