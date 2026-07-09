#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Updating package list and installing dependencies ==="
sudo apt update
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl

echo "=== Adding Caddy GPG security key ==="
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

echo "=== Adding official Caddy repository ==="
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list

echo "=== Installing Caddy web server ==="
sudo apt update
sudo apt install -y caddy

echo "=== Enabling and starting Caddy service ==="
sudo systemctl daemon-reload
sudo systemctl enable --now caddy

echo "=== Caddy Installation Complete ==="
caddy version
