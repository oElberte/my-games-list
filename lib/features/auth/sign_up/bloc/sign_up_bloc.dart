import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_games_list/features/auth/auth_repository.dart';
import 'package:my_games_list/features/auth/sign_up/bloc/sign_up_event.dart';
import 'package:my_games_list/features/auth/sign_up/bloc/sign_up_state.dart';
import 'package:my_games_list/features/auth/sign_up/sign_up_request.dart';

/// BLoC that handles sign-up business logic.
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc(this._authRepository) : super(const SignUpInitial()) {
    on<SignUpSubmitted>(_onSignUpSubmitted);
  }
  final AuthRepository _authRepository;

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(const SignUpLoading());

    try {
      final request = SignUpRequest(
        email: event.email,
        password: event.password,
        username: event.username,
      );

      final authResponse = await _authRepository.signUp(request);

      emit(SignUpSuccess(authResponse));
    } catch (e) {
      emit(SignUpError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
