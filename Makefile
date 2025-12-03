.PHONY: setup start stop teardown help

help:
	@echo "Usage: make <target>"
	@echo "targets:"
	@echo "  setup      - Sets up the entire Kubernetes environment using Ansible."
	@echo "  start      - Starts the Node-RED application by scaling replicas to 1."
	@echo "  stop       - Stops the Node-RED application by scaling replicas to 0."
	@echo "  teardown   - Deletes the entire KIND Kubernetes cluster."
	@echo "  help       - Shows this help message."

setup:
	@echo "--> Running setup script..."
	@bash scripts/setup.sh

start:
	@echo "--> Starting Node-RED application..."
	@bash scripts/start_app.sh

stop:
	@echo "--> Stopping Node-RED application..."
	@bash scripts/stop_app.sh

teardown:
	@echo "--> Tearing down environment..."
	@bash scripts/teardown.sh
