import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/utils/external_url_launcher.dart';
import '../../../core/widgets/eg_flow_scaffold.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../../core/widgets/eg_surface.dart';
import '../models/billing_confirm_models.dart';
import '../providers/billing_provider.dart';

/// Opens Stripe in the system browser and syncs subscription status in-app.
class BillingCheckoutBrowserScreen extends ConsumerStatefulWidget {
  const BillingCheckoutBrowserScreen({super.key, required this.checkoutUrl});

  final String checkoutUrl;

  @override
  ConsumerState<BillingCheckoutBrowserScreen> createState() => _BillingCheckoutBrowserScreenState();
}

class _BillingCheckoutBrowserScreenState extends ConsumerState<BillingCheckoutBrowserScreen>
    with WidgetsBindingObserver {
  Timer? _pollTimer;
  var _browserOpened = false;
  var _checking = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openCheckout());
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkStatus(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatus(silent: true);
    }
  }

  Future<void> _openCheckout() async {
    final opened = await launchExternalUrl(Uri.parse(widget.checkoutUrl));

    if (!mounted) {
      return;
    }

    setState(() {
      _browserOpened = opened;
      if (!opened) {
        _statusMessage = 'Could not open checkout. Tap below to try again.';
      }
    });
  }

  Future<void> _checkStatus({required bool silent}) async {
    if (_checking || !mounted) {
      return;
    }

    setState(() {
      _checking = true;
      if (!silent) {
        _statusMessage = 'Checking subscription status…';
      }
    });

    final syncResult = await ref.read(billingCheckoutControllerProvider.notifier).syncAfterCheckout();

    if (!mounted) {
      return;
    }

    setState(() {
      _checking = false;
      if (syncResult.isPro) {
        _statusMessage = 'Pro is active.';
      } else if (!silent) {
        _statusMessage = 'Not active yet. Finish checkout, then check again.';
      }
    });

    if (syncResult.isPro) {
      context.pop(syncResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EgFlowScaffold(
      title: 'Checkout',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(EgSpacing.page, 16, EgSpacing.page, 32),
        children: [
          EgSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: EgColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.lock_rounded, color: EgColors.success),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Secure Stripe checkout',
                        style: EgFonts.style(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _browserOpened
                      ? 'Complete payment in your browser. This screen updates when Pro is active.'
                      : 'Tap below to open Stripe checkout.',
                  style: EgFonts.style(fontSize: 15, color: EgColors.slate400, height: 1.55),
                ),
                if (_statusMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _statusMessage!,
                    style: EgFonts.style(fontSize: 14, color: EgColors.slate500, height: 1.45),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          EgPrimaryButton(
            label: _browserOpened ? 'Reopen checkout' : 'Open checkout',
            onPressed: _openCheckout,
          ),
          const SizedBox(height: 12),
          EgPrimaryButton(
            label: 'I completed payment',
            loading: _checking,
            backgroundColor: EgColors.accent,
            onPressed: _checking ? null : () => _checkStatus(silent: false),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.pop(const BillingSyncResult(isPro: false, cancelled: true)),
            child: Text(
              'Cancel',
              style: EgFonts.style(color: EgColors.slate400, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
