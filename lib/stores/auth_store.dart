import 'dart:convert';
import 'package:mobx/mobx.dart';

import '../models/user_model.dart';
import '../services/local_storage_service.dart';

part 'auth_store.g.dart';

class AuthStore = AuthStoreBase with _$AuthStore;

abstract class AuthStoreBase with Store {
  final LocalStorageService _storageService;
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _currentUserKey = 'current_user';

  AuthStoreBase(this._storageService) {
    _loadAuthState();
  }

  @observable
  bool isLoggedIn = false;

  @observable
  User? currentUser;

  @action
  Future<void> login(String email, String password) async {
    // Mock login - in a real app, you'd validate credentials with a server
    if (email.isNotEmpty && password.isNotEmpty) {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: email.split('@')[0], // Use email prefix as name
      );

      currentUser = user;
      isLoggedIn = true;
      await _saveAuthState();
    } else {
      throw Exception('Email and password cannot be empty');
    }
  }

  @action
  Future<void> logout() async {
    currentUser = null;
    isLoggedIn = false;
    await _clearAuthState();
  }

  @action
  Future<void> _loadAuthState() async {
    try {
      final loggedIn = await _storageService.getBool(_isLoggedInKey) ?? false;
      final userJson = await _storageService.getString(_currentUserKey);

      if (loggedIn && userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        currentUser = User.fromJson(userMap);
        isLoggedIn = true;
      }
    } catch (e) {
      // If there's an error loading auth state, reset to logged out
      await _clearAuthState();
    }
  }

  Future<void> _saveAuthState() async {
    await _storageService.setBool(_isLoggedInKey, isLoggedIn);
    if (currentUser != null) {
      final userJson = jsonEncode(currentUser!.toJson());
      await _storageService.setString(_currentUserKey, userJson);
    }
  }

  Future<void> _clearAuthState() async {
    await _storageService.remove(_isLoggedInKey);
    await _storageService.remove(_currentUserKey);
  }
}
