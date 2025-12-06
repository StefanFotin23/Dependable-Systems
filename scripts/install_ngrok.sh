#!/bin/bash
# This script installs ngrok if it's not already installed.

set -e

# Check if ngrok is installed
if command -v ngrok &> /dev/null
then
    echo "ngrok is already installed."
    exit 0
fi

echo "ngrok not found. Installing..."

# Download and install ngrok for Linux
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -O /tmp/ngrok.zip
unzip /tmp/ngrok.zip -d /tmp
sudo mv /tmp/ngrok /usr/local/bin/ngrok

echo "ngrok installed successfully."
echo ""
echo "Please configure your ngrok authtoken. You can get it from https://dashboard.ngrok.com/get-started/your-authtoken"
echo "Run the following command, replacing <YOUR_AUTHTOKEN> with your actual token:"
echo "ngrok authtoken <YOUR_AUTHTOKEN>"
