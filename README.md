# Resort To Grow

A desktop accountability tool that interrupts you every 30 minutes and forces you to answer one question: **"Are you really working hard right now?"**

It uses your own personal photos, affirmations, and emotional anchors to keep you focused and honest with yourself. If you admit you're slacking, it forces you to name the problem, read an action step, and write a concrete commitment before it lets you close the window.

Everything stays local. No cloud. No tracking. Just you vs. you.

---

## What's Inside

```
resort_to_grow/
├── app/                        # Tauri + Vite desktop app (the popup)
│   ├── src/
│   │   ├── config.js           # ← EDIT THIS to customize everything
│   │   ├── main.js             # App logic (reads from config.js)
│   │   ├── index.html          # App UI structure
│   │   ├── styles.css          # Visual design
│   │   └── images/             # ← PUT YOUR IMAGES HERE
│   │       ├── placeholder.jpg # Default placeholder (ships with repo)
│   │       └── README.md       # Instructions for adding images
│   ├── src-tauri/              # Rust backend (timer, tray, history saving)
│   ├── package.json
│   └── vite.config.js
├── dashboard/                  # Local analytics dashboard
│   ├── index.html              # Single-page dashboard UI
│   └── server.py               # Python server (serves dashboard + API)
├── setup-autostart.sh          # Linux auto-login start script
├── .gitignore
└── README.md
```

---

## Features

- **30-minute check-ins** — A popup demands your attention and won't let you ignore it
- **"Yes" path** — Walk through personal affirmation screens, then log what you're working on
- **"Not really" path** — Emotional plea → motivation images → identify your blocker → write a commitment
- **Intentional friction** — 3-second cooldowns, mandatory text inputs, no easy escape
- **Local dashboard** — Charts, heatmaps, streaks, a "Self-Integrity Index," and a brutal letter grade
- **100% private** — All data stays in `~/.accountability_history.json` on your machine

---

## Quick Start

### Prerequisites

- [Node.js](https://nodejs.org/) v18+
- [Rust](https://rustup.rs/) (for compiling Tauri)
- Python 3 (for the dashboard server)
- Linux desktop environment (tested on GNOME/KDE; Tauri also supports macOS/Windows)

### 1. Clone and install

```bash
git clone https://github.com/Ayan265/resort_to_grow.git
cd resort_to_grow/app
npm install
```

### 2. Add your images

Drop your personal motivation photos into `app/src/images/`. Then open `app/src/config.js` and update the filenames:

```js
images: {
  mainPhoto:       '/my-photo.jpg',
  pleaImage:       '/motivation.png',
  motivationLeft:  '/goal-left.jpg',
  motivationRight: '/goal-right.jpg',
  summaryLeft:     '/my-photo.jpg',
  summaryRight:    '/inspiration.png',
},
```

Also update the journey steps and personal messages in `config.js` to match your own goals.  
See [`app/src/images/README.md`](app/src/images/README.md) for full details.

> **Your images are safe.** The `.gitignore` ensures that nothing in `app/src/images/` except `placeholder.jpg` and `README.md` is ever committed to git.

### 3. Run in development mode

```bash
cd app
npm run tauri dev
```

### 4. Build for production

```bash
cd app
npm run tauri build
```

Binary output: `src-tauri/target/release/accountability-app`

Run it (from inside the `app/` directory):
```bash
./src-tauri/target/release/accountability-app
```

The check-in window will appear immediately on your screen. After you complete the check-in, the app hides itself and silently runs in the background — popping up again every 30 minutes.

### 5. Launch the dashboard

```bash
cd dashboard
python3 server.py
```

Opens automatically at [http://localhost:1422](http://localhost:1422).

### 6. Auto-start on login

<details>
<summary><strong>Linux (GNOME / KDE)</strong></summary>

Run the included setup script:
```bash
./setup-autostart.sh
```
This creates `.desktop` entries in `~/.config/autostart/` for both the popup app and the dashboard server.

</details>

<details>
<summary><strong>macOS</strong></summary>

1. Build the app: `cd app && npm run tauri build`
2. The `.app` bundle will be in `app/src-tauri/target/release/bundle/macos/`
3. Drag it to your **Applications** folder
4. Go to **System Settings → General → Login Items** → click **+** → select the app
5. For the dashboard, add a Login Item that runs:
   ```
   /usr/bin/python3 /path/to/resort_to_grow/dashboard/server.py
   ```

</details>

<details>
<summary><strong>Windows</strong></summary>

1. Build the app: `cd app && npm run tauri build`
2. The `.exe` will be in `app\src-tauri\target\release\`
3. Press `Win + R`, type `shell:startup`, press Enter
4. Create a shortcut to `accountability-app.exe` in the Startup folder that opens
5. For the dashboard, create another shortcut in the same folder with target:
   ```
   pythonw "C:\path\to\resort_to_grow\dashboard\server.py"
   ```

</details>

---

## Customization

**Everything** is controlled from one file: [`app/src/config.js`](app/src/config.js)

| What                     | Where in config.js          |
|--------------------------|-----------------------------|
| Check-in interval        | `timerIntervalMinutes`      |
| Images                   | `images: { ... }`           |
| Check-in question text   | `checkin: { ... }`          |
| "Not really" flow text   | `noPath: { ... }`           |
| Affirmation journey      | `journey: [ ... ]`          |
| Motivational quotes      | `quotes: { ... }`           |
| Problem buttons          | `problems: [ ... ]`         |
| Window sizes             | `window: { ... }`           |

After editing, rebuild with `npm run tauri build`.

---

## Data

All check-in history is stored locally on your machine. No cloud. No tracking.

| OS      | History file location                              |
|---------|----------------------------------------------------|
| Linux   | `~/.accountability_history.json`                   |
| macOS   | `~/.accountability_history.json`                   |
| Windows | `C:\Users\YourName\.accountability_history.json`   |

The dashboard reads this file directly.

---

## Tech Stack

- **Frontend:** Vanilla HTML/CSS/JS + Vite
- **Backend:** Rust (Tauri v2) — handles timer, system tray, window management, and JSON persistence
- **Dashboard:** Single HTML file + Chart.js, served by a minimal Python HTTP server

---

## Platform Support

| Platform | Popup App | Dashboard | Autostart |
|----------|-----------|-----------|-----------|
| Linux    | ✅         | ✅         | ✅ Script included |
| macOS    | ✅         | ✅         | ✅ Manual (Login Items) |
| Windows  | ✅         | ✅         | ✅ Manual (Startup folder) |

---

## License

MIT

