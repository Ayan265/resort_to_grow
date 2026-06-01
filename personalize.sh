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
RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/app/src/config.js"
IMAGES_DIR="$SCRIPT_DIR/app/src/images"

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║     RESORT TO GROW — Personalization Wizard      ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${DIM}This wizard will walk you through making the app yours.${RESET}"
echo -e "${DIM}Just answer the questions — no coding needed.${RESET}"
echo ""

# ────────────────────────────────────────────────────────────
#  STEP 1: Your Name
# ────────────────────────────────────────────────────────────

echo -e "${AMBER}${BOLD}Step 1 of 5: Your Name${RESET}"
echo -e "The app uses your name in motivational messages."
echo ""
read -rp "   What's your name? " USER_NAME
USER_NAME="${USER_NAME:-Friend}"
echo -e "   ${GREEN}✓${RESET} Got it, ${BOLD}$USER_NAME${RESET}."
echo ""

# ────────────────────────────────────────────────────────────
#  STEP 2: Timer Interval
# ────────────────────────────────────────────────────────────

echo -e "${AMBER}${BOLD}Step 2 of 5: Check-in Frequency${RESET}"
echo -e "How often should the popup interrupt you? (in minutes)"
echo -e "${DIM}   Common choices: 15, 20, 30, 45, 60${RESET}"
echo ""
read -rp "   Minutes between popups [30]: " TIMER_MINS
TIMER_MINS="${TIMER_MINS:-30}"

# Validate it's a number
if ! [[ "$TIMER_MINS" =~ ^[0-9]+$ ]] || [ "$TIMER_MINS" -lt 1 ]; then
  echo -e "   ${RED}That doesn't look right. Using 30 minutes.${RESET}"
  TIMER_MINS=30
fi

echo -e "   ${GREEN}✓${RESET} The popup will appear every ${BOLD}$TIMER_MINS minutes${RESET}."
echo ""

# ────────────────────────────────────────────────────────────
#  STEP 3: Personal Images
# ────────────────────────────────────────────────────────────

echo -e "${AMBER}${BOLD}Step 3 of 5: Your Motivation Images${RESET}"
echo -e "The app shows personal images during check-ins to keep you"
echo -e "emotionally connected to your goals."
echo ""
echo -e "You need ${BOLD}6 images${RESET}. They can be photos of:"
echo -e "   • Yourself  • Someone you love  • Your goals"
echo -e "   • Anything that makes you want to work harder"
echo ""
echo -e "${DIM}Supported formats: .jpg, .jpeg, .png, .webp${RESET}"
echo -e "${DIM}Best size: under 500 KB each, square or portrait.${RESET}"
echo ""

# List current images
echo -e "Images currently in your images folder (${DIM}$IMAGES_DIR${RESET}):"
echo ""
EXISTING_IMAGES=$(find "$IMAGES_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) ! -name 'placeholder.jpg' 2>/dev/null | sort)

if [ -z "$EXISTING_IMAGES" ]; then
  echo -e "   ${RED}(no images found — only the placeholder)${RESET}"
else
  i=1
  while IFS= read -r img; do
    echo -e "   $i. $(basename "$img")"
    ((i++))
  done <<< "$EXISTING_IMAGES"
fi
echo ""

IMAGE_NAMES=("mainPhoto" "pleaImage" "motivationLeft" "motivationRight" "summaryLeft" "summaryRight")
IMAGE_LABELS=(
  "Main Photo (circular image on the check-in screen)"
  "Plea Image (shown when you click 'Not really')"
  "Left Motivation Image (left side of the motivation screen)"
  "Right Motivation Image (right side of the motivation screen)"
  "Summary Photo Left (left ring on the progress page)"
  "Summary Photo Right (right ring on the progress page)"
)

declare -A IMAGE_FILES

echo -e "Now, either ${BOLD}drag and drop${RESET} image files into this folder:"
echo -e "   ${DIM}$IMAGES_DIR${RESET}"
echo ""
echo -e "Or type the filename for each slot. If the file is already"
echo -e "in the images folder, just type the name (e.g. ${DIM}photo.jpg${RESET})."
echo -e "Press Enter to keep the current image (shown in brackets)."
echo ""

# Defaults from current config
CURRENT_DEFAULTS=("/trigger.png" "/6.jpg" "/3.png" "/4.png" "/trigger.png" "/1.png")

for idx in "${!IMAGE_NAMES[@]}"; do
  label="${IMAGE_LABELS[$idx]}"
  default="${CURRENT_DEFAULTS[$idx]}"
  default_name=$(basename "$default")

  read -rp "   ${label} [${default_name}]: " chosen
  chosen="${chosen:-$default_name}"

  # If they gave a full path, copy it to images dir
  if [[ "$chosen" == /* ]] || [[ "$chosen" == ~/* ]]; then
    expanded_path="${chosen/#\~/$HOME}"
    if [ -f "$expanded_path" ]; then
      cp "$expanded_path" "$IMAGES_DIR/"
      chosen=$(basename "$expanded_path")
      echo -e "   ${GREEN}✓${RESET} Copied to images folder."
    else
      echo -e "   ${RED}File not found. Using default: $default_name${RESET}"
      chosen="$default_name"
    fi
  fi

  # Make sure it starts with /
  [[ "$chosen" != /* ]] && chosen="/$chosen"
  IMAGE_FILES[${IMAGE_NAMES[$idx]}]="$chosen"
done

echo ""
echo -e "   ${GREEN}✓${RESET} Images configured."
echo ""

# ────────────────────────────────────────────────────────────
#  STEP 4: Personal Messages
# ────────────────────────────────────────────────────────────

echo -e "${AMBER}${BOLD}Step 4 of 5: Personal Messages${RESET}"
echo -e "These appear on the \"Not really\" screens."
echo -e "Press Enter to keep the current message."
echo ""

read -rp "   Plea question (shown with your image when you're slacking)
   [$USER_NAME, Don't you want me?]: " PLEA_Q
PLEA_Q="${PLEA_Q:-$USER_NAME, Don\'t you want me?}"

read -rp "   Plea button text [I will work hard]: " PLEA_BTN
PLEA_BTN="${PLEA_BTN:-I will work hard}"

read -rp "   Second motivation button text [I have to become worthy]: " WORTHY_BTN
WORTHY_BTN="${WORTHY_BTN:-I have to become worthy}"

echo ""
echo -e "   ${GREEN}✓${RESET} Messages set."
echo ""

# ────────────────────────────────────────────────────────────
#  STEP 5: Journey Affirmations
# ────────────────────────────────────────────────────────────

echo -e "${AMBER}${BOLD}Step 5 of 5: Affirmation Journey${RESET}"
echo -e "When you click \"Yes, I am working hard\", the app shows a"
echo -e "series of affirmation screens. Each has a statement and"
echo -e "an image."
echo ""
echo -e "How many affirmation steps do you want? (1-5)"
read -rp "   Number of steps [3]: " JOURNEY_COUNT
JOURNEY_COUNT="${JOURNEY_COUNT:-3}"
if ! [[ "$JOURNEY_COUNT" =~ ^[0-9]+$ ]] || [ "$JOURNEY_COUNT" -lt 1 ] || [ "$JOURNEY_COUNT" -gt 5 ]; then
  JOURNEY_COUNT=3
fi

JOURNEY_QUESTIONS=()
JOURNEY_BUTTONS=()
JOURNEY_IMAGES=()

for ((j=1; j<=JOURNEY_COUNT; j++)); do
  echo ""
  echo -e "   ${BOLD}Affirmation #$j:${RESET}"
  read -rp "      Statement: " jq
  jq="${jq:-I am becoming the best version of myself}"
  JOURNEY_QUESTIONS+=("$jq")

  read -rp "      Button text [Yes]: " jb
  jb="${jb:-Yes}"
  JOURNEY_BUTTONS+=("$jb")

  read -rp "      Image filename [placeholder.jpg]: " ji
  ji="${ji:-placeholder.jpg}"
  [[ "$ji" != /* ]] && ji="/$ji"
  JOURNEY_IMAGES+=("$ji")
done

echo ""
echo -e "   ${GREEN}✓${RESET} Journey configured with ${BOLD}$JOURNEY_COUNT${RESET} steps."
echo ""

# ────────────────────────────────────────────────────────────
#  GENERATE CONFIG.JS
# ────────────────────────────────────────────────────────────

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

cat > "$CONFIG_FILE" << CONFIGEOF
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

echo -e "   ${GREEN}✓${RESET} Config saved to ${DIM}$CONFIG_FILE${RESET}"
echo ""

# ────────────────────────────────────────────────────────────
#  ASK IF USER WANTS TO BUILD NOW
# ────────────────────────────────────────────────────────────

echo -e "${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║               Personalization Complete!           ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "Your settings have been saved. Next steps:"
echo ""
echo -e "  ${BOLD}1.${RESET} Make sure your images are in:  ${DIM}$IMAGES_DIR${RESET}"
echo -e "  ${BOLD}2.${RESET} Build and install the app:     ${BOLD}./setup-autostart.sh${RESET}"
echo ""
read -rp "Would you like to build and install now? [Y/n]: " DO_BUILD
DO_BUILD="${DO_BUILD:-Y}"

if [[ "$DO_BUILD" =~ ^[Yy] ]]; then
  echo ""
  echo -e "${AMBER}Building and installing...${RESET}"
  # Remove old binary so setup-autostart.sh rebuilds
  rm -f "$SCRIPT_DIR/app/src-tauri/target/release/accountability-app"
  bash "$SCRIPT_DIR/setup-autostart.sh"
  echo ""
  echo -e "${GREEN}${BOLD}All done!${RESET} The app is now running and will start on login."
  echo -e "Right-click the tray icon → ${BOLD}Dashboard${RESET} to see your progress."
else
  echo ""
  echo -e "No problem! When you're ready, run:  ${BOLD}./setup-autostart.sh${RESET}"
fi

echo ""
