import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_service.dart';
import 'shared_preferences_service.dart';
import '../stores/auth_store.dart';
import '../stores/settings_store.dart';
import '../stores/home_store.dart';

/// Global service locator instance
final GetIt getIt = GetIt.instance;

/// Sets up all dependencies for the application
/// This should be called during app initialization
Future<void> setupServiceLocator() async {
  // Register core services first
  await _registerCoreServices();

  // Register stores
  _registerStores();
}

/// Registers core services like storage
Future<void> _registerCoreServices() async {
  // Register SharedPreferences instance
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register storage service implementation
  getIt.registerSingleton<LocalStorageService>(
    SharedPreferencesService(sharedPreferences),
  );
}

/// Registers MobX stores
void _registerStores() {
  // Register AuthStore
  getIt.registerSingleton<AuthStore>(AuthStore(getIt<LocalStorageService>()));

  // Register SettingsStore
  getIt.registerSingleton<SettingsStore>(
    SettingsStore(getIt<LocalStorageService>()),
  );

  // Register HomeStore
  getIt.registerSingleton<HomeStore>(HomeStore(getIt<LocalStorageService>()));
}

/// Resets all registrations - useful for testing
Future<void> resetServiceLocator() async {
  await getIt.reset();
}

/// Helper method to check if all services are ready
Future<void> waitForServicesReady() async {
  await getIt.allReady();
}
