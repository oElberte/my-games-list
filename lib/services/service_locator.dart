import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:my_games_list/blocs/auth_bloc.dart';
import 'package:my_games_list/blocs/home_bloc.dart';
import 'package:my_games_list/blocs/settings_bloc.dart';
import 'package:my_games_list/services/http/dio_http_client.dart';
import 'package:my_games_list/services/http/i_http_client.dart';
import 'package:my_games_list/services/local_storage_service.dart';
import 'package:my_games_list/services/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global service locator instance
final GetIt sl = GetIt.instance;

/// Sets up global dependencies for the application.
/// This should be called during app initialization.
/// Only registers dependencies that are needed globally throughout the app.
/// Module-specific dependencies should be registered lazily when modules are loaded.
Future<void> setupServiceLocator() async {
  // Load environment variables
  await dotenv.load();

  // Register core services first
  await _registerCoreServices();

  // Register global BLoCs (non-auth)
  _registerGlobalBlocs();
}

/// Registers core services like storage and HTTP client.
/// These are global dependencies needed throughout the app.
Future<void> _registerCoreServices() async {
  // Register SharedPreferences instance as singleton
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register storage service implementation
  sl.registerSingleton<LocalStorageService>(
    SharedPreferencesService(sharedPreferences),
  );

  // Register HTTP client as singleton (used globally for all API calls)
  sl.registerLazySingleton<IHttpClient>(() => DioHttpClient());
}

/// Registers global BLoCs that are needed throughout the app.
/// Auth-specific BLoCs (SignIn/SignUp) are registered modularly in the router.
void _registerGlobalBlocs() {
  // Register AuthBloc as lazy singleton - manages global authentication state
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(sl<LocalStorageService>()),
  );

  // Register SettingsBloc as lazy singleton
  sl.registerLazySingleton<SettingsBloc>(
    () => SettingsBloc(sl<LocalStorageService>()),
  );

  // Register HomeBloc as factory - new instance per screen
  sl.registerFactory<HomeBloc>(() => HomeBloc(sl<LocalStorageService>()));
}

/// Resets all registrations - useful for testing
Future<void> resetServiceLocator() async {
  await sl.reset();
}

/// Helper method to check if all services are ready
Future<void> waitForServicesReady() async {
  await sl.allReady();
}
