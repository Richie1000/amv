import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

// ── Screen imports ────────────────────────────────────────────────────────────
// import '../screens/auth/login_screen.dart';
// import '../screens/dashboard/dashboard_screen.dart';
// import '../screens/requests/requests_screen.dart';
// import '../screens/requests/request_detail_screen.dart';
// import '../screens/requests/create_request_screen.dart';
// import '../screens/suppliers/suppliers_screen.dart';
// import '../screens/followups/followups_screen.dart';
// import '../screens/history/history_screen.dart';

// ── Route paths ───────────────────────────────────────────────────────────────

abstract class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const requests = '/requests';
  static const suppliers = '/suppliers';
  static const followups = '/followups';
  static const history = '/history';
}

// ── Router factory ────────────────────────────────────────────────────────────

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

GoRouter createRouter(BuildContext context) {
  final auth = context.read<AuthProvider>();

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.dashboard,
    refreshListenable: auth,
    redirect: (context, state) {
      final onLogin = state.matchedLocation == AppRoutes.login;
      if (!auth.isAuthenticated && !onLogin) return AppRoutes.login;
      if (auth.isAuthenticated && onLogin) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const _Placeholder('Login'), // swap: LoginScreen()
      ),

      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, __) => const _Placeholder('Dashboard'),
          ),
          GoRoute(
            path: AppRoutes.requests,
            builder: (_, __) => const _Placeholder('Requests'),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootKey, // full-screen, no shell
                builder: (_, __) => const _Placeholder('Create Request'),
              ),
              GoRoute(
                path: ':id',
                builder: (_, s) =>
                    _Placeholder('Request · ${s.pathParameters['id']}'),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.suppliers,
            builder: (_, __) => const _Placeholder('Suppliers'),
          ),
          GoRoute(
            path: AppRoutes.followups,
            builder: (_, __) => const _Placeholder('Follow-ups'),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (_, __) => const _Placeholder('History'),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => _Placeholder('404 – ${state.error}'),
  );
}

// ── Shell (bottom nav) ────────────────────────────────────────────────────────

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    (
      icon: Icons.dashboard_outlined,
      label: 'Dashboard',
      path: AppRoutes.dashboard,
    ),
    (
      icon: Icons.swap_horiz_outlined,
      label: 'Requests',
      path: AppRoutes.requests,
    ),
    (
      icon: Icons.business_outlined,
      label: 'Suppliers',
      path: AppRoutes.suppliers,
    ),
    (
      icon: Icons.notifications_none,
      label: 'Follow-ups',
      path: AppRoutes.followups,
    ),
    (icon: Icons.history, label: 'History', path: AppRoutes.history),
  ];

  int _index(BuildContext ctx) {
    final loc = GoRouterState.of(ctx).matchedLocation;
    final i = _tabs.indexWhere((t) => loc.startsWith(t.path));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index(context),
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs
            .map(
              (t) => NavigationDestination(icon: Icon(t.icon), label: t.label),
            )
            .toList(),
      ),
    );
  }
}

// ── Placeholder – remove as real screens are added ────────────────────────────

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(label)),
    body: Center(child: Text(label)),
  );
}
