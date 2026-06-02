#!/bin/sh
set -e

echo "Installing backend dependencies..."
npm install

echo "Running migrations..."
npm run migrate

echo "Starting backend with hot reload (tsx watch)..."
exec npm run dev
