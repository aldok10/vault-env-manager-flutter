---
name: design_system.md
trigger: glob
description: Mandatory Design System tokens and Atomic components enforcement.
globs: lib/features/*/presentation/**/*.dart, lib/app/**/*.dart, lib/core/design_system/**/*.dart
---

# 🎨 UI/UX Design System Enforcement (Apple HIG & Pro Max)

This project uses a custom **Atomic Design System** with strict adherence to tokens. All UI elements must use the core tokens defined in `lib/core/design_system/`.

## 💎 Atomic Components (Apple Standard)

-   **Atoms**: Base UI units (`AppButton`, `AppBadge`, `AppTextField`, `AppIcon`). All interactive atoms MUST support selection haptics.
-   **Molecules**: Simple groups of atoms (`NavigationPill`, `AppCodeEditor`). Use **Squircle** borders for all molecule containers.
-   **Organisms**: Complex screen sections (`FeatureHeader`, `ScoutSidepanel`). Maintain a consistent 8pt/12pt spacing grid.
-   **Templates/Pages**: Full screen layouts (e.g. `WorkbenchPage`). Respect **Safe Areas** and **macOS Sidebar** conventions.

## 🧱 Design Tokens (HIG Compliant)

-   **Colors**: Use `AppColors` ONLY. Avoid `Colors.xyz`. Support **Vibrant Glassmorphism** (System-level transparency).
-   **Spacing**: Use `AppSpacing` (`smH`, `mdV`, `lgH`, etc.). Standard heights: 44pt/48pt for interactive targets.
-   **Typography**: Use `AppTypography`. Use **San Francisco** weight mappings (T1: Black/Bold, T2: Semi-Bold, T3: Medium, T4: Regular).
-   **Shapes**: Use **Squircle (SmoothRectangleBorder)** with `cornerRadius: 14.0` for cards and `cornerRadius: 8.0` for small atoms.

---

## ✅ DOs
-   **DO** use **SmoothRectangleBorder** from `figma_squircle` to achieve the Apple "Continuous Corner" look.
-   **DO** use **SF Symbols** (matching font-weight) for iconography where possible.
-   **DO** implement subtle micro-animations (duration: 250ms, curve: easeOutExpo).
-   **DO** respect **Dark Mode** as the primary high-contrast theme.

## ❌ DON'Ts
-   **DON'T** use standard `RoundedRectangleBorder`; it lacks the "Apple Squircle" aesthetic.
-   **DON'T** use emojis as functional icons.
-   **DON'T** use `SizedBox(width: 8)`; use `AppSpacing` tokens.
-   **DON'T** use hardcoded hex values; add to `AppColors` with appropriate transparency tokens.

---

## 🛠️ Code Examples

### Good Practice (Apple Squircle & Icons)
```dart
Container(
  decoration: ShapeDecoration(
    shape: SmoothRectangleBorder(
      borderRadius: BorderRadius.circular(AppColors.radiusMD),
      smoothness: 0.6, // Apple standard smoothness
    ),
    color: AppColors.surface,
  ),
  child: Icon(
    SFSymbols.command, // ✅ Using system-matched icons
    size: 24,
  ),
)
```

### Bad Practice (Non-Apple Compliant)
```dart
// ❌ WRONG: Non-smooth corners and ad-hoc icons
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12), 
    color: Colors.blue,
  ),
  child: Icon(Icons.settings), // ❌ NOT native feel
)
```
