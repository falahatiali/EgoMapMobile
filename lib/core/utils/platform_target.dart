import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

enum BillingCheckoutPlatform {
  browser,
  macosNative,
  mobileWebView,
}

BillingCheckoutPlatform get billingCheckoutPlatform {
  if (kIsWeb) {
    return BillingCheckoutPlatform.browser;
  }

  if (Platform.isMacOS) {
    return BillingCheckoutPlatform.macosNative;
  }

  if (Platform.isWindows || Platform.isLinux) {
    return BillingCheckoutPlatform.browser;
  }

  return BillingCheckoutPlatform.mobileWebView;
}
