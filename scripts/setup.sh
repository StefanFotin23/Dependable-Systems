#!/bin/bash
set -e

# Default to 'dev' if no environment is specified
ENV=${1:-dev}

# Navigate to the ansible directory from the script's location
cd "$(dirname "$0")/../k8s/ansible"

echo "==> Activating Ansible virtual environment..."
source .venv/bin/activate

echo "==> Running Ansible playbook for [${ENV}] environment..."
ansible-playbook -i "inventory-${ENV}.ini" playbook.yaml

echo "==> Setup complete!"
