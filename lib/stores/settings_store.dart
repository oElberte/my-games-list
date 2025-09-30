import 'package:mobx/mobx.dart';

import '../services/local_storage_service.dart';

part 'settings_store.g.dart';

class SettingsStore = SettingsStoreBase with _$SettingsStore;

abstract class SettingsStoreBase with Store {
  final LocalStorageService _storageService;
  static const String _isDarkModeKey = 'is_dark_mode';

  SettingsStoreBase(this._storageService) {
    _loadSettings();
  }

  @observable
  bool isDarkMode = false;

  @action
  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
    await _saveSettings();
  }

  @action
  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    await _saveSettings();
  }

  @action
  Future<void> _loadSettings() async {
    try {
      final darkMode = await _storageService.getBool(_isDarkModeKey) ?? false;
      isDarkMode = darkMode;
    } catch (e) {
      // If there's an error loading settings, use default values
      isDarkMode = false;
    }
  }

  Future<void> _saveSettings() async {
    await _storageService.setBool(_isDarkModeKey, isDarkMode);
  }
}
