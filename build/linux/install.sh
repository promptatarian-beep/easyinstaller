#!/bin/bash
# Easy Diffusion Installer
# Version: 2.5

set -e

INSTALL_DIR="${HOME}/.local/easy diffusion"

echo "Installing Easy Diffusion to $INSTALL_DIR..."

mkdir -p "$INSTALL_DIR"
cp -r ./* "$INSTALL_DIR/"

# Create launcher script
cat > ~/.local/bin/easy diffusion << 'EOF'
#!/bin/bash
cd "$INSTALL_DIR"
exec ./start.sh "$@"
EOF

chmod +x ~/.local/bin/easy diffusion

echo "✓ Installation complete!"
echo "Run: easy diffusion"
