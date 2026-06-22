import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:my_games_list/features/settings/services/account_export_saver.dart';

AccountExportSaver createAccountExportSaver() => _IoAccountExportSaver();

class _IoAccountExportSaver implements AccountExportSaver {
  @override
  Future<void> save({required String fileName, required String json}) async {
    final directory = await Directory.systemTemp.createTemp('mgl_export');
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(json);

    await Share.shareXFiles([
      XFile(file.path, mimeType: 'application/json', name: fileName),
    ]);
  }
}
