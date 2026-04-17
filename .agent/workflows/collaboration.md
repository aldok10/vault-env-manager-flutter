---
description: Collaborative workflow for AI and Human interaction.
---

# 🤝 Collaborative Workflow (Team interaction)

This workflow defines the **Vault's** high-fidelity interaction standards for AI agents and human collaborators to ensure zero context loss.

## 📝 Phase 1: Conventional Commits (MANDATORY)
- **Format**: `<type>(<scope>): <short description>`
- **Standard Types**:
    - `feat`: New business feature (e.g., `feat(workbench): add scout node`).
    - `fix`: Bug resolution (e.g., `fix(auth): resolve token expiry`).
    - `refactor`: Structural change with no logic shift (e.g., `refactor(core): apply rule of 200`).
    - `style`: UI refinement or formatting (e.g., `style(design): update button tokens`).
    - `test`: Adding or updating tests (e.g., `test(vault): add gherkin for backup`).
    - `chore`: Build system, CI, or dependency updates.
    - `docs`: Documentation only changes.

## 📑 Phase 2: The "Context Bookmark" (Session Handover)
- **Action**: Always update **AGENT_STATE.md** before ending a turn or session.
- **Handover Structure**:
    - `Timestamp`: Current local time and specific session IDE.
    - `Milestone`: What was achieved vs the original `task.md`.
    - `Current Context`: List of open files and active controllers.
    - `Caveats`: Known logic loops, incomplete refactors, or skipped tests.
    - `Next Action`: Clear instruction for the next agent/turn.

## 💬 Phase 3: Interaction & Communication Style
- **AI-to-Human**: Use technical, objective language. Avoid fluff. Provide direct links to artifacts and diffs.
- **AI-to-AI**: Treat the `AGENT_STATE.md` and `task.md` as the source of truth. 100% adherence to defined workflows is the only form of collaboration.
- **Feedback Loop**: When a design decision is ambiguous, **STOP** and request human feedback before modifying the `Domain` layer.

// turbo
## ✅ Phase 4: Protocol Enforcement Gate
- **Action**: Run the `Review Protocol` checklist.
- **Action**: Ensure `task.md` reflects 100% completion before declaring victory.
- **Action**: Verify that the latest `walkthrough.md` correctly visualizes the changes.

---
*Status: Active. Communication: Standardized. Synergy: Optimized.*
