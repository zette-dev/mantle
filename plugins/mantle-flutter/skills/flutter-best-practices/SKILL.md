---
name: flutter-best-practices
description: Flutter and Dart conventions, state management patterns, navigation, and testing standards. This skill should be used when writing, reviewing, or debugging Flutter/Dart code including widgets, providers, routes, and tests.
user-invocable: false
---

# Flutter Best Practices

Comprehensive conventions and patterns for Flutter development covering code style, state management with Riverpod, type-safe navigation with GoRouter, and testing strategies.

## Reference Files

Load the relevant reference based on the task at hand:

- [conventions.md](./references/conventions.md) - Dart code conventions: theming, localization, config, logging, spacing
- [state-management.md](./references/state-management.md) - Riverpod provider types, naming, widget usage, and async patterns
- [navigation.md](./references/navigation.md) - GoRouter type-safe routing, shell routes, and router provider patterns
- [testing.md](./references/testing.md) - Testing philosophy, structure, mocking patterns, provider testing, and coverage
- [dev-workflow.md](./references/dev-workflow.md) - Simulator testing with Marionette MCP: hot reload, screenshots, widget tree, UI interaction

## Quick Reference

### Code Style

- All colors and text styles from the theme — widgets only contain styles when overriding
- Use `AppText` with localization keys for all user-facing strings
- Use design system components (`AppSpacing`, `AppRadius`) instead of raw Flutter primitives
- Config values via `--dart-define-from-file`, never hardcoded
- Logging via `logger.I` / `logger.E` from `zette_utils` (integrates with Sentry)

### State Management

- No code generation (`@riverpod`, `.g.dart`) - use manual provider declarations
- Prefix providers with `$`: `$authProvider`, `$itemsProvider`
- Use `ConsumerWidget` for provider access
- `ref.watch()` in build methods, `ref.read()` in callbacks

### Navigation

- Always use type-safe route classes: `MyRoute(id: item.id).push(context)`
- Never use string-based routing: `context.go('/path')`
- Use `.go()` for tab switches, `.push()` for detail screens

### Testing

- Understand test cases before writing - each test validates specific behavior
- Unit tests first (100% coverage target on providers)
- All mocks in `test/helpers/mock_providers.dart`

### Simulator Testing

- Use the **Marionette Flutter MCP** to test features in the running simulator
- Check the project Makefile for the command to start the app (wraps [run-debug-mcp.sh](./scripts/run-debug-mcp.sh))
- Read `.marionette_uri` to `connect`, then use MCP tools: `hot_reload`, `take_screenshots`, `get_interactive_elements`, `tap`, `enter_text`, `scroll_to`, `get_logs`
- After every code change: hot reload, navigate to affected screen, screenshot to verify
