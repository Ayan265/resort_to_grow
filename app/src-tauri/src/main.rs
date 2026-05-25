#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;
use std::time::Duration;
use std::sync::atomic::{AtomicBool, Ordering};
use tokio::time;
use tauri::{
    Manager,
    menu::{Menu, MenuItem},
    tray::TrayIconBuilder,
};

#[derive(Serialize, Deserialize, Clone, Debug)]
struct CheckinEntry {
    entry_type: String,
    problem: String,
    satisfied: bool,
    timestamp: String,
    task: Option<String>,
    commitment: Option<String>,
}

fn get_history_path() -> PathBuf {
    let home = dirs::home_dir().unwrap_or_else(|| PathBuf::from("."));
    home.join(".accountability_history.json")
}

fn load_history() -> Vec<CheckinEntry> {
    let path = get_history_path();
    if path.exists() {
        let data = fs::read_to_string(&path).unwrap_or_else(|_| "[]".to_string());
        serde_json::from_str(&data).unwrap_or_default()
    } else {
        Vec::new()
    }
}

fn save_history(history: &Vec<CheckinEntry>) {
    let path = get_history_path();
    if let Ok(json) = serde_json::to_string_pretty(history) {
        let _ = fs::write(path, json);
    }
}

#[tauri::command]
fn record_checkin(
    entry_type: String,
    problem: String,
    satisfied: bool,
    task: Option<String>,
    commitment: Option<String>,
) {
    let entry = CheckinEntry {
        entry_type,
        problem,
        satisfied,
        timestamp: chrono::Local::now().to_rfc3339(),
        task,
        commitment,
    };
    let mut history = load_history();
    history.push(entry);
    save_history(&history);
}

#[tauri::command]
fn update_last_commitment(commitment: String) {
    let mut history = load_history();
    if let Some(last) = history.last_mut() {
        last.commitment = Some(commitment);
    }
    save_history(&history);
}

static TIMER_STARTED: AtomicBool = AtomicBool::new(false);

#[tauri::command]
fn start_timer(window: tauri::WebviewWindow, interval_minutes: f64) {
    if TIMER_STARTED.swap(true, Ordering::SeqCst) {
        return;
    }

    let window_clone = window.clone();
    tauri::async_runtime::spawn(async move {
        loop {
            time::sleep(Duration::from_secs_f64(interval_minutes * 60.0)).await;
            let _ = window_clone.show();
            let _ = window_clone.set_focus();
            let _ = window_clone.eval("window.onAppShow && window.onAppShow();");
        }
    });
}

fn main() {
    tauri::Builder::default()
        .setup(|app| {
            let show = MenuItem::with_id(app, "show", "Show", true, None::<&str>)?;
            let quit = MenuItem::with_id(app, "quit", "Quit", true, None::<&str>)?;
            let menu = Menu::with_items(app, &[&show, &quit])?;

            TrayIconBuilder::new()
                .tooltip("Accountability Reminder")
                .icon(app.default_window_icon().unwrap().clone())
                .menu(&menu)
                .on_menu_event(|app, event| {
                    match event.id().as_ref() {
                        "show" => {
                            if let Some(window) = app.get_webview_window("main") {
                                let _ = window.show();
                                let _ = window.set_focus();
                            }
                        }
                        "quit" => app.exit(0),
                        _ => {}
                    }
                })
                .build(app)?;

            // Show window immediately on first launch so users know it works.
            // After check-in, main.js hides it and the 30-min timer takes over.
            if let Some(window) = app.get_webview_window("main") {
                let _ = window.show();
                let _ = window.set_focus();
            }

            Ok(())
        })
        .on_window_event(|window, event| {
            if let tauri::WindowEvent::CloseRequested { api, .. } = event {
                let _ = window.hide();
                api.prevent_close();
            }
        })
        .invoke_handler(tauri::generate_handler![record_checkin, start_timer, update_last_commitment])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
