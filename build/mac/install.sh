#!/bin/bash
# Easy Diffusion Installer (macOS)
# Version: 2.5

set -e

INSTALL_DIR="/Applications/Easy Diffusion"

echo "Installing Easy Diffusion to $INSTALL_DIR..."

sudo mkdir -p "$INSTALL_DIR"
sudo cp -r ./* "$INSTALL_DIR/"

echo "✓ Installation complete!"
echo "Run: open /Applications/Easy Diffusion/start.sh"
