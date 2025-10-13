import 'package:equatable/equatable.dart';

/// Base class for SignIn events.
sealed class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the user submits the sign-in form.
final class SignInSubmitted extends SignInEvent {
  const SignInSubmitted({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
