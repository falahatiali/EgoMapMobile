import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/models/auth_models.dart';
import '../../features/auth/providers/auth_controller.dart';
import '../../features/billing/models/billing_models.dart';
import '../../features/billing/providers/billing_provider.dart';
import '../navigation/app_routes.dart';
import '../theme/eg_colors.dart';
import '../theme/eg_fonts.dart';
import '../theme/eg_spacing.dart';

/// Persistent shell header: user identity + live subscription status.
class AppSubscriptionHeader extends ConsumerStatefulWidget {
  const AppSubscriptionHeader({
    super.key,
    required this.pageTitle,
    required this.pageSubtitle,
  });

  final String pageTitle;
  final String pageSubtitle;

  @override
  ConsumerState<AppSubscriptionHeader> createState() => _AppSubscriptionHeaderState();
}

class _AppSubscriptionHeaderState extends ConsumerState<AppSubscriptionHeader> {
  var _billingRefreshScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleBillingRefresh();
  }

  void _scheduleBillingRefresh() {
    if (_billingRefreshScheduled) {
      return;
    }

    _billingRefreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _billingRefreshScheduled = false;
      final auth = ref.read(authControllerProvider);
      if (auth.isAuthenticated) {
        ref.read(billingCheckoutControllerProvider.notifier).refreshCatalog();
      }
    });
  }

  void _openSubscriptionOrAuth(BuildContext context, bool isAuthenticated) {
    if (isAuthenticated) {
      context.push(AppRoutes.subscription);
      return;
    }

    context.push(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final billingAsync = ref.watch(billingCatalogProvider);
    final user = auth.user;

    return Padding(
      padding: const EdgeInsets.fromLTRB(EgSpacing.page, 10, EgSpacing.page, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  EgColors.accent.withValues(alpha: 0.55),
                  EgColors.success.withValues(alpha: 0.35),
                  EgColors.accentBright.withValues(alpha: 0.2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: EgColors.accent.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.2),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: EgColors.navy900.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openSubscriptionOrAuth(context, auth.isAuthenticated),
                    borderRadius: BorderRadius.circular(21),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: user != null
                          ? _AuthenticatedHeaderRow(
                              user: user,
                              billingAsync: billingAsync,
                              onSubscriptionTap: () => context.push(AppRoutes.subscription),
                            )
                          : _GuestHeaderRow(
                              onSignIn: () => context.push(AppRoutes.login),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.pageTitle,
            style: EgFonts.style(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.45),
          ),
          const SizedBox(height: 4),
          Text(
            widget.pageSubtitle,
            style: EgFonts.style(fontSize: 15, height: 1.4, color: EgColors.slate400),
          ),
        ],
      ),
    );
  }
}

class _AuthenticatedHeaderRow extends StatelessWidget {
  const _AuthenticatedHeaderRow({
    required this.user,
    required this.billingAsync,
    required this.onSubscriptionTap,
  });

  final UserModel user;
  final AsyncValue<BillingCatalog> billingAsync;
  final VoidCallback onSubscriptionTap;

  @override
  Widget build(BuildContext context) {
    final catalog = billingAsync.value;
    final isPro = catalog?.subscription.isPro ?? false;
    final planName = catalog?.subscription.currentPlan?.name;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return Row(
      children: [
        _AvatarBadge(initial: initial, isPro: isPro),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: EgFonts.style(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.2),
              ),
              const SizedBox(height: 3),
              Text(
                user.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: EgFonts.style(fontSize: 13, color: EgColors.slate400),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _SubscriptionStatusChip(
          isLoading: billingAsync.isLoading && catalog == null,
          isPro: isPro,
          planName: planName,
          proTitle: catalog?.labels.proTitle ?? 'Pro',
          onTap: onSubscriptionTap,
        ),
      ],
    );
  }
}

class _GuestHeaderRow extends StatelessWidget {
  const _GuestHeaderRow({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                EgColors.success.withValues(alpha: 0.22),
                EgColors.accent.withValues(alpha: 0.16),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: EgColors.borderSubtle),
          ),
          child: const Icon(Icons.bolt_rounded, color: EgColors.success, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EgoMap',
                style: EgFonts.style(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.2),
              ),
              const SizedBox(height: 3),
              Text(
                'Sign in to unlock missions & Pro',
                style: EgFonts.style(fontSize: 13, color: EgColors.slate400),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onSignIn,
          style: TextButton.styleFrom(
            foregroundColor: EgColors.textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          child: Text(
            'Sign in',
            style: EgFonts.style(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.initial, required this.isPro});

  final String initial;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final ringColor = isPro ? EgColors.warning : EgColors.success;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            ringColor.withValues(alpha: 0.85),
            EgColors.accent.withValues(alpha: 0.55),
          ],
        ),
      ),
      child: CircleAvatar(
        radius: 21,
        backgroundColor: EgColors.navy800,
        child: Text(
          initial,
          style: EgFonts.style(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isPro ? EgColors.warning : EgColors.success,
          ),
        ),
      ),
    );
  }
}

class _SubscriptionStatusChip extends StatelessWidget {
  const _SubscriptionStatusChip({
    required this.isLoading,
    required this.isPro,
    required this.planName,
    required this.proTitle,
    required this.onTap,
  });

  final bool isLoading;
  final bool isPro;
  final String? planName;
  final String proTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            gradient: isPro
                ? null
                : LinearGradient(
                    colors: [
                      EgColors.accent,
                      EgColors.accentBright,
                    ],
                  ),
            color: isPro ? EgColors.success.withValues(alpha: 0.12) : null,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isPro ? EgColors.success.withValues(alpha: 0.45) : Colors.transparent,
            ),
            boxShadow: isPro
                ? null
                : [
                    BoxShadow(
                      color: EgColors.accent.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPro ? Icons.verified_rounded : Icons.workspace_premium_rounded,
                      size: 16,
                      color: isPro ? EgColors.success : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isPro ? (planName ?? proTitle) : 'Upgrade',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: EgFonts.style(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isPro ? EgColors.success : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
