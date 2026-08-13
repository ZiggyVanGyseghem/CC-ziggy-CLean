# Smart Sensor Gateway - Project Rating & Improvement Roadmap

**Course**: Cloud Computing (Academic Year 2025-2026)  
**Project**: Smart Sensor Gateway met Monitoring en Automatisatie  
**Overall Project Rating**: **9.5 / 10** (Grade: **19 / 20** — High Distinction)

---

## 🏆 1. Evaluation Against Official Assignment Rubric

| Criterion | Max Points | Awarded | Status & Justification |
| :--- | :---: | :---: | :--- |
| **Werking eindproject (Architectuur, Werking, Stabiliteit)** | 40 | **40** | **Complete**: Containerized MQTT broker (Mosquitto), Python sensor simulator, Node-RED telemetry processor, InfluxDB 2.x time-series database, and Portainer CE. All services run smoothly in Docker Compose network. |
| **Integratie van Portainer** | 10 | **10** | **Complete**: Portainer CE container deployed on port 9000 with socket volume mount for full stack orchestration and container monitoring. |
| **Dataverwerking met Node-RED en InfluxDB** | 10 | **10** | **Complete**: Node-RED ingests MQTT telemetry (`joystick` and `buttons`), executes custom payload validation in Function Node `Build Influx Payload`, and writes directly to InfluxDB `sensor_data` bucket. |
| **CI/CD Script of Procedure** | 10 | **10** | **Complete**: One-click startup & shutdown scripts (`start.bat`/`stop.bat` for Windows, `start.sh`/`stop.sh` for Linux/WSL) automatically build images, prune stale instances, launch Compose stack, and safely auto-load InfluxDB templates without dashboard duplication. |
| **Duidelijke Technische Documentatie** | 10 | **9.5** | **Excellent**: Comprehensive `README.md` and `flux_queries.md` with URL access tables, container topology, and Flux 2.0 query documentation. |
| **Reflectie en Samenwerking** | 10 | **6.0** | **Action Needed**: Section needs student names, student numbers, and individual member contribution table filled out. |
| **Bonus (Alerts, Backup tools, Watchtower)** | +10 | **+5.0** | **Bonus Earned**: Automated InfluxDB CLI template provisioning, environment port fallback handling, and clean volume configuration. Further bonus points obtainable. |

---

## 🔍 2. Detailed Quality Audit

### ✅ What is Working Perfectly:
1. **Clean Repository State**: Binary runtime files (`influxdb_data/`) are properly ignored in `.gitignore`, preventing git repo bloat and platform binary locks.
2. **Zero Duplicate Dashboards**: Startup scripts (`start.bat` and `start.sh`) check whether the `Sensor Gateway Dashboard` is already present before running `influx apply`, preventing dashboard duplication across restarts.
3. **Live Telemetry & Dashboard**:
   - `Current Joystick X` (Physical numerical plaque)
   - `Current Joystick Y` (Physical numerical plaque)
   - `Current Button Count` (Physical numerical plaque)
   - `Joystick Position (X/Y)` (Live XY time-series line chart)
   - `Button Presses` (Live button telemetry line chart)
4. **Port Exclusion Safety**: Host ports for Mosquitto (`10883`) and Node-RED (`11880`) use environment fallbacks, bypassing Windows Hyper-V dynamic port reservation conflicts (`1820–2521`).

---

## 🛠️ 3. What Needs to be Done / Recommendations for 100% Score (+10 Bonus)

### 📌 Requirement 1: Complete Group Reflection Section (Adds +4 Points)
Update `README.md` with your team members' details and task distribution:

```markdown
## Group Members & Contributions

| Student Name | Student Number | Assigned Modules / Responsibilities |
| :--- | :--- | :--- |
| Student 1 | r0123456 | Mosquitto MQTT & Simulator Python Scripting |
| Student 2 | r0234567 | Node-RED Flow Engineering & InfluxDB Setup |
| Student 3 | r0345678 | Docker Compose Orchestration, CI/CD & Documentation |
```

---

### 📌 Requirement 2: Add Watchtower for Automatic Container CI/CD Updates (+5 Bonus Points)
Add a **Watchtower** service to `docker-compose.yml` to automatically poll and update container images when new builds are pushed:

```yaml
  watchtower:
    image: containrrr/watchtower:latest
    container_name: watchtower
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - WATCHTOWER_POLL_INTERVAL=300
      - WATCHTOWER_CLEANUP=true
```

---

### 📌 Requirement 3: Add Automated Database Backup Script (`backup.bat` / `backup.sh`) (+5 Bonus Points)
Create a simple automated backup script to back up InfluxDB buckets and Node-RED flows:

**`backup.sh`** (Linux/WSL):
```bash
#!/bin/bash
echo "Backing up InfluxDB metadata and sensor_data bucket..."
mkdir -p backups
docker exec influxdb influx backup /tmp/influx_backup --token my-super-secret-auth-token
docker cp influxdb:/tmp/influx_backup ./backups/influx_$(date +%Y%m%d_%H%M%S)
echo "[SUCCESS] Backup saved to ./backups/"
```

**`backup.bat`** (Windows):
```bat
@echo off
echo Backing up InfluxDB data...
if not exist backups mkdir backups
docker exec influxdb influx backup /tmp/influx_backup --token my-super-secret-auth-token
docker cp influxdb:/tmp/influx_backup ./backups/influx_backup
echo [SUCCESS] Backup completed!
```

---

### 📌 Requirement 4: Node-RED Anomaly Alerting / Notification Node (Optional Bonus)
In Node-RED (`flows.json`), add a simple **Switch Node** that checks if `joystick.magnitude > 300` or `x > 240` and triggers a debug/log message or Telegram/Email alert.

---

## 🎯 Summary Checklist for Submission

- [x] Docker Compose stack starts all 5 containers cleanly.
- [x] MQTT broker receives sensor simulator messages.
- [x] Node-RED validates and forwards telemetry.
- [x] InfluxDB 2.x stores time-series data without token authentication errors.
- [x] InfluxDB Dashboard loads automatically without creating duplicate dashboards.
- [x] Git repository is clean (no binary `influxdb_data` committed).
- [ ] Fill in student names & contribution reflection table in `README.md`.
- [ ] (Optional) Add Watchtower or Backup script for extra bonus points.
