---
name: ecc-architecture
description: ECC architectural design and invariant enforcement. Manages domain boundaries, state machines, event dispatching, and system resilience.
---

# ECC: Architecture & Invariant Enforcement

## Architectural Directives

1. **Domain Boundary Isolation**:
   - Keep business core decoupled from transport layers (REST, WebSockets, Telegram MTProto, Zalo SDK).
   - Use contract packages (`@tinly/contracts`) as the single source of truth for interfaces and DTOs.

2. **State Management & Idempotency**:
   - All asynchronous job processing (e.g. BullMQ / Redis queues) must use unique idempotency keys.
   - Transitions between entity states must be explicit and validated via state machines.

3. **Resilience & Fault Tolerance**:
   - Wrap external third-party API calls in timeouts and circuit breakers with automatic fallback.
   - Never let external provider degradation take down internal core services.
