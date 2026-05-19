# Class A Education / NETS Homework OS Coursework

This repository contains shell scripts and Docker configuration for an Ubuntu Server based operating systems coursework.

## Case Study

Class A Education / NETS Homework Platform Server.

## Scripts

- `install_classa_services.sh` - installs Nginx and PostgreSQL
- `manage_users.sh` - creates users, group, aliases, and default permissions
- `setup_structure.sh` - creates `/var/classa` structure and permissions
- `monitor.sh` - logs CPU, memory, and disk usage
- `disk_alert.sh` - checks disk space and sends terminal/log/Telegram alerts
- `log_management.sh` - rotates, compresses, and backs up logs
- `install_docker.sh` - installs Docker
- `docker_manage.sh` - demonstrates Docker lifecycle commands

## Docker Website

Located in:

```bash
docker-web/
