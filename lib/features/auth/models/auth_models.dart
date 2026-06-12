class UserModel {
  const UserModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.email,
    required this.emailVerified,
  });

  final int id;
  final String uuid;
  final String name;
  final String email;
  final bool emailVerified;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num).toInt(),
      uuid: json['uuid'] as String,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : json['email'] as String,
      email: json['email'] as String,
      emailVerified: json['email_verified'] as bool? ?? false,
    );
  }
}

class VerificationChallenge {
  const VerificationChallenge({
    required this.email,
    required this.verificationToken,
    required this.remainingSeconds,
    required this.message,
  });

  final String email;
  final String verificationToken;
  final int remainingSeconds;
  final String message;

  factory VerificationChallenge.fromJson(Map<String, dynamic> json) {
    return VerificationChallenge(
      email: json['email'] as String,
      verificationToken: json['verification_token'] as String,
      remainingSeconds: json['remaining_seconds'] as int? ?? 0,
      message: json['message'] as String? ?? 'Please verify your email.',
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
  });

  final String token;
  final UserModel user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
