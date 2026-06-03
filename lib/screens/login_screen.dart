import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/routes/routes.dart';
import '../core/theme/responsive.dart';
import '../core/theme/theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthProvider>().signIn(_emailCtrl.text, _passCtrl.text);
    // Router redirect handles navigation on success
  }

  Future<void> _resetPassword() async {
    if (_emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter your email first.')));
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.resetPassword(_emailCtrl.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Reset link sent to ${_emailCtrl.text}'
              : auth.error ?? 'Failed to send reset link.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Responsive.isDesktop(context)
          ? _DesktopLayout(child: _buildForm())
          : _MobileLayout(child: _buildForm()),
    );
  }

  Widget _buildForm() {
    final auth = context.watch<AuthProvider>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sign in', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Enter your credentials to continue.',
            style: AppTextStyles.bodyMedium,
          ),

          const SizedBox(height: 32),

          // Email
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required.';
              if (!v.contains('@')) return 'Enter a valid email.';
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required.';
              if (v.length < 6) return 'At least 6 characters.';
              return null;
            },
          ),

          // Error banner
          if (auth.error != null) ...[
            const SizedBox(height: 12),
            AuthErrorBanner(message: auth.error!),
          ],

          const SizedBox(height: 24),

          // Sign in button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: auth.isLoading ? null : _submit,
              child: auth.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : const Text('Sign In'),
            ),
          ),

          const SizedBox(height: 12),

          // Forgot password
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: auth.isLoading ? null : _resetPassword,
              child: const Text('Forgot Password?'),
            ),
          ),

          const SizedBox(height: 24),

          // Register
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?", style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () {
                  auth.clearError();
                  context.go(AppRoutes.register);
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Layouts ───────────────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            color: AppColors.bgSurface,
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Logo(),
                const Spacer(),
                Text(
                  'Telecom route\noperations,\ncentralised.',
                  style: AppTextStyles.displayLarge.copyWith(height: 1.15),
                ),
                const SizedBox(height: 20),
                Text(
                  'Track SMS & Voice route requests, supplier rates,\nfollow-ups and traffic — faster than WhatsApp.',
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                ),
                const Spacer(),
                Row(
                  children: [
                    _Stat(label: 'SMS', value: 'EUR'),
                    const SizedBox(width: 32),
                    _Stat(label: 'Voice', value: 'USD'),
                    const SizedBox(width: 32),
                    _Stat(label: 'Routes', value: '∞'),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Center(child: SizedBox(width: 380, child: child)),
        ),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _Logo(small: true),
            const SizedBox(height: 40),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  const _Logo({this.small = false});
  final bool small;

  @override
  Widget build(BuildContext context) {
    final size = small ? 36.0 : 40.0;
    return Row(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            Icons.route,
            color: AppColors.textOnPrimary,
            size: small ? 20 : 22,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'RouteFlow',
          style: small
              ? AppTextStyles.headlineMedium
              : AppTextStyles.headlineLarge,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.monoLarge.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}

/// Shared across login and register screens
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
