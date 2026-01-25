# Auth Feature Documentation

## Overview
Handles user authentication including Sign In, Sign Up, and Session Management.

## Architecture
**Feature-First Structure**:
- `auth_model.dart` / `user_model.dart`: Core models.
- `auth_repository.dart`: Concrete repository implementation.
- `sign_in/`: Sub-feature for Sign In logic and UI.
- `sign_up/`: Sub-feature for Sign Up logic and UI.
- `bloc/`: Global AuthBloc.

### Dependencies
- `AuthBloc` (Global, Lazy Singleton): Manages global authentication state.
- `SignInBloc` (Factory): Manages Sign In form state.
- `SignUpBloc` (Factory): Manages Sign Up form state.
- `AuthRepository`: Handles data operations (Concrete class).

## Authentication Flow

**Endpoints**:
- POST `/auth/signin` - Sign in user
- POST `/auth/signup` - Sign up new user

**Token storage**: Store JWT in secure local storage

## Patterns & Examples

### Repository Implementation
Concrete class without interface.

```dart
class AuthRepository {
  Future<AuthResponse> signIn(SignInRequest request);
  Future<AuthResponse> signUp(SignUpRequest request);
  Future<void> signOut();
}
```

### BLoC Implementation (SignInBloc)

```dart
class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AuthRepository _repository;

  SignInBloc(this._repository) : super(SignInInitial()) {
    on<SignInSubmitted>(_onSignInSubmitted);
  }
  // ...
}
```
