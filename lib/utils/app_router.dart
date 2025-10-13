import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_games_list/blocs/sign_in/sign_in_bloc.dart';
import 'package:my_games_list/blocs/sign_up/sign_up_bloc.dart';
import 'package:my_games_list/data/repositories/auth_repository.dart';
import 'package:my_games_list/domain/repositories/i_auth_repository.dart';
import 'package:my_games_list/services/http/i_http_client.dart';
import 'package:my_games_list/services/service_locator.dart';
import 'package:my_games_list/ui/home_screen.dart';
import 'package:my_games_list/ui/settings_screen.dart';
import 'package:my_games_list/ui/sign_in_screen.dart';
import 'package:my_games_list/ui/sign_up_screen.dart';
import 'package:my_games_list/ui/webview_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Application router configuration using GoRouter with modular dependency injection.
///
/// Architecture Pattern:
/// - AuthRepository: Lazily registered on first auth route access, stays in memory as singleton
/// - BLoCs: Created per route via BlocProvider, automatically disposed when route is popped
///
/// This approach provides:
/// - Performance: Auth module not loaded until needed
/// - Memory efficiency: BLoCs are disposed automatically by Flutter
/// - Maintainability: Clear separation of concerns
class AppRouter {
  static const String signInPath = '/signin';
  static const String signUpPath = '/signup';
  static const String homePath = '/';
  static const String settingsPath = '/settings';
  static const String webviewPath = '/webview';

  /// Route names for named navigation
  static const String signInName = 'signin';
  static const String signUpName = 'signup';
  static const String homeName = 'home';
  static const String settingsName = 'settings';
  static const String webviewName = 'webview';

  /// Creates the GoRouter configuration for the app.
  /// Auth-specific dependencies are registered lazily when routes are accessed.
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: signInPath,
      routes: [
        // SignIn Route with modular dependency injection
        GoRoute(
          path: signInPath,
          name: signInName,
          builder: (context, state) {
            // Register auth repository lazily (only once, stays in memory)
            _ensureAuthRepositoryRegistered();

            // Provide SignInBloc to the screen (auto-disposed by BlocProvider)
            return BlocProvider(
              create: (_) => SignInBloc(sl<IAuthRepository>()),
              child: const SignInScreen(),
            );
          },
        ),

        // SignUp Route with modular dependency injection
        GoRoute(
          path: signUpPath,
          name: signUpName,
          builder: (context, state) {
            // Register auth repository lazily (only once, stays in memory)
            _ensureAuthRepositoryRegistered();

            // Provide SignUpBloc to the screen (auto-disposed by BlocProvider)
            return BlocProvider(
              create: (_) => SignUpBloc(sl<IAuthRepository>()),
              child: const SignUpScreen(),
            );
          },
        ),

        // Home Route
        GoRoute(
          path: homePath,
          name: homeName,
          builder: (context, state) => const HomeScreen(),
        ),

        // Settings Route
        GoRoute(
          path: settingsPath,
          name: settingsName,
          builder: (context, state) => const SettingsScreen(),
        ),

        // WebView Route
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

  /// Ensures AuthRepository is registered in the service locator.
  /// This is called lazily when auth routes are accessed.
  /// The repository stays registered as a singleton for token management and logout.
  static void _ensureAuthRepositoryRegistered() {
    if (!sl.isRegistered<IAuthRepository>()) {
      sl.registerLazySingleton<IAuthRepository>(
        () => AuthRepository(
          httpClient: sl<IHttpClient>(),
          prefs: sl<SharedPreferences>(),
        ),
      );
    }
  }
}

/// Error screen widget for handling route errors
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({this.error});
  final Exception? error;

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
