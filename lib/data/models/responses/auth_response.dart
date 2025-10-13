import 'package:equatable/equatable.dart';
import 'package:my_games_list/domain/entities/user.dart';

/// Response model for authentication operations (signin/signup).
class AuthResponse extends Equatable {
  const AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User(
        id: json['user']['id'] as String,
        email: json['user']['email'] as String,
        username: json['user']['username'] as String,
      ),
    );
  }
  final String token;
  final User user;

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': {'id': user.id, 'email': user.email, 'username': user.username},
    };
  }

  @override
  List<Object?> get props => [token, user];
}
