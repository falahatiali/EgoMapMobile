class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
    this.verificationRequired = false,
    this.verificationToken,
    this.email,
    this.remainingSeconds,
  });

  final String message;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;
  final bool verificationRequired;
  final String? verificationToken;
  final String? email;
  final int? remainingSeconds;

  String get displayMessage {
    if (fieldErrors.isNotEmpty) {
      return fieldErrors.values.first.first;
    }

    return message;
  }

  @override
  String toString() => displayMessage;
}
