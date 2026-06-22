import 'package:my_games_list/features/settings/services/account_export_saver_stub.dart'
    if (dart.library.io) 'package:my_games_list/features/settings/services/account_export_saver_io.dart'
    if (dart.library.js_interop) 'package:my_games_list/features/settings/services/account_export_saver_web.dart';

/// Delivers an exported-data JSON payload to the user in a platform-appropriate
/// way: a browser download on web, and a shareable file on mobile/desktop.
abstract class AccountExportSaver {
  factory AccountExportSaver() => createAccountExportSaver();

  /// Saves or shares [json] under [fileName]. Throws on failure so callers can
  /// surface an error to the user.
  Future<void> save({required String fileName, required String json});
}
