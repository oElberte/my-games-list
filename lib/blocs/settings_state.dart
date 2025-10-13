import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  const SettingsState({this.isDarkMode = false});
  final bool isDarkMode;

  SettingsState copyWith({bool? isDarkMode}) {
    return SettingsState(isDarkMode: isDarkMode ?? this.isDarkMode);
  }

  @override
  List<Object?> get props => [isDarkMode];
}
