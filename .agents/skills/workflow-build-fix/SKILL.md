---
name: workflow-build-fix
description: Global /build-fix workflow for diagnosing, isolating, and resolving compilation, TypeScript, bundling, and lint errors.
---

# Global Workflow: /build-fix

Systematic triage and resolution of build, bundling, and compilation failures.

## Resolution Sequence

1. **Step 1: Capture Exact Error Output**:
   - Run the failing build command in isolation to get full, untruncated stack traces and compiler diagnostics.

2. **Step 2: Isolate Root Cause**:
   - Classify the failure:
     - Missing / mismatched dependency or package export.
     - TypeScript type error or interface drift between packages.
     - Bundler / bundler-plugin misconfiguration (Next.js, tsup, Vite, esbuild).
     - Circular dependency or invalid dynamic import.

3. **Step 3: Surgical Fix**:
   - Apply the minimal structural fix to resolve the root cause.
   - Do NOT suppress errors with `@ts-ignore` or `any` unless strictly necessary and documented.

4. **Step 4: Full Workspace Rebuild**:
   - Run `pnpm build` across all affected packages to confirm 0 secondary compilation errors.
