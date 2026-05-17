#!/bin/bash

# Exit immediately if any command fails
set -e

echo "=================================================="
echo " Starting Spotify Connect Receiver Setup (Snap Mode)"
echo "=================================================="

# 1. Install System Dependencies
echo "[*] Installing core utilities and audio tools..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y snapd bluez bluez-tools alsa-utils curl

# Ensure snapd service is active (required on bare Debian)
sudo systemctl enable --now snapd.service
# Create the necessary symlink for classic snap support on Debian
sudo ln -s /var/lib/snapd/snap /snap || true

echo "[*] Waiting for snapd to fully initialize..."
sleep 5

# 2. Install Librespot via Snap
echo "[*] Installing librespot-dev from snap..."
sudo snap install librespot-dev

# Ensure our environment knows where snap binaries live
export PATH="$PATH:/snap/bin"

# 3. Create the Systemd service to run Librespot in the background
echo "[*] Creating background service using Rodio backend..."
sudo bash -c 'cat << EOF > /etc/systemd/system/librespot.service
[Unit]
Description=Librespot Spotify Connect Receiver (Snap)
After=network.target sound.target snapd.service

[Service]
# We point to the explicit snap binary location and use the working rodio backend
ExecStart=/snap/bin/librespot-dev.librespot --name "PiSpeaker" --backend rodio
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF'

# 4. Fix headless audio permissions
echo "[*] Enabling user session lingering for headless playback..."
sudo loginctl enable-linger $USER

# 5. Reload systemd and spin up the service
echo "[*] Starting the Spotify Connect service..."
sudo systemctl daemon-reload
sudo systemctl enable librespot
sudo systemctl start librespot

echo "=================================================="
echo " Setup Complete!"
echo "=================================================="
echo "Your receiver is running in the background."
echo "Simply pair your Bluetooth speaker via bluetoothctl,"
echo "and 'PiSpeaker' will stay alive and ready on Spotify!"
echo "=================================================="