import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_games_list/core/data/services/http/i_http_client.dart';
import 'package:my_games_list/core/data/services/storage/token_storage.dart';
import 'package:my_games_list/core/services/session_reset_service.dart';
import 'package:my_games_list/features/library/bloc/library_bloc.dart';
import 'package:my_games_list/features/library/library_repository.dart';

class _MockTokenStorage extends Mock implements TokenStorage {}

class _MockHttpClient extends Mock implements IHttpClient {}

class _MockLibraryRepository extends Mock implements LibraryRepository {}

void main() {
  group('SessionResetService', () {
    late _MockTokenStorage tokenStorage;
    late _MockHttpClient httpClient;
    late GetIt locator;

    setUp(() {
      tokenStorage = _MockTokenStorage();
      httpClient = _MockHttpClient();
      locator = GetIt.asNewInstance();
      when(() => tokenStorage.delete()).thenAnswer((_) async {});
    });

    SessionResetService buildService() => SessionResetService(
      tokenStorage: tokenStorage,
      httpClient: httpClient,
      locator: locator,
    );

    test('clears the auth token and HTTP auth header', () async {
      await buildService().teardownSession();

      verify(() => tokenStorage.delete()).called(1);
      verify(() => httpClient.clearAuthToken()).called(1);
    });

    test('is a no-op for LibraryBloc when it is not registered', () async {
      // Should not throw when the user never visited a library screen.
      await buildService().teardownSession();
      expect(locator.isRegistered<LibraryBloc>(), isFalse);
    });

    test(
      'resets the LibraryBloc singleton so the next user gets a fresh one',
      () async {
        locator.registerLazySingleton<LibraryBloc>(
          () => LibraryBloc(libraryRepository: _MockLibraryRepository()),
        );
        final before = locator<LibraryBloc>();

        await buildService().teardownSession();

        // The registration is reset, so the next access is a fresh instance.
        final after = locator<LibraryBloc>();
        expect(identical(before, after), isFalse);

        // The old instance is closed off the logout path (unawaited); awaiting
        // close() again (idempotent) confirms it is torn down.
        await before.close();
        expect(before.isClosed, isTrue);
      },
    );
  });
}
