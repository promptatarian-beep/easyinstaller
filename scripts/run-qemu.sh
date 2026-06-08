#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Ensure disk image exists
if [ ! -f disk.img ]; then
  echo "disk.img not found — running 'make disk'"
  make disk
fi

# Helper to launch QEMU via the repo's Makefile if available
if make -n run >/dev/null 2>&1; then
  echo "Launching VibeOS via 'make run' (this will block)."
  # Run in background so we can start websockify
  make run &
  QEMU_PID=$!
  echo "QEMU PID=$QEMU_PID"
else
  echo "No 'make run' target detected — please run QEMU manually or update Makefile."
  exit 1
fi

# Wait a bit for QEMU to start and listen for VNC (5900)
echo "Waiting for QEMU..."
sleep 4

# Start websockify (noVNC) mapping 6080 -> 5900
WS_PORT=6080
VNC_HOST=127.0.0.1
VNC_PORT=5900

echo "Starting websockify on port ${WS_PORT} -> ${VNC_HOST}:${VNC_PORT}"
# Use the bundled websockify if available
WEBSOCKIFY_PY="/opt/noVNC/utils/websockify/run"
if [ -x "$WEBSOCKIFY_PY" ]; then
  python3 "$WEBSOCKIFY_PY" --web /opt/noVNC ${WS_PORT} ${VNC_HOST}:${VNC_PORT} &
else
  # fallback to system websockify
  websockify --web /opt/noVNC ${WS_PORT} ${VNC_HOST}:${VNC_PORT} &
fi
WEBSOCKIFY_PID=$!

echo "noVNC web UI should be available on port ${WS_PORT}."

echo "To stop: kill $QEMU_PID $WEBSOCKIFY_PID"

wait $QEMU_PID
