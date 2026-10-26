---
name: web-design-guidelines
description: Modern web design standards covering mobile-first responsive layouts, fluid typography, dark/light accessibility, and SEO foundations.
---

# UI/UX Stack: Web Design Guidelines

## Technical Design Standards

### 1. Mobile-First Responsiveness
- Always design for 375px (mobile) first, then scale gracefully to 768px (tablet), 1024px (desktop), and 1440px+ (wide screen).
- Use responsive flex and grid layouts: `grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4`.
- Never allow horizontal overflow scrolling on mobile (`overflow-x-hidden` on main root).

### 2. Semantic & Accessible HTML
- Single `<h1>` per view for clean semantic document hierarchy.
- Interactive elements must use native `<button>` or `<a>` with unique, descriptive `id` and `aria-label` attributes.
- Meaningful `alt` text for images; `role="status"` for live announcement regions.

### 3. SEO & Metadata
- Proper `<title>` and `<meta name="description">` tags on every public page.
- OpenGraph (OG) image and Twitter card meta tags for rich social sharing previews.
