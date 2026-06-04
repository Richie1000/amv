import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../core/routes/routes.dart';

class PromoScreen extends StatefulWidget {
  const PromoScreen({super.key});

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _PromoPage(
      icon: Icons.swap_horiz_outlined,
      title: 'Route Requests\nCentralised',
      subtitle:
          'Track every SMS and Voice route request from creation to traffic confirmation — all in one place.',
    ),
    _PromoPage(
      icon: Icons.business_outlined,
      title: 'Supplier Rates\nat a Glance',
      subtitle:
          'Log supplier rates, compare against targets, and track selling rates with full history.',
    ),
    _PromoPage(
      icon: Icons.notifications_active_outlined,
      title: 'Never Miss\na Follow-up',
      subtitle:
          'Schedule reminders for customers and suppliers. Overdue follow-ups surface automatically.',
    ),
    _PromoPage(
      icon: Icons.history_outlined,
      title: 'Full Rate\nHistory',
      subtitle:
          'Search historical rates by country, operator, and route type. Data-driven decisions, every time.',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go(AppRoutes.login);
    }
  }

  void _skip() => context.go(AppRoutes.login);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _pages[i],
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.bgSubtle,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                );
              }),
            ),

            const SizedBox(height: AppSpacing.x3l),

            // CTA button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(isLast ? 'Get Started' : 'Next'),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.x3l),
          ],
        ),
      ),
    );
  }
}

class _PromoPage extends StatelessWidget {
  const _PromoPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, size: 44, color: AppColors.primary),
          ),

          const SizedBox(height: AppSpacing.x3l),

          Text(
            title,
            style: AppTextStyles.displayMedium.copyWith(height: 1.2),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
