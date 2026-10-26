---
name: database-migrations-design
description: Production database design, indexing strategy, zero-downtime schema migrations (Expand-Contract pattern), and ORM query optimization (Prisma, Drizzle, SQLAlchemy).
triggers:
  - Database schema changes
  - SQL migrations
  - Index optimization
  - ORM query tuning (PostgreSQL, MySQL, SQLite)
---

# Database Design & Zero-Downtime Migrations

## 1. Schema Design Principles
- Normalization: Design to 3NF for transactional tables (OLTP) to eliminate redundancy and update anomalies. Denormalize judiciously only for high-read performance paths or reporting.
- Data Types: Use exact, bounded types. For example in PostgreSQL:
  - Use `TIMESTAMPTZ` instead of `TIMESTAMP` or string timestamps.
  - Use `UUIDv7` or `BIGINT GENERATED ALWAYS AS IDENTITY` for primary keys.
  - Use `NUMERIC(12, 2)` or integer cents for monetary calculations, never floating-point numbers.
- Constraints: Enforce domain invariants at the database level (`NOT NULL`, `CHECK`, `UNIQUE`, Foreign Key `ON DELETE RESTRICT/CASCADE`).

## 2. Zero-Downtime Migration Pattern (Expand - Contract)
Never perform breaking schema alterations (such as renaming or dropping columns) in a single deployment:
1. **Phase 1 (Expand)**: Add the new column or table as nullable. Deploy code that writes to both old and new columns, reading from the old.
2. **Phase 2 (Backfill)**: Run a background backfill script in small batches to populate existing rows in the new column.
3. **Phase 3 (Switch)**: Deploy code to read and write primarily from the new column.
4. **Phase 4 (Contract)**: Stop writing to the old column and safely drop the old column/table in a future maintenance migration.

## 3. PostgreSQL Non-Blocking DDL
- Adding an index: Always use `CREATE INDEX CONCURRENTLY` in production to prevent locking writes on large tables.
- Adding a NOT NULL constraint: Add the constraint `NOT VALID` first, then validate it in a separate transaction (`VALIDATE CONSTRAINT`) to prevent full-table write locks.

## 4. Indexing Strategy & Query Optimization
- Index columns used in `WHERE`, `JOIN ... ON`, and `ORDER BY` clauses.
- Order composite index columns: `(equality_column_1, equality_column_2, range_or_sort_column)`.
- Avoid the N+1 query problem in ORMs (Prisma `include`, SQLAlchemy `joinedload`/`selectinload`, Drizzle relational queries).
- Profile slow queries using `EXPLAIN (ANALYZE, BUFFERS) <query>` to verify Index Scans vs Sequential Scans.
