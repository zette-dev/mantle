# Navigation (GoRouter)

## Type-Safe Routes
```dart
// Use
ItemDetailRoute(id: item.id).push(context)

// Not
context.go('/items/${item.id}')
```

## Route Definitions
```dart
@TypedGoRoute<MyRoute>(path: '/my-path/:id')
class MyRoute extends GoRouteData { ... }
```

## ShellRoute for Tabbars
```dart
@TypedShellRoute<AppShellRoute>(
  routes: [
    TypedGoRoute<HomeRoute>(path: '/home'),
    TypedGoRoute<EventsRoute>(path: '/events'),
  ],
)
class AppShellRoute extends ShellRouteData {
  @override
  Widget builder(context, state, navigator) => AppShell(child: navigator);
}
```
- `.go()` for tab switches, `.push()` for detail screens

## $extra Parameter
- Prefer path/query params over `$extra`
- `$extra` requires router codec and doesn't survive refresh

## Router Provider
Never `watch()` in router provider. Use `ref.read()` + redirect:
```dart
final router = GoRouter(
  redirect: (context, state) {
    final auth = ref.read($authProvider);
    if (!auth.isAuthenticated) return '/login';
    return null;
  },
);
```
