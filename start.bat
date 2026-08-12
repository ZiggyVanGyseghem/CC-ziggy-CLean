@echo off
title Edge Gateway Stack - Startup
echo ==============================================================================
echo Edge Gateway Docker Stack Launcher (Windows)
echo ==============================================================================
echo.

:: Check if Docker is installed and running
echo [1/3] Checking Docker status...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Docker is not running or not installed!
    echo Please make sure Docker Desktop is installed and running, then try again.
    echo.
    pause
    exit /b 1
)

echo [OK] Docker is running.
echo.

:: Build container images
echo [2/3] Building container images...
docker compose build
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Failed to build containers. Please check Docker output above.
    echo.
    pause
    exit /b 1
)

echo.
:: Start containers
echo [3/3] Starting Edge Gateway stack in background...
docker compose up -d
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Failed to start Docker Compose stack.
    echo.
    pause
    exit /b 1
)

echo.
echo ==============================================================================
echo [SUCCESS] Edge Gateway Stack is live!
echo ==============================================================================
echo.
echo Accessible Web Dashboards:
echo   - Node-RED Flow Editor:    http://localhost:1880
echo   - InfluxDB Dashboard:      http://localhost:8086
echo   - Portainer Management:    http://localhost:9000
echo   - MQTT Broker Port:        localhost:1883
echo.
echo Active Containers:
docker compose ps
echo.
echo To stop the gateway at any time, double-click 'stop.bat'.
echo.
pause
