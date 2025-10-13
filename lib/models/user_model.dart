/// User model representing a user in the application
class User {
  const User({required this.id, required this.email, required this.name});

  /// Creates a User from JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }
  final String id;
  final String email;
  final String name;

  /// Converts User to JSON map
  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name};
  }

  /// Creates a copy of this User with given fields replaced with new values
  User copyWith({String? id, String? email, String? name}) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ name.hashCode;

  @override
  String toString() => 'User(id: $id, email: $email, name: $name)';
}
