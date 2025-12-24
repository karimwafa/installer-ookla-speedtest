# Ookla Speedtest Server Migration & Installer

This repository contains scripts to help migrate and install an Ookla Speedtest Server.

## Files

*   `OoklaServer.properties`: Template configuration file.
*   `prepare_migration.sh`: Script to run on the *source* server to bundle config and certificates.
*   `install_on_new_server.sh`: Script to run on the *destination* server to install and configure.
*   `ooklaserver.sh`: Official Ookla management script.

## Usage

### 1. Migrating from an existing server

1.  Clone this repo or download the scripts to your source server.
2.  Run `prepare_migration.sh`.
    *   This will create `ookla-server-migration.tar.gz`.
    *   **Note**: This bundle contains your **private SSL keys**. Do NOT commit the tarball or the keys to this repository.
3.  Transfer `ookla-server-migration.tar.gz` to your new server.
4.  Run `tar -xzvf ookla-server-migration.tar.gz`.
5.  Run `./install_on_new_server.sh`.

### 2. Fresh Install

1.  Run `./ooklaserver.sh install`.
2.  Edit `OoklaServer.properties` as needed.
