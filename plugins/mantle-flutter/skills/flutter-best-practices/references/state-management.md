# State Management

## No Code Generation
Do NOT use `@riverpod`, `riverpod_generator`, or `.g.dart` for providers.

## Provider Naming
Prefix with `$`: `$authProvider`, `$itemsProvider`

## Provider Types
| Need | Use |
|------|-----|
| Computed/services | `Provider` |
| Simple toggles | `StateProvider` |
| Async data | `FutureProvider` |
| With params | `FutureProvider.family` |
| Complex mutable | `NotifierProvider` |
| Async init | `AsyncNotifierProvider` |

## Widget Usage
- `ConsumerWidget` for provider access
- `ref.watch()` in build, `ref.read()` in callbacks

## Async Pattern
```dart
ref.watch($provider).when(
  loading: () => ...,
  error: (e, s) => ...,
  data: (data) => ...,
)
```

## Dependencies
Declare explicitly:
```dart
final $itemsProvider = FutureProvider<List<Item>>(
  (ref) async {
    final auth = ref.watch($authProvider);
    return fetchItems(auth.userId);
  },
  dependencies: [$authProvider],
);
```
Keep chains shallow: A -> B -> C max.
