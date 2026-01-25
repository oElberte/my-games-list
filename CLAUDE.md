# MyGamesList Architecture Guide

> **Note for AI Agents**: This is a living document that should be updated whenever significant architectural patterns, conventions, or important implementation details are added or changed. Focus on cost-benefit: document patterns that will help future development, avoid over-documenting trivial details.

## Critical Requirements

### FVM (Flutter Version Management)

**Always use FVM for all Flutter commands.** This project uses FVM to manage Flutter versions.

```bash
# Use fvm prefix for all Flutter commands
fvm flutter pub get
fvm flutter run
fvm flutter test
fvm flutter analyze
```

### Testing Requirements

**Tests are mandatory.** Whenever code is updated or created:

1. **Run existing tests** to ensure nothing is broken: `fvm flutter test`
2. **Update tests** if behavior changes
3. **Create new tests** for new functionality

**Test coverage expectations:**
- All BLoC events must have corresponding tests
- All repository methods must be tested
- Widget tests for critical user flows

## Feature Documentation Architecture

This project uses a distributed documentation strategy. Specific feature details are documented within their respective feature directories.

- **Root (This file)**: High-level patterns, coding standards, and project-wide architecture.
- **Feature Documentation**: Located at `lib/features/<feature>/CLAUDE.md`.
    - [Auth Feature](lib/features/auth/CLAUDE.md)
    - [Home Feature](lib/features/home/CLAUDE.md)
    - [Settings Feature](lib/features/settings/CLAUDE.md)
- **Core Documentation**: Located at `lib/core/CLAUDE.md`.
    - [Core Module](lib/core/CLAUDE.md)

**Instruction**: When adding a new feature, **always create a `CLAUDE.md` file** in the feature's root directory (`lib/features/<feature_name>/CLAUDE.md`) to capture domain-specific logic, special patterns, and architectural decisions relevant to that feature.

## Architecture Principles

This project follows **SOLID principles** and **Domain-Driven Design (DDD)** for a clean, maintainable, and scalable codebase.

## Project Structure

This project follows a **Feature-First Architecture** with Clean Architecture layers within each feature module.

```
lib/
├── features/           # Feature modules (feature-first organization)
│   ├── auth/          # Authentication feature
│   │   ├── CLAUDE.md  # Feature-specific documentation
│   │   ├── data/      # Data layer
│   │   ├── domain/    # Domain layer
│   │   └── presentation/  # Presentation layer
│   └── ...
├── core/              # Shared/core functionality
│   ├── data/
│   ├── domain/
│   └── utils/
└── ...
```

## Core Architectural Patterns

### 1. Modular Dependency Injection

**Pattern**: Register dependencies based on their lifecycle and scope.

- **Lazy Singleton**: Global state (e.g., Auth state, Settings, HTTP Client).
- **Factory**: Screen-specific instances (e.g., Screen-specific BLoCs).
- **Modular**: Registered only when module is accessed.

### 2. Interface Segregation (SOLID)

**Pattern**: Create interfaces for all major dependencies (Repositories, Services) to allow easy replacement and testing.

### 3. Feature-First Architecture

Each feature is a self-contained module with its own Clean Architecture layers:
- **Domain**: Pure Dart entities and interfaces.
- **Data**: Repository implementations and data sources.
- **Presentation**: BLoC and UI.

Data flow: `UI → BLoC → Repository Interface → Repository Impl → Data Source → API`

### 4. BLoC State Management

**States**: `Initial` → `Loading` → `Success`/`Error`
**Events**: Naming `<Feature><Action>` (e.g., `LoadData`, `SubmitForm`)

### 5. Standardized Error Handling

All API errors are parsed into `ApiError` objects containing `message` (debug) and `userMessage` (display friendly).
Repositories throw exceptions with user messages; BLoCs catch them and emit Error states.

## API Integration

**Interface**: `IHttpClient`
**Configuration**: Base URL from environment, standard 30s timeout.

## Testing Strategy

**Priority 1 (Must Have)**:
- Repository tests (mocking HTTP/Data Sources)
- BLoC tests (mocking Repositories)

**Priority 2 (Should Have)**:
- Integration tests for main flows
- Utility function tests

**Test Commands:**
```bash
# Run all tests
fvm flutter test

# Run specific test file
fvm flutter test test/features/auth/bloc/auth_bloc_test.dart

# Run with coverage
fvm flutter test --coverage
```

**Test Location:**
- Tests mirror the `lib/` structure in `test/`
- Mock services are in `test/mocks/`

## Code Style & Conventions

- **Naming**: PascalCase for Classes, snake_case for files, camelCase for variables.
- **Organization**: One class per file.
- **Comments**: Document WHY, not WHAT.
- **Commits**: Conventional Commits (`feat:`, `fix:`, `chore:`, etc.).

## Common Patterns (Generic Examples)

### Repository Interface

```dart
abstract class IFeatureRepository {
  Future<DataEntity> getData(RequestDto request);
}
```

### BLoC Implementation

```dart
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final IFeatureRepository _repository;

  FeatureBloc(this._repository) : super(FeatureInitial()) {
    on<FeatureEvent>(_onEvent);
  }

  Future<void> _onEvent(FeatureEvent event, Emitter<FeatureState> emit) async {
    emit(FeatureLoading());
    try {
      final result = await _repository.getData(event.params);
      emit(FeatureSuccess(result));
    } catch (e) {
      emit(FeatureError(e.toString()));
    }
  }
}
```

---

## Maintenance

**When to Update this Root File**:
- New architectural patterns are introduced.
- Global standards change.

**When to Update Feature Files**:
- Feature-specific business logic changes.
- New endpoints or data models are added to a feature.
- Specific implementation details for that feature change.
