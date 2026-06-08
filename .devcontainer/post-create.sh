#!/usr/bin/env bash
# Post-create setup for devcontainer - make executable helper scripts
chmod +x /workspace/scripts/run-qemu.sh || true

# Optionally install python websockify dependencies in user site
python3 -m pip install --user --upgrade websockify || true

echo "Devcontainer post-create complete. Use the VS Code Tasks or run ./scripts/run-qemu.sh to start the VM."
