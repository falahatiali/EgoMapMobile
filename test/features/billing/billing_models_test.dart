import 'package:flutter_test/flutter_test.dart';

import 'package:egomap_mobile/features/billing/models/billing_models.dart';

void main() {
  test('BillingCatalog parses subscription and plans', () {
    final catalog = BillingCatalog.fromJson({
      'subscription': {
        'active': false,
        'is_pro': false,
        'has_incomplete_payment': false,
        'current_plan': null,
      },
      'plans': [
        {
          'id': 1,
          'billing_period': 'monthly',
          'name': 'Monthly',
          'price': {'formatted': '\$9.99', 'unit_amount': 999, 'currency': 'USD'},
          'cadence_label': 'Billed monthly',
          'relation': null,
          'cta_label': 'Get Pro',
          'selectable': true,
        },
      ],
      'features': {
        'free': ['Basic check-in'],
        'pro': ['AI coach'],
      },
      'labels': {
        'page_title': 'Pricing',
        'hero_title': 'Invest',
        'hero_subtitle': 'Start free',
        'free_title': 'Free',
        'free_price': '\$0',
        'free_interval': 'forever',
        'pro_title': 'Pro',
        'already_pro': 'Already Pro',
        'already_subscribed': 'Subscribed',
        'compare_title': 'Compare',
        'compare_subtitle': 'Free vs Pro',
        'empty_plans': 'No plans',
        'secure_checkout': 'Stripe',
        'checkout_cancelled': 'Cancelled',
        'current_plan_badge': 'Current',
        'popular_badge': 'Popular',
        'best_value_badge': 'Best value',
        'return_to_app_hint': 'Return to app',
      },
    });

    expect(catalog.subscription.isPro, isFalse);
    expect(catalog.plans, hasLength(1));
    expect(catalog.plans.first.price.formatted, '\$9.99');
    expect(catalog.features.pro, ['AI coach']);
  });

  test('BillingCheckoutResult parses redirect without labels object', () {
    final result = BillingCheckoutResult.fromJson({
      'outcome': 'redirect',
      'checkout_url': 'https://checkout.stripe.com/test',
      'labels': [],
    });

    expect(result.isRedirect, isTrue);
    expect(result.checkoutUrl, 'https://checkout.stripe.com/test');
  });
}
