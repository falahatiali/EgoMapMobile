bool isBillingCheckoutReturnUrl(Uri uri) {
  return uri.path.contains('billing/app-return');
}

bool isBillingCheckoutSuccess(Uri uri) {
  return isBillingCheckoutReturnUrl(uri) && uri.queryParameters['checkout'] == 'success';
}

bool isBillingCheckoutCancelled(Uri uri) {
  return isBillingCheckoutReturnUrl(uri) && uri.queryParameters['checkout'] == 'cancelled';
}

String? billingCheckoutSessionId(Uri uri) {
  final sessionId = uri.queryParameters['session_id'];

  if (sessionId == null || sessionId.isEmpty) {
    return null;
  }

  return sessionId;
}
