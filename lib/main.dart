import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_games_list/core/utils/app_router.dart';
import 'package:my_games_list/core/utils/service_locator.dart';
import 'package:my_games_list/features/auth/bloc/auth_bloc.dart';
import 'package:my_games_list/features/auth/bloc/auth_event.dart';
import 'package:my_games_list/features/settings/bloc/settings_bloc.dart';
import 'package:my_games_list/features/settings/bloc/settings_event.dart';
import 'package:my_games_list/features/settings/bloc/settings_state.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection (loads env variables and registers global services)
  await setupServiceLocator();

  // Run the app
  runApp(const MyGamesListApp());
}

class MyGamesListApp extends StatefulWidget {
  const MyGamesListApp({super.key});

  @override
  State<MyGamesListApp> createState() => _MyGamesListAppState();
}

class _MyGamesListAppState extends State<MyGamesListApp> {
  late final AuthBloc authBloc;
  late final SettingsBloc settingsBloc;

  @override
  void initState() {
    super.initState();
    // Initialize global BLoCs
    authBloc = sl<AuthBloc>()..add(const AuthStateLoaded());
    settingsBloc = sl<SettingsBloc>()..add(const SettingsInitialized());
  }

  @override
  void dispose() {
    // Note: These are singletons, but we close them here when the app terminates
    authBloc.close();
    settingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: settingsBloc),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'My Games List',
            routerConfig: AppRouter.createRouter(),
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: state.isDarkMode
                    ? Brightness.dark
                    : Brightness.light,
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
