---
name: go-engineering
description: Production Go (Golang) engineering standard covering standard project layout, table-driven tests, goroutine & channel safety, context propagation, and error wrapping.
triggers:
  - Go / Golang projects
  - Goroutines, channels, and concurrency
  - Table-driven testing in Go
  - gRPC and REST APIs in Go
---

# Go Production Engineering Guidelines

## 1. Project Layout & Idioms
- Follow the standard Go project structure:
  - `cmd/<app>/`: main entrypoints.
  - `internal/`: private application and library code (not importable by external packages).
  - `pkg/`: reusable public libraries (only if intended for public consumption).
- Keep packages focused and cohesive. Avoid generic `utils`, `common`, or `helpers` packages. Name packages for what they provide (`auth`, `httputil`, `postgres`).

## 2. Error Handling & Invariants
- Always wrap errors with context: `fmt.Errorf("fetching user %s: %w", userID, err)`.
- Use `errors.Is()` and `errors.As()` for error inspection. Never compare error strings with `==`.
- Sentinel errors should start with `Err` (e.g., `var ErrUserNotFound = errors.New("user not found")`).
- Custom error types should end with `Error` (e.g., `type ValidationError struct`).

## 3. Concurrency & Context Safety
- Always pass `ctx context.Context` as the very first argument in functions performing I/O or long-running tasks.
- Never spawn an unmonitored goroutine:
  - Always have a mechanism for goroutine termination (listen to `ctx.Done()`).
  - Use `sync.WaitGroup` or `golang.org/x/sync/errgroup` to wait for goroutines to exit cleanly.
- Protect shared memory with `sync.Mutex` or prefer communication via channels. Run the race detector during tests: `go test -race ./...`.

## 4. Table-Driven Testing & TDD
- Write tests in `*_test.go` using the table-driven test pattern:
```go
func TestCalculateDiscount(t *testing.T) {
    tests := []struct {
        name     string
        tier     string
        amount   float64
        expected float64
        wantErr  bool
    }{
        {name: "gold tier discount", tier: "gold", amount: 100, expected: 80, wantErr: false},
        {name: "invalid tier error", tier: "unknown", amount: 100, expected: 0, wantErr: true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := CalculateDiscount(tt.tier, tt.amount)
            if (err != nil) != tt.wantErr {
                t.Fatalf("CalculateDiscount() error = %v, wantErr %v", err, tt.wantErr)
            }
            if got != tt.expected {
                t.Errorf("CalculateDiscount() = %v, want %v", got, tt.expected)
            }
        })
    }
}
```
- Keep tests fast and isolated. Use interface mocking or `testcontainers-go` for real integration tests.
