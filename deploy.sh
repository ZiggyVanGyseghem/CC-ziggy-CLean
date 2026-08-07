#!/bin/bash
# Reminder: Run 'chmod +x deploy.sh' to make this script executable on Linux.
# ==============================================================================
# Edge Gateway Deployment Script (Linux Target)
# ==============================================================================

set -e

echo "============================================="
echo "Building / Pulling container images..."
echo "============================================="
docker compose build --pull

echo "============================================="
echo "Stopping existing containers..."
echo "============================================="
docker compose down

echo "============================================="
echo "Starting Edge Gateway stack in detached mode..."
echo "============================================="
docker compose up -d

echo "============================================="
echo "Deployment successful! Active containers:"
echo "============================================="
docker compose ps
