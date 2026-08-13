#!/bin/bash
# ==============================================================================
# Edge Gateway Automated Backup Script (Linux & WSL)
# ==============================================================================

set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/backup_${TIMESTAMP}"

echo "============================================="
echo "Edge Gateway Backup Script"
echo "============================================="

echo "[1/3] Creating backup destination folder: ${BACKUP_DIR}"
mkdir -p "${BACKUP_DIR}"

echo "[2/3] Backing up InfluxDB time-series database..."
if docker exec influxdb influx backup /tmp/influx_backup --token my-super-secret-auth-token >/dev/null 2>&1; then
    docker cp influxdb:/tmp/influx_backup "${BACKUP_DIR}/influxdb_data"
    docker exec influxdb rm -rf /tmp/influx_backup
    echo "[OK] InfluxDB data backed up."
else
    echo "[WARNING] InfluxDB container not running or backup failed."
fi

echo "[3/3] Backing up Node-RED flows and config..."
if [ -d "nodered_data" ]; then
    mkdir -p "${BACKUP_DIR}/nodered_config"
    cp nodered_data/flows.json "${BACKUP_DIR}/nodered_config/" 2>/dev/null || true
    cp nodered_data/flows_cred.json "${BACKUP_DIR}/nodered_config/" 2>/dev/null || true
    cp nodered_data/settings.js "${BACKUP_DIR}/nodered_config/" 2>/dev/null || true
    echo "[OK] Node-RED configurations backed up."
fi

echo "============================================="
echo "[SUCCESS] Backup stored at: ${BACKUP_DIR}"
echo "============================================="
