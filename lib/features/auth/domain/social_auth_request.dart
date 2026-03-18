import 'package:equatable/equatable.dart';

/// Request model for social authentication (Google/Apple).
class SocialAuthRequest extends Equatable {
  const SocialAuthRequest({
    required this.provider,
    required this.firebaseIdToken,
  });

  final String provider;
  final String firebaseIdToken;

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'firebase_id_token': firebaseIdToken,
  };

  @override
  List<Object?> get props => [provider, firebaseIdToken];
}
