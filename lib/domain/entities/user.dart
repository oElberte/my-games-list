import 'package:equatable/equatable.dart';

/// Domain entity representing a user.
class User extends Equatable {
  const User({required this.id, required this.email, required this.username});
  final String id;
  final String email;
  final String username;

  @override
  List<Object?> get props => [id, email, username];
}
