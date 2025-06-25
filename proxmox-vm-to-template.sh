#!/bin/bash
set -e

echo "Updating package lists..."
sudo apt update

echo "Installing qemu-guest-agent..."
sudo apt install -y qemu-guest-agent

echo "Enabling qemu-guest-agent service..."
sudo systemctl enable qemu-guest-agent

echo "Resetting machine-id..."
sudo truncate -s 0 /etc/machine-id
sudo truncate -s 0 /var/lib/dbus/machine-id

echo "Cleaning cloud-init..."
sudo cloud-init clean

echo "Resetting hostname to 'template'..."
sudo hostnamectl set-hostname template
echo "template" | sudo tee /etc/hostname

echo "Removing SSH host keys..."
sudo rm -f /etc/ssh/ssh_host_*

echo "Removing persistent udev rules (network)..."
sudo rm -f /etc/udev/rules.d/70-persistent-net.rules

echo "Cleaning temporary files..."
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

echo "Cleaning shell history..."
history -c
cat /dev/null > ~/.bash_history

echo "Proxmox template preparation complete. Shut down the VM and convert it to a template."
