import 'package:flutter/material.dart';

import '../../../core/utils/platform_target.dart';
import 'billing_checkout_browser_screen.dart';
import 'billing_checkout_macos_screen.dart';
import 'billing_checkout_mobile_screen.dart';

class BillingCheckoutScreen extends StatelessWidget {
  const BillingCheckoutScreen({super.key, required this.checkoutUrl});

  final String checkoutUrl;

  @override
  Widget build(BuildContext context) {
    return switch (billingCheckoutPlatform) {
      BillingCheckoutPlatform.browser => BillingCheckoutBrowserScreen(checkoutUrl: checkoutUrl),
      BillingCheckoutPlatform.macosNative => BillingCheckoutMacosScreen(checkoutUrl: checkoutUrl),
      BillingCheckoutPlatform.mobileWebView => BillingCheckoutMobileScreen(checkoutUrl: checkoutUrl),
    };
  }
}
