# Flutter Testing

## Philosophy
- Understand test cases before writing - each test validates specific behavior/edge case
- Identify: inputs/outputs, error cases, edge cases, branches/conditions
- Test names describe specific scenarios, not "test provider works"

## Priority
1. **Unit tests** - Providers, services, utilities (100% coverage target)
2. **Widget tests** - Only when explicitly requested
3. **E2E tests** - Only when explicitly requested

## Structure
```
test/
├── helpers/
│   ├── mock_providers.dart   # All mocks here
│   └── pump_app.dart         # Widget test helpers
├── core/providers/           # Provider unit tests
└── features/{feature}/       # Feature-specific tests
```

## Mocks
All mocks in `test/helpers/mock_providers.dart` - check before creating new ones.

**Interfaces:** `class MockFirebaseAuth extends Mock implements FirebaseAuth {}`

**Concrete classes:** Extend and call `super`:
```dart
class MockRequestInterceptorHandler extends RequestInterceptorHandler {
  bool nextCalled = false;
  @override
  void next(RequestOptions opts) { nextCalled = true; super.next(opts); }
}
```

**Factory functions:** `createTestVehicle({String id = 'test-1', ...})`

**Stub extensions:** Add `.stub*()` helpers on mock classes

## Provider Testing
```dart
final container = ProviderContainer.test(overrides: [
  $firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
]);
final result = container.read($myProvider);
```

Use `createMockProviderOverrides()` for common API mocks.

## Coverage
- Run: `make mobile-test-cov`
- Report: `coverage/html/index.html`
- Target: 100% on providers
- Find gaps: `DA:48,0` = uncovered, `DA:49,1` = covered
