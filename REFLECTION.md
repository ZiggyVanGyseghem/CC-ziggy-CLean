# Project Reflection & Individual Task Breakdown

**Course**: Cloud Computing (Academic Year 2025-2026)  
**Project**: Smart Sensor Gateway with Monitoring and Automation  
**Author**: Ziggy Van Gyseghem (Individual Project)  
**Degree**: Bachelor Electronics-ICT  

---

## 1. Project Overview & Task Breakdown

I worked on this project individually as a 1-person team. As the sole developer, I took full responsibility for the end-to-end architecture, implementation, debugging, testing, and technical documentation of the entire Edge Sensor Gateway stack.

### Summary of Component Ownership:

* **Container Orchestration & Architecture**:
  * Designed `docker-compose.yml` to launch and manage all stack services.
  * Configured isolated bridge networking (`iot-network`) and persistent storage volumes.
  * Integrated Portainer CE (`portainer`) for container lifecycle management and live logging.

* **Sensor Telemetry & MQTT Broker**:
  * Configured Eclipse Mosquitto broker with anonymous access rules and host port mapping.
  * Developed the Python sensor simulator (`simulator/sensor_simulator.py`) to generate multi-topic telemetry (`sensor/controller/joystick` and `sensor/controller/buttons`).

* **Node-RED Ingestion & Data Validation**:
  * Built the Node-RED flow canvas (`nodered_data/flows.json`).
  * Wrote custom JavaScript Function Nodes to validate coordinate bounds ($0 \le x, y \le 255$), calculate vector magnitude ($\sqrt{x^2 + y^2}$), and filter out invalid payloads before database ingestion.

* **InfluxDB Storage & Visualization**:
  * Configured InfluxDB 2.7 with bucket `sensor_data` under organization `sensorsim`.
  * Created automated startup initialization scripts (`influxdb_setup/template.yml`) to automatically load live gauge panels and 1-hour / 24-hour moving average calculations.

* **Automation & CI/CD**:
  * Built cross-platform deployment scripts (`start.sh` and `start.bat`) for automated container building and stack replacement.
  * Configured Watchtower (`containrrr/watchtower`) with socket access (`/var/run/docker.sock`) for automated background container updates.
  * Implemented backup and restoration scripts (`backup.sh`, `restore.sh`, `backup.bat`, `restore.bat`) for complete data preservation.

---

## 2. Key Learnings & Insights

Building this project provided practical experience with core cloud and edge computing concepts:
* **Edge Processing**: Validating and filtering telemetry early at the edge (in Node-RED) protects downstream database storage from corrupt data and reduces unnecessary write overhead.
* **Container Isolation & Security**: Running services in a dedicated bridge network ensures microservices can communicate internally without exposing unnecessary open ports to the host machine.
* **Continuous Deployment**: Learned how daemon services like Watchtower monitor container registries via the Docker socket to pull updated image layers without requiring manual SSH access.

---

## 3. Challenges & Technical Solutions

* **Hyper-V / Windows Port Locks**: Windows dynamic port reservations occasionally locked default MQTT port `1883`. Solved by mapping Mosquitto's host port to `10883`.
* **InfluxDB Dashboard Persistence across Restarts**: Solved by exporting the dashboard template into `influxdb_setup/template.yml` and adding auto-import logic to the startup scripts.
* **Docker Socket API Version Mismatches**: Fixed Watchtower container daemon communication errors by setting `DOCKER_API_VERSION=1.40` in `docker-compose.yml`.

---

## 4. Self-Evaluation & Conclusion

The project meets all mandatory and bonus requirements outlined in the course assignment. Working individually allowed me to gain a complete understanding of how edge gateways, MQTT message brokers, data processing engines, time-series databases, and CI/CD tools integrate into a unified IoT solution.
