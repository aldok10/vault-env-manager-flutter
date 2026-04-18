# CI / CD Pipeline

Reference for the GitHub Actions workflows that build, package, and release the desktop application. The authoritative source is [`.github/workflows/`](../.github/workflows/) — this document explains *why* the workflows are shaped the way they are.

Related: [`SETUP.md`](SETUP.md) · [`BUILD.md`](BUILD.md) · [`INSTALL.md`](INSTALL.md).

---

## Table of Contents

- [Workflow Inventory](#workflow-inventory)
- [Build Matrix](#build-matrix)
- [Desktop Pipeline Stages](#desktop-pipeline-stages)
- [Dynamic Secret Injection](#dynamic-secret-injection)
- [Caching Strategy](#caching-strategy)
- [Release Automation](#release-automation)
- [Quality Gates (currently paused)](#quality-gates-currently-paused)
- [Known Limitations](#known-limitations)
- [Adding a New Target](#adding-a-new-target)
- [Debugging Failed Runs](#debugging-failed-runs)

---

## Workflow Inventory

| File | Trigger | Purpose |
| --- | --- | --- |
| [`build.yml`](../.github/workflows/build.yml) | `push` / `pull_request` to `main` | Desktop multi-arch matrix build + native installer packaging + rolling release on merge to `main`. |
| [`flutter_ci.yml`](../.github/workflows/flutter_ci.yml) | `push` / `pull_request` to `main` | Lint + unit tests (quality gate steps temporarily commented out — see below). |
| [`flutter_release.yml`](../.github/workflows/flutter_release.yml) | `push` of `v*` tag | Signed release workflow reserved for tagged semantic versions (untouched by the desktop pipeline work). |

---

## Build Matrix

`build.yml` runs five jobs in parallel:

| Target | Runner | Flutter install | Installer produced |
| --- | --- | --- | --- |
| `linux-x64` | `ubuntu-latest` | `subosito/flutter-action@v2` (x64 prebuilt) | `.deb` (amd64) + `.tar.gz` |
| `linux-arm64` | `ubuntu-24.04-arm` | Shallow `git clone` of the Flutter tag | `.deb` (arm64) + `.tar.gz` |
| `windows-x64` | `windows-latest` | `subosito/flutter-action@v2` (x64 prebuilt) | Inno Setup `.exe` + `.zip` |
| `macos-arm64` | `macos-14` (Apple Silicon) | `subosito/flutter-action@v2` (arm64 prebuilt) | `.pkg` + `.dmg` + `.zip` |
| `macos-x64` | `macos-13` (Intel) | `subosito/flutter-action@v2` (x64 prebuilt) | `.pkg` + `.dmg` + `.zip` |

`windows-arm64` is intentionally excluded — see [Known Limitations](#known-limitations).

---

## Desktop Pipeline Stages

Each matrix job walks through the same staged pipeline (`.github/workflows/build.yml:95–440`):

1. **Checkout** (`actions/checkout@v4`).
2. **Install Flutter** — prebuilt via `subosito/flutter-action@v2`, or a shallow git clone of the pinned tag on Linux arm64. The git-clone path runs `flutter --disable-analytics && flutter --version` so Dart SDK bootstrap happens before any cache-sensitive step.
3. **Restore Pub cache** (`actions/cache@v4`) keyed on `runner.os + matrix.arch + pubspec.lock`.
4. **Enable desktop support** (`flutter config --enable-*-desktop`).
5. **Install OS prerequisites** — apt packages (Linux), Inno Setup via chocolatey (Windows), Xcode project patch (macOS).
6. **Resolve dependencies** (`flutter pub get`).
7. **Write runtime `.env`** — injected from `APP_ENV_FILE` GitHub Secret (falls back to `assets/.env.example`).
8. **Compute versions** — `semver`, `short_sha`, `version_tag = <semver>-ci.<run_number>`.
9. **Flutter build** — `flutter build <family> --release --no-tree-shake-icons` with `--dart-define=APP_BUILD_NUMBER|APP_GIT_SHA|APP_ENVIRONMENT=ci`.
10. **Package** — OS-specific steps described in [`BUILD.md`](BUILD.md#packaging-installers-locally).
11. **Upload artifacts** (`actions/upload-artifact@v4`, 14-day retention).

The final `release` job depends on every matrix build; see [Release Automation](#release-automation).

---

## Dynamic Secret Injection

No secret is ever written to the tracked filesystem. Two mechanisms feed the build:

1. **Runtime `.env`** — materialised from `${{ secrets.APP_ENV_FILE }}`:
   ```yaml
   echo "${{ secrets.APP_ENV_FILE }}" > assets/.env
   ```
   If the secret is unset, `assets/.env.example` is copied instead so PR runs still succeed.

2. **Compile-time `--dart-define`** — three non-sensitive values injected on every build:
   | Flag | Source |
   | --- | --- |
   | `APP_BUILD_NUMBER` | `${{ github.run_number }}` |
   | `APP_GIT_SHA` | `${{ github.sha }}` |
   | `APP_ENVIRONMENT` | Literal `ci` |

Required GitHub Secrets:

| Secret | Scope | Used for |
| --- | --- | --- |
| `APP_ENV_FILE` | Repo / org | Runtime `.env` contents. Optional — omission falls back to the tracked example. |
| `GITHUB_TOKEN` | Injected by Actions | Creating/updating the rolling GitHub Release. |

Additional secrets for the tagged `flutter_release.yml` (Apple Developer ID signing + notarization) are documented inside that workflow and are **not** consumed by `build.yml`.

---

## Caching Strategy

Two layers of cache keep runs under ~4 minutes for repeat invocations:

- **`subosito/flutter-action@v2`** caches the Flutter SDK itself under `~/.flutter-tool`. The action keys on the SDK tag + channel.
- **`actions/cache@v4`** caches pub dependencies:
  ```yaml
  path: |
    ~/.pub-cache
    .dart_tool
  key: ${{ runner.os }}-${{ matrix.arch }}-pub-${{ hashFiles('**/pubspec.lock') }}
  restore-keys: |
    ${{ runner.os }}-${{ matrix.arch }}-pub-
  ```

The cache key includes `matrix.arch` so x64 and arm64 runners do not clobber each other's caches, and it keys on `pubspec.lock` so dependency bumps produce a fresh cache on first run.

---

## Release Automation

A single `release` job depends on all five matrix builds. It:

1. Downloads every `dist/**` artifact via `actions/download-artifact@v4`.
2. Globs for the installer set:
   - `downloaded/**/*.deb`
   - `downloaded/**/*.tar.gz`
   - `downloaded/**/*setup.exe`
   - `downloaded/**/*windows-*.zip`
   - `downloaded/**/*.pkg`
   - `downloaded/**/*.dmg`
   - `downloaded/**/*macos-*.zip`
3. Creates/updates a rolling GitHub Release tagged `build-<run_number>-<short_sha>` via `softprops/action-gh-release@v2` with `fail_on_unmatched_files: true` to catch packaging regressions early.

`fail_on_unmatched_files` is why small packaging bugs (e.g. Inno Setup writing to the wrong `OutputDir`) surface as release-job failures rather than silent gaps in the release attachment list.

---

## Quality Gates (currently paused)

`flutter_ci.yml` still runs `flutter pub get` and boots the Flutter toolchain so badge status stays honest, but the following steps are commented out while the desktop pipeline stabilises:

- `dart format --set-exit-if-changed`
- `flutter analyze`
- `flutter test --coverage`
- `flutter build web` (pre-existing sanity check)

Developer responsibility: run `flutter analyze && flutter test` locally before opening a PR. At least one of these four gates must be re-enabled in CI before merging unrelated feature work to `main`.

---

## Known Limitations

### Windows ARM64 is not in the matrix

Flutter 3.41.7 stable does not ship Windows ARM64 desktop tooling. When `flutter build windows` runs on an ARM64 host it downloads the x64 toolchain and cross-compiles to x64 binaries. The transitive `jni` plugin then tries to link against the ARM64 JVM exposed by the hosted `Temurin Hotspot` toolcache, producing:

```
dartjni.obj : error LNK2019: unresolved external symbol __imp_JNI_CreateJavaVM
libjvm.lib : warning LNK4272: library machine type 'ARM64' conflicts with target machine type 'x64'
```

Workaround: Windows-on-ARM users install the x64 `.exe` setup — Windows 11's built-in x64 emulation runs it transparently. Revisit once Flutter publishes native Windows ARM64 desktop releases.

### Linux ARM64 requires git-clone install

`releases_linux.json` exposes x64 Flutter SDK prebuilts only, so `subosito/flutter-action@v2` fails on `ubuntu-24.04-arm` with `Unable to determine Flutter version for channel: stable version: 3.41.7 architecture: arm64`. The workflow falls back to a shallow `git clone --branch 3.41.7` — Flutter's own `update_dart_sdk` bootstrap then downloads the matching ARM64 Dart SDK on first invocation.

### macOS Gatekeeper warnings

Artifacts are ad-hoc signed; Gatekeeper warns on every first launch. See [`INSTALL.md`](INSTALL.md#why-the-damagedmalware-warning) for the user-facing workaround and [`tooling/macos/fix-gatekeeper.command`](../tooling/macos/fix-gatekeeper.command) for the bundled helper. Tier B (Developer ID + notarization) is scoped to a future PR.

---

## Adding a New Target

1. Append a new entry under `strategy.matrix.include` with the minimum keys (`target`, `os`, `family`, `arch`, and any `flutter_arch_dir` / `deb_arch` / `flutter_install` hints).
2. Ensure the OS-specific prerequisite step covers the new runner (apt package list for Linux, chocolatey package for Windows, Xcode pbxproj patch for macOS).
3. Extend the packaging step(s) if the output shape differs (e.g. a `.rpm` target would need `rpmbuild`).
4. Add the new artifact glob to the `release` job so the rolling release attaches it.
5. Update [`SETUP.md`](SETUP.md#toolchain-matrix), [`INSTALL.md`](INSTALL.md#pick-the-right-file), and this document's [Build Matrix](#build-matrix) table.

---

## Debugging Failed Runs

| Symptom | First place to look |
| --- | --- |
| `Unable to determine Flutter version for channel … architecture: arm64` | `subosito/flutter-action@v2` step — swap to `flutter_install: git`. |
| `flutter_secure_storage_linux` CMake error | Missing `libsecret-1-dev` / `libjsoncpp-dev` on a new Linux runner. |
| `LNK2019 __imp_JNI_CreateJavaVM` on Windows | Running on an ARM64 host — remove the target from the matrix. |
| `codesign` errors on macOS | `project.pbxproj` patch step was skipped or `DEVELOPMENT_TEAM` snuck back in. |
| `softprops/action-gh-release` fails with `no files matched` | A packaging step silently produced zero files — inspect the corresponding matrix job's `dist/` upload. |
| Release published but an installer is missing | Glob pattern in the `release` job does not match the artifact name. |

CI logs are available from the [Actions](https://github.com/aldok10/vault-env-manager-flutter/actions) tab. For local reproduction, follow the [Reproducing CI Output Locally](BUILD.md#reproducing-ci-output-locally) section of `BUILD.md`.
