import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../models/billing_confirm_models.dart';
import '../models/billing_models.dart';

class BillingRepository {
  BillingRepository(this._client);

  final ApiClient _client;

  Future<BillingCatalog> fetchCatalog() async {
    final json = await _client.get('/billing');
    return BillingCatalog.fromJson(json);
  }

  Future<BillingCheckoutResult> startCheckout(int planId) async {
    final json = await _client.post('/billing/checkout', data: {'plan_id': planId});
    return BillingCheckoutResult.fromJson(json);
  }

  Future<BillingConfirmResult> confirmCheckout(String sessionId) async {
    final json = await _client.post('/billing/checkout/confirm', data: {'session_id': sessionId});

    return BillingConfirmResult.fromJson(json);
  }

  Future<void> assertCheckoutSuccess(BillingCheckoutResult result) async {
    if (result.isError) {
      throw ApiException(
        message: result.message ?? result.title ?? 'Checkout failed.',
        statusCode: 422,
      );
    }

    if (result.isCurrent) {
      throw ApiException(
        message: result.message ?? result.title ?? 'You are already on this plan.',
        statusCode: 409,
      );
    }
  }
}
