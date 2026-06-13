import 'package:flutter_test/flutter_test.dart';

import 'package:egomap_mobile/core/utils/billing_checkout_return.dart';

void main() {
  test('detects billing checkout success return url', () {
    final uri = Uri.parse(
      'https://egomap.test/billing/app-return?checkout=success&session_id=cs_test_123',
    );

    expect(isBillingCheckoutReturnUrl(uri), isTrue);
    expect(isBillingCheckoutSuccess(uri), isTrue);
    expect(isBillingCheckoutCancelled(uri), isFalse);
    expect(billingCheckoutSessionId(uri), 'cs_test_123');
  });

  test('detects billing checkout cancelled return url', () {
    final uri = Uri.parse('https://egomap.test/billing/app-return?checkout=cancelled');

    expect(isBillingCheckoutCancelled(uri), isTrue);
    expect(isBillingCheckoutSuccess(uri), isFalse);
    expect(billingCheckoutSessionId(uri), isNull);
  });
}
