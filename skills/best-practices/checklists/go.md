# Go Checks

- [ ] Errors not wrapped with context (`fmt.Errorf("doing X: %w", err)`)
- [ ] `_` used to discard errors
- [ ] Goroutines launched without `WaitGroup` or done channel (goroutine leak risk)
- [ ] `context.Background()` used in request handlers (should use request context)
- [ ] Global variables used for state (not testable)
- [ ] No `golangci-lint` config
- [ ] Packages named with generic names (`util`, `common`, `helper`, `misc`)
- [ ] Missing `defer` for resource cleanup (file handles, mutexes)
- [ ] Struct fields not documented
