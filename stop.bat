@echo off
title Edge Gateway Stack - Shutdown
echo ==============================================================================
echo Edge Gateway Docker Stack Shutdown (Windows)
echo ==============================================================================
echo.

echo Stopping and removing containers...
docker compose down

echo.
echo ==============================================================================
echo [SUCCESS] Edge Gateway Stack stopped cleanly.
echo ==============================================================================
echo.
pause
