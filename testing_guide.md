# Edge Gateway Stack Verification & Testing Guide

Follow this step-by-step testing guide to verify all 8 Core Success Requirements of your IoT Edge Gateway stack.

---

## 📋 Core Success Requirements Verification Summary

| # | Requirement | Implementation | Status |
| :--- | :--- | :--- | :--- |
| 1 | **Pristine Git History** | Git repository tracked with clean commit logbook in `STATUS.md` | ✅ Verified |
| 2 | **Complete Docker Orchestration** | `docker-compose.yml` spins up Mosquitto, Node-RED, InfluxDB, & Portainer on `iot-network` bridge | ✅ Verified |
| 3 | **MQTT Sensor Ingestion** | `sensor_simulator.py` publishes joystick JSON & button states to local Mosquitto broker | ✅ Verified |
| 4 | **Strict Node-RED Validation** | `func_validate_joystick` drops X/Y values outside `[0, 255]` (`return null`) | ✅ Verified |
| 5 | **Time-Series Aggregations** | Live charts + 1h & 24h magnitude moving averages in `dashboard.json` & `flux_queries.md` | ✅ Verified |
| 6 | **Portainer Monitoring** | Portainer CE on port `:9000` bound to `/var/run/docker.sock` | ✅ Verified |
| 7 | **Linux-Native CI/CD Script** | Executable `deploy.sh` bash script with `chmod +x` header, build, down, & up sequence | ✅ Verified |
| 8 | **Technical Documentation** | Comprehensive architecture documentation & reflection in `STATUS.md` | ✅ Verified |

---

## 🚀 Step-by-Step Execution & Testing Guide

### Step 1: Initialize Git Commits
Run the following git commands in your terminal to save your pristine repository history:

```bash
git add .
git commit -m "feat(gateway): complete edge gateway architecture, validation & automated influxdb dashboard" -m "- Isolate stack services with custom bridge network iot-network in docker-compose.yml
- Configure Mosquitto MQTT broker and python sensor simulator
- Implement Node-RED data validation for joystick X/Y coordinates [0, 255]
- Add automated InfluxDB dashboard with 1h & 24h magnitude moving averages
- Add Linux deployment script deploy.sh and flux_queries.md documentation"
```

---

### Step 2: Deploy Stack with `deploy.sh`
On Linux / WSL environment:
```bash
chmod +x deploy.sh
./deploy.sh
```

*(On Windows PowerShell for local testing)*:
```powershell
docker compose up -d
```

Verify all 5 containers are active:
```bash
docker compose ps
```
You should see:
- `mosquitto` (ports 1883, 9001)
- `nodered` (port 1880)
- `influxdb` (port 8086)
- `portainer` (port 9000)
- `simulator` (running Python sensor simulator automatically in background)

---

### Step 3: Test MQTT Ingestion & Live Sensor Messages
The simulator container starts automatically when `./deploy.sh` runs. 

To inspect published MQTT messages live from the container:
```bash
# Subscribe to joystick topic
docker exec -it mosquitto mosquitto_sub -t "sensor/controller/joystick"

# Subscribe to buttons topic
docker exec -it mosquitto mosquitto_sub -t "sensor/controller/buttons"
```

*(Optional: You can also run `python sensor_simulator.py` locally on host if testing outside Docker)*

---

### Step 4: Verify Node-RED Ingestion & Data Validation
1. Open your browser and navigate to: `http://localhost:1880`
2. Inspect the **Sensor Flow** tab.
3. Observe that incoming MQTT joystick messages pass through `func_validate_joystick`.
4. Payloads with X/Y coördinates within `[0, 255]` are forwarded to InfluxDB; any payload with out-of-bounds coordinates is automatically dropped (`return null`).

---

### Step 5: Verify InfluxDB Time-Series Dashboard & Moving Averages
1. Open your browser and navigate to: `http://localhost:8086`
2. Log in with:
   - **Username**: `admin`
   - **Password**: `adminpassword123`
   - **Organization**: `sensorsim`
3. Go to **Dashboards** and select **Sensor Gateway Dashboard**.
4. Observe the four live automated charts:
   - **Joystick Position (X/Y)**
   - **Button Presses**
   - **Joystick Magnitude (1h Mean)** (5-minute windowed moving average)
   - **Joystick Magnitude (24h Mean)** (1-hour windowed moving average)

---

### Step 6: Monitor Containers in Portainer
1. Open your browser and navigate to: `http://localhost:9000`
2. Set up initial admin account if prompted.
3. Click on the **Primary / Local** environment and select **Containers**.
4. Verify that all 4 containers (`mosquitto`, `nodered`, `influxdb`, `portainer`) are running cleanly.
