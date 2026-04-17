---
name: desktop-utility
description: Advanced window, tray, and system menu management for high-fidelity desktop experience.
---

# 🖥️ Desktop Utility Mastery

Use this skill to create "Mac-First / Windows-Optimal" desktop experiences in Flutter.

## 🧩 1. Window Management: `window_manager`

Always persist the window's latest size and position to the local state (via `shared_preferences`) to ensure a native app feel upon restart.

```dart
// Initialization
await windowManager.ensureInitialized();
WindowOptions windowOptions = const WindowOptions(
  size: Size(800, 600),
  center: true,
  backgroundColor: Colors.transparent,
  skipTaskbar: false,
  titleBarStyle: TitleBarStyle.hidden,
);
```

### Protocol: Persist Window State
- **Save**: Listen to `onWindowResize` and `onWindowMove` events and debounce state updates.
- **Restore**: On main initialization, fetch the saved `rect` and `position` before `windowManager.show()`.

##  tray 2. System Tray: `tray_manager`

For background vaults and sync services, use the system tray to ensure the app is always "Ready but Unobtrusive."

```dart
// Setting up the Tray icon & menu
await trayManager.setContextMenu(Menu(
  items: [
    MenuItem(label: 'Show Vault', onClick: (i) => windowManager.show()),
    MenuItem.separator(),
    MenuItem(label: 'Lock & Exit', onClick: (i) => exit(0)),
  ],
));
```

## 🍎 3. Apple Menu Bar

Integrate native menu items into the macOS system menu bar (File, Edit, Vault) using `flutter_menubar` or `NativeMenuBar`.

- **Aesthetics**: Avoid hardcoding "Quit" in the UI. Reference the standard `Cmd+Q` system behavior.
- **Glassmorphism Integration**: Ensure windows with full-screen blurs have `hasShadow: true` or equivalent native window attributes for depth.

---
*Protocol: Active. Experience: Desktop-First.*
