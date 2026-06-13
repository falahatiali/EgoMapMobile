import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/utils/billing_checkout_return.dart';
import '../../../core/widgets/eg_flow_scaffold.dart';
import '../models/billing_confirm_models.dart';
import '../providers/billing_provider.dart';

/// In-app Stripe checkout for iOS and Android.
class BillingCheckoutMobileScreen extends ConsumerStatefulWidget {
  const BillingCheckoutMobileScreen({super.key, required this.checkoutUrl});

  final String checkoutUrl;

  @override
  ConsumerState<BillingCheckoutMobileScreen> createState() => _BillingCheckoutMobileScreenState();
}

class _BillingCheckoutMobileScreenState extends ConsumerState<BillingCheckoutMobileScreen> {
  WebViewController? _webViewController;
  var _isLoadingPage = true;
  var _isActivating = false;
  var _handledReturn = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) {
              return;
            }

            setState(() {
              _isLoadingPage = true;
              _loadError = null;
            });
          },
          onPageFinished: (url) async {
            if (!mounted) {
              return;
            }

            setState(() => _isLoadingPage = false);
            await _maybeHandleReturn(url);
          },
          onWebResourceError: (error) {
            if (!mounted) {
              return;
            }

            setState(() {
              _isLoadingPage = false;
              _loadError = error.description;
            });
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);

            if (uri != null && isBillingCheckoutReturnUrl(uri)) {
              unawaited(_maybeHandleReturn(request.url));
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));

    _webViewController = controller;
  }

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

  @override
  Widget build(BuildContext context) {
    final controller = _webViewController;

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
                      onPressed: () => controller?.loadRequest(Uri.parse(widget.checkoutUrl)),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            )
          else if (controller != null)
            WebViewWidget(controller: controller),
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
