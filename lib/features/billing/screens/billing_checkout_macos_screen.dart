import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/utils/billing_checkout_return.dart';
import '../../../core/widgets/eg_flow_scaffold.dart';
import '../models/billing_confirm_models.dart';
import '../providers/billing_provider.dart';

/// In-app Stripe checkout for macOS using a native WKWebView.
class BillingCheckoutMacosScreen extends ConsumerStatefulWidget {
  const BillingCheckoutMacosScreen({super.key, required this.checkoutUrl});

  final String checkoutUrl;

  @override
  ConsumerState<BillingCheckoutMacosScreen> createState() => _BillingCheckoutMacosScreenState();
}

class _BillingCheckoutMacosScreenState extends ConsumerState<BillingCheckoutMacosScreen> {
  MethodChannel? _channel;
  var _isLoadingPage = true;
  var _isActivating = false;
  var _handledReturn = false;
  String? _loadError;

  Future<void> _maybeHandleReturn(String? url) async {
    if (_handledReturn || _isActivating || url == null) {
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null || !isBillingCheckoutReturnUrl(uri)) {
      return;
    }

    _handledReturn = true;

    if (isBillingCheckoutCancelled(uri)) {
      if (mounted) {
        context.pop(const BillingSyncResult(isPro: false, cancelled: true));
      }

      return;
    }

    if (!isBillingCheckoutSuccess(uri)) {
      if (mounted) {
        context.pop(const BillingSyncResult(isPro: false, cancelled: true));
      }

      return;
    }

    if (mounted) {
      setState(() => _isActivating = true);
    }

    final syncResult = await ref.read(billingCheckoutControllerProvider.notifier).syncAfterCheckout(
          sessionId: billingCheckoutSessionId(uri),
        );

    if (!mounted) {
      return;
    }

    context.pop(syncResult);
  }

  Future<void> _onPlatformViewCreated(int id) async {
    final channel = MethodChannel('egomap/checkout_webview/$id');
    _channel = channel;

    channel.setMethodCallHandler((call) async {
      if (call.method == 'navigation') {
        final args = call.arguments as Map<dynamic, dynamic>?;
        final url = args?['url'] as String?;

        if (mounted) {
          setState(() {
            _isLoadingPage = false;
            _loadError = null;
          });
        }

        await _maybeHandleReturn(url);
        return;
      }

      if (call.method == 'loadError') {
        final args = call.arguments as Map<dynamic, dynamic>?;
        final message = args?['message'] as String? ?? 'Could not load checkout.';

        if (mounted) {
          setState(() {
            _isLoadingPage = false;
            _loadError = message;
          });
        }
      }
    });
  }

  Future<void> _retryLoad() async {
    setState(() {
      _isLoadingPage = true;
      _loadError = null;
    });

    await _channel?.invokeMethod('reload', widget.checkoutUrl);
  }

  @override
  Widget build(BuildContext context) {
    return EgFlowScaffold(
      title: 'Checkout',
      body: Stack(
        children: [
          if (_loadError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(EgSpacing.page),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Could not load checkout.',
                      style: EgFonts.style(fontSize: 18, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _loadError!,
                      style: EgFonts.style(color: EgColors.slate400, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _retryLoad,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            )
          else
            AppKitView(
              viewType: 'egomap/checkout-webview',
              creationParams: <String, dynamic>{'url': widget.checkoutUrl},
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: _onPlatformViewCreated,
            ),
          if (_isLoadingPage || _isActivating)
            ColoredBox(
              color: EgColors.navy950.withValues(alpha: 0.72),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: EgColors.success),
                    const SizedBox(height: 16),
                    Text(
                      _isActivating ? 'Activating your Pro plan…' : 'Loading secure checkout…',
                      style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
