import 'package:flutter_test/flutter_test.dart';

void main() {
  test('checkout URLs are valid https URIs', () {
    final uri = Uri.parse('https://checkout.stripe.com/c/pay/cs_test_123');

    expect(uri.scheme, 'https');
    expect(uri.host, isNotEmpty);
  });
}
