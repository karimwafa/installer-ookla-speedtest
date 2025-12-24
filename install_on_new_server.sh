#!/bin/bash

echo "Starting Ookla Speedtest Server Migration Setup..."

# Ensure we have the installer script
if [ ! -f "ooklaserver.sh" ]; then
    echo "Error: ooklaserver.sh not found in current directory."
    exit 1
fi

chmod +x ooklaserver.sh

# Run the official installer
# -f forces install without prompts
echo "Installing OoklaServer binary..."
./ooklaserver.sh install -f

# The bundle already contains the correct OoklaServer.properties and certs directory
# We just need to make sure permissions are correct
echo "Applying configuration..."
if [ -d "certs" ]; then
    chmod 600 certs/*
fi

echo "--------------------------------------------------------"
echo "Migration Setup Complete!"
echo "--------------------------------------------------------"
echo "To start the server, run:"
echo "  ./ooklaserver.sh start"
echo ""
echo "To test if it's working:"
echo "  tail -fooklaserver.log"
