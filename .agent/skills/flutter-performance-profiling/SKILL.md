---
name: Flutter Performance Profiling
description: Implementation of industrial-grade 60/120fps frame pacing, rendering optimization, and memory audit for the Vault project.
---

# ⚡ Flutter Performance Profiling

This skill identifies and remediates "Jank" to maintain a **Premium UI/UX (Zero-Lag)**.

## 🖼️ 1. Frame Pacing (P0)
- **Target**: 8.3ms for 120Hz (ProMotion) or 16.6ms for 60Hz.
- **Tools**: DevTools Performance View + `--enable-impeller`.

### ✅ Jank Detection:
1. Identify frames exceeding the budget in the **Timeline Events**.
2. Determine if the bottleneck is **Build** (Widget logic), **Layout** (Slivers/Constraints), or **Paint** (Shaders/Clipping).

## 🗃️ 2. Memory Analysis (P1)
- **Leaked Widgets**: Use the **Memory Profile** to detect `GetxController` or `StreamSubscription` leaks.
- **Image Cache**: Precache all SVG assets from `assets/images/` on app boot to eliminate flickering.

### ✅ Precaching Logic:
```dart
Future<void> prefetchAssets() async {
  // Pre-cache primary iconsax library items
  await Future.wait([
    precachePicture(...),
    precacheImage(...),
  ]);
}
```

## 🚥 3. Sentry Performance Monitoring
All production builds MUST include Sentry telemetry for:
- App Start Time (Cold/Warm boot).
- Screen Load Times.
- Frame Jank Detection (Slow/Frozen frames).

---
*Protocol: Hardened. Experience: Pro Max. Status: Industrial.*
