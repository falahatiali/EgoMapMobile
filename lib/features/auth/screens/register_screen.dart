import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../home/providers/bootstrap_provider.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_scaffold.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/verify-email');
        }
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.displayMessage)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final copy = ref.watch(bootstrapProvider).maybeWhen(
          data: (data) => data.auth,
          orElse: () => null,
        );

    return AuthScaffold(
      title: copy?.registerTitle ?? 'Create your account',
      subtitle: copy?.registerSubtitle ?? 'Save your results and unlock more tests.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required.';
                }

                return null;
              },
            ),
            const SizedBox(height: EgSpacing.md),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'At least 8 characters',
              ),
              validator: (value) {
                if (value == null || value.length < 8) {
                  return 'Use at least 8 characters.';
                }

                return null;
              },
            ),
            const SizedBox(height: EgSpacing.lg),
            EgPrimaryButton(
              label: 'Create account',
              loading: auth.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
      footer: Center(
        child: TextButton(
          onPressed: () => context.pop(),
          child: const Text('Already have an account? Sign in'),
        ),
      ),
    );
  }
}
