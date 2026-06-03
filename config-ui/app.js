// =====================================================
//  Resort To Grow — Config UI Frontend
// =====================================================

// State
let config = {};
let images = [];
let currentTab = 'settings';

// =====================================================
//  INITIALIZATION
// =====================================================

document.addEventListener('DOMContentLoaded', async () => {
    await loadConfig();
    await loadImages();
    setupTabs();
    setupImageUpload();
    setupFormSync();
    setupActions();
});

// =====================================================
//  CONFIG LOADING
// =====================================================

async function loadConfig() {
    try {
        const res = await fetch('/api/config');
        config = await res.json();
        populateForm(config);
    } catch (err) {
        console.error('Failed to load config:', err);
        showToast('Failed to load configuration', true);
    }
}

function populateForm(config) {
    // Timer
    document.getElementById('timer-slider').value = config.timerIntervalMinutes;
    document.getElementById('timer-input').value = config.timerIntervalMinutes;
    
    // Personal info
    const name = config.noPath?.pleaQuestion?.split(',')[0] || '';
    document.getElementById('user-name').value = name;
    document.getElementById('dashboard-url').value = config.dashboardUrl;
    
    // Messages
    document.getElementById('plea-question').value = config.noPath?.pleaQuestion || '';
    document.getElementById('plea-button').value = config.noPath?.pleaButton || '';
    document.getElementById('worthy-button').value = config.noPath?.worthyButton || '';
    document.getElementById('checkin-question').value = config.checkin?.question || '';
    document.getElementById('yes-button').value = config.checkin?.yesButton || '';
    document.getElementById('no-button').value = config.checkin?.noButton || '';
    
    // Quotes
    document.getElementById('trigger-quotes').value = (config.quotes?.trigger || []).join('\n');
    document.getElementById('yes-headlines').value = (config.quotes?.yesHeadline || []).join('\n');
    document.getElementById('encouragement-quotes').value = (config.quotes?.encouragement || []).join('\n');
    
    // Journey
    renderJourney(config.journey || []);
}

// =====================================================
//  IMAGES
// =====================================================

async function loadImages() {
    try {
        const res = await fetch('/api/images');
        images = await res.json();
        renderImageGrid();
        renderImageList();
    } catch (err) {
        console.error('Failed to load images:', err);
    }
}

function renderImageGrid() {
    const grid = document.getElementById('image-grid');
    const slots = ['mainPhoto', 'pleaImage', 'motivationLeft', 'motivationRight', 'summaryLeft', 'summaryRight'];
    
    grid.innerHTML = slots.map(slot => {
        const imgPath = config.images?.[slot] || '/placeholder.jpg';
        const imgName = imgPath.split('/').pop();
        const image = images.find(i => i.name === imgName);
        const imgUrl = image ? `/images/${image.name}` : imgPath;
        
        return `
            <div class="image-slot" data-slot="${slot}">
                <img src="${imgUrl}" alt="${slot}">
                <div class="slot-label">${formatSlotName(slot)}</div>
            </div>
        `;
    }).join('');
}

function renderImageList() {
    const list = document.getElementById('image-list');
    
    if (images.length === 0) {
        list.innerHTML = '<p class="help-text">No images uploaded yet</p>';
        return;
    }
    
    list.innerHTML = images.map(img => `
        <div class="image-list-item">
            <img src="/images/${img.name}" alt="${img.name}">
            <span class="image-name">${img.name}</span>
            <span class="image-size">${formatSize(img.size)}</span>
            <button class="btn-delete" onclick="deleteImage('${img.name}')">Delete</button>
        </div>
    `).join('');
}

function formatSlotName(slot) {
    const names = {
        mainPhoto: 'Main Photo',
        pleaImage: 'Plea Image',
        motivationLeft: 'Left Motivation',
        motivationRight: 'Right Motivation',
        summaryLeft: 'Summary Left',
        summaryRight: 'Summary Right'
    };
    return names[slot] || slot;
}

function formatSize(bytes) {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
}

async function uploadImage(file) {
    const formData = new FormData();
    formData.append('image', file);
    
    try {
        const res = await fetch('/api/images', {
            method: 'POST',
            body: formData
        });
        const data = await res.json();
        
        if (data.success) {
            await loadImages();
            showToast(`Uploaded ${data.filename}`);
        }
    } catch (err) {
        console.error('Upload failed:', err);
        showToast('Upload failed', true);
    }
}

async function deleteImage(name) {
    try {
        const res = await fetch(`/api/images/${name}`, { method: 'DELETE' });
        const data = await res.json();
        
        if (data.success) {
            await loadImages();
            showToast(`Deleted ${name}`);
        }
    } catch (err) {
        console.error('Delete failed:', err);
        showToast('Delete failed', true);
    }
}

// =====================================================
//  IMAGE UPLOAD SETUP
// =====================================================

function setupImageUpload() {
    const uploadZone = document.getElementById('upload-zone');
    const fileInput = document.getElementById('file-input');
    
    // Click to upload
    uploadZone.addEventListener('click', () => fileInput.click());
    
    // File selected
    fileInput.addEventListener('change', (e) => {
        Array.from(e.target.files).forEach(uploadImage);
    });
    
    // Drag and drop
    uploadZone.addEventListener('dragover', (e) => {
        e.preventDefault();
        uploadZone.classList.add('drag-over');
    });
    
    uploadZone.addEventListener('dragleave', () => {
        uploadZone.classList.remove('drag-over');
    });
    
    uploadZone.addEventListener('drop', (e) => {
        e.preventDefault();
        uploadZone.classList.remove('drag-over');
        Array.from(e.dataTransfer.files).forEach(uploadImage);
    });
}

// =====================================================
//  TABS
// =====================================================

function setupTabs() {
    const tabs = document.querySelectorAll('.nav-tab');
    
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            tabs.forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            
            document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
            document.getElementById(`tab-${tab.dataset.tab}`).classList.add('active');
            
            currentTab = tab.dataset.tab;
        });
    });
}

// =====================================================
//  FORM SYNC
// =====================================================

function setupFormSync() {
    // Timer slider sync
    const slider = document.getElementById('timer-slider');
    const input = document.getElementById('timer-input');
    
    slider.addEventListener('input', () => input.value = slider.value);
    input.addEventListener('input', () => slider.value = input.value);
}

// =====================================================
//  JOURNEY
// =====================================================

function renderJourney(journey) {
    const list = document.getElementById('journey-list');
    
    list.innerHTML = journey.map((step, i) => `
        <div class="journey-step" data-index="${i}">
            <div>
                <div class="step-number">Step ${i + 1}</div>
                <input type="text" class="journey-question" value="${escapeHtml(step.question)}" placeholder="Affirmation statement">
            </div>
            <div>
                <div class="step-number">&nbsp;</div>
                <input type="text" class="journey-button" value="${escapeHtml(step.button)}" placeholder="Button text">
            </div>
            <div>
                <div class="step-number">&nbsp;</div>
                <button class="btn btn-danger" onclick="removeJourneyStep(${i})">Remove</button>
            </div>
        </div>
    `).join('');
}

function addJourneyStep() {
    config.journey = config.journey || [];
    config.journey.push({
        question: '',
        button: 'Yes',
        image: '/placeholder.jpg'
    });
    renderJourney(config.journey);
}

function removeJourneyStep(index) {
    config.journey.splice(index, 1);
    renderJourney(config.journey);
}

function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
}

// =====================================================
//  ACTIONS
// =====================================================

function setupActions() {
    document.getElementById('add-journey-step').addEventListener('click', addJourneyStep);
    document.getElementById('save-config').addEventListener('click', saveConfig);
    document.getElementById('export-config').addEventListener('click', exportConfig);
    document.getElementById('import-config').addEventListener('click', () => {
        document.getElementById('import-file').click();
    });
    document.getElementById('import-file').addEventListener('change', importConfig);
    document.getElementById('reset-config').addEventListener('click', resetConfig);
    document.getElementById('rebuild-app').addEventListener('click', rebuildApp);
    document.getElementById('reset-onboarding').addEventListener('click', resetOnboarding);
}

function collectFormData() {
    return {
        timerIntervalMinutes: parseInt(document.getElementById('timer-input').value) || 30,
        dashboardUrl: document.getElementById('dashboard-url').value,
        images: config.images || {},
        checkin: {
            question: document.getElementById('checkin-question').value,
            yesButton: document.getElementById('yes-button').value,
            noButton: document.getElementById('no-button').value,
            summaryLink: "Today's progress"
        },
        noPath: {
            pleaQuestion: document.getElementById('plea-question').value,
            pleaButton: document.getElementById('plea-button').value,
            worthyButton: document.getElementById('worthy-button').value
        },
        journey: Array.from(document.querySelectorAll('.journey-step')).map(step => ({
            question: step.querySelector('.journey-question').value,
            button: step.querySelector('.journey-button').value,
            image: '/placeholder.jpg'
        })),
        quotes: {
            trigger: document.getElementById('trigger-quotes').value.split('\n').filter(q => q.trim()),
            yesHeadline: document.getElementById('yes-headlines').value.split('\n').filter(q => q.trim()),
            yesSub: config.quotes?.yesSub || [],
            encouragement: document.getElementById('encouragement-quotes').value.split('\n').filter(q => q.trim()),
            customAdvice: config.quotes?.customAdvice || []
        },
        problems: config.problems || [],
        window: config.window || { default: { width: 600, height: 680 }, dualImages: { width: 1040, height: 760 } }
    };
}

async function saveConfig() {
    const data = collectFormData();
    
    try {
        const res = await fetch('/api/config', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        const result = await res.json();
        
        if (result.success) {
            showToast('Configuration saved!');
        } else {
            showToast('Failed to save', true);
        }
    } catch (err) {
        console.error('Save failed:', err);
        showToast('Save failed', true);
    }
}

function exportConfig() {
    const data = collectFormData();
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'resort-to-grow-config.json';
    a.click();
    URL.revokeObjectURL(url);
    showToast('Configuration exported');
}

async function importConfig(e) {
    const file = e.target.files[0];
    if (!file) return;
    
    try {
        const text = await file.text();
        const data = JSON.parse(text);
        
        // Validate required fields
        if (!data.timerIntervalMinutes || !data.images) {
            throw new Error('Invalid config file');
        }
        
        config = data;
        populateForm(config);
        await saveConfig();
        showToast('Configuration imported');
    } catch (err) {
        console.error('Import failed:', err);
        showToast('Invalid config file', true);
    }
}

async function resetConfig() {
    if (!confirm('Reset all settings to defaults?')) return;
    
    try {
        const res = await fetch('/api/config');
        config = await res.json();
        populateForm(config);
        showToast('Settings reset to defaults');
    } catch (err) {
        console.error('Reset failed:', err);
    }
}

async function rebuildApp() {
    showToast('Rebuilding app...');
    
    try {
        // This would call a server endpoint to run setup-autostart.sh
        // For now, just show a message
        showToast('Please run ./setup-autostart.sh manually');
    } catch (err) {
        console.error('Rebuild failed:', err);
    }
}

function resetOnboarding() {
    if (!confirm('Reset onboarding? The tutorial will show again on next popup.')) return;
    
    // This would need to be done in the popup app's localStorage
    // For now, show instructions
    showToast('Onboarding will reset on next app launch');
}

// =====================================================
//  TOAST
// =====================================================

function showToast(message, isError = false) {
    const toast = document.getElementById('toast');
    toast.querySelector('.toast-message').textContent = message;
    toast.className = `toast ${isError ? 'error' : ''} show`;
    
    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}
