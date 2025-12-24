#!/bin/bash

BUNDLE_NAME="ookla-server-migration.tar.gz"
TEMP_DIR="migration_temp"

echo "Preparing migration bundle..."

# Clean up previous run
rm -rf "$TEMP_DIR"
rm -f "$BUNDLE_NAME"

# Create temp structure
mkdir -p "$TEMP_DIR/certs"

# 1. Copy Config
echo "Copying configuration..."
cp OoklaServer.properties "$TEMP_DIR/"

# 2. Copy SSL Certificates
# Based on previous analysis of OoklaServer.properties:
# openSSL.server.certificateFile = /etc/letsencrypt/live/jkt-ookla.nexa.net.id/fullchain.pem
# openSSL.server.privateKeyFile = /etc/letsencrypt/live/jkt-ookla.nexa.net.id/privkey.pem

echo "Copying SSL certificates..."
if [ -f "/etc/letsencrypt/live/jkt-ookla.nexa.net.id/fullchain.pem" ]; then
    cp "/etc/letsencrypt/live/jkt-ookla.nexa.net.id/fullchain.pem" "$TEMP_DIR/certs/fullchain.pem"
else
    echo "WARNING: Certificate file not found!"
fi

if [ -f "/etc/letsencrypt/live/jkt-ookla.nexa.net.id/privkey.pem" ]; then
    cp "/etc/letsencrypt/live/jkt-ookla.nexa.net.id/privkey.pem" "$TEMP_DIR/certs/privkey.pem"
else
    echo "WARNING: Private key file not found!"
fi

# 3. Update Configuration to point to local certs
echo "Updating configuration paths..."
# Using different delimiter | because paths contain slashes
sed -i 's|/etc/letsencrypt/live/jkt-ookla.nexa.net.id/fullchain.pem|certs/fullchain.pem|g' "$TEMP_DIR/OoklaServer.properties"
sed -i 's|/etc/letsencrypt/live/jkt-ookla.nexa.net.id/privkey.pem|certs/privkey.pem|g' "$TEMP_DIR/OoklaServer.properties"

# 4. Copy Scripts
echo "Copying helper scripts..."
cp install_on_new_server.sh "$TEMP_DIR/"
cp ooklaserver.sh "$TEMP_DIR/"

# 5. Create Tarball
echo "Creating archive $BUNDLE_NAME..."
tar -czvf "$BUNDLE_NAME" -C "$TEMP_DIR" .

# Cleanup
rm -rf "$TEMP_DIR"
chmod +x install_on_new_server.sh

echo "Done! The migration bundle is ready: $BUNDLE_NAME"
ls -lh "$BUNDLE_NAME"
