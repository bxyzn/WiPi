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

# 2. Install Rust and compile Librespot natively
echo "[*] Installing Rust and compiling Librespot from source..."

# Install the Rust toolchain non-interactively
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# Add compiler essentials required for building native dependencies
sudo apt install -y build-essential libasound2-dev pkg-config libpulse-dev

# Use Cargo to fetch, build, and install librespot globally with pulseaudio support
cargo install librespot --features "pulseaudio-backend"

# Move the compiled binary to your global system bin path
sudo cp "$HOME/.cargo/bin/librespot" /usr/local/bin/

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

    v c cv  cv  