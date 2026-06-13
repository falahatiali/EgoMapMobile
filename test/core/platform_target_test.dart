import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';

import 'package:egomap_mobile/core/utils/platform_target.dart';

void main() {
  test('billingCheckoutPlatform matches host operating system', () {
    if (Platform.isIOS || Platform.isAndroid) {
      expect(billingCheckoutPlatform, BillingCheckoutPlatform.mobileWebView);
      return;
    }

    if (Platform.isMacOS) {
      expect(billingCheckoutPlatform, BillingCheckoutPlatform.macosNative);
      return;
    }

    expect(billingCheckoutPlatform, BillingCheckoutPlatform.browser);
  });
}
