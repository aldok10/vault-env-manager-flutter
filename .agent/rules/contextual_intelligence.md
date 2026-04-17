---
trigger: always_on
---

# 🛡️ Contextual Intelligence Rule

You are an **Advanced Agentic AI**. To maintain the "Sam-Sam" standard of excellence, you must operate with perfect contextual awareness.

## 🧠 Core Reasoning Protocols

1.  **State Initialization**: Before starting any task, you **MUST**:
    -   Read `AGENT_STATE.md` to identify current milestones and progress.
    -   Read `AGENT.md` to refresh architectural protocols.
2.  **Research-First Protocol (Mandatory)**: Before implementing any new library, pattern, or platform-specific feature:
    -   Use `search_web` to verify latest syntax and breaking changes.
    -   Use `mcp_context7-locally_query-docs` for framework-specific deep dives.
    -   **Deep Traversal**: Research sub-concepts (e.g., G2/G3 continuity) until fully understood.
3.  **Recursive Discovery**: Never edit a file without first understanding its context within the feature structure:
    -   Use `list_dir` on the feature root (e.g., `lib/features/[feature_name]`).
    -   Use `grep_search` to find all usages and imports of the target file.
3.  **Fact-Checking Protocol**: Before implementing new Dart APIs, Flutter patterns, or third-party package features:
    -   Search the web to verify the latest syntax and BREAKING CHANGES.
    -   CROSS-REFERENCE version numbers in `pubspec.yaml` with official documentation.
4.  **Dependency Guard**: Identify all dependent files before using `replace_file_content`. Breaking a dependency chain is a failure of intelligence.
4.  **State Preservation**: After significant progress (e.g., completing a TODO or fixing a critical bug), you **MUST** update `AGENT_STATE.md` with a "Context Bookmark."
5.  **Visual Harmony Audit**: Before committing any UI change, perform a mental "HIG Check":
    - Use **Squircle** corners (14.0 radius) via `SmoothRectangleBorder`.
    - Respect **Contrast Ratio** (WCAG 4.5:1).
    - Animation duration: **200ms-300ms**.
6. **Documentation Retrieval (Context7)**:
    - Use `npx ctx7` to fetch up-to-date documentation for any library, framework, or API before implementation.
    - Resolve library ID first (`library`) then fetch docs (`docs`).
7. **Problem Guarding & RCA**:
    - Every bug fix REQUIRES a Root Cause Analysis (RCA) recorded in `AGENT_STATE.md`.
    - Every fix MUST include a reproduction test case in `test/reproduction/`.
    - **Fail-Fast**: Identify the exact line of failure using binary search debug logs before attempting a fix.
    - **Regression Check**: Run the full test suite after any fix to ensure zero side-effects.

8. **Cognitive Load Control (Rule of 200)**:
    - No single Dart file should exceed **200 lines**.
    - No single method should exceed **50 lines**.
    - Refactor complex widgets into smaller Molecules or Mixins to maintain high scannability.

9. **Memory Synchronization Protocol (Mandatory)**:
    - You ARE FORBIDDEN from ending a session or marking a feature as complete WITHOUT synchronizing context to the persistent memory bank via the `/update-memory` workflow.
    - Ensure all key architectural decisions and updated file paths are recorded for the next agent.

## 🎨 UI/UX Token Enforcement

-   **Atomic Design Integrity**: You are FORBIDDEN from using ad-hoc styling (e.g., `Colors.blue`, `EdgeInsets.all(8)`).
-   **Mandatory Token Usage**: All UI modifications MUST use tokens found in `lib/core/design_system/`.
-   **HIG Guardrail**: If a token doesn't exist for an Apple HIG requirement, propose a token update instead of hardcoding.

---
*Failure to adhere to these rules results in sub-optimal agentic performance.*
