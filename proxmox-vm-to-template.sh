#! /bin/bash

apt install qemu-guest-agent
systemctl enable qemu-guest-agent

cat /dev/null > /etc/machine-id
cat /dev/null > /var/lib/dbus/machine-id

cloud-init clean
