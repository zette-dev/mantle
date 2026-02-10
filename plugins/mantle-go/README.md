# mantle-go

Go framework plugin for mantle. Includes 3 specialized agents and 1 skill for Go code review, concurrency analysis, linting, and best practices.

## Components

### Agents (3)

#### Review

| Agent | Model | Description |
|---|---|---|
| `go-reviewer` | inherit | Quality standards and philosophy reviewer following Effective Go and Go Proverbs. Checks error handling, interface design, package organization, naming conventions, struct design, and context propagation. PASS/FAIL output. |
| `go-concurrency` | inherit | Concurrency reviewer for detecting goroutine leaks, race conditions, channel deadlocks, WaitGroup misuse, and unsafe synchronization patterns. Includes correct vs incorrect code examples. CRITICAL for Go codebases. |
| `go-lint` | haiku | Linter agent that runs golangci-lint, go vet, and gofmt checks. Reports findings categorized by severity. |

### Skills (1)

| Skill | Description |
|---|---|
| `go-best-practices` | Comprehensive Go best practices guidance covering error handling, interface design, concurrency patterns, testing strategies, and module management. |

#### go-best-practices Reference Files

- **INDEX.md** -- Overview of all reference files and topics.
- **error-handling.md** -- Error wrapping (`%w`), `errors.Is`/`errors.As`, sentinel errors, custom error types, error groups, `panic`/`recover`.
- **interfaces.md** -- Small interfaces (1-3 methods), accept interfaces/return structs, `io.Reader`/`io.Writer` patterns, interface embedding, testing with interfaces.
- **concurrency.md** -- Goroutines, channels (buffered vs unbuffered), `select`, `sync.WaitGroup`, `sync.Mutex`, `context`, `errgroup`, fan-in/fan-out, worker pools, rate limiting.
- **testing.md** -- Table-driven tests, testify, `httptest`, test helpers, benchmarks, fuzzing (`go test -fuzz`), parallel tests.
- **modules.md** -- `go.mod`, minimum version selection, major version suffixes, `replace` directives, workspace mode, vendoring.

## Installation

Install via the mantle marketplace:

```bash
claude /plugin install mantle-go
```

## Usage

### Agents

```bash
# Run the Go code reviewer on your changes
claude agent go-reviewer "Review the changes in this PR"

# Check for concurrency issues
claude agent go-concurrency "Analyze concurrency patterns in pkg/worker/"

# Run linting
claude agent go-lint "Lint the entire project"
```

### Skills

```bash
# Get Go best practices guidance
claude skill go-best-practices
```

## Author

Nate Frechette (nate@zette.dev)
https://github.com/natefrechette
