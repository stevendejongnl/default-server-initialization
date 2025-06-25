#!/bin/bash

set -e

PROFILED="/etc/profile.d"
PROFILED_BAK="/etc/profile.d.backup"
VMINFO_SCRIPT="$PROFILED/01-vm-info.sh"
MOTD="/etc/motd"
MOTD_BAK="/etc/motd.backup"
MOTD_D="/etc/update-motd.d"
MOTD_D_BAK="/etc/update-motd.d.backup"

if [ -d "$PROFILED_BAK" ]; then
    echo "Restoring $PROFILED from $PROFILED_BAK"
    sudo rm -rf "$PROFILED"
    sudo cp -a "$PROFILED_BAK" "$PROFILED"
else
    echo "No backup found for $PROFILED. Skipping restore."
fi

if [ -f "$VMINFO_SCRIPT" ]; then
    echo "Removing $VMINFO_SCRIPT"
    sudo rm -f "$VMINFO_SCRIPT"
fi

if [ -f "$MOTD_BAK" ]; then
    echo "Restoring $MOTD from $MOTD_BAK"
    sudo cp "$MOTD_BAK" "$MOTD"
else
    echo "No backup found for $MOTD. Skipping restore."
fi

if [ -d "$MOTD_D_BAK" ]; then
    echo "Restoring $MOTD_D from $MOTD_D_BAK"
    sudo rm -rf "$MOTD_D"
    sudo cp -a "$MOTD_D_BAK" "$MOTD_D"
else
    echo "No backup found for $MOTD_D. Skipping restore."
fi

echo "Revert complete! The original MOTD and login banners should be back after a new login."
