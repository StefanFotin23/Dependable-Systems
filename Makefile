.PHONY: setup start stop teardown help

# Default environment is 'dev' (WSL/local).
# To run for production, use: make setup ENV=prod
ENV ?= dev

help:
	@echo "Usage: make <target> [ENV=<environment>]"
	@echo ""
	@echo "Targets:"
	@echo "  setup      - Sets up the environment. Use ENV=prod for production."
	@echo "  start      - Starts the Node-RED application by scaling replicas to 1."
	@echo "  stop       - Stops the Node-RED application by scaling replicas to 0."
	@echo "  teardown   - Deletes the KIND Kubernetes cluster (for DEV environment only)."
	@echo "  help       - Shows this help message."
	@echo ""
	@echo "Environments:"
	@echo "  dev        - (Default) Local setup using KIND on WSL/Docker."
	@echo "  prod       - Remote setup targeting a pre-existing VM (e.g., on GCP)."


setup:
	@echo "--> Running setup for [${ENV}] environment..."
	@bash scripts/setup.sh ${ENV}

start:
	@echo "--> Starting Node-RED application..."
	@bash scripts/start_app.sh

stop:
	@echo "--> Stopping Node-RED application..."
	@bash scripts/stop_app.sh

teardown:
	@echo "--> Tearing down DEV environment..."
	@bash scripts/teardown.sh
