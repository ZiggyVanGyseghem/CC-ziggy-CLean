# Smart Sensor Gateway - Edge Gateway IoT Stack

**Course**: Cloud Computing (Academic Year 2025-2026)  
**Project**: Smart Sensor Gateway with Monitoring and Automation  
**Author**: Ziggy Van Gyseghem  
**Degree**: Bachelor Electronics-ICT / Technology  

---

## About the Project

This project implements a fully containerized **Edge Sensor Gateway Stack** for industrial Internet of Things (IoT) applications. The system receives real-time sensor data via MQTT, processes and validates telemetry in Node-RED, stores time-series data in InfluxDB 2.0, and visualizes live and aggregated metrics on dashboards. Container health and service management are handled using Docker Compose and Portainer CE.

---

## Quick Start Guide

### Prerequisites
* Ensure **Docker** (Docker Desktop on Windows/Mac, or Docker Engine on Linux) is installed and running on your system.

---

### Windows Execution
- **Launch & Deploy Stack**: Double-click [`start.bat`](file:///c:/Users/ziggy/Programssss/web%20apps/CC-ziggy-CLean/start.bat)
- **Create Backup**: Double-click [`backup.bat`](file:///c:/Users/ziggy/Programssss/web%20apps/CC-ziggy-CLean/backup.bat)
- **Restore Backup**: Double-click [`restore.bat`](file:///c:/Users/ziggy/Programssss/web%20apps/CC-ziggy-CLean/restore.bat)
- **Stop Stack**: Double-click [`stop.bat`](file:///c:/Users/ziggy/Programssss/web%20apps/CC-ziggy-CLean/stop.bat)

---

### Linux & WSL Execution
```bash
chmod +x start.sh stop.sh backup.sh restore.sh
./start.sh
```
- **Configuration Backup**: `./backup.sh`
- **Restore Backup**: `./restore.sh`
- **Stop Stack**: `./stop.sh`


---

## Web Dashboards & Service Endpoints

Once the stack is started, access management interfaces directly in your browser:

| Service | Access URL / Port | Default Credentials / Description |
| :--- | :--- | :--- |
| **Node-RED Flow Editor** | [http://localhost:3880](http://localhost:3880) | Visual flow canvas & validation nodes |
| **InfluxDB Dashboard** | [http://localhost:8086](http://localhost:8086) | **User**: `admin`<br>**Password**: `adminpassword123`<br>**Org**: `sensorsim` |
| **Portainer CE** | [http://localhost:9000](http://localhost:9000) | Container management & service logging |
| **Watchtower CD** | Background Daemon | Automated container polling (`5 min` interval) |
| **Mosquitto MQTT** | `localhost:10883` / `1883` | Topics: `sensor/controller/joystick`, `sensor/controller/buttons` |


---

## Documentation Index

For detailed technical specifications, architecture diagrams, testing procedures, and project reflection, see the dedicated documentation files:

* [`TECHNICAL_DOCUMENTATION.md`](file:///c:/Users/ziggy/Programssss/web%20apps/CC-ziggy-CLean/TECHNICAL_DOCUMENTATION.md) - Deep-dive technical specifications, data flow diagrams, network topology, and CI/CD concepts.
* [`testing_guide.md`](file:///c:/Users/ziggy/Programssss/web%20apps/CC-ziggy-CLean/testing_guide.md) - Step-by-step verification guide for all evaluation criteria.
* [`REFLECTION.md`](file:///c:/Users/ziggy/Programssss/web%20apps/CC-ziggy-CLean/REFLECTION.md) - Student reflection and individual task breakdown.
* [`docker-compose.yml`](file:///c:/Users/ziggy/Programssss/web%20apps/CC-ziggy-CLean/docker-compose.yml) - Container stack definition and `iot-network` bridge.
* [`nodered_data/flows.json`](file:///c:/Users/ziggy/Programssss/web%20apps/CC-ziggy-CLean/nodered_data/flows.json) - Node-RED flow definitions and data validation nodes.
