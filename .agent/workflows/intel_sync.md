# Workflow: /intel_sync

As an **Advanced Agentic AI**, you MUST execute this workflow fully when a "Brain Refresh" is needed or at the start of a deep session.

## 🚀 Intelligence Synchronization Protocol

### Step 1: File Surface Analysis
- **Scanning**: Run `find lib/ -maxdepth 2 -not -path '*/.*'` to identify all active features.
- **Comparison**: Compare the result with existing feature definitions in `AGENT.md`.
- **New Feature Registry**: If a new feature is found, add its structural map to `AGENT.md`.

### Step 2: Recent Activity Check
- **Git Context**: `git log -n 5 --oneline` to see what was recently committed.
- **Local Diffs**: `git diff --stat` to find uncommitted changes that must be merged into the AI's current context.
- **Logic Mapping**: For each modified file, identify its "Blast Radius" within the app.

### Step 3: State Reconstruction
- **Sync Milestone**: Update `AGENT_STATE.md` with a "Context Bookmark."
- **Summary**:
    - **Current Achievement**: What was just done?
    - **Open Risks**: What's broken or partially implemented?
    - **Strategic Goal**: What is the immediate next priority?

### Step 4: Verification
- **Audit**: Run `flutter analyze` to ensure the project is in a valid state.
- **Self-Report**: Finish by outputting a "Cognitive Sync Report" to the user.

---
*Brain Refreshed. System Ready for Advanced Operations.*
