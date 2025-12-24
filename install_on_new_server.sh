#!/bin/bash

# Default values
DOMAIN=""
INSTALL_CERTBOT=false

echo "Starting Ookla Speedtest Server Setup..."

# Function to detect OS and install dependencies
install_deps() {
    if [ -f /etc/debian_version ]; then
        apt-get update
        apt-get install -y wget curl tar certbot
    elif [ -f /etc/redhat-release ]; then
        yum install -y wget curl tar certbot
    else
        echo "Unsupported OS for auto-dependency install. Please ensure wget, curl, tar, and certbot are installed."
    fi
}

# 1. Install Dependencies
echo "Installing dependencies..."
install_deps

# 2. Check for Installer
if [ ! -f "ooklaserver.sh" ]; then
    echo "ooklaserver.sh not found. Downloading..."
    wget https://install.speedtest.net/ooklaserver/ooklaserver.sh
    chmod +x ooklaserver.sh
fi

# 3. Install OoklaServer
echo "Installing OoklaServer binary..."
./ooklaserver.sh install -f

# 4. Configure SSL (Optional Generation)
echo ""
echo "--------------------------------------------------------"
echo "SSL CONFIGURATION"
echo "--------------------------------------------------------"
echo "If you have migrated 'ookla-server-migration.tar.gz' with certs included,"
echo "you can skip generating new keys."
echo ""
echo "However, if this is a fresh install or you prefer to generate new keys,"
echo "we can use Certbot (Let's Encrypt) now."
echo "**IMPORTANT**: Your Domain DNS must already point to THIS server's IP."
echo ""
read -p "Do you want to generate new SSL certificates now? (y/n): " gen_ssl

if [ "$gen_ssl" = "y" ] || [ "$gen_ssl" = "Y" ]; then
    read -p "Enter your domain name (e.g., speedtest.example.com): " DOMAIN
    
    if [ -n "$DOMAIN" ]; then
        echo "Generating SSL certificate for $DOMAIN..."
        
        # Stop any process on port 80 just in case
        ./ooklaserver.sh stop
        
        certbot certonly --standalone --preferred-challenges http -d "$DOMAIN" --non-interactive --agree-tos --register-unsafely-without-email
        
        if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
            echo "Certificate generated successfully!"
            
            # Update OoklaServer.properties to point to the new system certs
            echo "Updating OoklaServer.properties..."
            sed -i "s|openSSL.server.certificateFile = .*|openSSL.server.certificateFile = /etc/letsencrypt/live/$DOMAIN/fullchain.pem|g" OoklaServer.properties
            sed -i "s|openSSL.server.privateKeyFile = .*|openSSL.server.privateKeyFile = /etc/letsencrypt/live/$DOMAIN/privkey.pem|g" OoklaServer.properties
            
            # Ensure file permissions allow reading (OoklaServer often runs as root, but good practice)
        else
            echo "Error: Certificate generation failed. Please check your DNS settings and firewall (Port 80)."
        fi
    else
        echo "No domain entered. Skipping SSL generation."
    fi
else
    echo "Skipping SSL generation. Assuming existing certs or migration bundle."
    
    # If using migration bundle (certs/ folder), ensure permissions
    if [ -d "certs" ]; then
        chmod 600 certs/*
        # Ensure config points to local certs if we are using the migration bundle logic
        # But if the user just downloaded this script fresh, OoklaServer.properties might be default.
        # We assume the user creates/edits OoklaServer.properties separately or it came from the bundle.
    fi
fi

echo "--------------------------------------------------------"
echo "Setup Complete!"
echo "--------------------------------------------------------"
echo "To start the server, run:"
echo "  ./ooklaserver.sh start"
