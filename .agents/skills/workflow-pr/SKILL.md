---
name: workflow-pr
description: Global /pr workflow for generating semantic Git commits, comprehensive PR descriptions, and executable verification artifacts.
---

# Global Workflow: /pr

Workflow for assembling production-ready commits and Pull Requests.

## Semantic Commit Guidelines
- `feat(...)`: New user-facing feature or capability
- `fix(...)`: Bug fix or error resolution
- `refactor(...)`: Code change that neither fixes a bug nor adds a feature
- `perf(...)`: Performance optimization
- `test(...)`: Adding or correcting tests
- `docs(...)`: Documentation updates

## Pull Request Description Format
1. **Summary of Changes**: High-level overview of what and why.
2. **Key Components Affected**: List of services, packages, and UI routes touched.
3. **Verification & Proof**: Exact commands run and observable outputs/screenshots.
4. **Migration / Deployment Notes**: Any database migrations, environment variables, or config changes required.
