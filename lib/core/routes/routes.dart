import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../screens/app_shell.dart';
import '../../screens/create_promotion_screen.dart';
import '../../screens/create_request_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/followup_screen.dart';
import '../../screens/history_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/promotions_screen.dart';
import '../../screens/promotion_detail_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/request_detail_screen.dart';
import '../../screens/requests_screen.dart';

abstract class AppRoutes {
  static const promo = '/promo';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const requests = '/requests';
  static const promotions = '/promotions';
  static const createPromotion = '/promotions/new';
  static const followups = '/followups';
  static const history = '/history';
}

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

GoRouter createRouter(BuildContext context) {
  final auth = context.read<AuthProvider>();

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.promo,
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final onAuth =
          loc == AppRoutes.login ||
          loc == AppRoutes.register ||
          loc == AppRoutes.promo;
      if (!auth.isAuthenticated && !onAuth) return AppRoutes.login;
      if (auth.isAuthenticated && onAuth) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.promo,
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const PromotionsScreen(),
      ),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),

      // Create promotion — full screen above shell
      GoRoute(
        path: AppRoutes.createPromotion,
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const CreatePromotionScreen(),
      ),

      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, __) => const DashboardScreen(),
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
            path: AppRoutes.promotions,
            builder: (_, __) => const PromotionsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, s) =>
                    PromotionDetailScreen(promotionId: s.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.followups,
            builder: (_, __) => const FollowupsScreen(),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (_, __) => const HistoryScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) =>
        Scaffold(body: Center(child: Text('404 – ${state.error}'))),
  );
}
