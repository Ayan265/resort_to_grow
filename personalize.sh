#!/bin/bash
# ============================================================
#  personalize.sh — Make this app yours.
#
#  This interactive wizard helps you personalize the
#  accountability app WITHOUT editing any code.
#
#  Run it:   ./personalize.sh
# ============================================================

set -e

# Colors for pretty output
BOLD='\033[1m'
DIM='\033[2m'
AMBER='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
CYAN='\033[36m'
RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/app/src/config.js"
IMAGES_DIR="$SCRIPT_DIR/app/src/images"

clear 2>/dev/null || true
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║       RESORT TO GROW — Personalization Wizard       ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${CYAN}${BOLD}What is this app?${RESET}"
echo ""
echo -e "  This app pops up every 30 minutes while you work and"
echo -e "  asks: ${BOLD}\"Are you really working hard right now?\"${RESET}"
echo ""
echo -e "  If you say ${GREEN}YES${RESET} → It shows affirmation screens with your"
echo -e "  photos, asks what you're working on, and closes."
echo ""
echo -e "  If you say ${RED}NOT REALLY${RESET} → It shows your motivation photos,"
echo -e "  makes you wait 15 seconds per screen (to absorb the guilt),"
echo -e "  asks what's blocking you, and makes you write a commitment"
echo -e "  before it lets you go back to work."
echo ""
echo -e "${DIM}  The idea: It uses YOUR personal photos and messages to"
echo -e "  hold you emotionally accountable. That's why we need"
echo -e "  you to set it up with images that matter to YOU.${RESET}"
echo ""
echo -e "${DIM}  Press Enter to start the setup...${RESET}"
read -r

# ────────────────────────────────────────────────────────────
#  STEP 1: Your Name
# ────────────────────────────────────────────────────────────

clear 2>/dev/null || true
echo ""
echo -e "${AMBER}${BOLD}━━━ Step 1 of 5: Your Name ━━━${RESET}"
echo ""
echo -e "  The app uses your name in motivation messages."
echo -e "  For example: ${DIM}\"Ayan, don't you want to achieve your goals?\"${RESET}"
echo ""
read -rp "  What's your name? " USER_NAME
USER_NAME="${USER_NAME:-Friend}"
echo ""
echo -e "  ${GREEN}✓${RESET} Got it, ${BOLD}$USER_NAME${RESET}."
sleep 1

# ────────────────────────────────────────────────────────────
#  STEP 2: Timer Interval
# ────────────────────────────────────────────────────────────

clear 2>/dev/null || true
echo ""
echo -e "${AMBER}${BOLD}━━━ Step 2 of 5: How Often Should It Pop Up? ━━━${RESET}"
echo ""
echo -e "  The popup will interrupt your work at this interval."
echo -e "  It does NOT pop up when you first log in — only after"
echo -e "  the first interval passes."
echo ""
echo -e "  ${DIM}Common choices:${RESET}"
echo -e "    ${BOLD}15${RESET} min — Very aggressive (for hardcore focus)"
echo -e "    ${BOLD}30${RESET} min — Recommended (balanced)"
echo -e "    ${BOLD}60${RESET} min — Gentle (once per hour)"
echo ""
read -rp "  Minutes between popups [30]: " TIMER_MINS
TIMER_MINS="${TIMER_MINS:-30}"

# Validate it's a number
if ! [[ "$TIMER_MINS" =~ ^[0-9]+$ ]] || [ "$TIMER_MINS" -lt 1 ]; then
  echo -e "  ${RED}Invalid input. Using 30 minutes.${RESET}"
  TIMER_MINS=30
fi

echo ""
echo -e "  ${GREEN}✓${RESET} Popup will appear every ${BOLD}$TIMER_MINS minutes${RESET}."
sleep 1

# ────────────────────────────────────────────────────────────
#  STEP 3: Personal Images
# ────────────────────────────────────────────────────────────

clear 2>/dev/null || true
echo ""
echo -e "${AMBER}${BOLD}━━━ Step 3 of 5: Your Motivation Images ━━━${RESET}"
echo ""
echo -e "  ${BOLD}This is the most important part.${RESET}"
echo ""
echo -e "  The app shows personal images on different screens."
echo -e "  Use photos of yourself, someone you love, your goals,"
echo -e "  or anything that makes you want to work harder."
echo ""
echo -e "  ${CYAN}The app has 6 image slots:${RESET}"
echo ""
echo -e "  ${BOLD}1. Main Photo${RESET}"
echo -e "     ${DIM}A circular photo on the check-in screen (the first thing you see).${RESET}"
echo -e "     ${DIM}Best: a photo of yourself or a close-up of someone you love.${RESET}"
echo ""
echo -e "  ${BOLD}2. Plea Image${RESET}"
echo -e "     ${DIM}Shown when you click \"Not really\" — a big image to guilt-trip you.${RESET}"
echo -e "     ${DIM}Best: a powerful emotional photo.${RESET}"
echo ""
echo -e "  ${BOLD}3. Left Motivation Image${RESET}"
echo -e "     ${DIM}Left side of the dual-image screen (second \"Not really\" screen).${RESET}"
echo ""
echo -e "  ${BOLD}4. Right Motivation Image${RESET}"
echo -e "     ${DIM}Right side of the dual-image screen.${RESET}"
echo ""
echo -e "  ${BOLD}5. Summary Left Photo${RESET}"
echo -e "     ${DIM}Small ring photo on the daily progress page.${RESET}"
echo ""
echo -e "  ${BOLD}6. Summary Right Photo${RESET}"
echo -e "     ${DIM}Second ring photo on the daily progress page.${RESET}"
echo ""
echo -e "  ${CYAN}How to add images:${RESET}"
echo -e "  • Type the ${BOLD}full path${RESET} to an image file on your computer"
echo -e "    (e.g. ${DIM}/home/you/Pictures/photo.jpg${RESET})"
echo -e "  • OR drag the file from your file manager into this terminal"
echo -e "  • OR just press Enter to use the placeholder for now"
echo ""
echo -e "  ${DIM}Supported formats: .jpg .jpeg .png .webp${RESET}"
echo -e "  ${DIM}Best size: under 500 KB, square or portrait.${RESET}"
echo ""

IMAGE_NAMES=("mainPhoto" "pleaImage" "motivationLeft" "motivationRight" "summaryLeft" "summaryRight")
IMAGE_LABELS=(
  "1. Main Photo (circular check-in image)"
  "2. Plea Image (guilt-trip image)"
  "3. Left Motivation Image"
  "4. Right Motivation Image"
  "5. Summary Left Photo"
  "6. Summary Right Photo"
)

declare -A IMAGE_FILES

for idx in "${!IMAGE_NAMES[@]}"; do
  label="${IMAGE_LABELS[$idx]}"

  read -rp "  ${label}
  Path or Enter to skip: " chosen

  # Trim whitespace and surrounding quotes (drag-drop often adds quotes)
  chosen=$(echo "$chosen" | sed "s/^['\"]//;s/['\"]$//;s/^[[:space:]]*//;s/[[:space:]]*$//")

  if [ -z "$chosen" ]; then
    IMAGE_FILES[${IMAGE_NAMES[$idx]}]="/placeholder.jpg"
    echo -e "  ${DIM}→ Using placeholder${RESET}"
  else
    # Expand ~ to $HOME
    expanded_path="${chosen/#\~/$HOME}"

    if [ -f "$expanded_path" ]; then
      # Copy the file into images/ dir
      filename=$(basename "$expanded_path")
      cp "$expanded_path" "$IMAGES_DIR/$filename"
      IMAGE_FILES[${IMAGE_NAMES[$idx]}]="/$filename"
      echo -e "  ${GREEN}✓${RESET} Copied ${BOLD}$filename${RESET} to images folder."
    else
      echo -e "  ${RED}File not found: $expanded_path${RESET}"
      echo -e "  ${DIM}→ Using placeholder instead${RESET}"
      IMAGE_FILES[${IMAGE_NAMES[$idx]}]="/placeholder.jpg"
    fi
  fi
  echo ""
done

echo -e "  ${GREEN}✓${RESET} Images configured."
sleep 1

# ────────────────────────────────────────────────────────────
#  STEP 4: Personal Messages
# ────────────────────────────────────────────────────────────

clear 2>/dev/null || true
echo ""
echo -e "${AMBER}${BOLD}━━━ Step 4 of 5: Your Personal Messages ━━━${RESET}"
echo ""
echo -e "  These messages appear when you click \"Not really\"."
echo ""
echo -e "  ${BOLD}Screen 1: The Plea Screen${RESET}"
echo -e "  ${DIM}Shows your plea image with a question and a button.${RESET}"
echo ""

read -rp "  Plea question (e.g. \"$USER_NAME, don't you want to succeed?\")
  [${USER_NAME}, don't you want to achieve your goals?]: " PLEA_Q
PLEA_Q="${PLEA_Q:-${USER_NAME}, don\'t you want to achieve your goals?}"

echo ""
read -rp "  Plea button text [I will work hard]: " PLEA_BTN
PLEA_BTN="${PLEA_BTN:-I will work hard}"

echo ""
echo -e "  ${BOLD}Screen 2: The Dual Image Screen${RESET}"
echo -e "  ${DIM}Shows two motivation images side by side with a button.${RESET}"
echo ""

read -rp "  Button text [I have to become worthy]: " WORTHY_BTN
WORTHY_BTN="${WORTHY_BTN:-I have to become worthy}"

echo ""
echo -e "  ${GREEN}✓${RESET} Messages set."
sleep 1

# ────────────────────────────────────────────────────────────
#  STEP 5: Journey Affirmations
# ────────────────────────────────────────────────────────────

clear 2>/dev/null || true
echo ""
echo -e "${AMBER}${BOLD}━━━ Step 5 of 5: Affirmation Journey ━━━${RESET}"
echo ""
echo -e "  When you click ${GREEN}\"Yes, I am\"${RESET}, the app shows a series of"
echo -e "  affirmation screens before logging your work."
echo ""
echo -e "  Each screen has:"
echo -e "    • A ${BOLD}statement${RESET} (your affirmation)"
echo -e "    • A ${BOLD}button${RESET} (to confirm and continue)"
echo -e "    • An ${BOLD}image${RESET} (a motivation photo)"
echo ""
echo -e "  ${DIM}Example:${RESET}"
echo -e "    Statement: \"I am becoming the best version of myself.\""
echo -e "    Button: \"Yes, I am.\""
echo -e "    Image: /photo.jpg"
echo ""

read -rp "  How many affirmation steps? (1-5) [3]: " JOURNEY_COUNT
JOURNEY_COUNT="${JOURNEY_COUNT:-3}"
if ! [[ "$JOURNEY_COUNT" =~ ^[0-9]+$ ]] || [ "$JOURNEY_COUNT" -lt 1 ] || [ "$JOURNEY_COUNT" -gt 5 ]; then
  JOURNEY_COUNT=3
fi

JOURNEY_QUESTIONS=()
JOURNEY_BUTTONS=()
JOURNEY_IMAGES=()

DEFAULT_STATEMENTS=(
  "I am becoming the best version of myself."
  "Every minute of focus brings me closer to my goals."
  "I will not waste this opportunity."
  "The work I do today defines my tomorrow."
  "I refuse to be average."
)
DEFAULT_BUTTONS=("Yes, I am." "Absolutely." "Never." "Let's go." "Always.")

for ((j=1; j<=JOURNEY_COUNT; j++)); do
  echo ""
  echo -e "  ${BOLD}── Affirmation #$j ──${RESET}"
  idx=$((j-1))

  default_q="${DEFAULT_STATEMENTS[$idx]}"
  read -rp "  Statement [$default_q]: " jq
  jq="${jq:-$default_q}"
  JOURNEY_QUESTIONS+=("$jq")

  default_b="${DEFAULT_BUTTONS[$idx]}"
  read -rp "  Button text [$default_b]: " jb
  jb="${jb:-$default_b}"
  JOURNEY_BUTTONS+=("$jb")

  read -rp "  Image path (or Enter for placeholder): " ji
  ji=$(echo "$ji" | sed "s/^['\"]//;s/['\"]$//;s/^[[:space:]]*//;s/[[:space:]]*$//")

  if [ -z "$ji" ]; then
    JOURNEY_IMAGES+=("/placeholder.jpg")
    echo -e "  ${DIM}→ Using placeholder${RESET}"
  else
    expanded="${ji/#\~/$HOME}"
    if [ -f "$expanded" ]; then
      fname=$(basename "$expanded")
      cp "$expanded" "$IMAGES_DIR/$fname"
      JOURNEY_IMAGES+=("/$fname")
      echo -e "  ${GREEN}✓${RESET} Copied ${BOLD}$fname${RESET}"
    else
      echo -e "  ${RED}File not found. Using placeholder.${RESET}"
      JOURNEY_IMAGES+=("/placeholder.jpg")
    fi
  fi
done

echo ""
echo -e "  ${GREEN}✓${RESET} Journey configured with ${BOLD}$JOURNEY_COUNT${RESET} steps."
sleep 1

# ────────────────────────────────────────────────────────────
#  GENERATE CONFIG.JS
# ────────────────────────────────────────────────────────────

clear 2>/dev/null || true
echo ""
echo -e "${AMBER}${BOLD}Generating your config...${RESET}"

# Escape single quotes in strings for JS
escape_js() {
  echo "$1" | sed "s/'/\\\\'/g"
}

# Build journey array
JOURNEY_JS=""
for ((j=0; j<JOURNEY_COUNT; j++)); do
  q=$(escape_js "${JOURNEY_QUESTIONS[$j]}")
  b=$(escape_js "${JOURNEY_BUTTONS[$j]}")
  i="${JOURNEY_IMAGES[$j]}"
  JOURNEY_JS+="    {
      question: '${q}',
      button: '${b}',
      image: '${i}',
    },
"
done

PLEA_Q_ESC=$(escape_js "$PLEA_Q")
PLEA_BTN_ESC=$(escape_js "$PLEA_BTN")
WORTHY_BTN_ESC=$(escape_js "$WORTHY_BTN")

cat > "$CONFIG_FILE" <<CONFIGEOF
// ================================================================
//  CONFIG.JS — All your personal customizations live here.
//  You do NOT need to touch any other file to change the content.
//
//  To re-run the personalization wizard: ./personalize.sh
// ================================================================

export const CONFIG = {

  // ----------------------------------------------------------------
  //  TIMER (in minutes)
  //  How often the accountability popup should appear.
  // ----------------------------------------------------------------
  timerIntervalMinutes: ${TIMER_MINS},

  // ----------------------------------------------------------------
  //  DASHBOARD
  //  URL of the local analytics dashboard.
  //  The dashboard server runs on this address (see dashboard/server.py).
  //  Change the port here AND in dashboard/server.py if you want a
  //  different one.
  // ----------------------------------------------------------------
  dashboardUrl: 'http://localhost:1422',

  // ----------------------------------------------------------------
  //  IMAGES
  //  Place your image files in the app/src/images/ folder.
  //  Use a leading slash before the filename: '/myimage.jpg'
  //  Supported formats: .jpg, .jpeg, .png, .webp
  // ----------------------------------------------------------------
  images: {
    mainPhoto: '${IMAGE_FILES[mainPhoto]}',       // Circular photo on the check-in page
    pleaImage: '${IMAGE_FILES[pleaImage]}',       // Image on "Not really" plea screen
    motivationLeft: '${IMAGE_FILES[motivationLeft]}',   // Left image in the dual motivation screen
    motivationRight: '${IMAGE_FILES[motivationRight]}',  // Right image in the dual motivation screen
    summaryLeft: '${IMAGE_FILES[summaryLeft]}',     // Left ring on Today's Check-ins page
    summaryRight: '${IMAGE_FILES[summaryRight]}',    // Right ring on Today's Check-ins page
  },

  // ----------------------------------------------------------------
  //  CHECK-IN PAGE (the first popup you see)
  // ----------------------------------------------------------------
  checkin: {
    question: 'Are you really working hard right now?',
    yesButton: 'Yes, I am',
    noButton: 'Not really',
    summaryLink: "Today's progress",
  },

  // ----------------------------------------------------------------
  //  "NOT REALLY" FLOW
  //  Shown when you click "Not really" on the check-in page.
  // ----------------------------------------------------------------
  noPath: {
    pleaQuestion: '${PLEA_Q_ESC}',
    pleaButton: '${PLEA_BTN_ESC}',
    worthyButton: '${WORTHY_BTN_ESC}',
  },

  // ----------------------------------------------------------------
  //  "YES" JOURNEY
  //  A sequence of affirmation screens shown when you click "Yes".
  //  Each entry needs: question, button (label), image (filename)
  // ----------------------------------------------------------------
  journey: [
${JOURNEY_JS}  ],

  // ----------------------------------------------------------------
  //  MOTIVATIONAL MESSAGES
  //  Random quotes shown across different screens.
  // ----------------------------------------------------------------
  quotes: {
    trigger: [
      '"Your future self is watching you right now."',
      '"Every wasted minute is a choice you made."',
      '"Discipline is remembering what you want."',
      '"You don\\'t rise to your goals — you fall to your systems."',
      '"Are you becoming who you said you\\'d be?"',
      '"Time doesn\\'t wait. Neither should you."',
      '"Small consistent effort beats everything."',
      '"What would the best version of you do right now?"',
      '"The work you avoid today becomes the regret of tomorrow."',
      '"Nobody cares about your potential. Show results."',
    ],

    yesHeadline: [
      'Good. Keep going.',
      "Respect. Don't stop now.",
      "This is how it's done.",
      'That discipline will pay off.',
      'Stay locked in.',
      "You're doing the real work.",
    ],
    yesSub: [
      "You're building something real. Don't stop now.",
      'Consistency separates winners from everyone else.',
      'This is the version of you that matters.',
      "One more focused session. That's all it takes.",
      'Your future self will thank you for this moment.',
    ],

    encouragement: [
      '"You\\'re smarter than this. Find a way to adapt."',
      '"One small step right now changes everything."',
      '"You\\'ve overcome harder things before. Do it again."',
      '"The struggle is temporary. The result is permanent."',
      '"Stop thinking. Start doing. Now."',
      '"You know what to do. Go do it."',
      '"This feeling will pass. Your work will remain."',
      '"Every expert was once a beginner who refused to quit."',
      '"You\\'re not tired. You\\'re uninspired. Find your reason."',
      '"The pain of discipline weighs ounces. The pain of regret weighs tons."',
    ],

    customAdvice: [
      "Take a deep breath. Write down what's really wrong. Then solve one piece of it.",
      "You identified the problem — that's half the battle. Now take the smallest possible action.",
      "Break it down. What's the ONE thing you can do in the next 5 minutes?",
      'Acknowledge it, accept it, and then move forward.',
      'Stop analyzing. Pick the smallest step and do it right now.',
    ],
  },

  // ----------------------------------------------------------------
  //  PROBLEM PICKER — buttons on "What's getting in your way?"
  // ----------------------------------------------------------------
  problems: [
    {
      id: 'distraction',
      label: 'Distraction',
      advice: 'Close the distraction right now. Just close it. You know what it is.',
    },
    {
      id: 'laziness',
      label: 'Laziness',
      advice: "Just start for 5 minutes. That's it. 5 minutes. You'll keep going.",
    },
    {
      id: 'confusion',
      label: 'Confusion',
      advice: 'Break it into 3 tiny steps. Write them down. Do the first one now.',
    },
    {
      id: 'low-energy',
      label: 'Low Energy',
      advice: 'Stand up. Drink water. Stretch for 2 minutes. Then come back stronger.',
    },
  ],

  // ----------------------------------------------------------------
  //  WINDOW SIZES (you generally don't need to change these)
  // ----------------------------------------------------------------
  window: {
    default: { width: 600, height: 680 },
    dualImages: { width: 1040, height: 760 },
  },

};
CONFIGEOF

echo -e "  ${GREEN}✓${RESET} Config saved to ${DIM}$CONFIG_FILE${RESET}"
echo ""

# ────────────────────────────────────────────────────────────
#  ASK IF USER WANTS TO BUILD NOW
# ────────────────────────────────────────────────────────────

echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║             Personalization Complete!                ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${BOLD}What happens next:${RESET}"
echo ""
echo -e "  The app needs to be built (compiled) before it can run."
echo -e "  This takes about 1-2 minutes the first time."
echo ""
echo -e "  After building, it will:"
echo -e "    • Install a tray icon (small icon in your taskbar)"
echo -e "    • Start popping up every ${BOLD}$TIMER_MINS minutes${RESET}"
echo -e "    • Auto-start when you log in to your computer"
echo ""
read -rp "  Build and install now? [Y/n]: " DO_BUILD
DO_BUILD="${DO_BUILD:-Y}"

if [[ "$DO_BUILD" =~ ^[Yy] ]]; then
  echo ""
  echo -e "${AMBER}Building and installing...${RESET}"
  echo -e "${DIM}(This takes 1-2 minutes — please wait)${RESET}"
  echo ""
  # Remove old binary so setup-autostart.sh rebuilds
  rm -f "$SCRIPT_DIR/app/src-tauri/target/release/accountability-app"
  bash "$SCRIPT_DIR/setup-autostart.sh"
  echo ""
  echo -e "${GREEN}${BOLD}All done!${RESET}"
  echo ""
  echo -e "  The app is now running in your system tray."
  echo -e "  The first popup will appear in ${BOLD}$TIMER_MINS minutes${RESET}."
  echo ""
  echo -e "  ${BOLD}To see your dashboard:${RESET}"
  echo -e "    • Right-click the tray icon → Dashboard"
  echo -e "    • Or open ${CYAN}http://localhost:1422${RESET} in your browser"
  echo ""
  echo -e "  ${BOLD}To change settings later:${RESET}"
  echo -e "    Just run ${BOLD}./personalize.sh${RESET} again."
else
  echo ""
  echo -e "  No problem! When you're ready, run:  ${BOLD}./setup-autostart.sh${RESET}"
fi

echo ""
