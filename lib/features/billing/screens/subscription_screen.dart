import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_flow_scaffold.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../../core/widgets/eg_surface.dart';
import '../models/billing_confirm_models.dart';
import '../models/billing_models.dart';
import '../providers/billing_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> with WidgetsBindingObserver {
  int? _loadingPlanId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(billingCheckoutControllerProvider.notifier).refreshCatalog();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(billingCheckoutControllerProvider.notifier).refreshCatalog();
    }
  }

  Future<void> _selectPlan(BillingPlan plan) async {
    if (!plan.selectable || _loadingPlanId != null) {
      return;
    }

    setState(() => _loadingPlanId = plan.id);

    try {
      final result = await ref.read(billingCheckoutControllerProvider.notifier).selectPlan(plan.id);

      if (!mounted || result == null) {
        return;
      }

      if (result.isRedirect && result.checkoutUrl != null) {
        final syncResult = await context.push<BillingSyncResult>(
          AppRoutes.billingCheckout,
          extra: result.checkoutUrl,
        );

        if (!mounted) {
          return;
        }

        if (syncResult == null) {
          return;
        }

        await ref.read(billingCheckoutControllerProvider.notifier).refreshCatalog();

        if (syncResult.isPro) {
          _showSuccessDialog();
        } else if (syncResult.paymentCompleted) {
          _showMessage(
            'Payment received. Your Pro access should appear shortly — pull to refresh if needed.',
          );
        } else if (syncResult.cancelled) {
          _showMessage(
            ref.read(billingCatalogProvider).value?.labels.checkoutCancelled ??
                'Checkout cancelled. You can upgrade anytime.',
          );
        }

        return;
      }

      if (result.isChanged) {
        await ref.read(billingCheckoutControllerProvider.notifier).refreshCatalog();
        if (mounted) {
          _showMessage(result.body ?? result.title ?? 'Plan updated.');
        }
      }
    } on ApiException catch (error) {
      if (mounted) {
        _showMessage(error.message);
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Something went wrong. Please try again.');
        debugPrint('Billing checkout error: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _loadingPlanId = null);
      }
    }
  }

  void _showSuccessDialog() {
    final catalog = ref.read(billingCatalogProvider).value;
    final title = catalog?.labels.alreadyPro ?? 'Welcome to Pro.';
    final body = catalog?.subscription.currentPlan?.name != null
        ? 'Your ${catalog!.subscription.currentPlan!.name} plan is active.'
        : 'Your subscription is active. Full protocol unlocked.';

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: EgColors.navy900,
        title: Text(title, style: EgFonts.style(fontWeight: FontWeight.w700)),
        content: Text(body, style: EgFonts.style(color: EgColors.slate400, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(billingCatalogProvider);
    final checkoutState = ref.watch(billingCheckoutControllerProvider);

    return EgFlowScaffold(
      title: catalogAsync.value?.labels.pageTitle ?? 'Pro',
      body: catalogAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: EgColors.success),
        ),
        error: (error, _) => _ErrorState(
          message: error is ApiException ? error.message : 'Could not load plans.',
          onRetry: () => ref.read(billingCheckoutControllerProvider.notifier).refreshCatalog(),
        ),
        data: (catalog) => RefreshIndicator(
          color: EgColors.success,
          onRefresh: () => ref.read(billingCheckoutControllerProvider.notifier).refreshCatalog(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(EgSpacing.page, 8, EgSpacing.page, 32),
            children: [
              _HeroSection(catalog: catalog),
              const SizedBox(height: 24),
              if (catalog.subscription.isPro) ...[
                _ActiveProBanner(catalog: catalog),
                const SizedBox(height: 20),
              ],
              _CompareSection(catalog: catalog),
              const SizedBox(height: 24),
              if (catalog.plans.isEmpty)
                Text(
                  catalog.labels.emptyPlans,
                  style: EgFonts.style(color: EgColors.slate400, height: 1.5),
                )
              else ...[
                Text(
                  catalog.labels.proTitle,
                  style: EgFonts.style(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (catalog.proDescription != null)
                  Text(
                    catalog.proDescription!,
                    style: EgFonts.style(fontSize: 15, color: EgColors.slate400, height: 1.55),
                  ),
                const SizedBox(height: 16),
                ...catalog.plans.map(
                  (plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PlanCard(
                      plan: plan,
                      labels: catalog.labels,
                      loading: _loadingPlanId == plan.id || checkoutState.isLoading,
                      onSelect: () => _selectPlan(plan),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  catalog.labels.secureCheckout,
                  textAlign: TextAlign.center,
                  style: EgFonts.style(fontSize: 13, color: EgColors.slate500),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.catalog});

  final BillingCatalog catalog;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          catalog.labels.heroTitle,
          style: EgFonts.style(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        const SizedBox(height: 10),
        Text(
          catalog.labels.heroSubtitle,
          style: EgFonts.style(fontSize: 16, color: EgColors.slate400, height: 1.55),
        ),
      ],
    );
  }
}

class _ActiveProBanner extends StatelessWidget {
  const _ActiveProBanner({required this.catalog});

  final BillingCatalog catalog;

  @override
  Widget build(BuildContext context) {
    return EgSurface(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: EgColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: EgColors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  catalog.labels.alreadyPro,
                  style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                if (catalog.labels.activePlan != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    catalog.labels.activePlan!,
                    style: EgFonts.style(fontSize: 14, color: EgColors.slate400),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareSection extends StatelessWidget {
  const _CompareSection({required this.catalog});

  final BillingCatalog catalog;

  @override
  Widget build(BuildContext context) {
    return EgSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            catalog.labels.compareTitle,
            style: EgFonts.style(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            catalog.labels.compareSubtitle,
            style: EgFonts.style(fontSize: 14, color: EgColors.slate400, height: 1.5),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _FeatureColumn(title: catalog.labels.freeTitle, items: catalog.features.free)),
              const SizedBox(width: 16),
              Expanded(child: _FeatureColumn(title: catalog.labels.proTitle, items: catalog.features.pro, accent: true)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureColumn extends StatelessWidget {
  const _FeatureColumn({
    required this.title,
    required this.items,
    this.accent = false,
  });

  final String title;
  final List<String> items;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: EgFonts.style(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: accent ? EgColors.accent : EgColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: accent ? EgColors.success : EgColors.slate500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: EgFonts.style(fontSize: 13, color: EgColors.slate400, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.labels,
    required this.loading,
    required this.onSelect,
  });

  final BillingPlan plan;
  final BillingLabels labels;
  final bool loading;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final badgeLabel = switch (plan.badge) {
      'current' => labels.currentPlanBadge,
      'popular' => labels.popularBadge,
      'best_value' => labels.bestValueBadge,
      _ => null,
    };

    final highlighted = plan.badge == 'popular' || plan.badge == 'best_value';

    return Container(
      decoration: highlighted
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
              border: Border.all(color: EgColors.accent.withValues(alpha: 0.35)),
            )
          : null,
      child: EgSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badgeLabel != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: EgColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeLabel,
                  style: EgFonts.style(fontSize: 12, fontWeight: FontWeight.w700, color: EgColors.accent),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(plan.name, style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w800)),
            if (plan.price.formatted != null) ...[
              const SizedBox(height: 6),
              Text(
                plan.price.formatted!,
                style: EgFonts.style(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
            ],
            const SizedBox(height: 4),
            Text(plan.cadenceLabel, style: EgFonts.style(fontSize: 14, color: EgColors.slate400)),
            if (plan.savingsLabel != null) ...[
              const SizedBox(height: 8),
              Text(
                plan.savingsLabel!,
                style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w600, color: EgColors.success),
              ),
            ],
            const SizedBox(height: 16),
            EgPrimaryButton(
              label: plan.ctaLabel,
              loading: loading,
              onPressed: plan.selectable ? onSelect : null,
              backgroundColor: plan.isDowngrade ? EgColors.navy800 : EgColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(EgSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center, style: EgFonts.style(color: EgColors.slate400)),
            const SizedBox(height: 16),
            EgPrimaryButton(label: 'Try again', expanded: false, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
