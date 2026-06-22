import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_games_list/features/auth/bloc/auth_bloc.dart';
import 'package:my_games_list/features/auth/bloc/auth_state.dart';
import 'package:my_games_list/features/auth/sign_up/bloc/sign_up_bloc.dart';
import 'package:my_games_list/features/auth/sign_up/bloc/sign_up_event.dart';
import 'package:my_games_list/features/auth/sign_up/bloc/sign_up_state.dart';
import 'package:my_games_list/features/auth/sign_up/sign_up_screen.dart';
import 'package:my_games_list/l10n/app_localizations.dart';

import '../../../mocks/mock_blocs.dart';

void main() {
  setUpAll(
    () => registerFallbackValue(
      const SignUpSubmitted(email: '', password: '', username: ''),
    ),
  );

  group('SignUpScreen', () {
    late MockSignUpBloc signUpBloc;
    late MockAuthBloc authBloc;

    setUp(() {
      signUpBloc = MockSignUpBloc();
      authBloc = MockAuthBloc();
      when(() => signUpBloc.state).thenReturn(const SignUpInitial());
      when(() => authBloc.state).thenReturn(const AuthInitial());
    });

    tearDown(() {
      signUpBloc.close();
      authBloc.close();
    });

    Widget buildSubject() {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<SignUpBloc>.value(value: signUpBloc),
            BlocProvider<AuthBloc>.value(value: authBloc),
          ],
          child: const SignUpScreen(),
        ),
      );
    }

    testWidgets('renders the four credential fields and the submit button', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.widgetWithText(AppBar, 'Sign Up'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    });

    testWidgets('submitting an empty form does not dispatch SignUpSubmitted', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      final submit = find.widgetWithText(ElevatedButton, 'Sign Up');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();

      verifyNever(() => signUpBloc.add(any<SignUpSubmitted>()));
    });

    testWidgets('submitting a valid form dispatches SignUpSubmitted with the '
        'trimmed credentials', (tester) async {
      await tester.pumpWidget(buildSubject());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'gamer');
      await tester.enterText(fields.at(1), 'gamer@example.com');
      await tester.enterText(fields.at(2), 'secret123');
      await tester.enterText(fields.at(3), 'secret123');

      final submit = find.widgetWithText(ElevatedButton, 'Sign Up');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();

      final event =
          verify(() => signUpBloc.add(captureAny())).captured.single
              as SignUpSubmitted;
      expect(event.username, 'gamer');
      expect(event.email, 'gamer@example.com');
      expect(event.password, 'secret123');
    });

    testWidgets('mismatched passwords block submission', (tester) async {
      await tester.pumpWidget(buildSubject());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'gamer');
      await tester.enterText(fields.at(1), 'gamer@example.com');
      await tester.enterText(fields.at(2), 'secret123');
      await tester.enterText(fields.at(3), 'different');

      final submit = find.widgetWithText(ElevatedButton, 'Sign Up');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();

      verifyNever(() => signUpBloc.add(any<SignUpSubmitted>()));
    });

    testWidgets(
      'loading state shows a progress indicator and disables submit',
      (tester) async {
        when(() => signUpBloc.state).thenReturn(const SignUpLoading());

        await tester.pumpWidget(buildSubject());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets('an error state surfaces the message in a snackbar', (
      tester,
    ) async {
      whenListen(
        signUpBloc,
        Stream<SignUpState>.fromIterable([
          const SignUpError('Email already in use'),
        ]),
        initialState: const SignUpInitial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Email already in use'), findsOneWidget);
    });
  });
}
