# Changelog

## [1.0.0] - 2026-02-08

### Added

- **`dart-reviewer` agent** - Quality Standards reviewer for Dart code
  - Checks Effective Dart style and naming conventions
  - Validates null safety patterns
  - Reviews type system usage, error handling, async patterns
  - Architecture and testing best practices
  - PASS/FAIL methodology with actionable feedback

- **`dart-lint` agent** - Linter agent wrapping `dart analyze` and `dart format`
  - Runs static analysis with `--fatal-infos`
  - Checks formatting compliance
  - Reports deprecated API usage

- **`dart-best-practices` skill** - Curated reference documentation
  - `effective-dart.md` - Naming, style, documentation, API design
  - `null-safety.md` - Sound null safety patterns and migration
  - `testing.md` - Unit testing with package:test and mocktail
  - `isolates.md` - Concurrency with Isolates, Futures, Streams
  - `packages.md` - Dependency management with pub
