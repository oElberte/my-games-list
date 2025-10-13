import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:my_games_list/blocs/auth_event.dart';
import 'package:my_games_list/blocs/auth_state.dart';
import 'package:my_games_list/models/user_model.dart';
import 'package:my_games_list/services/local_storage_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._storageService) : super(const AuthInitial()) {
    on<AuthStateLoaded>(_onAuthStateLoaded);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }
  final LocalStorageService _storageService;
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _currentUserKey = 'current_user';

  Future<void> _onAuthStateLoaded(
    AuthStateLoaded event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final loggedIn = await _storageService.getBool(_isLoggedInKey) ?? false;
      final userJson = await _storageService.getString(_currentUserKey);

      if (loggedIn && userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final user = User.fromJson(userMap);
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      await _clearAuthState();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Mock login - in a real app, you'd validate credentials with a server
      if (event.email.isNotEmpty && event.password.isNotEmpty) {
        final user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: event.email,
          name: event.email.split('@')[0], // Use email prefix as name
        );

        await _saveAuthState(user);
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Email and password cannot be empty'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _clearAuthState();
    emit(const AuthUnauthenticated());
  }

  Future<void> _saveAuthState(User user) async {
    await _storageService.setBool(_isLoggedInKey, true);
    final userJson = jsonEncode(user.toJson());
    await _storageService.setString(_currentUserKey, userJson);
  }

  Future<void> _clearAuthState() async {
    await _storageService.remove(_isLoggedInKey);
    await _storageService.remove(_currentUserKey);
  }
}
