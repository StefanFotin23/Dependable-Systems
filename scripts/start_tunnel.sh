#!/bin/bash

set -e

echo "--> Activating Ansible virtual environment..."
source k8s/ansible/.venv/bin/activate

echo "--> Generating ngrok configuration..."
ansible-playbook -i /dev/null --connection=local k8s/ansible/ngrok-template.yaml

echo "--> Starting ngrok tunnel..."
ngrok start --all