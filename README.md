# My Games List

A Flutter application for managing your personal games collection with favorites and preferences.

## Overview

My Games List is a cross-platform mobile application built with Flutter that allows users to:

- Browse and discover games
- Mark games as favorites
- Manage personal preferences and settings
- Authenticate and maintain personal lists
- Toggle between light and dark themes

## Features

### 🎮 Game Management

- Browse a curated list of popular games
- View detailed game information including descriptions and images
- Add/remove games from your favorites list
- Persistent favorites storage across app sessions

### 🔐 User Authentication

- Secure user login and registration
- Persistent authentication state
- User profile management

### ⚙️ Settings & Preferences

- Toggle between light and dark themes
- Preference persistence across app restarts
- User-friendly settings interface

### 🌐 Web Integration

- Built-in web view for additional content
- Seamless navigation between native and web content

## Architecture

### State Management

- **MobX**: Reactive state management for real-time UI updates
- **Stores**: Organized business logic with AuthStore, HomeStore, and SettingsStore
- **Observables**: Automatic UI updates when data changes

### Dependency Injection

- **GetIt**: Service locator pattern for dependency management
- **Service Layer**: Clean separation of concerns with abstract interfaces

### Navigation

- **GoRouter**: Declarative routing with authentication guards
- **Route Protection**: Automatic redirection based on authentication state

### Data Persistence

- **SharedPreferences**: Local storage for user preferences and favorites
- **JSON Serialization**: Type-safe data models with automatic serialization

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
│   ├── user_model.dart      # User data structure
│   └── item_model.dart      # Game item structure
├── services/                 # Service layer
│   ├── local_storage_service.dart      # Storage abstraction
│   └── shared_preferences_service.dart # SharedPreferences implementation
├── stores/                   # MobX state management
│   ├── auth_store.dart      # Authentication state
│   ├── home_store.dart      # Games and favorites state
│   └── settings_store.dart  # User preferences state
├── ui/                      # User interface
│   ├── login_screen.dart    # Authentication interface
│   ├── home_screen.dart     # Main games list
│   ├── settings_screen.dart # User preferences
│   └── webview_screen.dart  # Web content viewer
└── config/
    └── app_router.dart      # Navigation configuration

test/                        # Comprehensive test suite
├── models/                  # Model tests
├── stores/                  # Store tests
├── services/                # Service tests
├── ui/                      # UI widget tests
└── mocks/                   # Test utilities
```

## Technologies Used

### Core Framework

- **Flutter**: Multi-platform UI toolkit
- **Dart**: Programming language

### State Management

- **MobX**: Reactive state management
- **MobX Codegen**: Code generation for MobX

### Dependency Injection

- **GetIt**: Service locator

### Navigation

- **GoRouter**: Declarative routing

### Storage

- **SharedPreferences**: Local data persistence

### Web Integration

- **WebView Flutter**: In-app web browser

### Development Tools

- **Build Runner**: Code generation
- **Flutter Lints**: Dart linting rules

## Getting Started

### Prerequisites

- **FVM (Flutter Version Manager)** - Recommended for managing Flutter SDK versions
- Flutter SDK 3.24.0 or later (managed via FVM)
- Dart SDK 3.5.0 or later (comes with Flutter)
- Android Studio / VS Code with Flutter extensions
- Android SDK for Android development
- Xcode for iOS development (macOS only)

### FVM Setup (Recommended)

**FVM (Flutter Version Manager)** allows you to easily manage multiple Flutter SDK versions and ensures consistent development environments across your team.

#### Verify Installation

```bash
fvm --version
fvm doctor  # Diagnose any issues
```

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd my_games_list
   ```

2. **Set up Flutter SDK version**

   ```bash
   # Install and use the project's Flutter version
   fvm use 3.35.4

   # This creates .fvmrc and configures the project
   # VS Code will automatically detect the FVM configuration
   ```

3. **Install dependencies**

   ```bash
   fvm flutter pub get
   ```

4. **Generate code**

   ```bash
   fvm flutter packages pub run build_runner build
   ```

5. **Run the application**
   ```bash
   fvm flutter run
   ```

### Development Setup

1. **Code Generation** (for MobX stores)

   ```bash
   # One-time generation
   fvm flutter packages pub run build_runner build

   # Watch mode for development
   fvm flutter packages pub run build_runner watch
   ```

2. **Running Tests**

   ```bash
   # Run all tests
   fvm flutter test

   # Run with coverage
   fvm flutter test --coverage
   ```

3. **Code Analysis**
   ```bash
   fvm flutter analyze
   ```

## Testing

The project includes comprehensive test coverage:

### Test Types

- **Unit Tests**: Model and service logic
- **Widget Tests**: UI component behavior
- **Store Tests**: State management logic
- **Integration Tests**: End-to-end workflows

### Running Tests

```bash
# All tests
fvm flutter test

# Specific test file
fvm flutter test test/stores/auth_store_test.dart

# With coverage report
fvm flutter test --coverage
```

### Test Coverage

- 75+ test cases covering all major functionality
- Model serialization and validation
- Store state management and persistence
- Service layer implementations
- UI widget behavior

## Building for Production

### Android

```bash
fvm flutter build apk --release
# or
fvm flutter build appbundle --release
```

### iOS

```bash
fvm flutter build ios --release
```

### Web

```bash
fvm flutter build web --release
```

## Configuration

### Environment Setup

The app uses service locator pattern for dependency injection. All services are registered in `main.dart`:

```dart
void setupServiceLocator() {
  GetIt.instance.registerLazySingleton<LocalStorageService>(
    () => SharedPreferencesService(),
  );
  // Additional services...
}
```

### Router Configuration

Navigation is handled by GoRouter with authentication guards:

```dart
final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    // Authentication logic
  },
  routes: [
    // Route definitions
  ],
);
```

## Performance Considerations

### State Management

- MobX provides efficient reactive updates
- Computed values for derived state
- Automatic disposal of observers

### Storage

- Asynchronous operations for non-blocking UI
- Efficient JSON serialization
- Minimal storage footprint

### UI

- Material 3 design system
- Responsive layouts
- Smooth animations and transitions

## Contributing

### Code Style

- Follow Dart/Flutter conventions
- Use `flutter analyze` to check code quality
- Maintain test coverage for new features

### Development Workflow

1. Create feature branch
2. Implement changes with tests
3. Run `fvm flutter analyze` and `fvm flutter test`
4. Submit pull request

### Commit Messages

Follow conventional commit format:

- `feat: add new feature`
- `fix: resolve bug`
- `test: add test coverage`
- `docs: update documentation`

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions, issues, or contributions, please refer to the project's issue tracker or contact the development team.

---

Built with ❤️ using Flutter
