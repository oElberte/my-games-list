import 'package:equatable/equatable.dart';

/// User model representing a user in the application
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.username,
  });

  /// Creates a User from JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      // Support both name and username fields
      name: (json['name'] ?? json['username'] ?? '') as String,
      username: json['username'] as String?,
    );
  }

  final String id;
  final String email;
  final String name;
  final String? username;

  /// Converts User to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      if (username != null) 'username': username,
    };
  }

  /// Creates a copy of this User with given fields replaced with new values
  User copyWith({String? id, String? email, String? name, String? username}) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
    );
  }

  @override
  List<Object?> get props => [id, email, name, username];

  @override
  String toString() =>
      'User(id: $id, email: $email, name: $name, username: $username)';
}
