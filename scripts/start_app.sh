#!/bin/bash
set -e

echo "==> Scaling Node-RED deployment to 1 replica..."
kubectl scale deployment nodered --replicas=1
echo "==> Node-RED application started."
