import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/login_screen.dart';
import '../ui/home_screen.dart';
import '../ui/settings_screen.dart';
import '../ui/webview_screen.dart';
import '../services/service_locator.dart';
import '../stores/auth_store.dart';

/// Application router configuration using GoRouter
class AppRouter {
  static const String loginPath = '/login';
  static const String homePath = '/';
  static const String settingsPath = '/settings';
  static const String webviewPath = '/webview';

  /// Route names for named navigation
  static const String loginName = 'login';
  static const String homeName = 'home';
  static const String settingsName = 'settings';
  static const String webviewName = 'webview';

  /// Creates the GoRouter configuration for the app
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: homePath,
      redirect: _handleRedirect,
      routes: [
        GoRoute(
          path: loginPath,
          name: loginName,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: homePath,
          name: homeName,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: settingsPath,
          name: settingsName,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: webviewPath,
          name: webviewName,
          builder: (context, state) => const WebViewScreen(),
        ),
      ],
      errorBuilder: (context, state) => _ErrorScreen(error: state.error),
      debugLogDiagnostics: true,
    );
  }

  /// Handles route redirection based on authentication state
  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authStore = getIt<AuthStore>();
    final isLoginRoute = state.matchedLocation == loginPath;

    // If user is not logged in and trying to access protected routes
    if (!authStore.isLoggedIn && !isLoginRoute) {
      return loginPath;
    }

    // If user is logged in and on login screen, redirect to home
    if (authStore.isLoggedIn && isLoginRoute) {
      return homePath;
    }

    // No redirect needed
    return null;
  }
}

/// Error screen widget for handling route errors
class _ErrorScreen extends StatelessWidget {
  final Exception? error;

  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Oops! Something went wrong.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (error != null)
                Text(
                  error.toString(),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go(AppRouter.homePath),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
