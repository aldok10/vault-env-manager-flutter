---
description: Mandatory Research-First Implementation Workflow for new features and libraries.
---

# 🔍 Deep Research Implementation Workflow

This workflow ensures that every technical implementation in the **Vault Master** project is backed by the latest documentation and architectural best practices.

## 📋 Execution Steps

### 1. Context Assimilation
Analyze the existing codebase and `pubspec.yaml` to identify the technical footprint.
- Check current library versions.
- Map existing architectural patterns (Features, Layers, DI).

### 2. Independent Search
// turbo
Use specialized tools to gather the latest technical intelligence.
- `search_web`: Find 2024/2025 best practices, breaking changes, and performance benchmarks.
- `mcp_context7-locally_query-docs`: Fetch specific API syntax for the target library.

### 3. Knowledge Mapping
Synthesize research into a structured "Skill Tree" for the specific task.
- Define Fundamental, Advanced, and Ecosystem-specific requirements.
- Identify platform-specific "Gotchas" (e.g., macOS Keychain entitlements).

### 4. Implementation Design
Propose the change using an **Implementation Plan** artifact.
- Must specify how the change fits into **Feature-Oriented Clean Architecture**.
- Must specify Security and UI tokens to be used.

### 5. Verified Execution
Implement following the **Atomic-Only** UI rule and **Result Pattern** for logic.
- Verify with `flutter analyze` and `flutter test`.

---
*Reference: Antigravity Agent Protocol v3.1*
