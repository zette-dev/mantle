# Changelog

All notable changes to the mantle-go plugin will be documented in this file.

## [1.0.0] - 2026-02-08

### Added

- **go-reviewer** agent: Quality standards and philosophy reviewer following Effective Go and Go Proverbs. Reviews error handling, interface design, package organization, naming conventions, struct design, and context propagation. PASS/FAIL output.
- **go-concurrency** agent: Concurrency reviewer for detecting goroutine leaks, race conditions, channel deadlocks, WaitGroup misuse, and unsafe synchronization patterns. Includes correct vs incorrect code examples.
- **go-lint** agent: Linter agent that runs golangci-lint, go vet, and gofmt checks with severity-categorized output.
- **go-best-practices** skill: Comprehensive Go best practices covering error handling, interface design, concurrency patterns, testing strategies, and module management. Includes 5 reference files with code examples and detailed guidance.
