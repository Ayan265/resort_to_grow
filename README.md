# Resort To Grow // Accountability & Focus

A brutal, friction-based desktop app that interrupts you every 30 minutes and asks: **"Are you really working hard right now?"**

## Why Does This Exist? (The Philosophy)

Most productivity tools assume you just need a better to-do list. **This tool assumes you are lying to yourself.** 

We often sit at our desks, switch tabs, doom-scroll, or do "fake work," while telling ourselves we're being productive. **Resort To Grow** is designed to break that illusion. It acts as an aggressive accountability partner that lives on your computer.

### How It Works: Emotional Friction
Instead of just blocking websites (which you can easily bypass), this app uses **your own personal anchors**:
- It uses **your own photos** (of yourself, your goals, or people you love) to remind you *why* you're working.
- If you admit you're slacking ("Not really"), the app forces you through **intentional friction**. It makes you look at your motivation photos, select your exact problem (Laziness, Distraction, Confusion), and **type out a concrete commitment** before it lets you close the window.
- It tracks your **Self-Integrity Index**: If you commit to working but slack off again 30 minutes later, the dashboard brutally fails your grade.

Everything stays on your computer. No cloud. No tracking. Just you vs. you.

---

## What It Does

- ⏰ **Pops up every 30 minutes** (customizable) and demands an honest answer
- ✅ **"Yes, I am" path** — Shows affirmation screens with your photos, then logs your task
- ❌ **"Not really" path** — Emotional plea → motivation images → identify your problem → write a commitment
- 🔒 **Intentional friction** — Cooldown timers, mandatory text, no shortcuts to close
- 📊 **Analytics dashboard** — Charts, heatmaps, streaks, and a letter grade in your browser
- 🔐 **100% private** — All data stays in one file on your machine

---

## Getting Started

### What You Need First

Before installing, make sure you have these (ask a techy friend to help if needed):

1. **Node.js** — Download from [nodejs.org](https://nodejs.org/) (click the big green button)
2. **Rust** — Install by pasting this in your terminal: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
3. **Python 3** — Usually pre-installed on Linux/Mac. Check with: `python3 --version`

### Step 1: Download the app

```bash
git clone https://github.com/Ayan265/resort_to_grow.git
cd resort_to_grow
```

### Step 2: Add your images

Copy your personal motivation photos (`.jpg`, `.png`, or `.webp`) into this folder:

```
resort_to_grow/app/src/images/
```

You need at least a few photos — of yourself, someone you care about, your goals, or anything that motivates you. Name them something you'll remember (like `me.jpg`, `goal.png`).

### Step 3: Personalize the app

Run the personalization wizard — it asks you simple questions and sets everything up:

```bash
./personalize.sh
```

It will ask you:
- Your name
- How often the popup should appear
- Which image to use for each screen
- Your personal motivation messages
- Your affirmation statements

**No coding required.** Just answer the questions.

At the end, it will ask if you want to build and install the app automatically.

### Step 4: You're done!

The app now runs silently in your system tray. Every 30 minutes (or whatever you set), it will pop up and ask if you're focused.

To check your progress:
- **From the popup:** Click **"Open Dashboard"** at the bottom of the check-in screen
- **From the tray:** Right-click the tray icon → **Dashboard**
- **From your browser:** Go to [http://localhost:1422](http://localhost:1422)

---

## How To Use It Daily

1. The app runs in the background — you'll see a small icon in your system tray
2. Every 30 minutes, a popup appears asking if you're working hard
3. **If yes:** Walk through your affirmations, log what you're doing, close
4. **If not:** Face your motivation images, identify what's blocking you, write a commitment to fix it
5. Check the **Dashboard** anytime to see your charts, streaks, and letter grade

---

## Changing Your Settings Later

### The Easy Way

Run the wizard again anytime:

```bash
./personalize.sh
```

### The Manual Way

If you prefer, everything lives in one file: `app/src/config.js`

Open it in any text editor and change the values between the quotes. The comments explain what each setting does.

| What you want to change          | Where to look                     |
|----------------------------------|-----------------------------------|
| How often the popup appears      | `timerIntervalMinutes: 30`        |
| Your images                      | `images: { ... }`                 |
| Your motivation messages         | `noPath: { ... }`                 |
| Your affirmation screens         | `journey: [ ... ]`                |
| Motivational quotes              | `quotes: { ... }`                 |

After changing anything, rebuild the app:

```bash
./setup-autostart.sh
```

### Changing Your App Icon (System Tray)

The small icon in your system tray can also be customized:

1. Make a square PNG image (at least 256×256 pixels)
2. Replace the files in `app/src-tauri/icons/` with your image at the correct sizes
3. See `app/src/images/README.md` for detailed instructions

---

## Commands Reference

| What you want to do                | Command                   |
|------------------------------------|---------------------------|
| Personalize the app                | `./personalize.sh`        |
| Build + set up auto-start         | `./setup-autostart.sh`    |
| Run in development mode            | `cd app && npm run tauri dev` |
| Open the dashboard                 | Right-click tray → Dashboard |

---

## Where Your Data Lives

All your check-in history is stored in one file on your computer:

| OS      | Location                                         |
|---------|--------------------------------------------------|
| Linux   | `~/.accountability_history.json`                 |
| macOS   | `~/.accountability_history.json`                 |
| Windows | `C:\Users\YourName\.accountability_history.json` |

The dashboard reads this file. Nothing leaves your machine.

---

## Auto-Start on Login

<details>
<summary><strong>Linux (already handled by setup-autostart.sh)</strong></summary>

The `./setup-autostart.sh` script creates auto-start entries for both the popup and the dashboard. If you ran the personalize wizard and chose to build, this is already done.

</details>

<details>
<summary><strong>macOS</strong></summary>

1. Build the app: `cd app && npm run tauri build`
2. Find the `.app` in `app/src-tauri/target/release/bundle/macos/`
3. Drag it to **Applications**
4. Go to **System Settings → General → Login Items** → add the app
5. For the dashboard, add a Login Item running:
   ```
   /usr/bin/python3 /path/to/resort_to_grow/dashboard/server.py
   ```

</details>

<details>
<summary><strong>Windows</strong></summary>

1. Build the app: `cd app && npm run tauri build`
2. Find `accountability-app.exe` in `app\src-tauri\target\release\`
3. Press `Win + R`, type `shell:startup`, press Enter
4. Create a shortcut to the `.exe` in that folder
5. For the dashboard, create another shortcut with:
   ```
   pythonw "C:\path\to\resort_to_grow\dashboard\server.py"
   ```

</details>

---

## Project Structure

```
resort_to_grow/
├── personalize.sh              ← Run this to set up your app
├── setup-autostart.sh          ← Builds and installs the app
├── app/
│   └── src/
│       ├── config.js           ← Your settings (auto-generated by personalize.sh)
│       ├── images/             ← Drop your photos here
│       ├── main.js             ← App logic (don't need to edit)
│       ├── index.html          ← App layout (don't need to edit)
│       └── styles.css          ← App design (don't need to edit)
├── dashboard/
│   ├── index.html              ← Analytics dashboard
│   └── server.py               ← Dashboard server
└── README.md
```

---

## License

MIT — Use it, share it, make it yours.
