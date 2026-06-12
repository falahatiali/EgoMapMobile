import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../home/providers/bootstrap_provider.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
      final challenge = await ref.read(authControllerProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        if (challenge != null) {
          context.go('/verify-email');
          return;
        }

        context.go('/');
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
        SnackBar(content: Text('Sign in failed: $error')),
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
      title: copy?.loginTitle ?? 'Welcome back',
      subtitle: copy?.loginSubtitle ?? 'Sign in with your email and password.',
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

                if (!value.contains('@')) {
                  return 'Enter a valid email.';
                }

                return null;
              },
            ),
            const SizedBox(height: EgSpacing.md),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required.';
                }

                return null;
              },
            ),
            const SizedBox(height: EgSpacing.lg),
            EgPrimaryButton(
              label: 'Sign in',
              loading: auth.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
      footer: Center(
        child: TextButton(
          onPressed: () => context.push('/register'),
          child: const Text('No account yet? Create one'),
        ),
      ),
    );
  }
}
