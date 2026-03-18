import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_games_list/features/auth/auth_repository.dart';
import 'package:my_games_list/features/auth/sign_in/bloc/sign_in_event.dart';
import 'package:my_games_list/features/auth/sign_in/bloc/sign_in_state.dart';
import 'package:my_games_list/features/auth/sign_in/sign_in_request.dart';

/// BLoC that handles sign-in business logic.
class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc(this._authRepository) : super(const SignInInitial()) {
    on<SignInSubmitted>(_onSignInSubmitted);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<AppleSignInRequested>(_onAppleSignInRequested);
  }
  final AuthRepository _authRepository;

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

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<SignInState> emit,
  ) async {
    emit(const SignInLoading());
    try {
      final authResponse = await _authRepository.signInWithGoogle();
      emit(SignInSuccess(authResponse));
    } catch (e) {
      emit(SignInError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onAppleSignInRequested(
    AppleSignInRequested event,
    Emitter<SignInState> emit,
  ) async {
    emit(const SignInLoading());
    try {
      final authResponse = await _authRepository.signInWithApple();
      emit(SignInSuccess(authResponse));
    } catch (e) {
      emit(SignInError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
