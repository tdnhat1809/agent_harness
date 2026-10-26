---
name: vercel-react-best-practices
description: Vercel React & Next.js performance playbook. Enforces RSC boundaries, eliminating async waterfalls, bundle optimization, and Server Actions.
---

# UI/UX Stack: Vercel React Best Practices

## Performance Impact: Critical Rules

### 1. Eliminating Async Waterfalls (CRITICAL)
- **Rule**: Fetch data in parallel using `Promise.all` or `Promise.allSettled` instead of sequential `await` calls.
- **Rule**: Defer non-critical data fetching using React Suspense boundaries.
- **Anti-Pattern**:
  ```ts
  // ❌ Slow sequential waterfall:
  const user = await getUser();
  const orders = await getOrders(user.id);
  ```
- **Pattern**:
  ```ts
  // ✅ Parallel execution:
  const [user, catalog] = await Promise.all([getUser(), getCatalog()]);
  ```

### 2. Server Components (RSC) vs. Client Components
- Keep components as Server Components (`async function Component()`) by default.
- Push `'use client'` down to the smallest interactive leaf components (buttons, dropdowns, modal toggles).
- Never import heavy server-only packages (ORM, DB drivers, private keys) into client bundles.

### 3. Bundle Size Control & Code Splitting
- Avoid barrel file re-exports (`index.ts` re-exporting hundreds of large icons or charts).
- Use `next/dynamic` with `{ ssr: false }` for client-heavy libraries (rich text editors, QR code scanners, large chart libs).

### 4. Server Actions & Form Mutations
- Use Next.js Server Actions for data mutations with `useTransition` or `useActionState` for pending states.
- Revalidate cached paths via `revalidatePath()` or `revalidateTag()`.
