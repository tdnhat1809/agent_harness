# Git Safety Net & Commit Protocol

Inspired by Aider and SWE-agent engineering practices, Git is your primary safety net.

## 1. Atomic Semantic Commits
When completing a verified unit of work, produce clean, semantic Git commits following Conventional Commits:
- `feat(scope): ...` for new capabilities.
- `fix(scope): ...` for bug fixes.
- `test(scope): ...` for test suites and TDD red tests.
- `refactor(scope): ...` for restructuring without behavioral changes.
- `chore(scope): ...` for maintenance, dependencies, or harness updates.

## 2. Invariants Before Committing
1. **Never commit broken code**: Static typecheck (`tsc`, `mypy`, `cargo check`, `go vet`) and all tests MUST pass (exit code 0).
2. **Never commit secrets**: Check `git status` and `git diff --cached` to verify no `.env`, keys, credentials, or personal data are staged.
3. **Never leave working tree dirty**: Stash or commit cleanly upon task completion.

## 3. Commit Message Standards
- Keep the title line concise (under 72 characters) and imperative ("add user validation", not "added user validation").
- In the commit body, summarize the *why* and list verifiable test results.
