@echo off
title Edge Gateway Stack - Automated Restore
echo ==============================================================================
echo Edge Gateway Automated Restore Script (Windows)
echo ==============================================================================
echo.

REM Step 1: Check Docker Daemon Status
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running! Please start Docker Desktop and try again.
    echo.
    pause
    exit /b 1
)

REM Step 2: Ensure Docker Compose stack is running
echo [1/3] Checking service container state...
docker compose ps -q influxdb >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Edge stack is not currently running. Starting containers in background...
    docker compose up -d
    echo Waiting for InfluxDB service to initialize...
    timeout /t 4 /nobreak >nul
) else (
    echo [OK] Containers are active.
)
echo.

REM Step 3: Check if backups directory exists
if not exist backups (
    echo [ERROR] No backups directory found! Run 'backup.bat' first to create a backup.
    echo.
    pause
    exit /b 1
)

REM Step 4: Find available backups
echo Available Backups in ./backups/:
echo ------------------------------------------------------------------------------
for /f "delims=" %%I in ('dir /b /ad backups 2^>nul ^| findstr /i "backup_"') do echo %%I
echo ------------------------------------------------------------------------------
echo.

set LATEST_BACKUP=
for /f "delims=" %%D in ('dir /b /ad /o-d backups\backup_* 2^>nul') do (
    if not defined LATEST_BACKUP set "LATEST_BACKUP=backups\%%D"
)

if "%LATEST_BACKUP%"=="" (
    echo [ERROR] No valid backup folders found in ./backups/!
    echo.
    pause
    exit /b 1
)

echo Selected backup folder for restore: %LATEST_BACKUP%
echo.

REM Step 5: Restore InfluxDB Time-Series Data & Telemetry Points
if not exist "%LATEST_BACKUP%\influxdb_data" goto RESTORE_NODERED

echo [2/3] Restoring InfluxDB time-series database and simulator metrics...
docker cp "%LATEST_BACKUP%\influxdb_data" influxdb:/tmp/influx_restore >nul 2>&1
docker exec influxdb influx restore --full --token my-super-secret-auth-token /tmp/influx_restore >nul 2>&1
if %errorlevel% neq 0 (
    docker exec influxdb influx restore --token my-super-secret-auth-token /tmp/influx_restore >nul 2>&1
)
docker exec influxdb rm -rf /tmp/influx_restore >nul 2>&1
docker compose restart influxdb >nul 2>&1
echo [OK] InfluxDB time-series database and simulator data restored successfully.
echo.

:RESTORE_NODERED
REM Step 6: Restore Node-RED Configurations & Flow Diagrams
if not exist "%LATEST_BACKUP%\nodered_config" goto RESTORE_FINISH

echo [3/3] Restoring Node-RED flow configurations...
if not exist nodered_data mkdir nodered_data
copy /y "%LATEST_BACKUP%\nodered_config\flows.json" nodered_data\ >nul 2>&1
copy /y "%LATEST_BACKUP%\nodered_config\flows_cred.json" nodered_data\ >nul 2>&1
copy /y "%LATEST_BACKUP%\nodered_config\settings.js" nodered_data\ >nul 2>&1
docker compose restart nodered >nul 2>&1
echo [OK] Node-RED flow configurations restored successfully.
echo.

:RESTORE_FINISH
echo ==============================================================================
echo [SUCCESS] Restore operation completed successfully from %LATEST_BACKUP%!
echo ==============================================================================
echo.
pause
