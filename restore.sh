#!/bin/bash
# ==============================================================================
# Edge Gateway Automated Restore Script (Linux & WSL)
# ==============================================================================

set -e

echo "============================================="
echo "Edge Gateway Restore Script"
echo "============================================="

if ! docker info >/dev/null 2>&1; then
    echo "[ERROR] Docker daemon is not active. Please start Docker."
    exit 1
fi

# Auto-start containers if currently stopped
if ! docker compose ps --services --filter "status=running" 2>/dev/null | grep -q "influxdb"; then
    echo "[INFO] Stack is not currently running. Starting containers..."
    docker compose up -d
    sleep 4
fi

if [ ! -d "backups" ]; then
    echo "[ERROR] No backups directory found. Run './backup.sh' first."
    exit 1
fi

LATEST_BACKUP=$(ls -td backups/backup_* 2>/dev/null | head -n 1)

if [ -z "${LATEST_BACKUP}" ]; then
    echo "[ERROR] No backup folders found in ./backups/"
    exit 1
fi

echo "Selected backup folder: ${LATEST_BACKUP}"

# Step 1: Restore InfluxDB Time-Series Data & Simulator Telemetry Points
if [ -d "${LATEST_BACKUP}/influxdb_data" ]; then
    echo "[1/2] Restoring InfluxDB time-series database & simulator metrics..."
    docker cp "${LATEST_BACKUP}/influxdb_data" influxdb:/tmp/influx_restore
    docker exec influxdb influx restore --full --token my-super-secret-auth-token /tmp/influx_restore || \
    docker exec influxdb influx restore --token my-super-secret-auth-token /tmp/influx_restore || true
    docker exec influxdb rm -rf /tmp/influx_restore
    docker compose restart influxdb
    echo "[OK] InfluxDB data restored successfully."
fi

# Step 2: Restore Node-RED Configurations & Flows
if [ -d "${LATEST_BACKUP}/nodered_config" ]; then
    echo "[2/2] Restoring Node-RED flow configurations..."
    mkdir -p nodered_data
    cp "${LATEST_BACKUP}/nodered_config/flows.json" nodered_data/ 2>/dev/null || true
    cp "${LATEST_BACKUP}/nodered_config/flows_cred.json" nodered_data/ 2>/dev/null || true
    cp "${LATEST_BACKUP}/nodered_config/settings.js" nodered_data/ 2>/dev/null || true
    docker compose restart nodered
    echo "[OK] Node-RED configurations restored successfully."
fi

echo "============================================="
echo "[SUCCESS] Restore completed from ${LATEST_BACKUP}"
echo "============================================="
