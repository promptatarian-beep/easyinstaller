# VibeOS in a Codespace / Devcontainer

This workspace adds a devcontainer that builds VibeOS and exposes the QEMU VM desktop through noVNC so you can interact with the OS in your browser.

Quick start (Codespaces / Devcontainer):

1. Open this repository in GitHub Codespaces or VS Code Remote - Containers.
2. The container will be built from `.devcontainer/Dockerfile`.
3. In the container, open the Terminal and run one of the VS Code tasks (Terminal > Run Task):
   - "VibeOS: make disk" — create disk image
   - "VibeOS: build all" — build kernel and userspace
   - "VibeOS: run (QEMU + noVNC)" — starts QEMU (via `make run`) and launches noVNC on port 6080

4. Forward port 6080 (Codespaces will auto-forward). Open the forwarded port in your browser to see the desktop.

Notes and caveats:
- DOOM requires `doom1.wad` or `DOOM.WAD` placed in the workspace at `vibeos_root/games/doom1.wad` (not included due to licensing).
- Nested virtualization / KVM may not be available in Codespaces; QEMU will use emulation mode and can be slower.
- If `make run` does not launch QEMU with VNC, edit `scripts/run-qemu.sh` to invoke QEMU with `-vnc :0` or adjust your Makefile.

Security:
- Do not commit secrets into the devcontainer. The noVNC port is exposed within your Codespace — close it when not testing.
