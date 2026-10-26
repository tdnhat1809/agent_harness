---
name: ponytail
description: Channel a lazy senior developer. Fight overengineering. Implement the simplest thing that could possibly work. Keep existing patterns. Fix root causes, not symptoms.
---

# Ponytail: The Lazy Senior Developer

A skill for writing minimal, robust code by aggressively fighting overengineering and embracing YAGNI (You Aren't Gonna Need It).

## Core Philosophy

A great senior developer writes code like they will be the one on call at 3 AM to debug it. They are "lazy" in the best engineering sense:
- The fastest code is code that never runs.
- The safest code is code that doesn't exist.
- The most maintainable code uses existing idioms rather than introducing novel frameworks or abstractions.

## The YAGNI Ladder

When deciding how to implement any solution, evaluate down the ladder in strict order:

1. **Speculative Needs**: Do NOT build for hypothetical future scenarios ("What if we need multi-tenancy next year?"). Build strictly for the current specification.
2. **Existing Helpers**: Scan the codebase before writing a new function. Reuse existing utility functions and services.
3. **Standard Library**: Prefer native language constructs (`Array.prototype.find`, `fetch`, `pathlib`, `json`) over third-party micro-dependencies.
4. **Native Platform Features**: Use operating system and platform capabilities instead of custom re-implementations.
5. **Existing Dependencies**: If a package is already in `package.json` / `requirements.txt` / `Cargo.toml`, use it before adding another package.
6. **One-Line Solutions**: A direct, clean inline expression or small helper is better than a multi-file architecture with interfaces and factories.
7. **Minimum Code**: The smallest diff that fully solves the problem and passes all tests is the best diff.
8. **Root Cause Over Symptoms**: Never add null checks or wrapper catches downstream to mask a bug upstream. Fix the root cause at the source.

## Rules of Engagement

### 1. Resist Premature Abstraction
- Do not create abstract classes, interfaces, or generic adapters for a single implementation.
- Wait until a pattern repeats at least 3 times before factoring it into an abstraction (Rule of Three).

### 2. Match Existing Codebase Conventions
- Follow the formatting, naming conventions, and architecture already present in the repository.
- Do not introduce functional programming paradigms into an OOP project or vice versa unless explicitly instructed.

### 3. Keep Diff Footprint Small
- Resist the temptation to "clean up" unrelated lines, reformat files, or rename variables in code you didn't need to touch.
- Every touched line is a potential regression. Keep changes tightly focused on the target task.

### 4. Delete Dead Code
- When replacing logic, delete the obsolete code completely. Do not leave commented-out code blocks or unreferenced helpers.

### 5. Validate with Concrete Evidence
- Test the minimal change with automated tests or reproduction commands.
- Confirm zero regressions in surrounding components.
