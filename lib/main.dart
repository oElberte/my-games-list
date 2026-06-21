import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:my_games_list/core/services/notification_service.dart';
import 'package:my_games_list/core/utils/app_router.dart';
import 'package:my_games_list/core/utils/env.dart';
import 'package:my_games_list/core/utils/l10n_extensions.dart';
import 'package:my_games_list/core/utils/service_locator.dart';
import 'package:my_games_list/features/auth/bloc/auth_bloc.dart';
import 'package:my_games_list/features/auth/bloc/auth_event.dart';
import 'package:my_games_list/features/settings/bloc/settings_bloc.dart';
import 'package:my_games_list/features/settings/bloc/settings_event.dart';
import 'package:my_games_list/features/settings/bloc/settings_state.dart';
import 'package:my_games_list/firebase_options_production.dart';
import 'package:my_games_list/firebase_options_staging.dart';
import 'package:my_games_list/l10n/app_localizations.dart';

/// Firebase options for the active build flavor.
FirebaseOptions get _firebaseOptions => Env.isProduction
    ? ProductionFirebaseOptions.currentPlatform
    : StagingFirebaseOptions.currentPlatform;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: _firebaseOptions);
}

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase and the service locator are independent; initialize concurrently.
  await Future.wait([
    Firebase.initializeApp(options: _firebaseOptions),
    setupServiceLocator(),
  ]);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Register FCM background message handler (mobile only; not supported on web).
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

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
  late final GoRouter router;
  StreamSubscription<String>? _notificationNavSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize global BLoCs
    authBloc = sl<AuthBloc>()..add(const AuthStateLoaded());
    settingsBloc = sl<SettingsBloc>()..add(const SettingsInitialized());
    // Create router once to avoid recreation on theme changes
    router = AppRouter.createRouter();

    // Initialize NotificationService and wire up navigation from tapped notifications
    _initNotificationService();
  }

  void _initNotificationService() {
    final notificationService = sl<NotificationService>();

    // Forward notification tap routes to the GoRouter
    _notificationNavSubscription = notificationService.navigationStream.listen(
      (route) => router.go(route),
    );

    // Initialize the service (request permissions, get token, register listeners).
    // Called without await so it runs asynchronously and does not block the UI.
    // Failures are handled internally by the service (e.g. in test environments
    // where Firebase is not initialized).
    notificationService.initialize().catchError((_) {});
  }

  @override
  void dispose() {
    _notificationNavSubscription?.cancel();
    sl<NotificationService>().dispose();
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
            onGenerateTitle: (context) => context.l10n.appTitle,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
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
