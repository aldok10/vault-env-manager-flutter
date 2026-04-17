# 📖 Documentation Lifecycle (V4.1)

This workflow ensures the project's **Self-Documenting Standard**. Our goal is to maintain zero-manual-effort documentation that is always in sync with the codebase.

---

## 🚀 Documentation Command (CLI)

Use the automated wiki generator to safely update `WIKI.md`:

- **Generate Elite Wiki**: `dart bin/wiki_gen.dart` (Metadata-aware generation)

---

## 📦 Lifecycle Hooks

1.  **Weekly Audit**: Run `dart bin/wiki_gen.dart` every Friday to verify feature map integrity.
2.  **Major Feature Addition**: Before adding a new feature, ensure its architecture is tracked by the generator.
3.  **CI/CD**: The pipeline should fail if `WIKI.md` is significantly out of sync with `AGENT.md`.

---

*Status: Automated. Tooling: bin/wiki_gen.dart.*
