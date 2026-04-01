import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/features/authentication/presentation/pages/login_page.dart';
import 'package:account_ledger/features/authentication/presentation/pages/register_page.dart';
import 'package:account_ledger/features/dashboard/presentation/pages/dashboard_page.dart';
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

      // Shell Route with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) =>
            _MainShell(state: state, child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            builder: (_, __) => const DashboardPage(),
          ),
          GoRoute(
            path: RouteNames.transaction,
            builder: (_, __) => const _PlaceholderPage(title: 'Transactions'),
          ),
          GoRoute(
            path: RouteNames.account,
            builder: (_, __) => const _PlaceholderPage(title: 'Accounts'),
          ),
          GoRoute(
            path: RouteNames.setting,
            builder: (_, __) => const _PlaceholderPage(title: 'Settings'),
          ),
        ],
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

// ──────────────────────────────────────────────────────────────
// Main Shell with Bottom Navigation
// ──────────────────────────────────────────────────────────────

class _MainShell extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const _MainShell({required this.state, required this.child});

  static const List<String> _navRoutes = [
    RouteNames.dashboard,
    RouteNames.transaction,
    RouteNames.account,
    RouteNames.setting,
  ];

  int get _currentIndex {
    final location = state.matchedLocation;
    final index = _navRoutes.indexWhere((route) => location.startsWith(route));
    return index == -1 ? 0 : index;
  }

  void _onTabTapped(BuildContext context, int index) {
    if (index == _currentIndex) return; // Avoid unnecessary navigation
    context.go(_navRoutes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTabChanged: (index) => _onTabTapped(context, index),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Placeholder Page (for routes under development)
// ──────────────────────────────────────────────────────────────

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '$title Page',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Under Development',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
