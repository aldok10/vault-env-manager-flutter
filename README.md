# Vault Env Manager

[![Desktop Build](https://github.com/aldok10/vault-env-manager-flutter/actions/workflows/build.yml/badge.svg)](https://github.com/aldok10/vault-env-manager-flutter/actions/workflows/build.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.41.7-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%5E3.11.4-0175C2.svg)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean--Feature-green.svg)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![Security](https://img.shields.io/badge/Security-AES--GCM--256-red.svg)](https://en.wikipedia.org/wiki/Galois/Counter_Mode)
[![License](https://img.shields.io/badge/License-Proprietary-black.svg)](#license)

**Vault Env Manager** is an industrial-grade Flutter desktop application for secure environment variable management. It combines AES-GCM authenticated encryption, PBKDF2 key derivation, and OS-native secure storage with an Apple-inspired UI that targets Linux, Windows, and macOS on both x86_64 and arm64.

> Looking for a quick start? Jump straight to [Developer Setup](docs/SETUP.md) or the [End-User Install Guide](docs/INSTALL.md).

---

## Table of Contents

- [Core Pillars](#core-pillars)
- [Supported Platforms](#supported-platforms)
- [Documentation Map](#documentation-map)
- [Quick Start (Developer)](#quick-start-developer)
- [Quick Start (End User)](#quick-start-end-user)
- [Repository Layout](#repository-layout)
- [Scripts](#scripts)
- [Contributing](#contributing)
- [License](#license)

---

## Core Pillars

### 1. Industrial-Grade Security
- **AES-GCM (256-bit)** authenticated encryption via `package:cryptography`.
- **PBKDF2 / HMAC-SHA256** with 100,000 iterations for master-key derivation.
- **OS-native secret storage**: macOS Keychain, GNOME libsecret on Linux, Windows Credential Manager.
- Heavy crypto offloaded to Dart `Isolate`s so the UI stays at 120 fps.

### 2. Apple-Inspired Premium UI/UX
- Squircle surfaces (`SmoothRectangleBorder`, radius 14.0 / smoothing 0.6).
- High-blur glassmorphism with saturated overlays.
- 250–300 ms micro-animations powered by `flutter_animate`.
- San Francisco typographic hierarchy and 44pt minimum tap targets.

### 3. Feature-Oriented Clean Architecture
- Strict `domain` / `data` / `presentation` separation per feature.
- `Either<Failure, T>` result pattern via `dartz`.
- GetX-powered reactive state and persistent `GetxService` registry.
- 3-tier dependency injection (sync services → async services → feature bindings).

See the full architectural charter in [`AGENT.md`](AGENT.md).

---

## Supported Platforms

| Platform | Architectures | Installer shipped |
| --- | --- | --- |
| Linux | `amd64`, `arm64` | `.deb` + `.tar.gz` |
| Windows | `x64` (Windows-on-ARM runs the x64 setup via emulation) | Inno Setup `.exe` + `.zip` portable |
| macOS | Apple Silicon (`arm64`), Intel (`x64`) | `.pkg` + `.dmg` + `.zip` |

Every push to `main` triggers the full 5-target matrix build and publishes a [GitHub Release](https://github.com/aldok10/vault-env-manager-flutter/releases) with all platform bundles attached. Native Windows-on-ARM builds are parked until Flutter ships ARM64 desktop tooling — see the note in [`docs/CI.md`](docs/CI.md).

---

## Documentation Map

| Document | When to read it |
| --- | --- |
| [`docs/SETUP.md`](docs/SETUP.md) | First-time setup of the Flutter toolchain and per-OS prerequisites. |
| [`docs/BUILD.md`](docs/BUILD.md) | Running Debug builds, producing Release artifacts, packaging installers locally. |
| [`docs/INSTALL.md`](docs/INSTALL.md) | End-user install instructions for `.deb`, `.exe`, `.pkg`, `.dmg` (including the macOS Gatekeeper helper). |
| [`docs/CI.md`](docs/CI.md) | How the `.github/workflows/build.yml` pipeline works and which secrets it consumes. |
| [`AGENT.md`](AGENT.md) | Institutional knowledge, architectural rules, coding standards. |
| [`WIKI.md`](WIKI.md) | Generated feature-by-feature wiki. |

---

## Quick Start (Developer)

Prerequisites checked in [`docs/SETUP.md`](docs/SETUP.md). The TL;DR:

```bash
git clone https://github.com/aldok10/vault-env-manager-flutter.git
cd vault-env-manager-flutter

# One-time: pick up the pinned Flutter SDK (3.41.7, Dart ^3.11.4).
flutter --version

# Resolve dependencies and the platform-specific desktop scaffolding.
flutter pub get
flutter config --enable-linux-desktop --enable-windows-desktop --enable-macos-desktop

# Copy the runtime env template — edit before first launch if needed.
cp assets/.env.example assets/.env

# Launch in Debug mode on the current host platform.
flutter run -d linux   # or: -d windows, -d macos
```

For Release builds and native installers, see [`docs/BUILD.md`](docs/BUILD.md).

---

## Quick Start (End User)

Grab the matching installer from the latest [GitHub Release](https://github.com/aldok10/vault-env-manager-flutter/releases):

- **Linux (amd64 / arm64)** → `*-linux-<arch>.deb` → `sudo dpkg -i <file>.deb` (falls back to `*.tar.gz`).
- **Windows (x64)** → `*-windows-x64-setup.exe` → double-click, the Inno Setup wizard handles Start Menu + Add/Remove Programs entries (falls back to `*.zip`). Windows-on-ARM runs the x64 installer under the built-in x64 emulator (`ArchitecturesAllowed=x64compatible`).
- **macOS (Apple Silicon / Intel)** → `*-macos-<arch>.pkg` → double-click to install into `/Applications`. If Gatekeeper blocks the first launch, run `FIX-GATEKEEPER.command` inside the bundled `.dmg` or right-click the app → Open → Open.

Full details per platform, including dependency list and verification commands, live in [`docs/INSTALL.md`](docs/INSTALL.md).

---

## Repository Layout

```text
.
├── lib/src/
│   ├── core/            # App-wide services (storage, crypto, compute, DI)
│   ├── features/        # Feature modules: auth, workbench, settings, …
│   │   └── <feature>/{domain,data,presentation}
│   └── shared/          # Atomic/molecular/organism widgets and shared utils
├── assets/              # Fonts, runtime .env.example, static media
├── android/ ios/        # Mobile shells (not part of the desktop CI)
├── linux/ windows/ macos/
│                        # Native runner scaffolding (CMake / Xcode)
├── installer/windows/   # Inno Setup script compiled in CI
├── tooling/macos/       # Gatekeeper helper bundled into the .dmg
├── .github/workflows/   # build.yml (desktop matrix), flutter_release.yml (tagged)
├── docs/                # Developer + end-user guides
└── pubspec.yaml
```

---

## Scripts

Helper scripts live under `bin/`:

| Script | Purpose |
| --- | --- |
| `bin/version_bump.dart` | Increment `pubspec.yaml` version + build number. |
| `bin/wiki_gen.dart` | Regenerate `WIKI.md` from source annotations. |

Run any of them via `dart run bin/<name>.dart`.

---

## Contributing

- Follow the architecture and coding standards laid out in [`AGENT.md`](AGENT.md).
- Keep source files **under 200 lines** where practical (Rule of 200).
- All async side effects must return `Either<Failure, T>` from `dartz`.
- Test robots (`test/robots/`) use the AAA pattern for UI widget coverage.
- Before opening a PR, run `flutter analyze` and `flutter test` locally. CI has analysis and tests temporarily disabled while the desktop pipeline is stabilised — they **must** be re-enabled in at least one workflow before merging feature work to `main` (see [`docs/CI.md`](docs/CI.md)).

---

## License

Proprietary. All rights reserved © 2026.
