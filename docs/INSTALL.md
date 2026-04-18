# End-User Installation Guide

Step-by-step instructions for installing Vault Env Manager from the official GitHub Releases. Every merge to `main` publishes a rolling release containing all platform installers.

- Latest release: <https://github.com/aldok10/vault-env-manager-flutter/releases>
- Source: [`docs/CI.md`](CI.md) describes how the release is produced.

---

## Table of Contents

- [Artifact Naming Convention](#artifact-naming-convention)
- [Pick the Right File](#pick-the-right-file)
- [Linux](#linux)
  - [`.deb` (recommended, Debian/Ubuntu/Mint)](#deb-recommended-debianubuntumint)
  - [`.tar.gz` (portable)](#targz-portable)
- [Windows](#windows)
  - [`.exe` Inno Setup (recommended)](#exe-inno-setup-recommended)
  - [`.zip` portable](#zip-portable)
  - [Windows on ARM](#windows-on-arm)
- [macOS](#macos)
  - [`.pkg` (recommended)](#pkg-recommended)
  - [`.dmg` + Gatekeeper](#dmg--gatekeeper)
  - [`.zip` fallback](#zip-fallback)
  - [Why the "damaged/malware" warning?](#why-the-damagedmalware-warning)
- [Verifying the Install](#verifying-the-install)
- [Upgrading / Uninstalling](#upgrading--uninstalling)

---

## Artifact Naming Convention

```
vault-env-manager-<semver>-ci.<run_number>-<platform>-<arch>[-setup].<ext>
```

| Segment | Example | Meaning |
| --- | --- | --- |
| `<semver>` | `1.0.1` | `pubspec.yaml` version (without build code). |
| `ci.<run_number>` | `ci.42` | GitHub Actions run number — acts as build identifier. |
| `<platform>` | `linux`, `windows`, `macos` | OS family. |
| `<arch>` | `amd64`, `arm64`, `x64` | Target CPU (Linux uses `amd64`/`arm64`, Windows uses `x64`, macOS uses `arm64`/`x64`). |
| `-setup` | optional | Present only on the Windows Inno Setup installer. |
| `<ext>` | `.deb`, `.tar.gz`, `.exe`, `.zip`, `.pkg`, `.dmg` | Package format. |

Example: `vault-env-manager-1.0.1-ci.42-macos-arm64.pkg`.

---

## Pick the Right File

| OS | Recommended file | Fallback |
| --- | --- | --- |
| Ubuntu / Debian / Mint | `*-linux-amd64.deb` (Intel/AMD) or `*-linux-arm64.deb` (Raspberry Pi / Ampere) | `*-linux-<arch>.tar.gz` |
| Other Linux (Fedora, Arch, openSUSE, CentOS) | `*-linux-<arch>.tar.gz` | — |
| Windows 10/11 (x64) | `*-windows-x64-setup.exe` | `*-windows-x64.zip` |
| Windows on ARM | `*-windows-x64-setup.exe` under x64 emulation | `*-windows-x64.zip` |
| macOS Apple Silicon | `*-macos-arm64.pkg` | `*-macos-arm64.dmg` or `.zip` |
| macOS Intel | `*-macos-x64.pkg` | `*-macos-x64.dmg` or `.zip` |

---

## Linux

### `.deb` (recommended, Debian/Ubuntu/Mint)

```bash
# 1. Download the matching .deb from the Releases page.
curl -L -o vault-env-manager.deb \
  https://github.com/aldok10/vault-env-manager-flutter/releases/latest/download/vault-env-manager-<semver>-ci.<run>-linux-amd64.deb

# 2. Install (dependencies resolve automatically via apt).
sudo apt install ./vault-env-manager.deb

# 3. Launch.
vault-env-manager        # or use the launcher entry under "Applications"
```

What the `.deb` installs:

- Main app under `/opt/vault-env-manager/`.
- Launcher symlink at `/usr/bin/vault-env-manager`.
- Freedesktop `.desktop` entry at `/usr/share/applications/vault-env-manager.desktop`.
- Icon in `/usr/share/icons/hicolor/{128,256,512}x{128,256,512}/apps/`.

System requirements: `libgtk-3-0`, `libsecret-1-0`, `libjsoncpp25` (or newer). `apt install` pulls them in automatically.

### `.tar.gz` (portable)

```bash
tar -xzf vault-env-manager-<semver>-ci.<run>-linux-<arch>.tar.gz -C ~/apps/vault-env-manager
~/apps/vault-env-manager/vault_env_manager
```

No launcher integration, no apt dependencies resolved — useful for sandboxed runs or distros without `dpkg`. Install `libsecret-1-0` and `libgtk-3-0` via the host package manager if the binary fails to start.

---

## Windows

### `.exe` Inno Setup (recommended)

1. Download `vault-env-manager-<semver>-ci.<run>-windows-x64-setup.exe`.
2. Double-click → accept the SmartScreen warning ("More info" → "Run anyway"). The binary is unsigned on the free tier — see [Why the warning?](#why-the-damagedmalware-warning).
3. Follow the wizard. Defaults install into `C:\Program Files\VaultEnvManager`, register an "Add/Remove Programs" entry, and create a Start Menu shortcut.
4. Launch from the Start Menu or the optional desktop shortcut.

Silent install (for mass deployment):

```powershell
Start-Process -FilePath 'vault-env-manager-1.0.1-ci.42-windows-x64-setup.exe' `
  -ArgumentList '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART' -Wait
```

### `.zip` portable

```powershell
Expand-Archive vault-env-manager-<semver>-ci.<run>-windows-x64.zip -DestinationPath 'C:\apps\VaultEnvManager'
& 'C:\apps\VaultEnvManager\vault_env_manager.exe'
```

No registry entries, no uninstaller. Delete the folder to uninstall.

### Windows on ARM

Native Windows ARM64 builds are not produced yet (Flutter 3.41.7 has no Windows ARM64 desktop tooling). Windows 11 on ARM runs the x64 `setup.exe` transparently under the built-in x64 emulation layer; install it the same way as on x64 hardware.

---

## macOS

### `.pkg` (recommended)

1. Download the matching `.pkg` for the CPU architecture (`arm64` for Apple Silicon, `x64` for Intel).
2. Double-click → Installer runs the standard wizard → the app lands in `/Applications/vault_env_manager.app`.
3. On first launch Gatekeeper will still prompt: right-click → **Open** → **Open** in the confirmation sheet. This whitelists the bundle for future launches.

The `.pkg` is **pkgbuild**-generated and ships the Info.plist bundle identifier `com.aldok10.vaultenvmanager` for `launchctl`/MDM targeting.

### `.dmg` + Gatekeeper

1. Download the matching `.dmg`, double-click to mount.
2. Drag `vault_env_manager.app` into `/Applications` (the `.dmg` shows the standard Applications shortcut).
3. If macOS reports **"app is damaged and can't be opened"** or **"Apple could not verify …"**, either:
   - Right-click the app → **Open** → **Open** in the confirmation sheet, or
   - Double-click `FIX-GATEKEEPER.command` inside the mounted `.dmg` volume. The helper resolves the installed `.app` in this order — `/Applications/vault_env_manager.app`, `$HOME/Applications/vault_env_manager.app`, then any `.app` sitting next to the script — and runs `/usr/bin/xattr -cr` against every match, so the workflow "drag to /Applications, then run the helper" scrubs the right copy. Source: [`tooling/macos/fix-gatekeeper.command`](../tooling/macos/fix-gatekeeper.command).

### `.zip` fallback

```bash
unzip vault-env-manager-<semver>-ci.<run>-macos-<arch>.zip -d /Applications   # <arch> = arm64 or x64
xattr -cr /Applications/vault_env_manager.app
open /Applications/vault_env_manager.app
```

Same Gatekeeper caveats apply.

### Why the "damaged/malware" warning?

Gatekeeper in macOS 14+ flags every app that is **not** signed with a Developer ID Application certificate **and** notarized by Apple. The CI produces ad-hoc signed builds (`codesign --sign -`) because that path does not require an Apple Developer membership. Ad-hoc is sufficient for the OS to *execute* the app once trusted, but Gatekeeper still warns on first launch.

Two permanent fixes, both requiring Apple Developer infrastructure:

1. **Developer ID signing + notarization** (planned as "Tier B"): needs `APPLE_ID`, app-specific password, team id, and a Developer ID Application `.p12`. Eliminates the prompt entirely.
2. **Install via Mac App Store**: outside the scope of this project.

Until either is wired in, the Gatekeeper helper + right-click → Open workflow is the expected UX.

---

## Verifying the Install

```bash
# Linux
dpkg -L vault-env-manager | grep -E '(bin|desktop|icons)'
vault-env-manager --version           # if the app exposes --version in future

# Windows (PowerShell)
Get-Item 'C:\Program Files\VaultEnvManager\vault_env_manager.exe'

# macOS
codesign -dv --verbose=2 /Applications/vault_env_manager.app
spctl -a -t exec -vv /Applications/vault_env_manager.app  # expect "rejected (ad-hoc)"
```

SHA-256 checksums for every artifact are visible on the Release page sidebar.

---

## Upgrading / Uninstalling

| Platform | Upgrade | Uninstall |
| --- | --- | --- |
| Linux `.deb` | `sudo apt install ./<new>.deb` | `sudo apt remove vault-env-manager` |
| Linux `.tar.gz` | Overwrite the extracted folder | Delete the folder |
| Windows `.exe` | Run the new installer over the top — Inno Setup detects the prior install | Settings → Apps → "Vault Env Manager" → Uninstall |
| Windows `.zip` | Delete folder, extract new | Delete the folder |
| macOS `.pkg` / `.dmg` | Drag the new `.app` over the old one in `/Applications` | Drag the app to Trash, empty Trash |

User data (encrypted vault payload, keychain entries, preferences) is preserved across upgrades because it lives in the OS-native secure storage, not inside the installed bundle.
