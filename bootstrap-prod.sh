#!/bin/bash
#
# This script bootstraps a new Ubuntu VM to be a production node for the rss_feed project.
# It installs all necessary dependencies, clones the repository, and runs the production setup.
#
# USAGE:
# 1. Copy or upload this script to your new Ubuntu VM.
# 2. Make it executable: chmod +x bootstrap-prod.sh
# 3. Run it, providing your Git repository URL: ./bootstrap-prod.sh <your-git-repo-url>
#

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
GIT_REPO_URL=$1
PROJECT_DIR="rss_feed" # The directory name after cloning

if [ -z "$GIT_REPO_URL" ]; then
    echo "ERROR: Please provide the Git repository URL as the first argument."
    echo "Usage: $0 <your-git-repo-url>"
    exit 1
fi

echo "--- [Step 1/7] Updating system packages ---"
sudo apt-get update -y

echo "--- [Step 2/7] Installing essential dependencies (Git, Ansible, Python, iSCSI) ---"
sudo apt-get install -y git ansible python3-pip python3-venv open-iscsi

echo "--- [Step 3/7] Starting iSCSI service ---"
sudo systemctl enable --now iscsid
echo "iSCSI service status:"
sudo systemctl status iscsid --no-pager

echo "--- [Step 4/7] Installing Docker ---"
sudo apt-get install -y docker.io
# Add current user to the docker group to run docker without sudo
# Note: A new login session is required for this to take effect.
sudo usermod -aG docker $USER
echo "Docker installed. You may need to log out and back in to run 'docker' without 'sudo'."

echo "--- [Step 5/7] Installing Kubernetes tools (kubectl, kind, helm) ---"
# Install kubectl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# Install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "--- [Step 6/7] Cloning project repository ---"
if [ -d "$PROJECT_DIR" ]; then
    echo "Project directory '$PROJECT_DIR' already exists. Deleting it for a clean clone."
    rm -rf "$PROJECT_DIR"
fi
git clone "$GIT_REPO_URL"
cd "$PROJECT_DIR"

echo "--- [Step 7/7] Running Production Setup ---"
echo "IMPORTANT: This script assumes it is running ON the production target machine."
echo "It will temporarily modify the production inventory to run locally."

# Since the playbook is running on the target machine itself,
# we modify the prod inventory to point to localhost.
cp k8s/ansible/inventory-prod.ini k8s/ansible/inventory-prod.ini.backup
cat > k8s/ansible/inventory-prod.ini <<EOL
[k8s_cluster]
localhost ansible_connection=local
EOL

echo "Inventory file has been temporarily adjusted for local execution."
read -p "Press [Enter] to run the final 'make setup ENV=prod' command..."

# Run the final setup
make setup ENV=prod

# Optional: Restore the original inventory
mv k8s/ansible/inventory-prod.ini.backup k8s/ansible/inventory-prod.ini

echo ""
echo "--- BOOTSTRAP COMPLETE! ---"
echo "The production environment setup has been executed."
echo "Please note that the Ansible logic for 'prod' mode assumes a Kubernetes cluster already exists."
echo "This script does NOT create a production Kubernetes cluster, it only runs the application deployment."

