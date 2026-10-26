---
name: python-engineering
description: Production-grade Python engineering best practices covering FastAPI, Django, Pytest TDD, Type Annotations, Pydantic v2, Ruff, and async patterns.
triggers:
  - Python projects
  - FastAPI / Django / Flask development
  - Pytest unit and integration testing
  - Asyncio and concurrency in Python
---

# Python Production Engineering Guidelines

## 1. Environment & Package Management
- Use modern packaging standards: `pyproject.toml` with `uv` or `poetry`.
- Pin exact versions in lockfiles (`uv.lock` or `poetry.lock`).
- Enforce formatting and linting via `ruff` (`ruff check .` and `ruff format .`).

## 2. Type Hints & Schema Modeling
- Use strict type hints everywhere (PEP 484, PEP 585, PEP 604: `X | None` instead of `Optional[X]`).
- Validate inputs and settings using **Pydantic v2** (`BaseModel`, `Field`, `ConfigDict(strict=True)`).
- Use `TypedDict` or `@dataclass(slots=True, frozen=True)` for lightweight data structures.

## 3. Asynchronous Programming (Asyncio)
- Never mix blocking I/O inside `async def` routines. Use `asyncio.to_thread()` for legacy synchronous libraries.
- Always use `asyncio.gather(*tasks, return_exceptions=True)` or `asyncio.TaskGroup` (Python 3.11+) to avoid dangling unhandled background exceptions.
- Implement explicit timeouts for all external HTTP and network calls using `asyncio.timeout()` or `httpx.AsyncClient(timeout=...)`.

## 4. Testing & Strict TDD (Pytest)
- Adhere to the Red-Green-Refactor cycle: Write failing tests in `tests/test_*.py` first.
- Use explicit pytest fixtures with proper scopes (`scope="function"` or `scope="session"`).
- Test async code using `pytest-asyncio` with `@pytest.mark.asyncio(loop_scope="function")`.
- Mock at the boundaries using `pytest-mock` (`mocker.patch`), never mock internal private implementations.

## 5. Clean Architecture & FastAPI Patterns
- Separate presentation (routers), application logic (services), and data access (repositories/models).
- Leverage FastAPI Dependency Injection (`Depends`) for database sessions, authentication, and service locators.
- Never leak raw SQLAlchemy or database models directly into HTTP response contracts. Use explicit Pydantic response schemas (`response_model=...`).
