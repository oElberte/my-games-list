import 'package:equatable/equatable.dart';

/// Request model for social authentication (Google/Apple).
class SocialAuthRequest extends Equatable {
  const SocialAuthRequest({
    required this.provider,
    required this.firebaseIdToken,
    required this.consentVersion,
  });

  final String provider;
  final String firebaseIdToken;

  /// Version of the Privacy Policy / Terms the user accepted. Required by the
  /// API (`consent_version`, binding:"required") on social auth as well.
  final String consentVersion;

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'firebase_id_token': firebaseIdToken,
    'consent_version': consentVersion,
  };

  @override
  List<Object?> get props => [provider, firebaseIdToken, consentVersion];
}
