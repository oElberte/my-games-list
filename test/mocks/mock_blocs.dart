import 'package:bloc_test/bloc_test.dart';
import 'package:my_games_list/blocs/auth_bloc.dart';
import 'package:my_games_list/blocs/auth_event.dart';
import 'package:my_games_list/blocs/auth_state.dart';
import 'package:my_games_list/blocs/home_bloc.dart';
import 'package:my_games_list/blocs/home_event.dart';
import 'package:my_games_list/blocs/home_state.dart';
import 'package:my_games_list/blocs/settings_bloc.dart';
import 'package:my_games_list/blocs/settings_event.dart';
import 'package:my_games_list/blocs/settings_state.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}
