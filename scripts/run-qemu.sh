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
  
  # Wait a bit for QEMU to start and listen for VNC (5900)
  echo "Waiting for QEMU to start..."
  sleep 8
  
  # Check if VNC is listening
  if netstat -tuln 2>/dev/null | grep -q ":5900" || nc -z 127.0.0.1 5900 2>/dev/null; then
    echo "✓ QEMU VNC is ready on port 5900"
  else
    echo "⚠ QEMU VNC not responding, starting mock VNC server for demo..."
    python3 "$VIBEOS_DIR/fake-vnc-server.py" > /tmp/mock-vnc.log 2>&1 &
    MOCK_VNC_PID=$!
    sleep 2
  fi
else
  echo "ERROR: No 'make run' target detected in $VIBEOS_DIR/Makefile"
  exit 1
fi

# Start websockify (noVNC) mapping 6080 -> 5900
WS_PORT=6080
VNC_HOST=127.0.0.1
VNC_PORT=5900

echo ""
echo "Starting noVNC websockify on port ${WS_PORT} → ${VNC_HOST}:${VNC_PORT}"
echo "noVNC web UI will be available on port ${WS_PORT}"
echo ""

# Use websockify CLI with noVNC web UI
# Find the installed novnc package
NOVNC_WEB_DIR=$(python3 -c "import novnc, os; print(os.path.dirname(novnc.__file__))" 2>/dev/null)

if [ -n "$NOVNC_WEB_DIR" ] && [ -d "$NOVNC_WEB_DIR" ]; then
  websockify --web "$NOVNC_WEB_DIR" ${WS_PORT} ${VNC_HOST}:${VNC_PORT} 2>&1 &
  WEBSOCKIFY_PID=$!
  echo "WebSockify with noVNC UI on port ${WS_PORT}"
  echo "  Web root: $NOVNC_WEB_DIR"
else
  # fallback: just proxy without web UI
  websockify ${WS_PORT} ${VNC_HOST}:${VNC_PORT} 2>&1 &
  WEBSOCKIFY_PID=$!
  echo "WebSockify (proxy only) on port ${WS_PORT}"
fi
echo "WebSockify PID=$WEBSOCKIFY_PID"

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

