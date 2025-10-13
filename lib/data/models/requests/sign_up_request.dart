import 'package:equatable/equatable.dart';

/// Request model for sign up operation.
class SignUpRequest extends Equatable {
  const SignUpRequest({
    required this.email,
    required this.password,
    required this.username,
  });
  final String email;
  final String password;
  final String username;

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, 'username': username};
  }

  @override
  List<Object?> get props => [email, password, username];
}
