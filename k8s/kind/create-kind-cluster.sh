#!/usr/bin/env bash
set -e
CLUSTER_NAME="nodered-ha"
kind create cluster --name $CLUSTER_NAME --config kind-config.yaml
kubectl cluster-info --context kind-$CLUSTER_NAME

echo "Cluster '$CLUSTER_NAME' creat și ingress instalat."