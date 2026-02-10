# Changelog

## [1.0.0] - 2026-02-08

### Added

- **flutter-reviewer** agent: Quality standards reviewer for Flutter widget code covering composition, build method complexity, tree depth, keys, const constructors, theming, layout, and responsive design.
- **flutter-lint** agent: Linter agent wrapping `flutter analyze` and `dart format` with deprecation reporting and `analysis_options.yaml` validation.
- **flutter-lifecycle** agent: Concurrency and lifecycle reviewer for StatefulWidget lifecycle methods, setState safety, resource cleanup, rebuild optimization, and memory leak prevention.
- **flutter-best-practices** skill with reference files:
  - `widget-patterns.md`: Widget composition, extraction, StatelessWidget vs StatefulWidget, const constructors, keys, builder patterns, InheritedWidget.
  - `state-management.md`: setState, Provider, Riverpod, BLoC comparison, selection guidance, state lifting.
  - `lifecycle.md`: StatefulWidget lifecycle methods, dispose cleanup, didUpdateWidget, deactivate.
  - `testing.md`: Widget tests, pumpWidget, finders, matchers, golden tests, integration tests.
  - `platform-channels.md`: MethodChannel, EventChannel, BasicMessageChannel, platform-specific code.
