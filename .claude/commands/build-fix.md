---
description: Systematically diagnose and resolve build, TypeScript, or dependency errors
argument-hint: [build error message or command]
---

# /build-fix Command Execution

Resolve build failure: **$ARGUMENTS**

## Procedure:
1. Run the native build command to isolate the exact error stack and root-cause file.
2. Formulate a minimal hypothesis for why the type error or compilation failed.
3. Make the smallest surgical fix without introducing breaking changes or type hacks (`any` / `@ts-ignore`).
4. Re-run the build to confirm clean exit code 0.
