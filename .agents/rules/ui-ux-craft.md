# UI/UX Craft & Frontend Quality Rule

Whenever creating, modifying, or reviewing frontend user interfaces, pages, or components:

1. **Aesthetics & Brand Polish**:
   - Implement designs that wow the user on first impression.
   - Use curated, harmonic color palettes, subtle gradients, and luminous borders.
   - Never use unstyled raw inputs or default browser buttons.

2. **Next.js & React Architecture**:
   - Server Components by default; isolate `'use client'` to leaf interactive nodes.
   - Eliminate async waterfalls using `Promise.all` and React Suspense.
   - Avoid barrel-file bloat; use dynamic imports for client-heavy modules.

3. **Responsiveness & Accessibility**:
   - Mobile-first layout testing (375px, 768px, 1024px, 1440px).
   - High text contrast, visible focus rings, and proper ARIA labels on all interactive controls.
