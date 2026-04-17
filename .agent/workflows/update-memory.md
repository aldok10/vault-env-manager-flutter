---
description: How to update the project memory bank with new findings
---

# Update Memory Bank

Follow this workflow to document important architectural decisions, patterns, or features using the **antigravity-memory** bank.

1.  **Start Session**: Initialize a memory session for the current task.
    ```javascript
    memory_start_session({
      "projectPath": "/Users/aldo/Apps/personal/flutter-desktop/vault_env_manager",
      "userPrompt": "<Current Task Description>"
    })
    ```

2.  **Save Notes**: Document significant milestones or architectural decisions.
    ```javascript
    memory_save_note({
      "sessionId": "<Active Session ID>",
      "userPrompt": "<Original Requirement>",
      "aiResponse": "<Detailed summary of implementation & architecture>",
      "annotation": "<Key decisions, trade-offs, or side-effects>"
    })
    ```

3.  **End Session**: Finalize and summarize the work.
    ```javascript
    memory_end_session({
      "sessionId": "<Active Session ID>"
    })
    ```

4.  **Retrieve Context**: At the start of a new session, load past intelligence.
    ```javascript
    memory_get_context({
      "projectPath": "/Users/aldo/Apps/personal/flutter-desktop/vault_env_manager",
      "currentPrompt": "<New Search Query>"
    })
    ```

> [!IMPORTANT]
> **Persistent Memory is Mandatory.** You ARE FORBIDDEN from ending a session without synchronizing context to the persistent memory bank.
