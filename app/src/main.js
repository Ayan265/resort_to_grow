// =====================================================
//  ACCOUNTABILITY REMINDER — main.js
//  All content lives in config.js — edit that instead.
// =====================================================

import { CONFIG } from './config.js';

// --- Tauri APIs (null in browser mode) ---
let tauriInvoke   = null;
let tauriGetWindow = null;
let LogicalSize   = null;

async function loadTauri() {
  try {
    const { invoke }           = await import('@tauri-apps/api/core');
    const { getCurrentWindow } = await import('@tauri-apps/api/window');
    const dpi                  = await import('@tauri-apps/api/dpi');
    tauriInvoke   = invoke;
    tauriGetWindow = getCurrentWindow;
    LogicalSize   = dpi.LogicalSize;
  } catch {
    console.log('[accountability] Browser mode — Tauri APIs not available');
  }
}

// --- Utilities ---
function randomFrom(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

// =====================================================
//  LOCAL STORAGE
// =====================================================

const STORAGE_KEY = 'accountability_history';

function getHistory() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch { return []; }
}

function saveEntry(entry) {
  const history = getHistory();
  history.push({ ...entry, timestamp: new Date().toISOString() });
  localStorage.setItem(STORAGE_KEY, JSON.stringify(history));
}

function getTodayEntries() {
  const todayStr = new Date().toISOString().slice(0, 10);
  return getHistory().filter(e => e.timestamp?.startsWith(todayStr));
}

function getCurrentStreak() {
  const entries = getTodayEntries();
  let streak = 0;
  for (let i = entries.length - 1; i >= 0; i--) {
    if (entries[i].type === 'productive') streak++;
    else break;
  }
  return streak;
}

function resetAllData() {
  localStorage.removeItem(STORAGE_KEY);
  tauriInvoke?.('reset_history').catch(() => {});
}

// =====================================================
//  APPLY CONFIG TO DOM
// =====================================================

function applyConfig() {
  const { images, checkin, noPath, problems } = CONFIG;

  // Images
  document.getElementById('main-photo').src         = images.mainPhoto;
  document.getElementById('plea-image').src          = images.pleaImage;
  document.getElementById('motivation-image-1').src  = images.motivationLeft;
  document.getElementById('motivation-image-2').src  = images.motivationRight;
  document.getElementById('summary-photo-1').src     = images.summaryLeft;
  document.getElementById('summary-photo-2').src     = images.summaryRight;

  // Check-in page text
  document.getElementById('btn-yes').childNodes[0].textContent = checkin.yesButton + ' ';
  document.getElementById('btn-no').childNodes[0].textContent  = checkin.noButton + ' ';
  document.getElementById('btn-summary').textContent = checkin.summaryLink;

  // Satisfaction label — dynamic interval
  const mins = CONFIG.timerIntervalMinutes;
  const satisfactionLbl = document.getElementById('satisfaction-label');
  if (satisfactionLbl) satisfactionLbl.textContent = `Satisfied with your last ${mins} minute${mins === 1 ? '' : 's'}?`;

  // No-path text
  document.getElementById('plea-question').textContent = noPath.pleaQuestion;
  document.getElementById('btn-work-hard').textContent = noPath.pleaButton;
  document.getElementById('btn-worthy').textContent    = noPath.worthyButton;

  // Problem grid — render from config
  const grid = document.getElementById('problem-grid');
  const iconMap = {
    distraction:  'icon-distraction',
    laziness:     'icon-laziness',
    confusion:    'icon-confusion',
    'low-energy': 'icon-energy',
  };
  problems.forEach(p => {
    const btn = document.createElement('button');
    btn.className = 'btn problem-btn';
    btn.dataset.problem = p.id;
    btn.dataset.action  = p.advice;
    btn.innerHTML = `
      <span class="problem-icon-css ${iconMap[p.id] || ''}"></span>
      <span class="problem-label">${p.label}</span>
    `;
    grid.appendChild(btn);
  });
}

// =====================================================
//  APP LOGIC
// =====================================================

document.addEventListener('DOMContentLoaded', async () => {
  await loadTauri();
  applyConfig();

  // Start the background timer loop in Rust
  if (tauriInvoke && CONFIG.timerIntervalMinutes) {
    tauriInvoke('start_timer', { intervalMinutes: CONFIG.timerIntervalMinutes })
      .catch(err => console.error('[accountability] Failed to start timer:', err));
  }

  // --- Window resize helper ---
  async function resizeWindow(w, h) {
    if (!tauriGetWindow || !LogicalSize) return;
    try {
      const win = tauriGetWindow();
      await win.setSize(new LogicalSize(w, h));
      await win.center();
    } catch (err) {
      console.log('[accountability] Resize skipped:', err);
    }
  }

  // --- DOM: Steps ---
  const stepCheckin    = document.getElementById('step-checkin');
  const stepNoPlea     = document.getElementById('step-no-plea');
  const stepNoImages   = document.getElementById('step-no-images');
  const stepYesJourney = document.getElementById('step-yes-journey');
  const stepYes        = document.getElementById('step-yes');
  const stepProblem    = document.getElementById('step-problem');
  const stepAdvice     = document.getElementById('step-advice');
  const stepSummary    = document.getElementById('step-summary');
  const allSteps = [stepCheckin, stepNoPlea, stepNoImages, stepYesJourney, stepYes, stepProblem, stepAdvice, stepSummary];
  const stepsWithOwnImage = [stepNoPlea, stepNoImages, stepYesJourney, stepSummary];

  // --- DOM: Layout ---
  const containerEl         = document.querySelector('.container');
  const mainPhotoSection    = document.getElementById('main-photo-section');
  const progressFill        = document.getElementById('progress-fill');
  const progressLabelRow    = document.getElementById('progress-label-row');
  const progressPctBadge    = document.getElementById('progress-pct-badge');
  const stepFlowIndicator   = document.getElementById('step-flow-indicator');
  const streakDisplay       = document.getElementById('streak-display');
  const streakCount         = document.getElementById('streak-count');

  // --- DOM: Check-in ---
  const greetingEl = document.getElementById('greeting-text');
  const quoteEl    = document.getElementById('trigger-quote');
  const btnYes     = document.getElementById('btn-yes');
  const btnNo      = document.getElementById('btn-no');
  const btnSummary = document.getElementById('btn-summary');
  const btnDashboard = document.getElementById('btn-dashboard');
  const btnDashboardFromSummary = document.getElementById('btn-dashboard-from-summary');

  // --- DOM: Journey (Yes path) ---
  const btnJourneyAnswer  = document.getElementById('btn-journey-answer');
  const journeyQuestionEl = document.getElementById('journey-question');
  const journeyImageEl    = document.getElementById('journey-image');

  // --- DOM: Yes encouragement ---
  const yesMessageEl     = document.getElementById('yes-message');
  const yesSubEl         = document.getElementById('yes-sub');
  const taskInput        = document.getElementById('task-input');
  const taskHint         = document.getElementById('task-hint');
  const satisfactionBtns = document.querySelectorAll('[data-satisfied]');

  // --- DOM: No path ---
  const btnWorkHard = document.getElementById('btn-work-hard');
  const btnWorthy   = document.getElementById('btn-worthy');

  // --- DOM: Problem picker ---
  const customInput     = document.getElementById('custom-problem-input');
  const btnCustomSubmit = document.getElementById('btn-custom-submit');

  // --- DOM: Advice ---
  const adviceTextEl    = document.getElementById('advice-text');
  const encourageTextEl = document.getElementById('encourage-text');
  const commitInput     = document.getElementById('commit-input');
  const commitHint      = document.getElementById('commit-hint');
  const btnGotIt        = document.getElementById('btn-got-it');

  // --- DOM: Summary ---
  const statProductive     = document.getElementById('stat-productive');
  const statStruggled      = document.getElementById('stat-struggled');
  const statTotal          = document.getElementById('stat-total');
  const summaryBarFill     = document.getElementById('summary-bar-fill');
  const summaryPercent     = document.getElementById('summary-percent');
  const historyList        = document.getElementById('history-list');
  const btnBackFromSummary = document.getElementById('btn-back-from-summary');

  // --- State ---
  let alreadySaved = false;
  let currentStep  = 'checkin';

  // =====================================================
  //  STEP FLOW INDICATOR
  // =====================================================

  // Steps: checkin(0), journey(1), yes(2)  OR  checkin(0), plea(1), images(2), problem(3), advice(4)
  const FLOW_YES  = ['checkin', 'journey', 'yes'];
  const FLOW_NO   = ['checkin', 'plea', 'images', 'problem', 'advice'];
  let currentFlow = FLOW_YES;

  function buildFlowDots(flow, activeIdx) {
    stepFlowIndicator.innerHTML = '';
    flow.forEach((_, i) => {
      const dot = document.createElement('div');
      dot.className = 'flow-dot';
      if (i < activeIdx)  dot.classList.add('done');
      if (i === activeIdx) dot.classList.add('active');
      stepFlowIndicator.appendChild(dot);
    });
  }

  function setFlowStep(stepName) {
    // Determine which flow we're in
    if (['plea', 'images', 'problem', 'advice'].includes(stepName)) {
      currentFlow = FLOW_NO;
    } else if (['journey', 'yes'].includes(stepName)) {
      currentFlow = FLOW_YES;
    }
    // If it's checkin, keep whichever flow was last (or default YES)
    const idx = currentFlow.indexOf(stepName);
    buildFlowDots(currentFlow, idx === -1 ? 0 : idx);
  }

  // =====================================================
  //  CORE FUNCTIONS
  // =====================================================

  let isTransitioning = false;

  async function showStep(stepToShow, immediate = false) {
    if (isTransitioning) return;

    // Show/hide flow indicator for full-screen image steps
    const hideIndicator = stepsWithOwnImage.includes(stepToShow);
    stepFlowIndicator.classList.toggle('hidden', hideIndicator);

    if (!immediate) {
      isTransitioning = true;
      const current = document.querySelector('.step:not(.hidden)');
      if (current && current !== stepToShow) {
        current.style.transition = 'opacity 0.25s ease, transform 0.25s ease';
        current.style.opacity = '0';
        current.style.transform = 'translateY(8px)';
        await new Promise(r => setTimeout(r, 250));
        current.style.opacity = '';
        current.style.transform = '';
        current.style.transition = '';
      }
    }

    allSteps.forEach(s => s.classList.add('hidden'));
    stepToShow.classList.remove('hidden');

    const hideMain = stepsWithOwnImage.includes(stepToShow);
    mainPhotoSection.classList.toggle('hidden', hideMain);

    stepToShow.classList.remove('fade-in');
    mainPhotoSection.classList.remove('fade-in');
    void stepToShow.offsetWidth;

    stepToShow.classList.add('fade-in');
    if (!hideMain) mainPhotoSection.classList.add('fade-in');

    isTransitioning = false;
  }

  window.onAppShow = () => {
    const current = document.querySelector('.step:not(.hidden)');
    if (current) showStep(current, true);
  };

  async function closePopup() {
    const { width, height } = CONFIG.window.default;
    await resizeWindow(width, height);
    if (tauriGetWindow) {
      try { await tauriGetWindow().hide(); }
      catch (err) { console.error('[accountability] Error hiding window:', err); }
    }
    containerEl.classList.remove('container-expanded');
    taskInput.value   = '';
    commitInput.value = '';
    customInput.value = '';
    taskHint.classList.add('hidden');
    commitHint.classList.add('hidden');
    commitInput.style.borderColor = '';
    showStep(stepCheckin, true);
    initCheckin();
  }

  function getTimeGreeting() {
    const h = new Date().getHours();
    if (h < 6)  return 'Late night. Still going?';
    if (h < 12) return 'Good morning.';
    if (h < 17) return 'Quick check-in.';
    if (h < 21) return 'Still with me?';
    return 'Late session. Be honest.';
  }

  function updateProgressBar() {
    const entries = getTodayEntries();
    if (!entries.length) {
      progressFill.style.width = '0%';
      progressLabelRow.classList.add('hidden');
      return;
    }
    const pct = Math.round(entries.filter(e => e.type === 'productive').length / entries.length * 100);
    progressFill.style.width = `${pct}%`;
    progressPctBadge.textContent = `${pct}%`;
    progressLabelRow.classList.remove('hidden');
  }

  function updateStreak() {
    const streak = getCurrentStreak();
    streakCount.textContent = streak;
    streakDisplay.classList.toggle('hidden', streak < 2);
  }

  function startButtonCooldown(btn, ms) {
    if (btn._cooldownInterval) clearInterval(btn._cooldownInterval);
    const TICK_MS = 50;
    let elapsed = 0;
    const originalText = btn.textContent;
    btn.classList.add('btn-disabled', 'counting');
    btn.style.setProperty('--fill-pct', '0%');
    
    // Show remaining seconds on the button
    const secsTotal = Math.ceil(ms / 1000);
    btn.textContent = `${originalText.trim()} (${secsTotal}s)`;
    
    btn._cooldownInterval = setInterval(() => {
      elapsed += TICK_MS;
      const pct = Math.min((elapsed / ms) * 100, 100);
      btn.style.setProperty('--fill-pct', `${pct.toFixed(1)}%`);
      
      // Update remaining seconds
      const remaining = Math.ceil((ms - elapsed) / 1000);
      if (remaining > 0) {
        btn.textContent = `${originalText.trim()} (${remaining}s)`;
      }
      
      if (elapsed >= ms) {
        clearInterval(btn._cooldownInterval);
        btn._cooldownInterval = null;
        btn.classList.remove('btn-disabled', 'counting');
        btn.style.removeProperty('--fill-pct');
        btn.textContent = originalText.trim();
      }
    }, TICK_MS);
  }

  function initCheckin() {
    greetingEl.textContent = getTimeGreeting();
    quoteEl.textContent    = randomFrom(CONFIG.quotes.trigger);
    updateProgressBar();
    updateStreak();
    alreadySaved = false;
    currentStep  = 'checkin';
    currentFlow  = FLOW_YES;
    setFlowStep('checkin');

    // Intentional Friction Lock — left-to-right amber sweep on the button
    startButtonCooldown(btnNo, 3000);
  }

  function notifyBackend(entryType, problem, satisfied, task, commitment) {
    tauriInvoke?.('record_checkin', { entryType, problem, satisfied, task, commitment }).catch(() => {});
  }

  // =====================================================
  //  CHECK-IN STEP
  // =====================================================

  initCheckin();

  btnSummary.addEventListener('click', () => {
    renderSummary();
    showStep(stepSummary);
    currentStep = 'summary';
  });

  // --- Dashboard buttons ---
  function openDashboard() {
    const url = CONFIG.dashboardUrl || 'http://localhost:1422';
    if (tauriInvoke) {
      tauriInvoke('open_dashboard', { url }).catch(() => {
        window.open(url, '_blank');
      });
    } else {
      window.open(url, '_blank');
    }
  }

  btnDashboard.addEventListener('click', openDashboard);
  btnDashboardFromSummary.addEventListener('click', openDashboard);

  // =====================================================
  //  YES PATH — Journey Questions
  // =====================================================

  let journeyStep = 0;

  btnYes.addEventListener('click', () => {
    journeyStep = 0;
    const q = CONFIG.journey[0];
    journeyQuestionEl.textContent = q.question;
    btnJourneyAnswer.textContent  = q.button;
    journeyImageEl.src            = q.image;
    showStep(stepYesJourney);
    currentStep = 'journey';
    setFlowStep('journey');
  });

  btnJourneyAnswer.addEventListener('click', () => {
    journeyStep++;
    if (journeyStep < CONFIG.journey.length) {
      const q = CONFIG.journey[journeyStep];
      journeyQuestionEl.textContent = q.question;
      btnJourneyAnswer.textContent  = q.button;
      journeyImageEl.src            = q.image;
      stepYesJourney.classList.remove('fade-in');
      void stepYesJourney.offsetWidth;
      stepYesJourney.classList.add('fade-in');
    } else {
      // Journey complete — show encouragement + mandatory task input
      alreadySaved = false;
      yesMessageEl.textContent = randomFrom(CONFIG.quotes.yesHeadline);
      yesSubEl.textContent     = randomFrom(CONFIG.quotes.yesSub);
      showStep(stepYes);
      currentStep = 'yes';
      setFlowStep('yes');
      taskInput.focus();
    }
  });

  // Satisfaction buttons — REQUIRE task input before closing
  satisfactionBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      if (alreadySaved) return;

      // Validate: task input is mandatory
      const task = taskInput.value.trim();
      if (!task) {
        taskHint.classList.remove('hidden');
        // Re-trigger shake animation
        taskHint.classList.remove('input-hint');
        void taskHint.offsetWidth;
        taskHint.classList.add('input-hint');
        taskInput.focus();
        taskInput.style.borderColor = 'var(--red-soft)';
        return;
      }

      // Valid — save and close
      taskHint.classList.add('hidden');
      taskInput.style.borderColor = '';
      alreadySaved = true;
      const satisfied = btn.getAttribute('data-satisfied');
      saveEntry({ type: 'productive', satisfied, task });
      notifyBackend('productive', '', satisfied === 'yes', task, null);
      closePopup();
    });
  });

  // Clear validation hint when user starts typing
  taskInput.addEventListener('input', () => {
    if (taskInput.value.trim()) {
      taskHint.classList.add('hidden');
      taskInput.style.borderColor = '';
    }
  });

  // =====================================================
  //  NO PATH — Plea → Dual Images → Problem Picker
  // =====================================================

  btnNo.addEventListener('click', () => {
    showStep(stepNoPlea);
    currentStep = 'plea';
    setFlowStep('plea');
    startButtonCooldown(btnWorkHard, 15000); // 15s delay
  });

  btnWorkHard.addEventListener('click', async () => {
    const { width, height } = CONFIG.window.dualImages;
    await resizeWindow(width, height);
    showStep(stepNoImages);
    containerEl.classList.add('container-expanded');
    currentStep = 'images';
    setFlowStep('images');
    startButtonCooldown(btnWorthy, 15000); // 15s delay
  });

  btnWorthy.addEventListener('click', async () => {
    const { width, height } = CONFIG.window.default;
    await resizeWindow(width, height);
    containerEl.classList.remove('container-expanded');
    showStep(stepProblem);
    currentStep = 'problem';
    setFlowStep('problem');
  });

  // =====================================================
  //  PROBLEM PICKER → ADVICE
  // =====================================================

  document.getElementById('problem-grid').addEventListener('click', e => {
    const btn = e.target.closest('.problem-btn');
    if (btn) showAdvice(btn.dataset.action, btn.dataset.problem);
  });

  btnCustomSubmit.addEventListener('click', () => {
    const val = customInput.value.trim();
    if (val) showAdvice(randomFrom(CONFIG.quotes.customAdvice), 'custom: ' + val);
  });

  customInput.addEventListener('keydown', e => {
    if (e.key === 'Enter') btnCustomSubmit.click();
  });

  function showAdvice(actionText, problem) {
    adviceTextEl.textContent    = actionText;
    encourageTextEl.textContent = randomFrom(CONFIG.quotes.encouragement);
    showStep(stepAdvice);
    currentStep = 'advice';
    setFlowStep('advice');
    saveEntry({ type: 'struggled', problem });
    notifyBackend('struggled', problem || '', false, null, null);
    // No auto-close — user must write commitment and click "Got it"
    setTimeout(() => commitInput.focus(), 350); // wait for step fade-in
  }

  btnGotIt.addEventListener('click', () => {
    const commitment = commitInput.value.trim();
    if (!commitment) {
      commitHint.classList.remove('hidden');
      commitHint.classList.remove('input-hint');
      void commitHint.offsetWidth;
      commitHint.classList.add('input-hint');
      commitInput.focus();
      commitInput.style.borderColor = 'var(--red-soft)';
      return;
    }
    commitInput.style.borderColor = '';
    // Patch the last entry with the commitment text
    try {
      const history = getHistory();
      if (history.length > 0) {
        history[history.length - 1].commitment = commitment;
        localStorage.setItem('accountability_history', JSON.stringify(history));
      }
    } catch {}
    tauriInvoke?.('update_last_commitment', { commitment }).catch(() => {});
    closePopup();
  });

  // Clear validation on typing
  commitInput.addEventListener('input', () => {
    if (commitInput.value.trim()) {
      commitHint.classList.add('hidden');
      commitInput.style.borderColor = '';
    }
  });

  // =====================================================
  //  SUMMARY
  // =====================================================

  btnBackFromSummary.addEventListener('click', () => {
    showStep(stepCheckin);
    currentStep = 'checkin';
  });

  function renderSummary() {
    const entries    = getTodayEntries();
    const productive = entries.filter(e => e.type === 'productive').length;
    const struggled  = entries.filter(e => e.type === 'struggled').length;
    const total      = entries.length;
    const pct        = total > 0 ? Math.round(productive / total * 100) : 0;

    statProductive.textContent = productive;
    statStruggled.textContent  = struggled;
    statTotal.textContent      = total;
    summaryBarFill.style.width = `${pct}%`;
    summaryPercent.textContent = total > 0 ? `${pct}% focused today` : 'No check-ins yet';

    historyList.innerHTML = '';
    if (!entries.length) {
      historyList.innerHTML = '<p style="text-align:center;color:var(--text-muted);font-size:0.78rem;padding:16px;">No check-ins yet today.</p>';
      return;
    }
    [...entries].reverse().forEach(entry => {
      const time     = new Date(entry.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
      const dotClass = entry.type === 'productive' ? 'productive' : 'struggled';
      const label    = entry.type === 'productive'
        ? (entry.satisfied === 'yes' ? 'Focused' : 'Working, could improve')
        : (entry.problem || 'Struggled');

      const displayLabel = entry.type === 'struggled' && (label.startsWith('custom:') || label.startsWith('custom: '))
        ? label.replace(/^custom:\s*/, '').trim()
        : label;

      const item = document.createElement('div');
      item.className = 'history-item';
      item.innerHTML = `
        <span class="history-dot ${dotClass}"></span>
        <span class="history-time">${time}</span>
        <span>${displayLabel}</span>
        ${entry.task ? `<span class="history-task">— ${entry.task}</span>` : ''}
        ${entry.commitment ? `<span class="history-task" style="color: var(--amber);">— Commit: ${entry.commitment}</span>` : ''}
      `;
      historyList.appendChild(item);
    });
  }

  // =====================================================
  //  KEYBOARD SHORTCUTS
  // =====================================================

  document.addEventListener('keydown', e => {
    if (e.target.tagName === 'INPUT') {
      if (e.key === 'Enter' && e.target.id === 'task-input' && currentStep === 'yes') {
        e.preventDefault();
        if (taskInput.value.trim()) {
          document.querySelector('[data-satisfied="yes"]')?.click();
        } else {
          taskHint.classList.remove('hidden');
          taskHint.classList.remove('input-hint');
          void taskHint.offsetWidth;
          taskHint.classList.add('input-hint');
        }
      }
      if (e.key === 'Enter' && e.target.id === 'commit-input' && currentStep === 'advice') {
        e.preventDefault();
        btnGotIt.click();
      }
      return;
    }
    if (currentStep === 'checkin') {
      if (e.key === 'y' || e.key === 'Y') { e.preventDefault(); btnYes.click(); }
      if (e.key === 'n' || e.key === 'N') {
        e.preventDefault();
        if (!btnNo.classList.contains('btn-disabled')) btnNo.click();
      }
    } else if (currentStep === 'advice') {
      if (e.key === 'Enter') { e.preventDefault(); commitInput.focus(); }
    } else if (currentStep === 'summary') {
      if (e.key === 'Escape' || e.key === 'Backspace') { e.preventDefault(); btnBackFromSummary.click(); }
    }
  });
});
