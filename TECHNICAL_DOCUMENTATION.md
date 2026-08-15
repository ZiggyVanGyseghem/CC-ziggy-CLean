# Edge Gateway IoT Stack - Technical Documentation

**Course**: Cloud Computing (Academic Year 2025-2026)  
**Project**: Smart Sensor Gateway with Monitoring and Automation  
**Author**: Ziggy Van Gyseghem  
**Degree**: Bachelor Electronics-ICT / Technology  

---

## 1. System Architecture & Data Flow

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

## 2. Service Topology & Network Specifications

The stack is composed of 5 core container services defined in `docker-compose.yml`:

| Service Name | Container Name | Host Port | Container Port | Purpose / Role | Persistent Volumes / Mounts |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Mosquitto** | `mosquitto` | `10883`, `9001` | `1883`, `9001` | Local MQTT Telemetry Broker | `./mosquitto/config`, `./mosquitto/data`, `./mosquitto/log` |
| **Node-RED** | `nodered` | `3880` | `1880` | Data Ingestion, Range Validation & Filtering | `./nodered_data` |
| **Simulator** | `simulator` | Internal | N/A | Automated Field Sensor Generator (Python) | Built from `./simulator` |
| **InfluxDB** | `influxdb` | `8086` | `8086` | Time-Series Database (InfluxDB v2.7) | `influxdb_data`, `./influxdb_setup` |
| **Portainer** | `portainer` | `9000` | `9000` | Real-time Container Management UI | `/var/run/docker.sock`, `portainer_data` |

---

## 3. Deep-Dive Component Specifications

### 3.1 Sensor Communication (MQTT Broker & Simulator)
* **Broker**: Eclipse Mosquitto v2.0 running anonymously on internal container port `1883`. Host access is mapped to port `10883` to prevent Hyper-V dynamic port reservation conflicts on Windows systems.
* **Active Topics**:
  1. `sensor/controller/joystick`: Publishes structured JSON objects containing X-axis coordinate (`x`), Y-axis coordinate (`y`), and calculated vector magnitude (`magnitude`).
  2. `sensor/controller/buttons`: Publishes plain integer telemetry representing active pressed button counts (`0` to `6`).
* **Simulator Logic**: Written in Python (`simulator/sensor_simulator.py`) using `paho-mqtt`. Generates random integer coordinate sets at 5-second intervals.

### 3.2 Telemetry Ingestion & Data Validation (Node-RED)
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

### 3.3 Time-Series Storage & Dashboards (InfluxDB 2.0)
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

### 3.4 Container Orchestration & Security
* **Docker Compose**: Entire stack orchestrated via `docker-compose.yml`.
* **Network Isolation**: All services communicate over an isolated custom bridge network named `iot-network`.
* **Service Healthchecks**: Automated healthchecks verify Mosquitto TCP listener availability and InfluxDB `/ping` endpoint status.

---

## 4. Continuous Integration / Continuous Deployment (CI/CD)

### 4.1 Local Infrastructure Automation
The primary startup scripts (`start.sh` and `start.bat`) demonstrate the core principles of automated infrastructure management without requiring manual container configuration. Executing either script automatically runs the following deployment cycle:
1. **Container Image Build (`docker compose build`)**: Detects source code or configuration changes in custom services (`./nodered`, `./simulator`) and builds fresh service images.
2. **Legacy Stack Teardown (`docker compose down`)**: Gracefully stops and prunes older running container instances to prevent port binding locks or stale state issues.
3. **Stack Deployment (`docker compose up -d`)**: Launches the updated stack in background mode attached to the internal `iot-network` bridge.

### 4.2 Production Pipeline Automation Concept
In an enterprise cloud/edge production environment, this workflow would be fully automated using a remote CI/CD runner (such as GitHub Actions, GitLab CI, or Jenkins):
* **Automated Build (CI)**: When a developer pushes a code update to the primary Git branch, the remote pipeline triggers, builds the container images, and executes automated verification tests.
* **Image Registry Push**: Validated container images are pushed to a container registry (e.g., Docker Hub or GitHub Container Registry).
* **Automated Rollout (CD)**: The pipeline connects to edge servers via SSH or webhook triggers to execute `docker compose pull && docker compose up -d`, deploying updated infrastructure automatically across edge hosts.

---

## 5. Verification & Testing Matrix

| Test Case | Description | Command / Procedure | Expected Result |
| :--- | :--- | :--- | :--- |
| **MQTT Telemetry** | Verify active sensor message publishing | `docker exec -it mosquitto mosquitto_sub -t "sensor/#" -v` | Continuous JSON messages on joystick and buttons topics |
| **Payload Filtering** | Test invalid sensor payload drop | `docker exec -it mosquitto mosquitto_pub -t "sensor/controller/joystick" -m '{"x": 999, "y": 50}'` | Node-RED debug logs warning; message is dropped and NOT written to InfluxDB |
| **Container Status** | Verify service health & bridge network | `docker compose ps` | All containers reported as `Up (healthy)` |
| **Backup Integrity** | Test automated backup snapshot | Execute `backup.bat` or `./backup.sh` | Timestamped zip/tar file created in `./backups/` |
| **Restore Verification** | Test data & flow restoration | Execute `restore.bat` or `./restore.sh` | InfluxDB buckets & Node-RED flows restored and containers restarted |
