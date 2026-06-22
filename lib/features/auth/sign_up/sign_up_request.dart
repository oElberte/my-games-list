import 'package:equatable/equatable.dart';

/// Request model for sign up operation.
class SignUpRequest extends Equatable {
  const SignUpRequest({
    required this.email,
    required this.password,
    required this.username,
    required this.consentVersion,
  });
  final String email;
  final String password;
  final String username;

  /// Version of the Privacy Policy / Terms the user accepted at sign-up.
  /// Required by the API (`consent_version`, binding:"required").
  final String consentVersion;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
      'consent_version': consentVersion,
    };
  }

  @override
  List<Object?> get props => [email, password, username, consentVersion];
}
