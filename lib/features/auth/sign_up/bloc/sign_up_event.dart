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
    required this.acceptedTerms,
  });
  final String email;
  final String password;
  final String username;

  /// Whether the user ticked the required Privacy Policy / Terms acceptance.
  /// The bloc refuses to submit when this is false (the UI also gates the
  /// button), keeping the consent rule out of the widget.
  final bool acceptedTerms;

  @override
  List<Object?> get props => [email, password, username, acceptedTerms];
}
