import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  const SettingsState({this.isDarkMode = false, this.localeCode});

  final bool isDarkMode;

  /// The chosen language code ('en', 'pt'), or null to follow the device.
  final String? localeCode;

  // Sentinel so copyWith can distinguish "leave unchanged" from "set to null"
  // (null is a valid localeCode meaning "follow the device locale").
  static const Object _unchanged = Object();

  SettingsState copyWith({bool? isDarkMode, Object? localeCode = _unchanged}) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      localeCode: identical(localeCode, _unchanged)
          ? this.localeCode
          : localeCode as String?,
    );
  }

  @override
  List<Object?> get props => [isDarkMode, localeCode];
}
