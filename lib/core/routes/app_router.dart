import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/features/authentication/presentation/pages/login_page.dart';
import 'package:account_ledger/features/authentication/presentation/pages/register_page.dart';
import 'package:account_ledger/features/splash/presentation/pages/splash_page.dart';
import 'package:account_ledger/shared/components/bottom_nav_bar.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    redirect: _redirect,
    routes: [
      GoRoute(path: RouteNames.splash, builder: (_, __) => const SplashPage()),
      // GoRoute(path: RouteNames.intro, builder: (_, __) => const IntroPage()),
      // GoRoute(
      //   path: RouteNames.onboarding,
      //   // builder: (_, __) => const OnboardingPage(),
      // ),
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginPage()),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => const RegisterPage(),
      ),
      ShellRoute(
        builder: (_, state, child) => _MainShell(state: state, child: child),
        routes: [
          // GoRoute(
          //   path: RouteNames.dashboard,
          //   builder: (_, __) => const DashboardPage(),
          // ),
          GoRoute(
            path: RouteNames.analytics,
            builder: (_, __) => const _PlaceholderPage(title: 'Analytics'),
          ),
          // GoRoute(
          //   path: RouteNames.addTransaction,
          //   builder: (_, __) => const AddTransactionPage(),
          // ),
          GoRoute(
            path: RouteNames.transactionList,
            builder: (_, __) => const _PlaceholderPage(title: 'Transactions'),
          ),
          // GoRoute(
          //   path: RouteNames.profile,
          //   builder: (_, __) => const ProfilePage(),
          // ),
        ],
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = authBloc.state is AuthAuthenticated;
    final location = state.matchedLocation;

    const publicRoutes = [
      RouteNames.splash,
      RouteNames.intro,
      RouteNames.onboarding,
      RouteNames.login,
      RouteNames.register,
      RouteNames.dashboard,
      RouteNames.addTransaction,
      RouteNames.profile,
      RouteNames.analytics,
      RouteNames.transactionList,
    ];

    if (!isAuthenticated && !publicRoutes.contains(location))
      return RouteNames.login;
    if (isAuthenticated &&
        (location == RouteNames.login || location == RouteNames.register)) {
      return RouteNames.dashboard;
    }
    return null;
  }
}

// ── Shell ──────────────────────────────────────────────────────────────────────

class _MainShell extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const _MainShell({required this.state, required this.child});

  static const _routes = [
    RouteNames.dashboard,
    RouteNames.analytics,
    RouteNames.addTransaction,
    RouteNames.transactionList,
    RouteNames.profile,
  ];

  int get _currentIndex {
    final location = state.matchedLocation;
    final index = _routes.indexWhere(location.startsWith);
    return index == -1 ? 0 : index;
  }

  void _onTap(BuildContext context, int index) {
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}

// ── Placeholder ────────────────────────────────────────────────────────────────

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
