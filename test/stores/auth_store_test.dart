import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';
import 'package:my_games_list/stores/auth_store.dart';

import '../mocks/mock_services.dart';

void main() {
  group('AuthStore', () {
    late MockLocalStorageService mockStorageService;
    late AuthStore authStore;

    setUp(() {
      mockStorageService = MockLocalStorageService();
      authStore = AuthStore(mockStorageService);
    });

    test('should initialize with null user', () {
      expect(authStore.currentUser, isNull);
      expect(authStore.isLoggedIn, isFalse);
    });

    test('should login user successfully', () async {
      await authStore.login('test@example.com', 'password123');

      expect(authStore.currentUser, isNotNull);
      expect(authStore.currentUser!.email, equals('test@example.com'));
      expect(authStore.isLoggedIn, isTrue);
      expect(mockStorageService.setStringCallHistory.length, greaterThan(0));
    });

    test('should load auth state from storage', () async {
      // Set up storage to return a saved user
      mockStorageService.setBoolReturn(true);
      mockStorageService.setStringReturn('{"id":"123","email":"saved@example.com","name":"Saved User"}');

      // Create a new store to trigger _loadAuthState in constructor
      final newAuthStore = AuthStore(mockStorageService);
      
      // Wait a bit for async initialization
      await Future.delayed(Duration(milliseconds: 10));

      expect(newAuthStore.currentUser, isNotNull);
      expect(newAuthStore.currentUser!.email, equals('saved@example.com'));
      expect(newAuthStore.currentUser!.name, equals('Saved User'));
      expect(newAuthStore.isLoggedIn, isTrue);
    });

    test('should handle missing auth state gracefully', () async {
      mockStorageService.setBoolReturn(false);
      mockStorageService.setStringReturn(null);

      final newAuthStore = AuthStore(mockStorageService);
      await Future.delayed(Duration(milliseconds: 10));

      expect(newAuthStore.currentUser, isNull);
      expect(newAuthStore.isLoggedIn, isFalse);
    });

    test('should handle invalid JSON in auth state', () async {
      mockStorageService.setBoolReturn(true);
      mockStorageService.setStringReturn('invalid json');

      final newAuthStore = AuthStore(mockStorageService);
      await Future.delayed(Duration(milliseconds: 10));

      expect(newAuthStore.currentUser, isNull);
      expect(newAuthStore.isLoggedIn, isFalse);
    });

    test('should logout user successfully', () async {
      // First login
      await authStore.login('test@example.com', 'password123');
      expect(authStore.isLoggedIn, isTrue);

      // Then logout
      await authStore.logout();

      expect(authStore.currentUser, isNull);
      expect(authStore.isLoggedIn, isFalse);
      expect(mockStorageService.removeCallHistory.length, greaterThan(0));
    });

    test('should persist user data on login', () async {
      await authStore.login('test@example.com', 'password123');

      expect(mockStorageService.setStringCallHistory.length, greaterThan(0));
      final savedData = mockStorageService.setStringCallHistory.first['value'] as String;
      expect(savedData, contains('test@example.com'));
    });

    test('should be observable', () async {
      var observationCount = 0;
      final dispose = autorun((_) {
        // Access observable properties to track changes
        authStore.currentUser;
        authStore.isLoggedIn;
        observationCount++;
      });

      // Initial observation
      expect(observationCount, equals(1));

      // Login should trigger observation
      await authStore.login('test@example.com', 'password123');
      expect(observationCount, equals(2));

      // Logout should trigger observation
      await authStore.logout();
      expect(observationCount, equals(3));

      dispose();
    });

    test('should validate empty credentials on login', () async {
      // Test with empty email
      expect(
        () => authStore.login('', 'password123'),
        throwsException,
      );

      // Test with empty password
      expect(
        () => authStore.login('test@example.com', ''),
        throwsException,
      );

      // Test with valid credentials
      await authStore.login('test@example.com', 'validpassword');
      expect(authStore.isLoggedIn, isTrue);
    });

    test('should generate unique user IDs', () async {
      await authStore.login('user1@example.com', 'password123');
      final userId1 = authStore.currentUser!.id;
      
      await authStore.logout();
      
      // Wait a bit to ensure different timestamp
      await Future.delayed(Duration(milliseconds: 10));
      
      await authStore.login('user2@example.com', 'password123');
      final userId2 = authStore.currentUser!.id;

      expect(userId1, isNot(equals(userId2)));
    });

    test('should use email prefix as user name', () async {
      await authStore.login('johndoe@example.com', 'password123');
      
      expect(authStore.currentUser!.name, equals('johndoe'));
    });
  });
}