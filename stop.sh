#!/bin/bash
# ==============================================================================
# Edge Gateway Shutdown Script (Linux & WSL)
# ==============================================================================

echo "============================================="
echo "Stopping Edge Gateway containers..."
echo "============================================="
docker compose down

echo ""
echo "[SUCCESS] Edge Gateway Stack stopped cleanly."
