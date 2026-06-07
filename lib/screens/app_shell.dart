import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/routes/routes.dart';
import '../core/theme/responsive.dart';
import '../core/theme/theme.dart';
import '../providers/auth_provider.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    (
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      path: AppRoutes.dashboard,
    ),
    (
      icon: Icons.swap_horiz_outlined,
      activeIcon: Icons.swap_horiz,
      label: 'Requests',
      path: AppRoutes.requests,
    ),
    (
      icon: Icons.campaign_outlined,
      activeIcon: Icons.campaign,
      label: 'Promotions',
      path: AppRoutes.promotions,
    ),
    (
      icon: Icons.notifications_none,
      activeIcon: Icons.notifications,
      label: 'Follow-ups',
      path: AppRoutes.followups,
    ),
    (
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
      label: 'History',
      path: AppRoutes.history,
    ),
  ];

  int _index(BuildContext ctx) {
    final loc = GoRouterState.of(ctx).matchedLocation;
    final i = _tabs.indexWhere((t) => loc.startsWith(t.path));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    return Responsive.showSideNav(context)
        ? _DesktopShell(
            child: child,
            tabs: _tabs,
            currentIndex: _index(context),
          )
        : _MobileShell(
            child: child,
            tabs: _tabs,
            currentIndex: _index(context),
          );
  }
}

// ── Desktop shell — permanent side nav ───────────────────────────────────────

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.child,
    required this.tabs,
    required this.currentIndex,
  });

  final Widget child;
  final List<({IconData icon, IconData activeIcon, String label, String path})>
  tabs;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _SideNav(tabs: tabs, currentIndex: currentIndex),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({required this.tabs, required this.currentIndex});

  final List<({IconData icon, IconData activeIcon, String label, String path})>
  tabs;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Container(
      width: 220,
      color: AppColors.bgSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo / app name
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.route,
                    color: AppColors.textOnPrimary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text('RouteFlow', style: AppTextStyles.headlineSmall),
              ],
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 8),

          // Nav items
          ...List.generate(tabs.length, (i) {
            final tab = tabs[i];
            final selected = i == currentIndex;
            return _SideNavItem(
              icon: selected ? tab.activeIcon : tab.icon,
              label: tab.label,
              selected: selected,
              onTap: () => context.go(tab.path),
            );
          }),

          const Spacer(),
          const Divider(height: 1),

          // Sign out
          _SideNavItem(
            icon: Icons.logout,
            label: 'Sign Out',
            selected: false,
            onTap: () => auth.signOut(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: selected ? AppColors.primaryMuted : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mobile shell — bottom nav ─────────────────────────────────────────────────

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.child,
    required this.tabs,
    required this.currentIndex,
  });

  final Widget child;
  final List<({IconData icon, IconData activeIcon, String label, String path})>
  tabs;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(tabs[i].path),
        destinations: tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.activeIcon),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
