# Default Server Initialization

This repository provides a simple and robust way to initialize a Linux server with useful system information at login, and to clean up the default Message of the Day (MOTD).  

## Features

- **Colorful server info banner** on login (CPU, RAM, disk, network, Kubernetes context, etc)
- **Backs up** your original `/etc/profile.d`, `/etc/motd`, and `/etc/update-motd.d`
- **Removes default and dynamic MOTD** content (including Ubuntu’s welcome screen)
- **Easy installation** via a single `curl | sudo bash` command
- **Easy revert** to bring back the default Ubuntu login experience

## Quick Start

Run the following command on your server:

```bash
curl -fsSL https://raw.githubusercontent.com/stevendejongnl/default-server-initialization/main/init.sh | sudo bash
```

This will:
- Backup `/etc/profile.d` to `/etc/profile.d.backup`
- Backup `/etc/update-motd.d` to `/etc/update-motd.d.backup`
- Install `01-vm-info.sh` from this repository into `/etc/profile.d/`
- Backup `/etc/motd` to `/etc/motd.backup` (if it exists)
- Clear `/etc/motd`
- Disable all scripts in `/etc/update-motd.d/` so that the default (Ubuntu) login message and system stats are no longer shown
- On next login, display a colorful server info summary

## How to Revert

To undo all changes and restore the default Ubuntu login banners and MOTD:

```bash
curl -fsSL https://raw.githubusercontent.com/stevendejongnl/default-server-initialization/main/revert.sh | sudo bash
```

This will:
- Restore `/etc/profile.d` from the backup
- Remove the custom server info script
- Restore `/etc/motd` from the backup
- Restore `/etc/update-motd.d` from the backup (default Ubuntu banners and MOTD return)

## What Will I See at Login?

After installation, every interactive shell session (e.g. SSH login) will show a banner with:

- Linux distribution, kernel version, and hostname  
- CPU model, number of cores, and load average  
- RAM and swap usage  
- Disk usage for all mounted filesystems  
- Network interface addresses  
- Kubernetes context and cluster info (if `kubectl` is installed)

## Files

- `init.sh` – Install/backup script for one-line setup (see above)
- `revert.sh` – Restore all changes and reactivate default MOTD/Ubuntu login
- `01-vm-info.sh` – The actual server info script, installed to `/etc/profile.d/`

## Customization

Edit `01-vm-info.sh` in your repo before running `init.sh` if you want to add or change info in the banner.

## License

MIT License

---

*Created by [stevendejongnl](https://github.com/stevendejongnl)*
