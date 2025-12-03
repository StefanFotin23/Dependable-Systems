#!/bin/bash
set -e

# The cluster name is defined in the ansible playbook variables
CLUSTER_NAME="rss-feed-cluster"

echo "==> Deleting KIND cluster named '$CLUSTER_NAME'..."
kind delete cluster --name "$CLUSTER_NAME"
echo "==> Environment torn down."
