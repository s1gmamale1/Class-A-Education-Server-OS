# Class A Education / NETS Homework — OS Coursework

Shell scripts and Docker configuration for an **Ubuntu Server** operating-systems
coursework. Case study: the **Class A Education / NETS Homework Platform Server**.

The two core software packages are **Nginx** (web server) and **PostgreSQL**
(database). Nginx is also containerised with Docker as the second package.

## Scripts (`scripts/`)

| Script | Purpose |
|---|---|
| `install_classa_services.sh` | Install & enable Nginx + PostgreSQL (+ curl, bc, gzip) |
| `manage_users.sh` | Create `classa_staff` group + 3 users, aliases, `umask 0277`, sudo, readme (`--reset` to recreate) |
| `setup_structure.sh` | Build `/var/classa` tree, permissions, sticky bit, symlinks |
| `monitor.sh` | Log CPU / memory / disk with a timestamp |
| `disk_alert.sh` | Low-disk alert via terminal + OS broadcast + file log + Telegram (`--setup` for config) |
| `log_management.sh` | Rotate, compress, back up and purge logs (`--force` for an instant demo) |
| `install_docker.sh` | Install Docker Engine, enable it, add user to the `docker` group |
| `docker_manage.sh` | Demonstrate the container lifecycle (build, run, logs, ports, volumes, stop, rm) |
| `setup_cron.sh` | **Automatically** install the scheduled jobs (monitor / disk_alert / log rotation) |

## Run order

```bash
cd scripts
sudo ./install_classa_services.sh      # 1. Nginx + PostgreSQL
sudo ./manage_users.sh                 # 2. users & group  (run before setup_structure)
sudo ./setup_structure.sh              # 3. directories & permissions
sudo ./install_docker.sh               # 4. Docker Engine  (re-login afterwards)
sudo ./setup_cron.sh                   # 5. schedule monitor / disk_alert / log rotation
sudo ./disk_alert.sh --setup           # 6. (optional) save your Telegram chat ID
```

## Scheduling (cron)

`setup_cron.sh` installs these into **root's** crontab automatically:

```
*/5  * * * *  monitor.sh          # system metrics every 5 minutes
*/15 * * * *  disk_alert.sh       # disk check every 15 minutes
0 0  * * *    log_management.sh   # rotate/back up logs daily at midnight
```

Verify with `sudo crontab -l`.

## Docker website (`docker-web/`)

Static status page served by Nginx in a container — the second software package.

```bash
# Build the image
docker build -t classa-web-app docker-web/

# Run it (port 8080 -> 80) with a named volume for persistent data
docker run -d -p 8080:80 --name classa-web-container \
    -v classa_data:/usr/share/nginx/html classa-web-app

# Verify it is serving
curl -I http://localhost:8080
```

Open `http://localhost:8080` in a browser for the screenshot.
`scripts/docker_manage.sh` then demonstrates the management operations
(it builds the image automatically if it is missing).
