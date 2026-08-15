#!/bin/bash
# ==============================================================================
# Edge Gateway Deployment / Startup Script (Linux & WSL)
# ==============================================================================

set -e

echo "============================================="
echo "Checking Docker status..."
echo "============================================="
if ! docker info >/dev/null 2>&1; then
    echo "[ERROR] Docker is not running or current user lacks permissions."
    echo "Please ensure Docker is started (e.g. 'sudo systemctl start docker' or start Docker Desktop on WSL)."
    exit 1
fi
echo "[OK] Docker is running."

echo "============================================="
echo "Building container images..."
echo "============================================="
docker compose build

echo "============================================="
echo "Stopping existing containers..."
echo "============================================="
docker compose down

echo "============================================="
echo "Starting Edge Gateway stack in detached mode..."
echo "============================================="
docker compose up -d

echo "============================================="
if docker exec influxdb influx dashboards --org sensorsim --token my-super-secret-auth-token 2>/dev/null | grep -q "Sensor Gateway Dashboard"; then
    echo "Sensor Gateway Dashboard is already loaded."
else
    echo "Auto-importing Sensor Gateway Dashboard into InfluxDB..."
    sleep 4
    docker exec influxdb influx apply -f /docker-entrypoint-initdb.d/template.yml \
      --org sensorsim \
      --token my-super-secret-auth-token \
      --force yes >/dev/null 2>&1 || true
fi

echo "============================================="
echo "[SUCCESS] Deployment successful! Active containers:"
echo "============================================="
docker compose ps

echo ""
echo "Accessible Web Dashboards & Services:"
echo "  - Node-RED Flow Editor:    http://localhost:3880"
echo "  - InfluxDB Dashboard:      http://localhost:8086"
echo "  - Portainer Management:    http://localhost:9000"
echo "  - Watchtower CD Monitor:   Active (Automated Docker Updates)"
echo "  - MQTT Broker Port:        localhost:1883"
echo ""
echo "To stop the stack at any time, run './stop.sh', 'make down', or 'docker compose down'."

