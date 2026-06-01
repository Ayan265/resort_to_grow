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
  timerIntervalMinutes: 30,

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
    mainPhoto: '/placeholder.jpg',       // Circular photo on the check-in page
    pleaImage: '/placeholder.jpg',       // Image on "Not really" plea screen
    motivationLeft: '/placeholder.jpg',  // Left image in the dual motivation screen
    motivationRight: '/placeholder.jpg', // Right image in the dual motivation screen
    summaryLeft: '/placeholder.jpg',     // Left ring on Today's Check-ins page
    summaryRight: '/placeholder.jpg',    // Right ring on Today's Check-ins page
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
    pleaQuestion: 'Don\'t you want to achieve your goals?',
    pleaButton: 'I will work hard',
    worthyButton: 'I have to become worthy',
  },

  // ----------------------------------------------------------------
  //  "YES" JOURNEY
  //  A sequence of affirmation screens shown when you click "Yes".
  //  Each entry needs: question, button (label), image (filename)
  // ----------------------------------------------------------------
  journey: [
    {
      question: 'I am becoming the best version of myself.',
      button: 'Yes, I am.',
      image: '/placeholder.jpg',
    },
    {
      question: 'Every minute of focus brings me closer to my goals.',
      button: 'Absolutely.',
      image: '/placeholder.jpg',
    },
    {
      question: 'I will not waste this opportunity.',
      button: 'Never.',
      image: '/placeholder.jpg',
    },
  ],

  // ----------------------------------------------------------------
  //  MOTIVATIONAL MESSAGES
  //  Random quotes shown across different screens.
  // ----------------------------------------------------------------
  quotes: {
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
