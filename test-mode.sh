#!/bin/bash
# ============================================================
#  test-mode.sh — Test the accountability app without building
#
#  This script starts a local web server to preview the popup
#  in your browser without needing to build the Tauri app.
#
#  Usage: ./test-mode.sh
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$SCRIPT_DIR/app/src"

# Colors
BOLD='\033[1m'
GREEN='\033[32m'
CYAN='\033[36m'
RESET='\033[0m'

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║         RESORT TO GROW — Test Mode                  ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  This will start a local web server to preview the"
echo -e "  accountability popup in your browser."
echo ""
echo -e "  ${CYAN}Features:${RESET}"
echo -e "  • Preview the popup UI"
echo -e "  • Test Yes/No flows"
echo -e "  • No Tauri APIs (browser mode)"
echo ""
echo -e "  ${GREEN}Press Enter to start...${RESET}"
read -r

# Create a simple preview HTML file
PREVIEW_FILE="/tmp/resort-to-grow-preview.html"

cat > "$PREVIEW_FILE" << 'PREVIEW_EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Resort To Grow — Preview</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            background: #0c1118;
            color: #eef0f3;
            font-family: 'Inter', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }
        .preview-container {
            max-width: 600px;
            width: 100%;
            background: rgba(18, 24, 32, 0.96);
            border-radius: 18px;
            padding: 24px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
        }
        .preview-header {
            text-align: center;
            margin-bottom: 24px;
        }
        .preview-header h1 {
            font-size: 1.5rem;
            font-weight: 800;
            background: linear-gradient(135deg, #fff 50%, #f5a623 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .preview-header p {
            color: #8a95a3;
            font-size: 0.9rem;
            margin-top: 4px;
        }
        .preview-frame {
            border: 2px dashed rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            overflow: hidden;
            margin-bottom: 16px;
        }
        .preview-frame iframe {
            width: 100%;
            height: 500px;
            border: none;
        }
        .preview-controls {
            display: flex;
            gap: 12px;
            justify-content: center;
        }
        .preview-btn {
            background: #f5a623;
            color: #000;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .preview-btn:hover {
            background: #e6951a;
            transform: translateY(-1px);
        }
        .preview-btn.secondary {
            background: rgba(255, 255, 255, 0.07);
            color: #eef0f3;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .preview-btn.secondary:hover {
            background: rgba(255, 255, 255, 0.1);
        }
    </style>
</head>
<body>
    <div class="preview-container">
        <div class="preview-header">
            <h1>RESORT TO GROW</h1>
            <p>Preview Mode — Test the popup in your browser</p>
        </div>
        <div class="preview-frame">
            <iframe id="popup-frame" src="index.html"></iframe>
        </div>
        <div class="preview-controls">
            <button class="preview-btn" onclick="reloadPopup()">Reload Popup</button>
            <button class="preview-btn secondary" onclick="resetData()">Reset Data</button>
            <button class="preview-btn secondary" onclick="window.open('http://localhost:1422', '_blank')">Open Dashboard</button>
        </div>
    </div>
    <script>
        function reloadPopup() {
            document.getElementById('popup-frame').src = 'index.html';
        }
        function resetData() {
            localStorage.removeItem('accountability_history');
            localStorage.removeItem('accountability_onboarding_completed');
            reloadPopup();
        }
    </script>
</body>
</html>
PREVIEW_EOF

echo ""
echo -e "  ${GREEN}Starting preview server...${RESET}"
echo ""
echo -e "  Open this URL in your browser:"
echo -e "  ${CYAN}file://$PREVIEW_FILE${RESET}"
echo ""
echo -e "  Or run this command to start a local server:"
echo -e "  ${CYAN}cd $APP_DIR && python3 -m http.server 8080${RESET}"
echo ""
echo -e "  Then open: ${CYAN}http://localhost:8080${RESET}"
echo ""
echo -e "  ${GREEN}Press Enter to open in browser...${RESET}"
read -r

# Try to open in browser
if command -v xdg-open &> /dev/null; then
    xdg-open "$PREVIEW_FILE"
elif command -v open &> /dev/null; then
    open "$PREVIEW_FILE"
else
    echo -e "  Please open the file manually in your browser."
fi

echo ""
echo -e "  ${GREEN}Preview started!${RESET}"
echo -e "  Close the browser tab to stop."
echo ""
