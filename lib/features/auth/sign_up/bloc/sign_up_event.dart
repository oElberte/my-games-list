import 'package:equatable/equatable.dart';

/// Base class for SignUp events.
sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the user submits the sign-up form.
final class SignUpSubmitted extends SignUpEvent {
  const SignUpSubmitted({
    required this.email,
    required this.password,
    required this.username,
  });
  final String email;
  final String password;
  final String username;

  @override
  List<Object?> get props => [email, password, username];
}
