# ==============================================================================
# Smart Sensor Gateway Stack - Makefile (CI/CD Infrastructure Automation)
# ==============================================================================

.PHONY: all deploy build up down status logs backup restore help

# Default target
all: deploy

# Full CI/CD redeployment cycle: build, teardown legacy stack, launch updated stack
deploy: build down up status

# Build custom container images (nodered, simulator)
build:
	@echo "============================================="
	@echo "Building container images..."
	@echo "============================================="
	docker compose build

# Launch the Docker Compose stack in detached mode
up:
	@echo "============================================="
	@echo "Starting Edge Gateway stack in background..."
	@echo "============================================="
	docker compose up -d

# Stop and remove all stack containers
down:
	@echo "============================================="
	@echo "Stopping existing containers..."
	@echo "============================================="
	docker compose down

# View status of running containers
status:
	@echo "============================================="
	@echo "Active Edge Gateway Containers:"
	@echo "============================================="
	docker compose ps

# View live container logs
logs:
	docker compose logs -f

# Execute automated configuration & database backup
backup:
	@echo "Creating backup archive..."
	@./backup.sh

# Restore configuration & database backup
restore:
	@echo "Restoring backup archive..."
	@./restore.sh

# Help target
help:
	@echo "Available Makefile targets:"
	@echo "  make deploy   - Full rebuild, teardown, and start cycle (CI/CD)"
	@echo "  make build    - Build custom Docker images"
	@echo "  make up       - Start stack in background"
	@echo "  make down     - Stop running stack"
	@echo "  make status   - Show running container status"
	@echo "  make logs     - View real-time container logs"
	@echo "  make backup   - Run backup script"
	@echo "  make restore  - Run restore script"
