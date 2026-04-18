# Developer Setup

First-time setup guide for developers cloning the repo. Covers the Flutter toolchain, per-OS native prerequisites, and how the runtime `.env` is materialised.

See also: [`BUILD.md`](BUILD.md) · [`INSTALL.md`](INSTALL.md) · [`CI.md`](CI.md).

---

## Table of Contents

- [Toolchain Matrix](#toolchain-matrix)
- [1. Install Flutter](#1-install-flutter)
- [2. Clone & Dependencies](#2-clone--dependencies)
- [3. Runtime Environment File](#3-runtime-environment-file)
- [4. Per-OS Native Prerequisites](#4-per-os-native-prerequisites)
  - [Linux (x64 / arm64)](#linux-x64--arm64)
  - [Windows (x64)](#windows-x64)
  - [macOS (arm64 / x64)](#macos-arm64--x64)
- [5. IDE Setup](#5-ide-setup)
- [6. Verify the Setup](#6-verify-the-setup)
- [Troubleshooting](#troubleshooting)

---

## Toolchain Matrix

| Component | Pinned version | Why |
| --- | --- | --- |
| Flutter | **3.41.7** (stable) | Matches `pubspec.yaml` SDK constraint `^3.11.4` and the CI matrix. |
| Dart | **3.11.x** | Ships inside Flutter 3.41.7 — do not install separately. |
| CMake | 3.13+ (Linux / Windows) | Scaffolded by `flutter create --platforms=linux,windows`. |
| Xcode | 15+ (macOS only) | Required for the `Runner.xcodeproj` target. |
| Ninja / clang | latest | Default Linux build driver for Flutter desktop. |
| MSVC Build Tools | 2019 or 2022 (Desktop C++) | Windows native runner compilation. |
| JDK | Temurin 17+ (optional) | Only needed if the Android shell is touched — desktop CI builds skip it. |

Match these exactly — deviations cause `flutter pub get` to fail with `Because … requires SDK version …`.

---

## 1. Install Flutter

Use whichever method fits the workstation; the CI uses `subosito/flutter-action@v2` on x64 runners and a tagged git clone on arm64 Linux.

```bash
# Option A: fvm (recommended, pins per-repo)
fvm install 3.41.7
fvm use 3.41.7

# Option B: manual git clone
git clone --depth 1 --branch 3.41.7 https://github.com/flutter/flutter.git ~/flutter
export PATH="$HOME/flutter/bin:$PATH"

# Verify
flutter --version   # → Flutter 3.41.7 · channel stable · Dart 3.11.x
```

Disable first-run analytics once: `flutter --disable-analytics`.

---

## 2. Clone & Dependencies

```bash
git clone https://github.com/aldok10/vault-env-manager-flutter.git
cd vault-env-manager-flutter

flutter config \
  --enable-linux-desktop \
  --enable-windows-desktop \
  --enable-macos-desktop

flutter pub get
```

`flutter pub get` caches resolved dependencies under `~/.pub-cache` and `.dart_tool/`. CI keys its cache on `pubspec.lock`, so committing a stale lockfile is the top cause of flaky CI runs — regenerate with `flutter pub get` after any dependency bump.

---

## 3. Runtime Environment File

The app reads an `.env` at runtime from the bundled assets (see `lib/src/core/services/app_config_service.dart`). A template is tracked at `assets/.env.example`:

```bash
cp assets/.env.example assets/.env
```

Populate the values before launching. Notable keys:

| Key | Purpose |
| --- | --- |
| `STORAGE_ENCRYPTION_KEY` | 32-char key feeding PBKDF2 salt generation for the local vault. |
| `VAULT_ORIGIN`, `VAULT_UI_DOMAIN` | HashiCorp Vault endpoint (UI + API). |
| `VAULT_NAMESPACE`, `VAULT_DISCOVERY_PATH` | Optional multi-tenant addressing. |
| `THEME_MODE`, `COLOR_THEME`, `OS_STYLE`, `UI_SCALE` | First-run appearance defaults. |

`.env` is gitignored — never commit the populated file. CI injects values via `--dart-define` instead of shipping `.env`; see [`CI.md`](CI.md).

---

## 4. Per-OS Native Prerequisites

### Linux (x64 / arm64)

Install the GTK / secret-service stack required by `flutter_secure_storage_linux` and Flutter's desktop embedder:

```bash
sudo apt update
sudo apt install -y \
  clang cmake ninja-build pkg-config \
  libgtk-3-dev liblzma-dev libstdc++-12-dev \
  libsecret-1-dev libjsoncpp-dev \
  dpkg fakeroot
```

`libsecret-1-dev` + `libjsoncpp-dev` are load-bearing — omitting them produces the `flutter_secure_storage_linux` CMake error seen during the early PR #6 iterations.

On Fedora / RHEL, substitute `dnf install @development-tools gtk3-devel libsecret-devel jsoncpp-devel clang cmake ninja-build`.

### Windows (x64)

1. **Visual Studio 2022** (or 2019 Build Tools). Install the **"Desktop development with C++"** workload, including:
   - MSVC v143 C++ build tools
   - Windows 10/11 SDK
   - C++ CMake tools for Windows
2. **Git for Windows** and **PowerShell 7+**.
3. Optional for producing installers locally: **[Inno Setup 6](https://jrsoftware.org/isdl.php)**. CI installs it automatically via chocolatey.

Windows ARM64 as a **build target** is not supported by Flutter 3.41.7 — see [`CI.md`](CI.md) for the link-time failure. Windows-on-ARM machines run the x64 setup via emulation.

### macOS (arm64 / x64)

1. **Xcode 15+** from the App Store. Launch once, accept the license, and install the command-line tools:
   ```bash
   sudo xcode-select --install
   sudo xcodebuild -license accept
   ```
2. **CocoaPods** (required by Flutter's macOS embedder):
   ```bash
   sudo gem install cocoapods
   ```
3. Apple Silicon hosts do not need Rosetta for this project — both Intel (`macos-13`) and Apple Silicon (`macos-14`) runners compile natively.

Developer-signed builds are only needed for release distribution; local `flutter run` uses automatic Xcode signing.

---

## 5. IDE Setup

The repo ships opinionated configs for:

- **VS Code** (`.vscode/`) — launch configs for macOS/Linux/Windows desktop, plus analyzer settings.
- **JetBrains** (`.idea/`, `vault_env_manager.iml`) — IntelliJ / Android Studio module.

Recommended extensions:

- [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code) + [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) for VS Code.
- [Flutter Inspector](https://plugins.jetbrains.com/plugin/9212-flutter) for IntelliJ.

Enable *format on save* — `analysis_options.yaml` already enables `flutter_lints` so the formatter will keep diffs honest.

---

## 6. Verify the Setup

Run the full pre-flight suite — all of these must pass before the first build:

```bash
flutter doctor -v                 # green ticks for the host platform
flutter pub get                   # no SDK constraint errors
flutter analyze                   # no lints
flutter test                      # unit tests green
flutter run -d linux              # or: -d windows / -d macos
```

If `flutter doctor` flags a component, fix it before continuing. CI currently has `flutter analyze` / `flutter test` steps **commented out** in `flutter_ci.yml` while the desktop pipeline stabilises — run both locally before opening a PR.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `Because … requires SDK version ^3.11.4` | Flutter older than 3.41.7 on PATH. | Re-pin via fvm or update the SDK. |
| `flutter_secure_storage_linux` CMake error | Missing `libsecret-1-dev` / `libjsoncpp-dev`. | Re-run the `apt install` block above. |
| `No Linux desktop project configured` | Old checkout where `.gitignore` swallowed `*.txt`. | `git pull` main — scaffolding is now tracked. |
| `flutter run -d macos` immediately exits | `.env` missing or malformed. | `cp assets/.env.example assets/.env`, fill in required keys. |
| First launch on macOS blocked by Gatekeeper | Ad-hoc signed build. | See [`INSTALL.md`](INSTALL.md#macos) — run `xattr -cr` or the bundled helper. |
| `unresolved external __imp_JNI_CreateJavaVM` on Windows | Building on ARM64 host with x64 cross-tools. | Use an x64 Windows host until Flutter ships ARM64 desktop. |
