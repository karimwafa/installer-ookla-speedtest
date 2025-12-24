# Ookla Speedtest Server Migration & Installer

This repository contains scripts to help migrate and install an Ookla Speedtest Server.

## Files

*   `OoklaServer.properties`: Template configuration file.
*   `prepare_migration.sh`: Script to run on the *source* server to bundle config and certificates.
*   `install_on_new_server.sh`: Script to run on the *destination* server to install and configure.
*   `ooklaserver.sh`: Official Ookla management script.

## Usage

### Option A: Complete Migration (Copy Config + Keys)
Use this if you want to keep the exact same keys and configuration without re-verifying the domain immediately.

1.  On Source Server: Run `prepare_migration.sh`.
2.  Transfer `ookla-server-migration.tar.gz` to New Server.
3.  On New Server: Extract and run `./install_on_new_server.sh`. Say **No** to generating new keys.

### Option B: Fresh Keys (Generate on New Server)
Use this if you have already pointed your Domain DNS to the New Server IP.

1.  On Source Server: You only need `OoklaServer.properties` if you have custom settings.
2.  On New Server:
    *   Clone this repo.
    *   Run `./install_on_new_server.sh`.
    *   Say **Yes** when asked to generate SSL certificates.
    *   Enter your domain name.
    *   The script will:
        *   Generator valid keys using Let's Encrypt (Certbot).
        *   Update `OoklaServer.properties`.
        *   Configure a **Certbot renewal hook** to auto-restart the server on certificate renewal.
        *   Install and enable a **Systemd Service** (`ooklaserver.service`) so the server starts on boot.

## Service Management

After installation, the server runs as a systemd service:

```bash
systemctl start ooklaserver
systemctl stop ooklaserver
systemctl restart ooklaserver
systemctl status ooklaserver
```
