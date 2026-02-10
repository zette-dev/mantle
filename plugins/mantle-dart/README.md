# Mantle-Dart

Dart framework plugin for [mantle](../mantle/README.md). Provides Dart-specific code review agents and curated best practices.

## Components

| Component | Count |
|-----------|-------|
| Agents | 2 |
| Skills | 1 |

## Agents

| Agent | Archetype | Description |
|-------|-----------|-------------|
| `dart-reviewer` | Quality Standards | Review Dart code against Effective Dart guidelines |
| `dart-lint` | Linter | Run `dart analyze` and `dart format` checks |

## Skills

| Skill | Description |
|-------|-------------|
| `dart-best-practices` | Curated Dart best practices with reference docs |

### dart-best-practices References

| Reference | Topics |
|-----------|--------|
| `effective-dart.md` | Naming, style, documentation, API design |
| `null-safety.md` | Sound null safety, nullable types, patterns |
| `testing.md` | Unit tests, mocking, test organization |
| `isolates.md` | Isolates, Futures, Streams, concurrency |
| `packages.md` | pub.dev, dependency management, versioning |

## Installation

```bash
claude /plugin install mantle-dart
```

Requires the core `mantle` plugin to be installed for workflow integration.

## How It Works

When you run `/mantle:review`, the core plugin detects `pubspec.yaml` in your project and automatically discovers and launches the Dart review agents alongside the core review agents.

## License

MIT
