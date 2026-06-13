import 'billing_models.dart';

class BillingConfirmResult {
  const BillingConfirmResult({
    required this.confirmed,
    required this.subscription,
    this.title,
    this.body,
  });

  factory BillingConfirmResult.fromJson(Map<String, dynamic> json) {
    return BillingConfirmResult(
      confirmed: json['confirmed'] == true,
      subscription: BillingSubscription.fromJson(
        json['subscription'] as Map<String, dynamic>? ?? const {},
      ),
      title: json['labels'] is Map ? (json['labels'] as Map)['title'] as String? : null,
      body: json['labels'] is Map ? (json['labels'] as Map)['body'] as String? : null,
    );
  }

  final bool confirmed;
  final BillingSubscription subscription;
  final String? title;
  final String? body;
}

class BillingSyncResult {
  const BillingSyncResult({
    required this.isPro,
    this.cancelled = false,
    this.paymentCompleted = false,
    this.confirmResult,
    this.catalog,
  });

  final bool isPro;
  final bool cancelled;
  final bool paymentCompleted;
  final BillingConfirmResult? confirmResult;
  final BillingCatalog? catalog;
}
