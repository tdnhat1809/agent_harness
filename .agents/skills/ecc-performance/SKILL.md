---
name: ecc-performance
description: ECC high-performance engineering. Hot-path optimization, database query profiling, memory leak detection, and cache orchestration.
---

# ECC: Performance & Optimization

## Performance Optimization Playbook

1. **Database & Query Performance**:
   - Verify indexes on all foreign keys, tenant IDs, and filter columns.
   - Use batched queries / DataLoader patterns to eliminate N+1 roundtrips.
   - Avoid unbounded queries (`LIMIT` and keyset pagination required).

2. **Memory & Concurrency Management**:
   - Clean up event listeners, intervals, and WebSocket streams on disconnect/unmount.
   - Monitor PM2 process memory consumption; flag leaks early.

3. **Caching Strategy**:
   - Cache expensive immutable reads in Redis / LRU cache with sensible TTLs.
   - Implement cache invalidation tags on writes.
