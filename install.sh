#!/bin/bash

# Update and upgrade the system
echo "Preparing System..."
sudo apt update && sudo apt upgrade -y

# SSH Security Enhancements
echo "Copying SSH keys..."
cp /path/to/keys ~/.ssh/authorized_keys
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# Install dependencies
echo "Satisfying Dependencies..."
sudo apt install -y ansible podman podman-compose curl

# Create network
echo "Creating Network..."
podman network create --driver bridge --subnet 10.10.10.0/24 homelab-net

# Setup blank screen when idle
echo "Performing Tweaks..."
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet consoleblank=60"/' /etc/default/grub
sudo update-grub

# Clone and execute the full repository setup
echo "Setting Up Services..."
cd /opt
git clone https://github.com/m-spangenberg/homelab/homelab.git
cd homelab
# Source .env file
echo "Source Environment Variables..."
source .env
# Execute setup.sh
bash dev-services/setup.sh
