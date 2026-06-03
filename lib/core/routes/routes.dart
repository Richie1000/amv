import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../screens/app_shell.dart';
import '../../screens/create_request_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/request_detail_screen.dart';
import '../../screens/requests_screen.dart';

abstract class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const requests = '/requests';
  static const suppliers = '/suppliers';
  static const followups = '/followups';
  static const history = '/history';
}

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

GoRouter createRouter(BuildContext context) {
  final auth = context.read<AuthProvider>();

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.dashboard,
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final onAuth = loc == AppRoutes.login || loc == AppRoutes.register;
      if (!auth.isAuthenticated && !onAuth) return AppRoutes.login;
      if (auth.isAuthenticated && onAuth) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),

      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, __) => const _P('Dashboard'),
          ),
          GoRoute(
            path: AppRoutes.requests,
            builder: (_, __) => const RequestsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootKey,
                builder: (_, __) => const CreateRequestScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, s) =>
                    RequestDetailScreen(requestId: s.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.suppliers,
            builder: (_, __) => const _P('Suppliers'),
          ),
          GoRoute(
            path: AppRoutes.followups,
            builder: (_, __) => const _P('Follow-ups'),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (_, __) => const _P('History'),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => _P('404 – ${state.error}'),
  );
}

class _P extends StatelessWidget {
  const _P(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(label)),
    body: Center(child: Text(label)),
  );
}
