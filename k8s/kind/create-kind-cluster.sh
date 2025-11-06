#!/usr/bin/env bash
set -e
CLUSTER_NAME="nodered-ha"
kind create cluster --name $CLUSTER_NAME --config kind-config.yaml
kubectl cluster-info --context kind-$CLUSTER_NAME
# Install ingress-nginx (ingress controller)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.1/deploy/static/provider/kind/deploy.yaml
# Wait for ingress ready
kubectl -n ingress-nginx wait --for=condition=available deployment --all --timeout=120s
echo "Cluster '$CLUSTER_NAME' creat și ingress instalat."