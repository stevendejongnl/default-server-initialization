# Default Server Initialization

This repository provides scripts to quickly initialize a Linux server with a colorful system info banner at login,
clean up the default Message of the Day (MOTD), and includes utilities for Kubernetes setup and Proxmox VM templating.

## Features

- **Colorful server info banner** at login (CPU, RAM, disk, network, Kubernetes context, etc.)
- **Backs up** your original `/etc/profile.d`, `/etc/motd`, and `/etc/update-motd.d`
- **Removes default and dynamic MOTD** content (including Ubuntu’s welcome screen)
- **Easy installation** via a single command
- **Easy revert** to restore the default Ubuntu login experience
- **Kubernetes initialization** helper script
- **Proxmox VM to template** conversion script
- **Rancher installation** script for Kubernetes clusters

## Scripts

- `01-vm-info.sh`  
  Displays system and VM information at login.

- `init.sh`  
  Performs initial server setup, installs the info banner, and cleans up MOTD.

- `init-kubernetes.sh`  
  Installs and initializes Kubernetes on the server.

- `install-rancher.sh`  
  Installs Rancher on an existing Kubernetes cluster.

- `proxmox-vm-to-template.sh`  
  Converts a Proxmox VM to a template.

- `revert.sh`  
  Restores all changes and re-enables the default Ubuntu login/MOTD.

## Quick Start

To install on your server:

```bash
curl -fsSL https://raw.githubusercontent.com/stevendejongnl/default-server-initialization/main/init.sh | sudo bash
```

This will:
- Backup `/etc/profile.d` to `/etc/profile.d.backup`
- Backup `/etc/update-motd.d` to `/etc/update-motd.d.backup`
- Install `01-vm-info.sh` into `/etc/profile.d/`
- Backup `/etc/motd` to `/etc/motd.backup` (if it exists)
- Clear `/etc/motd`
- Disable all scripts in `/etc/update-motd.d/`
- Show a colorful server info summary at next login

## Usage

1. **Initialize the server:**  
   `./init.sh`

2. **Install Kubernetes:**  
   `./init-kubernetes.sh`

3. **Install Rancher:**  
   `./install-rancher.sh`

4. **View VM information:**  
   `./01-vm-info.sh`

5. **Convert Proxmox VM to template:**  
   `./proxmox-vm-to-template.sh`

6. **Revert all changes:**  
   `./revert.sh`

## How to Revert

To restore the default Ubuntu login banners and MOTD:

```bash
curl -fsSL https://raw.githubusercontent.com/stevendejongnl/default-server-initialization/main/revert.sh | sudo bash
```

This will:
- Restore `/etc/profile.d` from backup
- Remove the custom server info script
- Restore `/etc/motd` from backup
- Restore `/etc/update-motd.d` from backup

## What Will I See at Login?

After installation, every interactive shell session (e.g. SSH login) will show a banner with:

- Linux distribution, kernel version, and hostname
- CPU model, number of cores, and load average
- RAM and swap usage
- Disk usage for all mounted filesystems
- Network interface addresses
- Kubernetes context and cluster info (if `kubectl` is installed)

## Requirements

- Bash shell
- Access to a Linux server (preferably via Proxmox)
- Kubernetes cluster (for Rancher installation)
- `helm` and `kubectl` installed (for Rancher)

## Customization

Edit `01-vm-info.sh` in your repo before running `init.sh` if you want to add or change info in the banner.

## License

MIT License

---

*Created by [stevendejongnl](https://github.com/stevendejongnl)*