import 'package:bloc_test/bloc_test.dart';
import 'package:my_games_list/features/auth/bloc/auth_bloc.dart';
import 'package:my_games_list/features/auth/bloc/auth_event.dart';
import 'package:my_games_list/features/auth/bloc/auth_state.dart';
import 'package:my_games_list/features/home/bloc/home_bloc.dart';
import 'package:my_games_list/features/home/bloc/home_event.dart';
import 'package:my_games_list/features/home/bloc/home_state.dart';
import 'package:my_games_list/features/settings/bloc/settings_bloc.dart';
import 'package:my_games_list/features/settings/bloc/settings_event.dart';
import 'package:my_games_list/features/settings/bloc/settings_state.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}
