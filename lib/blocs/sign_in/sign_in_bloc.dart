import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_games_list/blocs/sign_in/sign_in_event.dart';
import 'package:my_games_list/blocs/sign_in/sign_in_state.dart';
import 'package:my_games_list/data/models/requests/sign_in_request.dart';
import 'package:my_games_list/domain/repositories/i_auth_repository.dart';

/// BLoC that handles sign-in business logic.
class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc(this._authRepository) : super(const SignInInitial()) {
    on<SignInSubmitted>(_onSignInSubmitted);
  }
  final IAuthRepository _authRepository;

  Future<void> _onSignInSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    emit(const SignInLoading());

    try {
      final request = SignInRequest(
        email: event.email,
        password: event.password,
      );

      final authResponse = await _authRepository.signIn(request);

      emit(SignInSuccess(authResponse));
    } catch (e) {
      emit(SignInError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
