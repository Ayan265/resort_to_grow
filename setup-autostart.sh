#!/bin/bash
# ============================================================
#  setup-autostart.sh — Build and configure auto-login start
#  Run this from the root of the resort_to_grow project.
# ============================================================

set -e

# Resolve the project root (directory where this script lives)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$SCRIPT_DIR/app"
BINARY="$APP_DIR/src-tauri/target/release/accountability-app"
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/accountability-reminder.desktop"
DASHBOARD_DESKTOP="$AUTOSTART_DIR/accountability-dashboard.desktop"

echo "=== Resort To Grow — Autostart Setup ==="
echo ""

# Build the Tauri app if the binary doesn't exist
if [ ! -f "$BINARY" ]; then
  echo "[1/3] Building the Tauri desktop app..."
  cd "$APP_DIR" && npm install && npm run tauri build
  if [ ! -f "$BINARY" ]; then
    echo "ERROR: Build failed. Binary not found at $BINARY"
    exit 1
  fi
  echo "      Build complete."
else
  echo "[1/3] Binary already exists, skipping build."
fi

# Create autostart directory
mkdir -p "$AUTOSTART_DIR"

# Create .desktop file for the Tauri popup app
echo "[2/3] Creating autostart entry for the popup app..."
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=Accountability Reminder
Comment=Check-in popup every 30 minutes to keep you focused
Exec=$BINARY
Icon=$APP_DIR/src-tauri/icons/128x128.png
Terminal=false
StartupNotify=false
X-GNOME-Autostart-enabled=true
EOF

# Create .desktop file for the dashboard server
echo "[3/3] Creating autostart entry for the dashboard server..."
cat > "$DASHBOARD_DESKTOP" <<EOF
[Desktop Entry]
Type=Application
Name=Accountability Dashboard Server
Comment=Local web server for the focus analytics dashboard
Exec=/usr/bin/python3 $SCRIPT_DIR/dashboard/server.py
Terminal=false
StartupNotify=false
X-GNOME-Autostart-enabled=true
EOF

echo ""
echo "Done! Both the popup app and dashboard will start on login."
echo ""
echo "To start them right now:"
echo "  $BINARY &"
echo "  python3 $SCRIPT_DIR/dashboard/server.py &"