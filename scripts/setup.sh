#!/bin/bash
set -e

# Navigate to the ansible directory from the script's location
cd "$(dirname "$0")/../k8s/ansible"

echo "==> Activating Ansible virtual environment..."
source .venv/bin/activate

echo "==> Running Ansible playbook to set up the environment..."
ansible-playbook -i inventory.ini playbook.yaml

echo "==> Setup complete!"
