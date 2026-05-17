#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=================================================="
echo " Starting Spotify Connect Receiver Setup"
echo "=================================================="

# 1. Update system and install system dependencies
echo "[*] Installing audio and bluetooth packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y pulseaudio pulseaudio-module-bluetooth bluez bluez-tools alsa-utils curl wget

# 2. Download and install the official Librespot binary
echo "[*] Fetching latest official Librespot binary..."
# Detect architecture (handles your VM vs the future Pi Zero 2 W which is aarch64/arm64)
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    URL="https://github.com/librespot-org/librespot/releases/latest/download/librespot-linux-amd64.tar.gz"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    URL="https://github.com/librespot-org/librespot/releases/latest/download/librespot-linux-arm64.tar.gz"
else
    URL="https://github.com/librespot-org/librespot/releases/latest/download/librespot-linux-armhf.tar.gz"
fi

wget -O librespot.tar.gz "$URL"
tar -xvzf librespot.tar.gz
chmod +x librespot
sudo mv librespot /usr/local/bin/
rm librespot.tar.gz

# 3. Create the Systemd service to manage Librespot background run
echo "[*] Creating background service..."
sudo bash -c 'cat << EOF > /etc/systemd/system/librespot.service
[Unit]
Description=Librespot Spotify Connect Receiver
After=network.target sound.target

[Service]
ExecStart=/usr/local/bin/librespot --name "PiSpeaker" --backend pulseaudio
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF'

# 4. Enable PulseAudio linger for headless environments
echo "[*] Enabling user lingering for seamless headless audio..."
sudo loginctl enable-linger $USER

# 5. Reload services
sudo systemctl daemon-reload
sudo systemctl enable librespot

echo "=================================================="
echo " Setup Complete!"
echo " Next Steps to Demo:"
echo " 1. Pair your speaker via 'bluetoothctl'"
echo " 2. Run 'sudo systemctl start librespot'"
echo " 3. Open Spotify on your phone and select 'PiSpeaker'"
echo "=================================================="