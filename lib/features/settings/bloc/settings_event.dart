import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsInitialized extends SettingsEvent {
  const SettingsInitialized();
}

class SettingsThemeToggled extends SettingsEvent {
  const SettingsThemeToggled();
}

class SettingsDarkModeSet extends SettingsEvent {
  const SettingsDarkModeSet(this.value);
  final bool value;

  @override
  List<Object?> get props => [value];
}

class SettingsLocaleSet extends SettingsEvent {
  const SettingsLocaleSet(this.localeCode);

  /// 'en', 'pt', or null to follow the device locale.
  final String? localeCode;

  @override
  List<Object?> get props => [localeCode];
}
