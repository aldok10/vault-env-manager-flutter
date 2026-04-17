---
description: Standardized way to manage images, icons, and fonts to prevent app bloat.
---

# 📦 Asset Management Flow (The "Pro Max" Standard)

Use this workflow to ensure the **Vault** remains lightweight, performant, and visually consistent with high-refresh-rate display standards.

## 🎨 Phase 1: SVG-First Icon Policy
- **Standard**: Always prefer **SVGs** (`flutter_svg`) or **Icon Fonts** (Lucide, Iconsax) over raster images.
- **Goal**: Infinite scaling and zero-aliasing on Retina/4K displays.
- **Action**: Place all icons in `assets/icons/`.
- **Constraint**: Raster icons (PNG) are strictly forbidden unless it's a 3rd party logo with no vector available.

## 🖼️ Phase 2: Raster Metadata & Optimization
- **Standard**: All raster images (PNG/JPG) must be passed through an optimization pipeline (WebP preferred).
- **Rule**: Avoid large background images; prefer `BackdropFilter` and `Gradients` from the Design System.
- **Action**: Place images in `assets/images/` with appropriate scaling (`@2x`, `@3x`) for high-fidelity rendering.

## 🔠 Phase 3: Typographic Hierarchy
- **Standard**: Only embed fonts that follow the **Apple HIG** or **Inter** scales.
- **Action**: Declare all fonts in `pubspec.yaml` with explicit `weight` (300, 400, 600, 700) and `style`.
- **Optimization**: Remove unused glyph subsets to keep the `.ttf` or `.otf` files under 500KB.

// turbo
## 📏 Phase 4: Asset Leak Protection & Audit
- **Check**: Run `flutter build bundle` and inspect `build/flutter_assets/`.
- **Audit**: Identify any asset declared in `pubspec.yaml` that is NOT referenced in the code via `grep`.
- **Action**: Remove orphaned assets immediately to maintain the "Sam-Sam" lean standard.

---
*Status: Active. Performance: 100%. Bloat: Zero.*
