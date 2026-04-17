---
description: Automated Multi-Platform Desktop Distribution
---

# Automated Build Workflow

This workflow governs the generation of production-ready distribution packages for macOS, Windows, and Linux using GitHub Actions.

## Triggering a Build

Building and releasing is automatically triggered by pushing a version tag to the repository.

1.  **Bump the Version**:
    ```bash
    dart bin/version_bump.dart patch # or minor, major
    ```
2.  **Commit the Changes**:
    ```bash
    git add pubspec.yaml
    git commit -m "chore: bump version to 1.0.x"
    ```
3.  **Tag the Release**:
    ```bash
    git tag v1.0.x
    ```
4.  **Push to GitHub**:
    ```bash
    git push origin main --tags
    ```

## CI/CD Pipeline Logic

The `.github/workflows/build.yml` will:
1.  **Build (Parallel)**:
    - **macOS**: Generates a `.dmg` using `hdiutil`.
    - **Windows**: Generates a `.zip` containing the Release binaries.
    - **Linux**: Generates a `.zip` containing the App bundle.
2.  **Release**:
    - Aggregates all artifacts.
    - Creates a new **GitHub Release** corresponding to the tag.
    - Uploads all artifacts to the Release page.

## Post-Build Verification

-   **macOS**: Download the `.dmg`, mount it, and drag the app to Applications.
-   **Windows**: Extract the `.zip` and run `vault_env_manager.exe`.
-   **Linux**: Extract the `.zip` and run `vault_env_manager`.

> [!WARNING]
> **Code Signing**: Currently, builds are not signed. macOS users will need to right-click and "Open" to bypass Gatekeeper. For production, add your Apple Developer certificates to GitHub Secrets and update the `build.yml` with signing steps.
