import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/theme/eg_text.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_scaffold.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _remainingSeconds = ref.read(authControllerProvider).pendingVerification?.remainingSeconds ?? 0;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        setState(() => _remainingSeconds = 0);
        return;
      }

      setState(() => _remainingSeconds -= 1);
    });
  }

  String get _timerLabel {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _verify() async {
    final challenge = ref.read(authControllerProvider).pendingVerification;
    if (challenge == null) {
      return;
    }

    final code = _codeController.text.trim();

    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 4-digit code from your email.')),
      );
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).verifyEmail(
            verificationToken: challenge.verificationToken,
            code: code,
          );

      if (!mounted) {
        return;
      }

      context.go('/');
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.displayMessage)),
      );
    }
  }

  Future<void> _resend() async {
    final challenge = ref.read(authControllerProvider).pendingVerification;
    if (challenge == null || _remainingSeconds > 0) {
      return;
    }

    try {
      final seconds = await ref
          .read(authControllerProvider.notifier)
          .resendVerification(challenge.verificationToken);

      setState(() => _remainingSeconds = seconds);
      _startTimer();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new code was sent to your email.')),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.displayMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final challenge = auth.pendingVerification;

    if (challenge == null) {
      return AuthScaffold(
        title: 'Verification unavailable',
        subtitle: 'Start registration again to receive a new code.',
        child: EgPrimaryButton(
          label: 'Go to register',
          onPressed: () => context.go('/register'),
        ),
      );
    }

    return AuthScaffold(
      title: 'Check your email',
      subtitle: 'We sent a 4-digit code to ${challenge.email}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 4,
            autofocus: true,
            style: EgText.display(context).copyWith(letterSpacing: 12, fontSize: 28),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              counterText: '',
              hintText: '0000',
              hintStyle: TextStyle(color: EgColors.borderSubtle, letterSpacing: 12),
            ),
          ),
          const SizedBox(height: EgSpacing.sm),
          Text(
            _remainingSeconds > 0
                ? 'Expires in $_timerLabel'
                : 'Code expired. Request a new one.',
            style: EgText.caption(),
          ),
          const SizedBox(height: EgSpacing.lg),
          EgPrimaryButton(
            label: 'Verify & continue',
            loading: auth.isLoading,
            onPressed: _verify,
          ),
          const SizedBox(height: EgSpacing.sm),
          EgPrimaryButton(
            label: 'Send new code',
            expanded: true,
            onPressed: _remainingSeconds > 0 ? null : _resend,
          ),
        ],
      ),
    );
  }
}
