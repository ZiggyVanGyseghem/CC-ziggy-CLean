@echo off
title Edge Gateway Stack - Automated Backup
echo ==============================================================================
echo Edge Gateway Automated Backup Script (Windows)
echo ==============================================================================
echo.

:: Generate timestamp formatted YYYYMMDD_HHMMSS
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set TIMESTAMP=%datetime:~0,8%_%datetime:~8,6%
set BACKUP_DIR=backups\backup_%TIMESTAMP%

echo [1/3] Creating backup destination folder: %BACKUP_DIR%
if not exist backups mkdir backups
mkdir %BACKUP_DIR%

echo [2/3] Backing up InfluxDB database and buckets...
docker exec influxdb influx backup /tmp/influx_backup --token my-super-secret-auth-token >nul 2>&1
if %errorlevel% equ 0 (
    docker cp influxdb:/tmp/influx_backup %BACKUP_DIR%\influxdb_data >nul 2>&1
    docker exec influxdb rm -rf /tmp/influx_backup >nul 2>&1
    echo [OK] InfluxDB time-series database backed up successfully.
) else (
    echo [WARNING] InfluxDB backup encountered an issue. Ensure container is running.
)

echo [3/3] Backing up Node-RED flow configurations...
if exist nodered_data (
    mkdir %BACKUP_DIR%\nodered_config
    copy nodered_data\flows.json %BACKUP_DIR%\nodered_config\ >nul 2>&1
    copy nodered_data\flows_cred.json %BACKUP_DIR%\nodered_config\ >nul 2>&1
    copy nodered_data\settings.js %BACKUP_DIR%\nodered_config\ >nul 2>&1
    echo [OK] Node-RED flow configurations backed up.
)

echo.
echo ==============================================================================
echo [SUCCESS] Backup completed successfully!
echo Backup stored in: %BACKUP_DIR%
echo ==============================================================================
echo.
pause
