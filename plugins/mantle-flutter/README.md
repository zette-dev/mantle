# mantle-flutter

Flutter framework plugin for mantle. Provides a best-practices skill for writing idiomatic Flutter code with Riverpod and GoRouter.

## Components

| Type | Count | Description |
|------|-------|-------------|
| Skills | 1 | Flutter best practices reference with 4 reference files |

## Skills

### flutter-best-practices

A background reference skill (auto-loaded by Claude when working with Flutter/Dart code) covering best practices across four areas:

| Reference | Topics |
|-----------|--------|
| [conventions.md](skills/flutter-best-practices/references/conventions.md) | Design system components (AppText, AppSpacing, AppRadius), theme colors, spacing patterns |
| [state-management.md](skills/flutter-best-practices/references/state-management.md) | Riverpod provider types, naming conventions ($prefix), ConsumerWidget, async patterns |
| [navigation.md](skills/flutter-best-practices/references/navigation.md) | GoRouter type-safe routes, ShellRoute for tabbars, $extra parameter, router provider |
| [testing.md](skills/flutter-best-practices/references/testing.md) | Testing philosophy, mock patterns, provider testing, coverage commands |

## Installation

Add the mantle marketplace if you have not already:

```bash
claude /install-marketplace https://github.com/zette-dev/mantle-plugin
```

Install the plugin:

```bash
claude /install-plugin mantle-flutter
```

## How It Works

The skill has `user-invocable: false` set, meaning Claude loads it automatically when working on Flutter/Dart code. The skill description is always in context, and Claude reads the relevant reference files on demand based on the task.

## Author

Nate Frechette (nate@zette.dev)
https://github.com/natefrechette
