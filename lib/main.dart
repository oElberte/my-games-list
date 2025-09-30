import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'services/service_locator.dart';
import 'utils/app_router.dart';
import 'stores/settings_store.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  await setupServiceLocator();

  // Run the app
  runApp(const MyGamesListApp());
}

class MyGamesListApp extends StatelessWidget {
  const MyGamesListApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsStore = getIt<SettingsStore>();
    final router = AppRouter.createRouter();

    return Observer(
      builder: (context) => MaterialApp.router(
        title: 'My Games List',
        routerConfig: router,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: settingsStore.isDarkMode
                ? Brightness.dark
                : Brightness.light,
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
