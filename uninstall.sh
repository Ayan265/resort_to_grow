#!/bin/bash
# ============================================================
#  uninstall.sh — Remove Resort To Grow completely
#
#  This script removes:
#  - Autostart entries
#  - App menu entries
#  - Built binaries
#  - Config files
#  - History data (with confirmation)
#
#  Usage: ./uninstall.sh
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
BOLD='\033[1m'
DIM='\033[2m'
AMBER='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
CYAN='\033[36m'
RESET='\033[0m'

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║       RESORT TO GROW — Uninstaller                  ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  This will remove Resort To Grow from your system."
echo ""

# Confirm
read -rp "  Are you sure you want to uninstall? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo -e "  ${RED}Uninstall cancelled.${RESET}"
  exit 0
fi

echo ""
echo -e "${AMBER}Removing...${RESET}"
echo ""

# ────────────────────────────────────────────────────────────
#  1. Stop running processes
# ────────────────────────────────────────────────────────────
echo -e "  ${DIM}[1/5]${RESET} Stopping running processes..."
pkill -f "accountability-app" 2>/dev/null || true
pkill -f "server.py.*1422" 2>/dev/null || true
pkill -f "server.py.*1423" 2>/dev/null || true
sleep 1
echo -e "  ${GREEN}✓${RESET} Processes stopped"

# ────────────────────────────────────────────────────────────
#  2. Remove autostart entries
# ────────────────────────────────────────────────────────────
echo -e "  ${DIM}[2/5]${RESET} Removing autostart entries..."
AUTOSTART_DIR="$HOME/.config/autostart"
rm -f "$AUTOSTART_DIR/accountability-reminder.desktop"
rm -f "$AUTOSTART_DIR/accountability-dashboard.desktop"
rm -f "$AUTOSTART_DIR/accountability-config.desktop"
echo -e "  ${GREEN}✓${RESET} Autostart entries removed"

# ────────────────────────────────────────────────────────────
#  3. Remove app menu entries
# ────────────────────────────────────────────────────────────
echo -e "  ${DIM}[3/5]${RESET} Removing app menu entries..."
APP_MENU_DIR="$HOME/.local/share/applications"
rm -f "$APP_MENU_DIR/resort-to-grow-dashboard.desktop"
echo -e "  ${GREEN}✓${RESET} App menu entries removed"

# ────────────────────────────────────────────────────────────
#  4. Remove built binaries
# ────────────────────────────────────────────────────────────
echo -e "  ${DIM}[4/5]${RESET} Removing built binaries..."
rm -rf "$SCRIPT_DIR/app/src-tauri/target"
echo -e "  ${GREEN}✓${RESET} Binaries removed"

# ────────────────────────────────────────────────────────────
#  5. Ask about history and config
# ────────────────────────────────────────────────────────────
echo -e "  ${DIM}[5/5]${RESET} Data cleanup..."
echo ""

# History file
HISTORY_FILE="$HOME/.accountability_history.json"
if [ -f "$HISTORY_FILE" ]; then
  echo -e "  Found history file: ${DIM}$HISTORY_FILE${RESET}"
  read -rp "  Delete check-in history? [y/N]: " DELETE_HISTORY
  if [[ "$DELETE_HISTORY" =~ ^[Yy]$ ]]; then
    rm -f "$HISTORY_FILE"
    echo -e "  ${GREEN}✓${RESET} History deleted"
  else
    echo -e "  ${DIM}→ History kept${RESET}"
  fi
fi

# Config files
echo ""
read -rp "  Delete personalization (images, config)? [y/N]: " DELETE_CONFIG
if [[ "$DELETE_CONFIG" =~ ^[Yy]$ ]]; then
  # Keep placeholder.jpg but remove user images
  cd "$SCRIPT_DIR/app/src/images"
  for f in *; do
    if [ "$f" != "placeholder.jpg" ] && [ "$f" != "README.md" ]; then
      rm -f "$f"
    fi
  done
  echo -e "  ${GREEN}✓${RESET} User images removed"
  
  # Reset config to defaults
  if [ -f "$SCRIPT_DIR/personalize.sh" ]; then
    echo -e "  ${DIM}→ Run ./personalize.sh to reconfigure${RESET}"
  fi
else
  echo -e "  ${DIM}→ Config and images kept${RESET}"
fi

# ────────────────────────────────────────────────────────────
#  Complete
# ────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║             Uninstall Complete!                      ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  Resort To Grow has been removed from your system."
echo ""
echo -e "  ${DIM}To reinstall, run:${RESET}"
echo -e "  ${BOLD}./setup-autostart.sh${RESET}"
echo ""
