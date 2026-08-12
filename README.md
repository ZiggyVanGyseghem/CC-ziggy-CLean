# Edge Gateway IoT Stack

An end-to-end containerized IoT Edge Gateway stack featuring **MQTT (Mosquitto)**, **Node-RED**, **InfluxDB 2.0 (Time-Series)**, **Portainer CE**, and an automated **Python Sensor Simulator**.

---

## One-Click Quick Start

### Prerequisite
Ensure **Docker** (Docker Desktop on Windows/Mac, or Docker Engine on Linux) is installed and running on your system.

---

### Windows Users
Simply double-click the **`start.bat`** file in Windows Explorer.

> **What it does:**
> - Checks if Docker Desktop is running.
> - Automatically builds and launches all 5 Docker containers.
> - Keeps the console window open to display dashboard URLs and container status.

To stop the application at any time, double-click **`stop.bat`**.

---

### Linux & WSL Users
Make the scripts executable and run `start.sh`:

```bash
chmod +x start.sh stop.sh
./start.sh
```

To stop the application at any time, run:
```bash
./stop.sh
```

---

## Dashboard Access Links

Once started, access your local dashboards directly in your web browser:

| Service | URL | Credentials / Notes |
| :--- | :--- | :--- |
| **Node-RED Flow Editor** | [http://localhost:1880](http://localhost:1880) | Sensor validation & MQTT flow |
| **InfluxDB Dashboard** | [http://localhost:8086](http://localhost:8086) | **User:** `admin`<br>**Password:** `adminpassword123`<br>**Org:** `sensorsim` |
| **Portainer CE** | [http://localhost:9000](http://localhost:9000) | Container management & logs |
| **Mosquitto MQTT** | `localhost:1883` | Topic: `sensor/controller/joystick`<br>Topic: `sensor/controller/buttons` |

---

## Repository Overview

- `start.bat` / `stop.bat` - One-click startup & shutdown scripts for **Windows**.
- `start.sh` / `stop.sh` - One-click startup & shutdown scripts for **Linux & WSL**.
- `docker-compose.yml` - Defines all stack services & network bridge (`iot-network`).
- `testing_guide.md` - Complete verification & testing guide for all 8 core requirements.
- `flux_queries.md` - Flux 2.0 query documentation for 1h & 24h moving average aggregations.
