import 'package:bloc/bloc.dart';
import 'package:my_games_list/blocs/settings_event.dart';
import 'package:my_games_list/blocs/settings_state.dart';
import 'package:my_games_list/services/local_storage_service.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._storageService) : super(const SettingsState()) {
    on<SettingsInitialized>(_onSettingsInitialized);
    on<SettingsThemeToggled>(_onSettingsThemeToggled);
    on<SettingsDarkModeSet>(_onSettingsDarkModeSet);
  }
  final LocalStorageService _storageService;
  static const String _isDarkModeKey = 'is_dark_mode';

  Future<void> _onSettingsInitialized(
    SettingsInitialized event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final darkMode = await _storageService.getBool(_isDarkModeKey) ?? false;
      emit(state.copyWith(isDarkMode: darkMode));
    } catch (e) {
      emit(state.copyWith(isDarkMode: false));
    }
  }

  Future<void> _onSettingsThemeToggled(
    SettingsThemeToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final newValue = !state.isDarkMode;
    await _saveSettings(newValue);
    emit(state.copyWith(isDarkMode: newValue));
  }

  Future<void> _onSettingsDarkModeSet(
    SettingsDarkModeSet event,
    Emitter<SettingsState> emit,
  ) async {
    await _saveSettings(event.value);
    emit(state.copyWith(isDarkMode: event.value));
  }

  Future<void> _saveSettings(bool isDarkMode) async {
    await _storageService.setBool(_isDarkModeKey, isDarkMode);
  }
}
