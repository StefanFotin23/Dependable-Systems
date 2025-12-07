#!/bin/bash
set -e

# This script is designed to be called from the Makefile.
# Makefile provides ENV and TAGS variables.

# Default to 'dev' if no environment is specified
ENV=${1:-dev}
TAGS=${2}

if [ -z "$TAGS" ]; then
  echo "Error: No tag specified."
  echo "Usage: make update TAGS=<tag_name>"
  echo "Available tags: cluster, storage, observability, networking, application"
  exit 1
fi

# Navigate to the ansible directory relative to the script's location
cd "$(dirname "$0")/../k8s/ansible"

echo "==> Activating Ansible virtual environment..."
source .venv/bin/activate

echo "==> Running Ansible playbook for [${ENV}] environment with tags [${TAGS}]..."
ansible-playbook -i "inventory-${ENV}.ini" playbook.yaml --tags "${TAGS}"

echo "==> Update for tag '${TAGS}' complete!"
