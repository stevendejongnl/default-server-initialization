# Default Server Initialization

This repository provides a simple and robust way to initialize a Linux server with useful system information at login, and to clean up the default Message of the Day (MOTD).  

## Features

- **Colorful server info banner** on login (CPU, RAM, disk, network, Kubernetes context, etc)
- **Backs up** your original `/etc/profile.d` and `/etc/motd`
- **Removes default MOTD** content
- **Easy installation** via a single `curl | sudo bash` command

## Quick Start

Run the following command on your server:

```bash
curl -fsSL https://raw.githubusercontent.com/stevendejongnl/default-server-initialization/main/init.sh | sudo bash
```

This will:
- Backup `/etc/profile.d` to `/etc/profile.d.backup`
- Install `01-vm-info.sh` from this repository into `/etc/profile.d/`
- Backup `/etc/motd` to `/etc/motd.backup` (if it exists)
- Clear `/etc/motd`
- On next login, display a colorful server info summary

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
- `01-vm-info.sh` – The actual server info script, installed to `/etc/profile.d/`

## Uninstall

To revert, simply restore your backups:

```bash
sudo rm /etc/profile.d/01-vm-info.sh
sudo rm -rf /etc/profile.d
sudo mv /etc/profile.d.backup /etc/profile.d
[ -f /etc/motd.backup ] && sudo mv /etc/motd.backup /etc/motd
```

## Customization

Edit `01-vm-info.sh` in your repo before running `init.sh` if you want to add or change info in the banner.

## License

MIT License

---

*Created by [stevendejongnl](https://github.com/stevendejongnl)*
