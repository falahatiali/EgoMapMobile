import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/billing_repository.dart';
import '../models/billing_models.dart';

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  return BillingRepository(ref.watch(apiClientProvider));
});

final billingCatalogProvider = FutureProvider<BillingCatalog>((ref) async {
  return ref.watch(billingRepositoryProvider).fetchCatalog();
});

class BillingCheckoutController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<BillingCheckoutResult?> selectPlan(int planId) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(billingRepositoryProvider);
      final result = await repository.startCheckout(planId);
      await repository.assertCheckoutSuccess(result);
      state = const AsyncData(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> refreshCatalog() async {
    ref.invalidate(billingCatalogProvider);
    await ref.read(billingCatalogProvider.future);
  }
}

final billingCheckoutControllerProvider =
    NotifierProvider<BillingCheckoutController, AsyncValue<void>>(BillingCheckoutController.new);
