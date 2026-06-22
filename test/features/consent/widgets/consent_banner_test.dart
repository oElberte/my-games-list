import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_games_list/core/data/services/storage/local_storage_service.dart';
import 'package:my_games_list/core/services/consent/consent_category.dart';
import 'package:my_games_list/core/services/consent/consent_service.dart';
import 'package:my_games_list/core/services/consent/telemetry_gateway.dart';
import 'package:my_games_list/features/consent/bloc/consent_cubit.dart';
import 'package:my_games_list/features/consent/widgets/consent_banner.dart';
import 'package:my_games_list/l10n/app_localizations.dart';

class _MockStorage extends Mock implements LocalStorageService {}

class _MockGateway extends Mock implements TelemetryGateway {}

void main() {
  setUpAll(() {
    registerFallbackValue(ConsentCategory.crash);
  });

  late _MockStorage storage;
  late _MockGateway gateway;
  late ConsentService service;

  setUp(() {
    storage = _MockStorage();
    gateway = _MockGateway();
    when(() => storage.getBool(any())).thenAnswer((_) async => null);
    when(() => storage.setBool(any(), any())).thenAnswer((_) async => true);
    when(() => storage.remove(any())).thenAnswer((_) async => true);
    when(
      () => gateway.applyConsent(any(), granted: any(named: 'granted')),
    ).thenAnswer((_) async {});
    service = ConsentService(storage: storage, gateway: gateway);
  });

  tearDown(() => service.dispose());

  // The cubit is created inside BlocProvider.create so it lives in the test's
  // async zone — a cubit built in setUp schedules its stream-driven emits on
  // the wrong zone and the BlocBuilder never rebuilds under the fake clock.
  Widget buildApp() {
    return BlocProvider<ConsentCubit>(
      create: (_) => ConsentCubit(service),
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ConsentBanner(child: Center(child: Text('app body'))),
        ),
      ),
    );
  }

  testWidgets('shows the banner when consent is unanswered', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text('Your privacy choices'), findsOneWidget);
    expect(find.text('Accept all'), findsOneWidget);
    expect(find.text('Reject all'), findsOneWidget);
    expect(find.text('Customize'), findsOneWidget);
    // App content stays usable behind the non-modal banner.
    expect(find.text('app body'), findsOneWidget);
  });

  testWidgets('accept all grants every category and hides the banner', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.text('Accept all'));
    await tester.pumpAndSettle();

    expect(find.text('Your privacy choices'), findsNothing);
    expect(service.hasAnswered, isTrue);
    for (final category in ConsentCategory.values) {
      expect(service.isGranted(category), isTrue);
    }
  });

  testWidgets('reject all denies every category and hides the banner', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.text('Reject all'));
    await tester.pumpAndSettle();

    expect(find.text('Your privacy choices'), findsNothing);
    expect(service.hasAnswered, isTrue);
    for (final category in ConsentCategory.values) {
      expect(service.isGranted(category), isFalse);
    }
  });

  testWidgets('customize sheet applies per-category choices', (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.text('Customize'));
    await tester.pumpAndSettle();

    // Sheet shows a switch per category; enable crash reporting only.
    expect(find.text('Choose what you allow'), findsOneWidget);
    await tester.tap(find.widgetWithText(SwitchListTile, 'Crash reports'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Your privacy choices'), findsNothing);
    expect(service.isGranted(ConsentCategory.crash), isTrue);
    expect(service.isGranted(ConsentCategory.analytics), isFalse);
    expect(service.hasAnswered, isTrue);
  });

  testWidgets('banner does not show once consent is already answered', (
    tester,
  ) async {
    when(
      () => storage.getBool(ConsentService.answeredStorageKey),
    ).thenAnswer((_) async => true);
    await service.load();

    await tester.pumpWidget(buildApp());

    expect(find.text('Your privacy choices'), findsNothing);
  });
}
