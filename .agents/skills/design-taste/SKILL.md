---
name: design-taste
description: Design Taste guidelines for visual hierarchy, depth layers, glassmorphism, sophisticated contrast, and premium aesthetic execution.
---

# UI/UX Stack: Design Taste & Visual Excellence

## Core Principles

### 1. Depth & Layering (Z-Index Architecture)
- **Base Layer (0)**: Canvas background (`bg-canvas` / subtle mesh or noise gradient).
- **Surface Layer (1)**: Card / Container surfaces (`bg-surface`, subtle border with `border-border/60`).
- **Elevated Layer (2)**: Hover states, popovers, dropdowns, sticky headers (`bg-surface-elevated`, soft shadow `shadow-tinly-sm`).
- **Modal Layer (3)**: Dialogs, sheets, modals (`backdrop-blur-md`, scrim overlay).

### 2. Spatial Rhythm
- Base 4px / 8px geometric grid.
- Consistent padding inside containers: `p-4 sm:p-6 lg:p-8`.
- Ample breathing room between sections (`space-y-6 sm:space-y-8`).

### 3. Contrast & Accessibility
- Primary text must have >= 7:1 contrast ratio against background.
- Secondary / muted text must have >= 4.5:1 contrast ratio.
- Accessible focus rings: `focus-visible:ring-2 focus-visible:ring-primary/80 focus-visible:outline-none`.

### 4. Interactive State Feedback
- Buttons and links must give immediate visual feedback on hover (`brightness-105` or subtle scale `active:scale-[0.98]`).
- Loading states must use skeleton screens or animated spinners, never leave buttons dead/frozen.
