---
name: rust-engineering
description: Production Rust guidelines covering ownership, lifetimes, Result/Option error handling, async Tokio, zero-cost abstractions, and Clippy invariants.
triggers:
  - Rust projects
  - Cargo builds and tests
  - Async Rust (Tokio)
  - Memory-safe systems engineering
---

# Rust Production Engineering Guidelines

## 1. Ownership, Borrowing & Lifetimes
- Prefer borrowing (`&T`, `&mut T`) over cloning (`.clone()`). Only clone when ownership transfer is structurally required or for clear semantic value semantics.
- Minimize lifetime annotations by adhering to lifetime elision rules. Use owned types (`String`, `Vec`) in public boundary structs where lifetime complexity outweighs negligible performance gains.
- Use `Arc<T>` and `RwLock<T>` / `Mutex<T>` only across thread boundaries; use `Rc<RefCell<T>>` for single-threaded interior mutability.

## 2. Error Handling
- Never use `.unwrap()` or `.expect()` in production application code unless preceded by an invariant proof.
- Use `thiserror` for domain-specific errors in libraries and internal domain layers:
```rust
#[derive(thiserror::Error, Debug)]
pub enum DatabaseError {
    #[error("connection failed: {0}")]
    Connection(String),
    #[error("record not found with id {0}")]
    NotFound(i64),
}
```
- Use `anyhow` for top-level binaries, CLIs, and integration test runners where arbitrary error reporting is required.

## 3. Asynchronous Programming (Tokio)
- Avoid long-running synchronous CPU-bound operations in `async` functions; offload them using `tokio::task::spawn_blocking`.
- Be mindful of cancel safety when using `tokio::select!`. Ensure futures cancelled mid-execution do not corrupt shared state.
- Keep lock guard lifetimes as small as possible; never hold a `std::sync::Mutex` across an `.await` boundary (use `tokio::sync::Mutex` or drop the guard before awaiting).

## 4. Testing & Code Quality
- Write unit tests in submodules with `#[cfg(test)] mod tests { ... }`.
- Run cargo lints on strict mode: `cargo clippy -- -D warnings`.
- Format code strictly with `cargo fmt --check`.
