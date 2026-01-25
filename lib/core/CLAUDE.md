# Core Module Documentation

## Overview
This directory contains the foundational building blocks of the application that are shared across multiple features. It must **NOT** contain any feature-specific business logic.

## Scope
- **Shared Utilities**: Helper functions, extensions, and constants.
- **Dependency Injection**: Service locator setup (e.g., `init_dependencies.dart` or similar).
- **Network Layer**: Generic HTTP clients (`IHttpClient`), interceptors, and error handling.
- **Storage Layer**: Local storage abstractions and implementations.
- **Common Widgets**: Reusable UI components (Buttons, Inputs, Loaders) used by multiple features.
- **Routing**: Global application router configuration.

## Architecture Principles
1.  **No Feature Dependencies**: Core components cannot depend on `features/`.
2.  **High Reusability**: Components here should be generic enough for any part of the app.
3.  **Stability**: Changes here affect the entire app, so changes should be backwards compatible where possible.

## Patterns

### Error Handling
See `lib/core/domain/models/api_error.dart` for the standardized error format used by the entire app.

### API Client
See `lib/core/data/network/` for the `IHttpClient` interface and `DioHttpClient` implementation.
