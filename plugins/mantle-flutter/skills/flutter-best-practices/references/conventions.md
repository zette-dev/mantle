# Dart Conventions

## Text & Localization
- Use: ``AppText.bodyLarge((t) => t.key)`
- Not: `Text()`, `AppLocalizations.of(context)`
- Always use localization keys via `AppText` for user-facing strings
- `AppText` wraps localization and theming in a single API

## Theming & Colors
- All colors and text styles must come from the theme
- Use: `Theme.of(context).colorScheme.primary`, `Theme.of(context).textTheme.bodyLarge`
- Not: `Color(0xFF...)`, `Colors.*`, `AppColors.*`
- Widgets should NOT contain inline styles unless explicitly overriding the theme
- If a widget needs a non-theme color, it should be a documented design system exception

## Spacing
- Use: `AppSpacing.lg`, `AppRadius.mdAll`, `AppSizes.avatarMd`
- Not: `EdgeInsets.all(16)`, `BorderRadius.circular(12)`

## Configuration
- All config values (API URLs, feature flags, keys) must be defined via `--dart-define-from-file`
- Never hardcode environment-specific values in source code
- Access config values through `const String.fromEnvironment('KEY')`
- Pass the config file at build/run time: `flutter run --dart-define-from-file=config/dev.json`

## Logging
- Use: `logger.i('message')`, `logger.w('warning')`, `logger.e('error', error, stackTrace)`
- Not: `print()`, `debugPrint()`, `log()`
- Import from `zette_utils` package
- Logger integrates with Sentry — all errors and exceptions are automatically reported
- Use appropriate log levels:
  - `logger.i` — informational messages
  - `logger.w` — warnings (unexpected but recoverable)
  - `logger.e` — errors (pass error object and stack trace for Sentry)
