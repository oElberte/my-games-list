import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_games_list/core/data/services/http/i_http_client.dart';
import 'package:my_games_list/core/utils/l10n_extensions.dart';
import 'package:my_games_list/core/utils/service_locator.dart';
import 'package:my_games_list/core/widgets/bottom_nav_bar.dart';
import 'package:my_games_list/features/auth/auth_repository.dart';
import 'package:my_games_list/features/auth/bloc/auth_bloc.dart';
import 'package:my_games_list/features/auth/bloc/auth_state.dart';
import 'package:my_games_list/features/auth/sign_in/bloc/sign_in_bloc.dart';
import 'package:my_games_list/features/auth/sign_in/sign_in_screen.dart';
import 'package:my_games_list/features/auth/sign_up/bloc/sign_up_bloc.dart';
import 'package:my_games_list/features/auth/sign_up/sign_up_screen.dart';
import 'package:my_games_list/features/games/bloc/anticipated_games_bloc.dart';
import 'package:my_games_list/features/games/bloc/anticipated_games_event.dart';
import 'package:my_games_list/features/games/games_repository.dart';
import 'package:my_games_list/features/games/games_screen.dart';
import 'package:my_games_list/features/home/bloc/home_bloc.dart';
import 'package:my_games_list/features/home/bloc/home_event.dart';
import 'package:my_games_list/features/home/home_screen.dart';
import 'package:my_games_list/features/profile/profile_screen.dart';
import 'package:my_games_list/features/settings/settings_screen.dart';
import 'package:my_games_list/features/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Application router configuration using GoRouter with modular dependency injection.
///
/// Architecture Pattern:
/// - AuthRepository: Lazily registered on first auth route access, stays in memory as singleton
/// - BLoCs: Created per route via BlocProvider, automatically disposed when route is popped
/// - Bottom Navigation: Uses StatefulShellRoute for persistent navigation with state preservation
///
/// This approach provides:
/// - Performance: Auth module not loaded until needed
/// - Memory efficiency: BLoCs are disposed automatically by Flutter
/// - Maintainability: Clear separation of concerns
/// - State preservation: Each bottom nav tab maintains its state when switching
class AppRouter {
  static const String splashPath = '/splash';
  static const String signInPath = '/signin';
  static const String signUpPath = '/signup';
  static const String homePath = '/home';
  static const String gamesPath = '/games';
  static const String profilePath = '/profile';
  static const String settingsPath = '/settings';

  /// Route names for named navigation
  static const String splashName = 'splash';
  static const String signInName = 'signin';
  static const String signUpName = 'signup';
  static const String homeName = 'home';
  static const String gamesName = 'games';
  static const String profileName = 'profile';
  static const String settingsName = 'settings';

  /// Creates the GoRouter configuration for the app.
  /// Auth-specific dependencies are registered lazily when routes are accessed.
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: splashPath,
      refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
      redirect: (context, state) {
        final authState = sl<AuthBloc>().state;
        final isAuthenticated = authState is AuthAuthenticated;
        final currentPath = state.matchedLocation;

        // Allow splash screen to handle initial navigation
        if (currentPath == splashPath) {
          return null;
        }

        final isGoingToAuth =
            currentPath == signInPath || currentPath == signUpPath;

        // If authenticated and going to auth pages, redirect to home
        if (isAuthenticated && isGoingToAuth) {
          return homePath;
        }

        // If not authenticated and trying to access protected routes, redirect to signin
        if (!isAuthenticated && !isGoingToAuth) {
          return signInPath;
        }

        // No redirect needed
        return null;
      },
      routes: [
        // Splash Route - Initial loading screen
        GoRoute(
          path: splashPath,
          name: splashName,
          builder: (context, state) => const SplashScreen(),
        ),

        // SignIn Route with modular dependency injection
        GoRoute(
          path: signInPath,
          name: signInName,
          builder: (context, state) {
            // Register auth repository lazily (only once, stays in memory)
            _ensureAuthRepositoryRegistered();

            // Provide SignInBloc to the screen (auto-disposed by BlocProvider)
            return BlocProvider(
              create: (_) => SignInBloc(sl<AuthRepository>()),
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
              create: (_) => SignUpBloc(sl<AuthRepository>()),
              child: const SignUpScreen(),
            );
          },
        ),

        // Shell Route for bottom navigation with state preservation
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return BottomNavBar(navigationShell: navigationShell);
          },
          branches: [
            // Home Branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: homePath,
                  name: homeName,
                  builder: (context, state) {
                    // Register games repository lazily (only once, stays in memory)
                    _ensureGamesRepositoryRegistered();

                    // Provide both HomeBloc and AnticipatedGamesBloc (auto-disposed by BlocProvider)
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (_) =>
                              sl<HomeBloc>()..add(const HomeInitialized()),
                        ),
                        BlocProvider(
                          create: (_) => AnticipatedGamesBloc(
                            gamesRepository: sl<GamesRepository>(),
                          )..add(const AnticipatedGamesLoadRequested()),
                        ),
                      ],
                      child: const HomeScreen(),
                    );
                  },
                ),
              ],
            ),

            // Games Branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: gamesPath,
                  name: gamesName,
                  builder: (context, state) => const GamesScreen(),
                ),
              ],
            ),

            // Profile Branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: profilePath,
                  name: profileName,
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),

        // Settings Route (outside bottom navigation)
        GoRoute(
          path: settingsPath,
          name: settingsName,
          builder: (context, state) => const SettingsScreen(),
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
    if (!sl.isRegistered<AuthRepository>()) {
      sl.registerLazySingleton<AuthRepository>(
        () => AuthRepository(
          httpClient: sl<IHttpClient>(),
          prefs: sl<SharedPreferences>(),
        ),
      );
    }
  }

  /// Ensures GamesRepository is registered in the service locator.
  /// This is called lazily when home route is accessed.
  /// The repository stays registered as a singleton for API calls.
  static void _ensureGamesRepositoryRegistered() {
    if (!sl.isRegistered<GamesRepository>()) {
      sl.registerLazySingleton<GamesRepository>(
        () => GamesRepository(httpClient: sl<IHttpClient>()),
      );
    }
  }
}

/// Helper class to convert Stream to ChangeNotifier for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
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
        title: Text(context.l10n.errorTitle),
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
              Text(
                context.l10n.errorMessage,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
                child: Text(context.l10n.goHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
