---
name: UI/UX Pro Max Standard
description: Implementation of premium Apple-inspired design standards, atomic components, and high-fidelity animations for Flutter Desktop.
---

# 🎨 UI/UX Pro Max: Apple-Inspired Standard

This skill defines the visual language and interaction principles for the **Vault Env Manager**, optimized for macOS and Windows desktop experiences.

## 🍏 1. Visual Foundations & Typography

### ✅ Squircle Corners (G2/G3 Continuity)
To achieve the true "Apple Look," use continuous curvature (Superellipse) instead of standard circular rounding.
- **Flutter 3.32+**: Use the native `RoundedSuperellipseBorder` for engine-level performance.
- **Figma Matched**: Use `SmoothRectangleBorder` from `figma_squircle`.
- **Tokens**: Standard `cornerRadius: 14.0`, `cornerSmoothing: 0.6`.
- **Why?**: Circular corners have a sudden change in curvature at the tangent point. Squircles ensure the rate of change is smooth, preventing visual "jank" in light reflections.

### ✅ Vibrant Glassmorphism (The "Pro Max" Look)
Use `BackdropFilter` with these calibrated tokens:
- **Blur**: `24.0`
- **Saturation**: `1.8`
- **Opacity**: `0.7 - 0.85`
- **Border**: `0.5px` with `white12` for a sharp edge.

---

## ⚡ 2. Animation Performance Patterns (flutter_animate)

Desktop apps must maintain 60/120 FPS. Chain animations wisely.

### ✅ Optimization Checklist
1.  **Use `const` Consumers**: Always use `const` for static widgets within an animation tree to prevent unnecessary rebuilds.
2.  **GPU-Accelerated Transforms**: Prefer `.scale()`, `.slide()`, and `.rotate()`. These are handled by the GPU and do not trigger expensive layout cycles.
3.  **Scope Rebuilds**: Ensure only the smallest possible subtree is rebuilding. Avoid `setState` on parent containers of large lists.
4.  **Repaint Isolation**: Wrap complex animated widgets (like those with `BackdropFilter` or `BoxShadow`) in a `RepaintBoundary`.

---

## 🖥️ 3. Advanced Desktop Layouts (MultiSplitView)

Desktop applications require sophisticated space management. Use `multi_split_view` for resizable, professional dashboards.

```dart
MultiSplitView(
  children: [
    SidebarWidget(), // weight: 0.2
    EditorWidget(),  // weight: 0.6
    DetailsPane(),   // weight: 0.2
  ],
  controller: MultiSplitViewController(
    areas: [
      Area(weight: 0.2, minimalWeight: 0.1),
      Area(weight: 0.6),
      Area(weight: 0.2),
    ],
  ),
)
```

---

## ⚛️ 4. Atomic Design & Token Enforcement

All UI modifications must use tokens from `lib/src/core/design_system/`.

- **Atoms**: `VaultButton`, `VaultTextField`, `VaultIcon`.
- **Contrast**: Maintain **WCAG 4.5:1** across themes.
- **Shortcuts**: Use `CallbackShortcuts` for desktop-first keyboard navigation.

---
*Reference: Apple Human Interface Guidelines (HIG) & Vault Manager Design System v1.0*
