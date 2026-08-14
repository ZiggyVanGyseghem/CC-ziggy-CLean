# Smart Sensor Gateway - Edge Gateway IoT Stack

**Course**: Cloud Computing (Academic Year 2025-2026)  
**Project**: Smart Sensor Gateway with Monitoring and Automation  
**Author**: Ziggy Van Gyseghem  
**Degree**: Bachelor Electronics-ICT / Bio & Technology  

---

## 1. Project Context & Objectives

In modern industrial Internet of Things (IoT) deployments, edge systems are required to collect, process, validate, store, and visualize field sensor data locally before forwarding or presenting telemetry to central management infrastructure.

This repository implements a fully containerized, production-grade **Edge Sensor Gateway Stack**. The architecture receives real-time telemetry from simulated field sensors via MQTT, processes and validates payload integrity within Node-RED, stores high-frequency time-series measurements in InfluxDB 2.0, and visualizes live and aggregated metric statistics on customized dashboards. Container management and infrastructure health are governed via Portainer CE and Docker Compose.

---

## 2. System Architecture & Data Flow

All services run inside isolated Docker containers connected via a dedicated internal bridge network (`iot-network`).

```text
  +-------------------------------------------------------------------+
  |                      Edge Gateway Stack                           |
  |                                                                   |
  |  +---------------------+                                          |
  |  |  Python Simulator   |                                          |
  |  +----------+----------+                                          |
  |             | (MQTT JSON Telemetry over Port 1883)                |
  |             v                                                     |
  |  +----------+----------+                                          |
  |  |  Mosquitto Broker   | (Eclipse Mosquitto v2.0)                 |
  |  +----------+----------+                                          |
  |             |                                                     |
  |             v                                                     |
  |  +----------+----------+                                          |
  |  |   Node-RED Engine   | (Function Nodes: Validation & Filtering) |
  |  +----------+----------+                                          |
  |             | (Validated Influx Points)                           |
  |             v                                                     |
  |  +----------+----------+                                          |
  |  |   InfluxDB 2.7 DB   | (Bucket: sensor_data, Org: sensorsim)    |
  |  +----------+----------+                                          |
  |             |                                                     |
  |             +--------------------------+                          |
  |             v                          v                          |
  |    [ InfluxDB Dashboard ]     [ Portainer CE Manager ]            |
  |    (Live + 1h/24h Means)      (Container Status & Logs)          |
  +-------------------------------------------------------------------+
```

---

## 3. Service Topology & Network Specifications

The stack is composed of 5 core container services (with optional Watchtower continuous deployment integration) defined in `docker-compose.yml`:

| Service Name | Container Name | Host Port | Container Port | Purpose / Role | Persistent Volumes / Mounts |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Mosquitto** | `mosquitto` | `10883`, `9001` | `1883`, `9001` | Local MQTT Telemetry Broker | `./mosquitto/config`, `./mosquitto/data`, `./mosquitto/log` |
| **Node-RED** | `nodered` | `11880` | `1880` | Data Ingestion, Range Validation & Filtering | `./nodered_data` |
| **Simulator** | `simulator` | Internal | N/A | Automated Field Sensor Generator (Python) | Built from `./simulator` |
| **InfluxDB** | `influxdb` | `8086` | `8086` | Time-Series Database (InfluxDB v2.7) | `influxdb_data`, `./influxdb_setup` |
| **Portainer** | `portainer` | `9000` | `9000` | Real-time Container Management UI | `/var/run/docker.sock`, `portainer_data` |

---

## 4. Deep-Dive Component Specifications

### 4.1 Sensor Communication (MQTT Broker & Simulator)
* **Broker**: Eclipse Mosquitto v2.0 running anonymously on internal container port `1883`. Host access is mapped to port `10883` to prevent Hyper-V dynamic port reservation conflicts on Windows systems.
* **Active Topics**:
  1. `sensor/controller/joystick`: Publishes structured JSON objects containing X-axis coordinate (`x`), Y-axis coordinate (`y`), and calculated vector magnitude (`magnitude`).
  2. `sensor/controller/buttons`: Publishes plain integer telemetry representing active pressed button counts (`0` to `6`).
* **Simulator Logic**: Written in Python (`simulator/sensor_simulator.py`) using `paho-mqtt`. Generates random integer coordinate sets at 5-second intervals.

### 4.2 Telemetry Ingestion & Data Validation (Node-RED)
Node-RED ingests MQTT payloads and executes strict validation logic inside custom Function Nodes before data reaches the database:
* **Joystick Validation (`Build Influx Payload`)**:
  * Parses JSON payload cleanly with exception handling.
  * Validates coordinate boundaries ($0 \le x, y \le 255$).
  * Recalculates mathematical magnitude ($\sqrt{x^2 + y^2}$) for integrity verification.
  * Drops invalid or corrupt payloads (`return null;`) and logs warning events (`node.warn`).
* **Button Validation (`Validate Buttons Payload`)**:
  * Parses incoming string data to integer values.
  * Enforces press count constraints ($0 \le \text{count} \le 6$).
  * Filters out invalid payloads before database write operations.

### 4.3 Time-Series Storage & Dashboards (InfluxDB 2.0)
* **Database**: InfluxDB 2.7 configured with initial bucket `sensor_data` under organization `sensorsim`.
* **Automated Provisioning**: Startup scripts automatically apply `influxdb_setup/template.yml` upon initialization, preventing duplicate dashboard creation across restarts.
* **Dashboard Elements**:
  * **Current Joystick X**: Live numerical single-stat plaque.
  * **Current Joystick Y**: Live numerical single-stat plaque.
  * **Current Button Count**: Live numerical single-stat plaque.
  * **Joystick Position (X/Y)**: Real-time time-series line chart tracking position over time.
  * **Button Presses**: Real-time time-series line chart tracking button count entries.
  * **Joystick Magnitude (1-Hour Average)**: Single-stat panel displaying mean magnitude aggregated over a 1-hour window (`range(start: -1h)`).
  * **Joystick Magnitude (24-Hour Average)**: Single-stat panel displaying mean magnitude aggregated over a 24-hour window (`range(start: -24h)`).
  * **Button Count (1-Hour Average)**: Single-stat panel displaying mean press count aggregated over 1 hour.
  * **Button Count (24-Hour Average)**: Single-stat panel displaying mean press count aggregated over 24 hours.

### 4.4 Container Orchestration & Security
* **Docker Compose**: Entire stack orchestrated via `docker-compose.yml`.
* **Network Isolation**: All services communicate over an isolated custom bridge network named `iot-network`.
* **Service Healthchecks**: Automated healthchecks verify Mosquitto TCP listener availability and InfluxDB `/ping` endpoint status.

---

## 5. Operations & Usage Guide

### Prerequisites
* **Docker Engine** v20.10+ or **Docker Desktop** (Windows/Linux/WSL2).

---

### Startup Procedure (Windows)
Double-click `start.bat` in Windows Explorer or run from CMD:
```cmd
start.bat
```
* **Actions Performed**:
  1. Checks if Docker Desktop daemon is active.
  2. Builds updated container images (`docker compose build`).
  3. Teardowns legacy container instances (`docker compose down`).
  4. Launches the stack in background mode (`docker compose up -d`).
  5. Auto-applies the InfluxDB dashboard template if not already imported.

---

### Startup Procedure (Linux / WSL)
Execute the shell script:
```bash
chmod +x start.sh stop.sh backup.sh
./start.sh
```

---

### Shutdown Procedure
* **Windows**: Double-click `stop.bat`
* **Linux/WSL**: Run `./stop.sh`

---

### Backup Procedure
To create timestamped archives of Node-RED flows and InfluxDB time-series data:
* **Windows**: Double-click `backup.bat`
* **Linux/WSL**: Run `./backup.sh`
* Output files are stored in the `./backups/` directory.

---

## 6. Access Endpoints & URLs

Once the stack is started, access web management interfaces directly in your browser:

| Interface | URL | Credentials / Notes |
| :--- | :--- | :--- |
| **Node-RED Flow Editor** | [http://localhost:1880](http://localhost:1880) | Visual flow canvas & debug panel |
| **InfluxDB Dashboard** | [http://localhost:8086](http://localhost:8086) | **User**: `admin`<br>**Password**: `adminpassword123`<br>**Org**: `sensorsim` |
| **Portainer CE** | [http://localhost:9000](http://localhost:9000) | Container management & service logging |
| **Mosquitto Broker** | `localhost:10883` / `1883` | Active MQTT broker port |

---

## 7. Verification & Testing Matrix

| Test Case | Description | Command / Procedure | Expected Result |
| :--- | :--- | :--- | :--- |
| **MQTT Telemetry** | Verify active sensor message publishing | `docker exec -it mosquitto mosquitto_sub -t "sensor/#" -v` | Continuous JSON messages on joystick and buttons topics |
| **Payload Filtering** | Test invalid sensor payload drop | `docker exec -it mosquitto mosquitto_pub -t "sensor/controller/joystick" -m '{"x": 999, "y": 50}'` | Node-RED debug logs warning; message is dropped and NOT written to InfluxDB |
| **Container Status** | Verify service health & bridge network | `docker compose ps` | All containers reported as `Up (healthy)` |
| **Backup Integrity** | Test automated backup snapshot | Execute `backup.bat` or `./backup.sh` | Timestamped zip/tar file created in `./backups/` |

---

## 8. Repository File Index

* `docker-compose.yml`: Main container stack orchestration file.
* `start.bat` / `start.sh`: Primary automated startup & deployment scripts.
* `stop.bat` / `stop.sh`: Graceful shutdown scripts.
* `backup.bat` / `backup.sh`: Data & configuration backup utilities.
* `testing_guide.md`: Step-by-step evaluation & verification guide.
* `REFLECTION.md`: Individual student contribution & project reflection report.
* `nodered_data/flows.json`: Node-RED flow configuration and function nodes.
* `influxdb_setup/template.yml`: Automated InfluxDB dashboard provisioning template.
