import 'package:equatable/equatable.dart';

/// Request model for sign in operation.
class SignInRequest extends Equatable {
  const SignInRequest({required this.email, required this.password});
  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  @override
  List<Object?> get props => [email, password];
}
