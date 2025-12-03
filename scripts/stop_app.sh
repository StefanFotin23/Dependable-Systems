#!/bin/bash
set -e

echo "==> Scaling Node-RED deployment to 0 replicas..."
kubectl scale deployment nodered --replicas=0
echo "==> Node-RED application stopped."
