import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/features/authentication/presentation/pages/login_page.dart';
import 'package:account_ledger/features/authentication/presentation/pages/register_page.dart';
import 'package:account_ledger/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:account_ledger/shared/app_bottom_navbar.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    redirect: _redirect,
    routes: [
      // Public Routes
      GoRoute(path: RouteNames.splash, builder: (_, __) => const SplashPage()),
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginPage()),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => const RegisterPage(),
      ),

      // Persistent bottom nav scaffold routes
      GoRoute(
        path: RouteNames.dashboard,
        builder: (_, __) => const BottomNavScaffold(initialIndex: 0),
      ),
      GoRoute(
        path: RouteNames.transaction,
        builder: (_, __) => const BottomNavScaffold(initialIndex: 1),
      ),
      GoRoute(
        path: RouteNames.account,
        builder: (_, __) => const BottomNavScaffold(initialIndex: 2),
      ),
      GoRoute(
        path: RouteNames.setting,
        builder: (_, __) => const BottomNavScaffold(initialIndex: 3),
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = authBloc.state is AuthAuthenticated;
    final isUnauthenticated = authBloc.state is AuthUnauthenticated;
    final location = state.matchedLocation;

    // Routes that don't require authentication
    const publicRoutes = [
      RouteNames.splash,
      RouteNames.login,
      RouteNames.register,
    ];

    // While splash is deciding, don't force redirects that cause flicker.
    if (location == RouteNames.splash) {
      return null;
    }

    // If user is not authenticated and trying to access protected route
    if (isUnauthenticated && !publicRoutes.contains(location)) {
      return RouteNames.login;
    }

    // If user is authenticated and tries to go to login/register
    if (isAuthenticated &&
        (location == RouteNames.login || location == RouteNames.register)) {
      return RouteNames.dashboard;
    }

    return null;
  }
}
