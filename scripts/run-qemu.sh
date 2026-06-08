#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VIBEOS_DIR="${REPO_ROOT}/vibeos"
cd "$VIBEOS_DIR"

echo "VibeOS directory: $VIBEOS_DIR"
echo ""

# Ensure disk image exists
if [ ! -f disk.img ]; then
  echo "disk.img not found — building with 'make disk'"
  make disk
fi

# Helper to launch QEMU via the repo's Makefile if available
if make -n run >/dev/null 2>&1; then
  echo "Launching VibeOS via 'make run' in background..."
  # Run in background so we can start websockify
  make run > /tmp/qemu.log 2>&1 &
  QEMU_PID=$!
  echo "QEMU PID=$QEMU_PID"
else
  echo "ERROR: No 'make run' target detected in $VIBEOS_DIR/Makefile"
  exit 1
fi

# Wait a bit for QEMU to start and listen for VNC (5900)
echo "Waiting for QEMU to start..."
sleep 5

# Check if VNC is listening
if netstat -tuln 2>/dev/null | grep -q ":5900" || nc -z 127.0.0.1 5900 2>/dev/null; then
  echo "✓ QEMU VNC is ready on port 5900"
else
  echo "⚠ VNC port 5900 not responding yet, but continuing..."
fi

# Start websockify (noVNC) mapping 6080 -> 5900
WS_PORT=6080
VNC_HOST=127.0.0.1
VNC_PORT=5900

echo ""
echo "Starting noVNC websockify on port ${WS_PORT} → ${VNC_HOST}:${VNC_PORT}"
echo "noVNC web UI will be available on port ${WS_PORT}"
echo ""

# Use the bundled websockify if available
WEBSOCKIFY_PY="/opt/noVNC/utils/websockify/run"
if [ -x "$WEBSOCKIFY_PY" ]; then
  python3 "$WEBSOCKIFY_PY" --web /opt/noVNC ${WS_PORT} ${VNC_HOST}:${VNC_PORT} 2>&1 &
  WEBSOCKIFY_PID=$!
  echo "WebSockify PID=$WEBSOCKIFY_PID"
else
  # fallback to system websockify
  websockify --web /opt/noVNC ${WS_PORT} ${VNC_HOST}:${VNC_PORT} 2>&1 &
  WEBSOCKIFY_PID=$!
  echo "WebSockify (system) PID=$WEBSOCKIFY_PID"
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "✓ VibeOS is running!"
echo "✓ Open your browser to port 6080 to view the noVNC console"
echo "════════════════════════════════════════════════════════"
echo ""
echo "QEMU PID: $QEMU_PID"
echo "WebSockify PID: $WEBSOCKIFY_PID"
echo ""
echo "To stop:"
echo "  kill $QEMU_PID $WEBSOCKIFY_PID"
echo ""

# Wait for QEMU to finish
wait $QEMU_PID || true

