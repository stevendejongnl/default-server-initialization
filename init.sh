#!/bin/bash

set -e

PROFILED="/etc/profile.d"
PROFILED_BAK="/etc/profile.d.backup"
VMINFO_SCRIPT="01-vm-info.sh"
MOTD="/etc/motd"
MOTD_BAK="/etc/motd.backup"
REPO_RAW="https://raw.githubusercontent.com/stevendejongnl/default-server-initialization/main"

if [ -d "$PROFILED" ]; then
    echo "Backing up $PROFILED to $PROFILED_BAK"
    sudo cp -a "$PROFILED" "$PROFILED_BAK"
else
    echo "$PROFILED does not exist. Aborting."
    exit 1
fi

echo "Installing $VMINFO_SCRIPT to $PROFILED"
sudo curl -fsSL "$REPO_RAW/$VMINFO_SCRIPT" -o "$PROFILED/$VMINFO_SCRIPT"
sudo chmod +x "$PROFILED/$VMINFO_SCRIPT"

if [ -f "$MOTD" ]; then
    echo "Backing up $MOTD to $MOTD_BAK"
    sudo cp "$MOTD" "$MOTD_BAK"
fi

echo "Clearing $MOTD"
sudo sh -c 'echo "" > /etc/motd'

echo "Done! Log out and back in to see server information on login."
