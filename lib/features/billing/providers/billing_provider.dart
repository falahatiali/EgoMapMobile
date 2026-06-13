import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/billing_repository.dart';
import '../models/billing_confirm_models.dart';
import '../models/billing_models.dart';

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  return BillingRepository(ref.watch(apiClientProvider));
});

final billingCatalogProvider = AsyncNotifierProvider<BillingCatalogNotifier, BillingCatalog>(
  BillingCatalogNotifier.new,
);

class BillingCatalogNotifier extends AsyncNotifier<BillingCatalog> {
  @override
  Future<BillingCatalog> build() async {
    return ref.read(billingRepositoryProvider).fetchCatalog();
  }

  Future<BillingCatalog> refreshCatalog() async {
    final catalog = await ref.read(billingRepositoryProvider).fetchCatalog();
    state = AsyncData(catalog);
    return catalog;
  }
}

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

  Future<BillingCatalog> refreshCatalog() {
    return ref.read(billingCatalogProvider.notifier).refreshCatalog();
  }

  /// Confirms the Stripe session when available, then polls billing until Pro is active.
  Future<BillingSyncResult> syncAfterCheckout({String? sessionId}) async {
    BillingConfirmResult? confirmResult;

    if (sessionId != null && sessionId.isNotEmpty) {
      try {
        confirmResult = await ref.read(billingRepositoryProvider).confirmCheckout(sessionId);
      } catch (_) {
        // Webhook may already have synced; keep polling catalog below.
      }
    }

    for (var attempt = 0; attempt < 12; attempt++) {
      try {
        final catalog = await ref.read(billingCatalogProvider.notifier).refreshCatalog();

        if (catalog.subscription.isPro) {
          return BillingSyncResult(
            isPro: true,
            paymentCompleted: true,
            confirmResult: confirmResult,
            catalog: catalog,
          );
        }
      } catch (_) {
        // Retry on transient API errors.
      }

      if (attempt < 11) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    try {
      final catalog = await ref.read(billingCatalogProvider.notifier).refreshCatalog();

      return BillingSyncResult(
        isPro: catalog.subscription.isPro,
        paymentCompleted: sessionId != null && sessionId.isNotEmpty,
        confirmResult: confirmResult,
        catalog: catalog,
      );
    } catch (_) {
      return BillingSyncResult(
        isPro: confirmResult?.subscription.isPro ?? false,
        paymentCompleted: sessionId != null && sessionId.isNotEmpty,
        confirmResult: confirmResult,
      );
    }
  }
}

final billingCheckoutControllerProvider =
    NotifierProvider<BillingCheckoutController, AsyncValue<void>>(BillingCheckoutController.new);
