# Building Vault Env Manager

End-to-end guide for building Debug and Release artifacts on Linux, Windows, and macOS — both via `flutter run`/`flutter build` directly and by reproducing the CI packaging steps locally.

Prereqs: [`SETUP.md`](SETUP.md) completed, `flutter pub get` clean, `assets/.env` populated.

---

## Table of Contents

- [Build Modes at a Glance](#build-modes-at-a-glance)
- [Debug Builds](#debug-builds)
- [Profile Builds](#profile-builds)
- [Release Builds](#release-builds)
  - [Linux](#linux-release)
  - [Windows](#windows-release)
  - [macOS](#macos-release)
- [Packaging Installers Locally](#packaging-installers-locally)
  - [Linux `.deb` + `.tar.gz`](#linux-deb--targz)
  - [Windows `.exe` setup + `.zip`](#windows-exe-setup--zip)
  - [macOS `.pkg` + `.dmg` + `.zip`](#macos-pkg--dmg--zip)
- [Injecting Build-time Variables](#injecting-build-time-variables)
- [Reproducing CI Output Locally](#reproducing-ci-output-locally)

---

## Build Modes at a Glance

| Mode | Command | Asserts | Tree-shake | JIT / AOT | When to use |
| --- | --- | --- | --- | --- | --- |
| Debug | `flutter run` | on | no | JIT | Daily development, hot reload. |
| Profile | `flutter run --profile` | partial | yes | AOT | Performance profiling, DevTools timeline. |
| Release | `flutter build <target> --release` | off | yes (disabled in CI) | AOT | Shipping artifacts. |

Release builds are always compiled with `--no-tree-shake-icons` because the codebase constructs `IconData(...)` dynamically in settings/workbench — tree-shaking strips the font glyphs and crashes at launch. Keep the flag in sync with CI.

---

## Debug Builds

```bash
# Auto-detect the host platform
flutter run

# Explicit targets
flutter run -d linux
flutter run -d windows
flutter run -d macos
```

Hot reload is active; hot restart resets singletons registered via `GetxService`. If reactive state looks stale after a restart, kill the app and relaunch — this is expected with the 3-tier DI bootstrap described in [`AGENT.md`](../AGENT.md).

To attach a debugger, launch from VS Code / IntelliJ using the run configurations under `.vscode/launch.json` and `.idea/`.

---

## Profile Builds

```bash
flutter run --profile -d <platform>
```

Opens DevTools automatically. Use for:

- 60/120 fps frame-time audits (target: `< 8.3 ms` per frame).
- Isolate scheduling checks for the AES-GCM / PBKDF2 paths that run in `ComputeService`.
- Memory snapshots before/after large payload operations.

Profile mode keeps asserts and service extensions enabled but compiles AOT, so performance numbers track the release behaviour closely.

---

## Release Builds

### Linux Release

```bash
flutter build linux --release --no-tree-shake-icons
```

Output bundle: `build/linux/<arch>/release/bundle/` containing the `vault_env_manager` binary, bundled `lib/` folder, and `data/` assets. `<arch>` matches the host — `x64` on amd64 hosts, `arm64` on aarch64 hosts. Flutter cross-compilation between Linux architectures is not supported; spin up an arm64 host for an arm64 bundle.

### Windows Release

```powershell
flutter build windows --release --no-tree-shake-icons
```

Output: `build\windows\x64\runner\Release\` containing `vault_env_manager.exe` plus its Flutter DLLs (`flutter_windows.dll`, `*_plugin.dll`, `data\`). A `x64` folder path is correct even on ARM64 hosts — Flutter 3.41.7 only emits x64 binaries on Windows.

### macOS Release

```bash
flutter build macos --release --no-tree-shake-icons
```

Output: `build/macos/Build/Products/Release/vault_env_manager.app`. Locally this is signed with the developer's automatic Xcode identity. For CI, the project is patched to use ad-hoc signing (`CODE_SIGN_IDENTITY = "-"`) before the build step so no Apple Developer account is required.

Verify the bundle:

```bash
codesign -dv --verbose=2 build/macos/Build/Products/Release/vault_env_manager.app
spctl -a -t exec -vv build/macos/Build/Products/Release/vault_env_manager.app || true
```

`spctl` will refuse ad-hoc signed apps; that's expected — see the Gatekeeper section in [`INSTALL.md`](INSTALL.md#macos).

---

## Packaging Installers Locally

The CI workflow at `.github/workflows/build.yml` is authoritative. The snippets below let developers reproduce the same artifact shapes without waiting for a pipeline run.

### Linux `.deb` + `.tar.gz`

```bash
APP_NAME=vault-env-manager
APP_BINARY=vault_env_manager
APP_DISPLAY_NAME="Vault Env Manager"
APP_VERSION="$(awk '/^version:/ {split($2,v,"+"); print v[1]}' pubspec.yaml)"
ARCH="$(dpkg --print-architecture)"   # amd64 or arm64
FLUTTER_ARCH_DIR=$([ "${ARCH}" = "amd64" ] && echo x64 || echo arm64)

# 1. Build
flutter build linux --release --no-tree-shake-icons

# 2. Stage a Debian tree
bundle_dir="build/linux/${FLUTTER_ARCH_DIR}/release/bundle"
pkg_root="pkg-linux"
rm -rf "${pkg_root}" && mkdir -p \
  "${pkg_root}/opt/${APP_NAME}" \
  "${pkg_root}/usr/bin" \
  "${pkg_root}/DEBIAN" \
  "${pkg_root}/usr/share/applications" \
  "${pkg_root}/usr/share/icons/hicolor/256x256/apps"
cp -r "${bundle_dir}/." "${pkg_root}/opt/${APP_NAME}/"
ln -sf "/opt/${APP_NAME}/${APP_BINARY}" "${pkg_root}/usr/bin/${APP_NAME}"
cp macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png \
  "${pkg_root}/usr/share/icons/hicolor/256x256/apps/${APP_NAME}.png"

# 3. .desktop entry + DEBIAN/control — see build.yml for exact contents.

# 4. Build the .deb
mkdir -p dist
fakeroot dpkg-deb --build --root-owner-group "${pkg_root}" \
  "dist/${APP_NAME}-${APP_VERSION}-linux-${ARCH}.deb"

# 5. Portable tarball
tar -C "${bundle_dir}" -czf \
  "dist/${APP_NAME}-${APP_VERSION}-linux-${ARCH}.tar.gz" .
```

### Windows `.exe` setup + `.zip`

```powershell
$AppVersion = (Get-Content pubspec.yaml | Select-String '^version:').Line.Split()[1].Split('+')[0]
flutter build windows --release --no-tree-shake-icons

New-Item -ItemType Directory -Force -Path dist | Out-Null
$releaseDir = (Resolve-Path 'build\windows\x64\runner\Release').Path
$absDistDir = (Resolve-Path 'dist').Path
$outputBase = "vault-env-manager-$AppVersion-windows-x64-setup"

# 1. Inno Setup installer (.exe)
iscc "/O$absDistDir" `
  "/DAppVersion=$AppVersion" `
  "/DBuildNumber=0" `
  "/DArch=x64" `
  "/DBuildDir=$releaseDir" `
  "/DOutputBase=$outputBase" `
  installer\windows\setup.iss

# 2. Portable zip
Compress-Archive -Path "$releaseDir\*" `
  -DestinationPath "dist\vault-env-manager-$AppVersion-windows-x64.zip"
```

### macOS `.pkg` + `.dmg` + `.zip`

```bash
APP_VERSION="$(awk '/^version:/ {split($2,v,"+"); print v[1]}' pubspec.yaml)"
ARCH="$(uname -m)"        # arm64 or x86_64
TAG="vault-env-manager-${APP_VERSION}-macos-${ARCH}"

flutter build macos --release --no-tree-shake-icons

APP="build/macos/Build/Products/Release/vault_env_manager.app"
codesign --force --deep --sign - "${APP}"
xattr -cr "${APP}"

mkdir -p dist

# 1. .pkg installer (installs into /Applications)
pkgbuild --identifier com.aldok10.vaultenvmanager \
  --version "${APP_VERSION}" \
  --install-location /Applications \
  --component "${APP}" \
  "dist/${TAG}.pkg"

# 2. .dmg with the Gatekeeper helper bundled at the root
stage="$(mktemp -d)"
cp -R "${APP}" "${stage}/"
cp tooling/macos/fix-gatekeeper.command "${stage}/FIX-GATEKEEPER.command"
chmod +x "${stage}/FIX-GATEKEEPER.command"
hdiutil create -volname "Vault Env Manager" -srcfolder "${stage}" \
  -ov -format UDZO "dist/${TAG}.dmg"

# 3. Flat .zip fallback
ditto -c -k --keepParent "${APP}" "dist/${TAG}.zip"
```

The same helper (`tooling/macos/fix-gatekeeper.command`) is shipped inside every `.dmg` and `.zip` — reuse the tracked script rather than regenerating it.

---

## Injecting Build-time Variables

Runtime config is injected via `--dart-define` compile-time constants. CI emits three values on every build; reproduce locally with:

```bash
flutter build linux --release --no-tree-shake-icons \
  --dart-define=APP_BUILD_NUMBER="42" \
  --dart-define=APP_GIT_SHA="$(git rev-parse HEAD)" \
  --dart-define=APP_ENVIRONMENT="local"
```

Custom `--dart-define` values appear on `String.fromEnvironment('APP_BUILD_NUMBER')` inside the app. Never pass secrets this way — they end up embedded in the binary. Use `assets/.env` (dev) or GitHub Secrets + the materialised `.env` in CI (see [`CI.md`](CI.md)).

---

## Reproducing CI Output Locally

To match CI exactly:

1. Check out the branch CI is building.
2. `flutter --version` → must print `3.41.7`.
3. Export the same env vars the workflow sets: `APP_NAME`, `APP_BINARY`, `APP_DISPLAY_NAME`, `APP_BUNDLE_ID` (see the top of `build.yml`).
4. Run the OS-specific build + packaging snippets above with `APP_BUILD_NUMBER=<CI run_number>`.
5. Compare SHA-256 of the produced artifact against the CI upload:
   ```bash
   shasum -a 256 dist/*.deb dist/*.pkg dist/*.zip
   ```

Byte-for-byte reproducibility is not guaranteed (timestamps, temp paths), but file shape and layout should match.
