# mantle-flutter

Flutter framework plugin for mantle. Provides specialized agents and a best-practices skill for reviewing, linting, and writing idiomatic Flutter code.

## Components

| Type | Count | Description |
|------|-------|-------------|
| Agents | 3 | Code review, linting, and lifecycle auditing |
| Skills | 1 | Flutter best practices reference with 5 reference files |

## Agents

### Review Agents

#### flutter-reviewer

Quality standards reviewer for Flutter widget code. Checks widget composition (StatelessWidget vs StatefulWidget vs ConsumerWidget), build method complexity, widget tree depth, key usage, const constructors, theme consistency, layout patterns, and responsive design. Outputs PASS/FAIL verdicts with actionable fix suggestions.

**Model**: inherit

#### flutter-lint

Linter agent that wraps `flutter analyze` and `dart format`. Runs static analysis, checks code formatting, reports deprecation warnings, and verifies `analysis_options.yaml` configuration.

**Model**: haiku

#### flutter-lifecycle

Concurrency and lifecycle reviewer for StatefulWidget code. Audits lifecycle method correctness (initState, didChangeDependencies, didUpdateWidget, deactivate, dispose), setState safety, Future/Stream cleanup, widget rebuild optimization, key usage for state preservation, memory leak prevention, and navigation lifecycle.

**Model**: inherit

## Skills

### flutter-best-practices

A reference skill covering Flutter best practices across five areas:

| Reference | Topics |
|-----------|--------|
| [widget-patterns.md](skills/flutter-best-practices/references/widget-patterns.md) | Composition, extracting widgets, StatelessWidget vs StatefulWidget, const constructors, keys, builder patterns, InheritedWidget |
| [state-management.md](skills/flutter-best-practices/references/state-management.md) | setState, Provider, Riverpod, BLoC comparison, when to use each, state lifting |
| [lifecycle.md](skills/flutter-best-practices/references/lifecycle.md) | StatefulWidget lifecycle methods, dispose cleanup, didUpdateWidget, deactivate |
| [testing.md](skills/flutter-best-practices/references/testing.md) | Widget tests, pumpWidget, finders, matchers, golden tests, integration tests |
| [platform-channels.md](skills/flutter-best-practices/references/platform-channels.md) | MethodChannel, EventChannel, BasicMessageChannel, platform-specific code |

## Installation

Add the mantle marketplace if you have not already:

```bash
claude /install-marketplace https://github.com/zette-dev/mantle-plugin
```

Install the plugin:

```bash
claude /install-plugin mantle-flutter
```

## Usage

### Agents

```bash
# Review Flutter widget code
claude agent flutter-reviewer "Review lib/features/profile/profile_screen.dart"

# Run lint checks
claude agent flutter-lint "Analyze the project"

# Audit lifecycle management
claude agent flutter-lifecycle "Review lib/features/chat/chat_screen.dart"
```

### Skill

```bash
# Access Flutter best practices
claude skill flutter-best-practices
```

## Author

Nate Frechette (nate@zette.dev)
https://github.com/natefrechette
