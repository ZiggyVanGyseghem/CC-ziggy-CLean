#!/bin/bash
set -e

echo "============================================="
echo "InfluxDB Auto-Importing Sensor Gateway Dashboard Template..."
echo "============================================="

sleep 2

influx apply -f /docker-entrypoint-initdb.d/template.yml \
  --org "$DOCKER_INFLUXDB_INIT_ORG" \
  --token "$DOCKER_INFLUXDB_INIT_ADMIN_TOKEN" \
  --force yes || true

echo "Dashboard import complete."
