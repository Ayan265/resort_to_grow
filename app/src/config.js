// ================================================================
//  CONFIG.JS — All your personal customizations live here.
//  You do NOT need to touch any other file to change the content.
// ================================================================

export const CONFIG = {

  // ----------------------------------------------------------------
  //  TIMER (in minutes)
  //  How often the accountability popup should appear.
  // ----------------------------------------------------------------
  timerIntervalMinutes: 30,

  // ----------------------------------------------------------------
  //  IMAGES
  //  Place your image files in the src/images/ folder, then update names here.
  //  Use a leading slash: '/myimage.jpg'
  //  See src/images/README.md for full instructions.
  //  Supported formats: .jpg, .jpeg, .png, .webp
  // ----------------------------------------------------------------
  images: {
    mainPhoto: '/trigger.png',  // Circular photo on the check-in page
    pleaImage: '/6.jpg',        // Image on "Not really" plea screen
    motivationLeft: '/3.png',        // Left image in the dual motivation screen
    motivationRight: '/4.png',        // Right image in the dual motivation screen
    summaryLeft: '/trigger.png',  // Left ring on Today's Check-ins page
    summaryRight: '/1.png',        // Right ring on Today's Check-ins page
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
    // --- Plea Screen ---
    pleaQuestion: "Ayan, Don't you want me?",
    pleaButton: 'I will work hard',

    // --- Dual Motivation Images Screen ---
    worthyButton: 'I have to become worthy of her. What you are doing Moron',
  },

  // ----------------------------------------------------------------
  //  "YES" JOURNEY
  //  A sequence of affirmation screens shown when you click "Yes, I am".
  //  Add, remove, or edit entries freely.
  //  Each entry needs: question, button (button label), image (filename)
  // ----------------------------------------------------------------
  journey: [
    {
      question: 'We will be together right?',
      button: 'Yes',
      image: '/6.jpg',
    },
    {
      question: 'I am becoming worthy of her',
      button: 'Yes',
      image: '/6.jpg',
    },
    {
      question: 'I am Ayan, son of Baidya Nath Kundu',
      button: 'Right!',
      image: '/5.jpg',
    },
  ],

  // ----------------------------------------------------------------
  //  MOTIVATIONAL MESSAGES
  //  Random quotes and messages shown across different screens.
  // ----------------------------------------------------------------
  quotes: {
    // Shown below the main check-in question (random each time)
    trigger: [
      '"Your future self is watching you right now."',
      '"Every wasted minute is a choice you made."',
      '"Discipline is remembering what you want."',
      '"You don\'t rise to your goals — you fall to your systems."',
      '"Are you becoming who you said you\'d be?"',
      '"Time doesn\'t wait. Neither should you."',
      '"Small consistent effort beats everything."',
      '"What would the best version of you do right now?"',
      '"The work you avoid today becomes the regret of tomorrow."',
      '"Nobody cares about your potential. Show results."',
    ],

    // Shown on the "Yes, I am" encouragement screen
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

    // Shown on the advice screen after selecting a problem
    encouragement: [
      '"You\'re smarter than this. Find a way to adapt."',
      '"One small step right now changes everything."',
      '"You\'ve overcome harder things before. Do it again."',
      '"The struggle is temporary. The result is permanent."',
      '"Stop thinking. Start doing. Now."',
      '"You know what to do. Go do it."',
      '"This feeling will pass. Your work will remain."',
      '"Every expert was once a beginner who refused to quit."',
      '"You\'re not tired. You\'re uninspired. Find your reason."',
      '"The pain of discipline weighs ounces. The pain of regret weighs tons."',
    ],

    // Shown when you type a custom problem and submit
    customAdvice: [
      "Take a deep breath. Write down what's really wrong. Then solve one piece of it.",
      "You identified the problem — that's half the battle. Now take the smallest possible action.",
      "Break it down. What's the ONE thing you can do in the next 5 minutes?",
      'Acknowledge it, accept it, and then move forward.',
      'Stop analyzing. Pick the smallest step and do it right now.',
    ],
  },

  // ----------------------------------------------------------------
  //  PROBLEM PICKER
  //  The 4 problem buttons on the "What's getting in your way?" screen.
  //  label = button text, advice = what you'll be told to do
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
  //  WINDOW SIZES (in logical pixels)
  //  You generally don't need to change these.
  // ----------------------------------------------------------------
  window: {
    default: { width: 600, height: 680 },  // Normal popup size
    dualImages: { width: 1040, height: 760 },  // Expanded for dual image screen
  },

};
