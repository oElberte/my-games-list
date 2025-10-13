# MyGamesList Architecture Guide

> **Note for AI Agents**: This is a living document that should be updated whenever significant architectural patterns, conventions, or important implementation details are added or changed. Focus on cost-benefit: document patterns that will help future development, avoid over-documenting trivial details.

## Architecture Principles

This project follows **SOLID principles** and **Domain-Driven Design (DDD)** for a clean, maintainable, and scalable codebase.

## Project Structure

```
lib/
├── blocs/              # BLoC state management
├── data/               # Data layer (repositories, data sources)
├── domain/             # Domain layer (entities, interfaces)
├── services/           # Core services (service locator, HTTP client)
├── ui/                 # Presentation layer (screens, widgets)
└── utils/              # Utilities (router, constants, etc.)
```

## Core Architectural Patterns

### 1. Modular Dependency Injection

**Pattern**: Register dependencies based on their lifecycle and scope.

**Registration Types**:

1. **Lazy Singleton** - For global state that lives throughout the app

   - `AuthBloc` - Global authentication state
   - `SettingsBloc` - App-wide settings
   - `IHttpClient` - Single HTTP client instance
   - `AuthRepository` - Manages tokens and auth operations

2. **Factory** - For screen-specific instances that are recreated

   - `HomeBloc` - New instance per home screen visit
   - `SignInBloc` - Temporary, created per signin route
   - `SignUpBloc` - Temporary, created per signup route

3. **Modular (Lazy-loaded)** - Registered only when module is accessed
   - `AuthRepository` - Registered on first auth route access
   - Future module repositories

**Implementation**:

```dart
// Global singletons (registered at app startup)
sl.registerLazySingleton<AuthBloc>(() => AuthBloc(sl()));
sl.registerLazySingleton<SettingsBloc>(() => SettingsBloc(sl()));

// Screen-specific factories
sl.registerFactory<HomeBloc>(() => HomeBloc(sl()));

// Modular lazy registration (in router)
GoRoute(
  path: '/auth/signin',
  builder: (context, state) {
    // Ensure auth repository is registered (only happens once)
    _ensureAuthRepositoryRegistered();

    // Provide temporary BLoC for this screen
    return BlocProvider(
      create: (_) => SignInBloc(sl<IAuthRepository>()),
      child: SignInScreen(),
    );
  },
)
```

**Key Rules**:

- **Never close singleton BLoCs** in screen dispose methods
- **Always dispose factory BLoCs** when leaving the screen (BlocProvider does this automatically)
- **Lazy singletons persist** until app terminates or explicitly reset

### 2. Interface Segregation (SOLID)

**Pattern**: Create interfaces for all major dependencies to allow easy replacement.

**Critical interfaces**:

- `IHttpClient` - HTTP client abstraction (current impl: Dio)
- `IAuthRepository` - Authentication data operations
- `IStorageService` - Local storage abstraction
- `IApiService` - API-specific operations

**Benefits**:

- Easy to swap implementations (e.g., Dio → http package)
- Testability with mocks
- Loose coupling between layers

### 3. Domain-Driven Design (DDD)

**Layers**:

1. **Domain Layer** (`lib/domain/`)

   - Pure Dart entities (no Flutter dependencies)
   - Business logic interfaces
   - Domain models (User, Game, etc.)

2. **Data Layer** (`lib/data/`)

   - Repository implementations
   - Data sources (remote, local)
   - DTOs and mappers

3. **Presentation Layer** (`lib/ui/`, `lib/blocs/`)
   - BLoC for state management
   - UI components
   - No direct data layer access

**Data flow**:

```
UI → BLoC → Repository Interface → Repository Impl → Data Source → API
```

### 4. BLoC State Management

**Pattern**: Use BLoC for business logic and state management.

**States**: Idle → Loading → Success/Error

- `Initial` - Initial state
- `Loading` - Operation in progress
- `Success` - Operation completed successfully
- `Error` - Operation failed with error message

**Events**: User actions or system events

- Naming: `<Feature><Action>` (e.g., `SignInSubmitted`, `SignUpFormValidated`)

### 5. Form Validation

**Package**: `validatorless`

**Pattern**: Compose validators for reusability

```dart
Validatorless.multiple([
  Validatorless.required('Email is required'),
  Validatorless.email('Invalid email format'),
])
```

### 6. Environment Configuration

**Pattern**: Use `.env` files with `flutter_dotenv`

**Files**:

- `.env` - Local environment (gitignored)
- `.env.example` - Template for version control

**Usage**:

```dart
final apiUrl = dotenv.env['API_BASE_URL'];
```

## API Integration

### HTTP Client

**Interface**: `IHttpClient`
**Implementation**: `DioHttpClient`

**Base configuration**:

- Base URL from environment
- Timeout: 30 seconds
- Content-Type: application/json
- Error interceptor for consistent error handling

### Standardized Error Handling

**Pattern**: All API errors follow a standardized format for consistency and i18n support.

**Error Model** (`ApiError`):

```json
{
  "name": "Validation Error: password",
  "message": "Password is too short",
  "action": "Password must be at least 6 characters long",
  "status_code": 400,
  "error_code": "error.validation.password.too_short"
}
```

**Error Flow**:

```
API Response → DioHttpClient (parses to ApiError) → ApiResponse<T> →
Repository (throws Exception with userMessage) → BLoC (catches and emits error) →
UI (displays in SnackBar)
```

**Key Components**:

1. **ApiError model** (`lib/domain/models/api_error.dart`):

   - `name` - Error title/name
   - `message` - Short error description
   - `action` - User-actionable suggestion
   - `statusCode` - HTTP status code
   - `errorCode` - Machine-readable code for i18n (e.g., `error.validation.password.too_short`)
   - `userMessage` getter - Combines message and action for display

2. **ApiResponse<T> wrapper** (`lib/domain/models/api_response.dart`):

   - Generic wrapper for all API responses
   - Contains either `data` or `error` (ApiError)
   - Provides `dataOrThrow` for convenience

3. **Error parsing in DioHttpClient**:

   - Parses standardized error format from API
   - Fallbacks for old format and network errors
   - Returns ApiError for all error cases

4. **Error display**:
   - BLoCs extract error message using `e.toString()`
   - UI shows combined message + action in SnackBars
   - Future: Use `errorCode` for internationalization

**Example Usage**:

```dart
// In Repository
if (response.isError) {
  throw Exception(response.error?.userMessage ?? 'Operation failed');
}

// In BLoC
try {
  final result = await repository.signIn(request);
  emit(SignInSuccess(result));
} catch (e) {
  emit(SignInError(e.toString().replaceFirst('Exception: ', '')));
}

// In UI
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(state.message), // Shows "Password is too short. Password must be at least 6 characters long"
    backgroundColor: Colors.red,
  ),
);
```

### Authentication Flow

**Endpoints**:

- POST `/auth/signin` - Sign in user
- POST `/auth/signup` - Sign up new user

**Token storage**: Store JWT in secure local storage

**Request/Response models**:

- Request DTOs in `lib/data/models/requests/`
- Response DTOs in `lib/data/models/responses/`
- Domain entities in `lib/domain/entities/`

## Testing Strategy

### Cost-Benefit Testing Approach

Focus on critical paths and business logic, avoid over-testing.

**Priority 1 - Must Have**:

- Repository tests (data layer)
- BLoC tests (business logic)
- Critical widget tests (auth flows)

**Priority 2 - Should Have**:

- Integration tests for main flows
- Utility function tests

**Priority 3 - Nice to Have**:

- Widget tests for all screens
- Golden tests for UI consistency

**Mocking strategy**:

- Use `mockito` for generating mocks
- Mock at interface boundaries (repositories, HTTP client)

## Code Style & Conventions

### Naming Conventions

- Classes: PascalCase (`AuthRepository`)
- Files: snake_case (`auth_repository.dart`)
- Variables: camelCase (`authToken`)
- Constants: camelCase (`apiBaseUrl`) or UPPER_CASE for compile-time constants

### File Organization

- One class per file
- Group related files in folders
- Index files (`index.dart`) for barrel exports when helpful

### Comments

- Document WHY, not WHAT
- Use `///` for public API documentation
- Keep comments up-to-date with code

## Common Patterns

### Error Handling

**Standardized Pattern**:

```dart
// Repository layer - throws exceptions with user-friendly messages
if (response.isError) {
  throw Exception(response.error?.userMessage ?? 'Operation failed');
}

// BLoC layer - catches and emits error state
try {
  final result = await repository.someOperation();
  emit(SuccessState(result));
} catch (e) {
  emit(ErrorState(e.toString().replaceFirst('Exception: ', '')));
}

// UI layer - displays error to user
if (state is ErrorState) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(state.message),
      backgroundColor: Colors.red,
    ),
  );
}
```

**Error Structure** (from API):

- `message` - What went wrong
- `action` - How to fix it
- `error_code` - For future i18n support

### Repository Pattern

```dart
abstract class IAuthRepository {
  Future<AuthResponse> signIn(SignInRequest request);
  Future<AuthResponse> signUp(SignUpRequest request);
}
```

### BLoC Pattern

```dart
class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final IAuthRepository _repository;

  SignInBloc(this._repository) : super(SignInInitial()) {
    on<SignInSubmitted>(_onSignInSubmitted);
  }

  Future<void> _onSignInSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    emit(SignInLoading());
    try {
      final response = await _repository.signIn(event.request);
      emit(SignInSuccess(response));
    } catch (e) {
      emit(SignInError(e.toString()));
    }
  }
}
```

### Commit Conventions

**Use conventional commits:**

- `feat:` - New features
- `fix:` - Bug fixes
- `refactor:` - Code refactoring
- `test:` - Test additions/changes
- `docs:` - Documentation changes
- `chore:` - Build/tooling changes

**Split commits by feature/module**, not by file count.

**Do NOT include AI attribution** in commit messages (no "Generated with Claude Code" or similar).

## Best Practices

1. **Always inject dependencies** - Never create instances directly
2. **Code to interfaces** - Depend on abstractions, not concretions
3. **Single Responsibility** - Each class should have one reason to change
4. **Immutable models** - Use `@immutable` and final fields
5. **Dispose resources** - Always dispose BLoCs, controllers, streams
6. **Type safety** - Avoid dynamic, use explicit types
7. **Null safety** - Handle null cases explicitly
8. **Async/await** - Use async/await for readability over raw Futures

## Performance Considerations

- Lazy load dependencies with `registerLazySingleton`
- Use `const` constructors where possible
- Avoid rebuilds with proper BLoC selectors
- Dispose unused module dependencies
- Use `ListView.builder` for large lists

## Security

- Never commit `.env` file
- Store tokens securely (flutter_secure_storage)
- Validate all user inputs
- Sanitize error messages (don't leak sensitive info)
- Use HTTPS in production

---

## Maintaining This Document

**When to Update**:

- New architectural patterns are introduced
- Major dependency or state management changes
- New API integration patterns
- Important conventions that affect multiple files
- Error handling or validation patterns change

**When NOT to Update**:

- Adding new features that follow existing patterns
- Bug fixes that don't change architecture
- UI styling changes
- Minor refactoring within the same pattern

**Last Updated**: 2025-10-12
**Maintainers**: Development Team
