import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/routes/routes.dart';
import '../core/theme/responsive.dart';
import '../core/theme/theme.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(_emailCtrl.text, _passwordCtrl.text);
    // Router redirect handles navigation on success
    if (!success && mounted) {
      // Error is shown inline via auth.error
    }
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
          Text('Create account', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Set up your RouteFlow account.',
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
            controller: _passwordCtrl,
            obscureText: _obscurePass,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required.';
              if (v.length < 6) return 'At least 6 characters.';
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Confirm password
          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty)
                return 'Please confirm your password.';
              if (v != _passwordCtrl.text) return 'Passwords do not match.';
              return null;
            },
          ),

          // Error banner
          if (auth.error != null) ...[
            const SizedBox(height: 12),
            _ErrorBanner(message: auth.error!),
          ],

          const SizedBox(height: 24),

          // Register button
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
                  : const Text('Create Account'),
            ),
          ),

          const SizedBox(height: 16),

          // Back to login
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Already have an account?',
                  style: AppTextStyles.bodyMedium,
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Sign in'),
                ),
              ],
            ),
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
        // Left branding panel
        Expanded(
          flex: 5,
          child: Container(
            color: AppColors.bgSurface,
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.route,
                        color: AppColors.textOnPrimary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('RouteFlow', style: AppTextStyles.headlineLarge),
                  ],
                ),
                const Spacer(),
                Text(
                  'One platform.\nEvery route.',
                  style: AppTextStyles.displayLarge.copyWith(height: 1.15),
                ),
                const SizedBox(height: 20),
                Text(
                  'SMS and Voice routes managed in one place.\nNo more spreadsheets. No more missed follow-ups.',
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),

        // Right form panel
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
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.route,
                    color: AppColors.textOnPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text('RouteFlow', style: AppTextStyles.headlineMedium),
              ],
            ),
            const SizedBox(height: 40),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Shared error banner ───────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
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
