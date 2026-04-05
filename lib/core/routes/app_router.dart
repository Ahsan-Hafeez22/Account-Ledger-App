import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:account_ledger/features/authentication/presentation/pages/login_page.dart';
import 'package:account_ledger/features/authentication/presentation/pages/otp_verification_page.dart';
import 'package:account_ledger/features/authentication/presentation/pages/register_page.dart';
import 'package:account_ledger/features/authentication/presentation/pages/reset_password_page.dart';
import 'package:account_ledger/features/authentication/presentation/pages/security_page.dart';
import 'package:account_ledger/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:account_ledger/shared/app_bottom_navbar.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: RouteEndpoints.splash,
    redirect: _redirect,
    routes: [
      // Public Routes
      GoRoute(
        path: RouteEndpoints.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: RouteEndpoints.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: RouteEndpoints.register,
        builder: (_, __) => const RegisterPage(),
      ),

      // Persistent bottom nav scaffold routes
      GoRoute(
        path: RouteEndpoints.dashboard,
        builder: (_, __) => const BottomNavScaffold(initialIndex: 0),
      ),
      GoRoute(
        path: RouteEndpoints.transaction,
        builder: (_, __) => const BottomNavScaffold(initialIndex: 1),
      ),
      GoRoute(
        path: RouteEndpoints.account,
        builder: (_, __) => const BottomNavScaffold(initialIndex: 2),
      ),
      GoRoute(
        path: RouteEndpoints.setting,
        builder: (_, __) => const BottomNavScaffold(initialIndex: 3),
      ),

      // GoRoute(
      //   path: RouteEndpoints.forgotPassword,
      //   builder: (_, __) => const BottomNavScaffold(initialIndex: 3),
      // ),
      GoRoute(
        path: RouteEndpoints.forgotPassword,
        pageBuilder: (context, state) => fadeTransitionPage(
          title: 'Forgot Password',
          child: ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: RouteEndpoints.resetPassword,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String? ?? '';
          final resetToken = extra?['resetToken'] as String? ?? '';
          return fadeTransitionPage(
            title: 'Reset Password',
            child: ResetPasswordPage(email: email, resetToken: resetToken),
          );
        },
      ),
      GoRoute(
        path: RouteEndpoints.changePassword,
        pageBuilder: (context, state) {
          return fadeTransitionPage(
            title: 'Change Password',
            child: SecurityPage(),
          );
        },
      ),
      GoRoute(
        path: RouteEndpoints.otpVerification,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final bool comingFromSignUp = extra['signUp'] as bool? ?? false;
          final String email = extra['email'] as String? ?? '';

          return fadeTransitionPage(
            title: 'Verify OTP',
            child: OtpVerificationPage(
              comingFromSignUp: comingFromSignUp,
              email: email,
            ),
          );
        },
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = authBloc.state is AuthAuthenticated;
    final location = state.matchedLocation;

    // Routes that don't require authentication
    const publicRoutes = [
      RouteEndpoints.splash,
      RouteEndpoints.login,
      RouteEndpoints.register,
      RouteEndpoints.forgotPassword,
      RouteEndpoints.otpVerification,
      RouteEndpoints.resetPassword,
    ];

    // While splash is deciding, don't force redirects that cause flicker.
    if (location == RouteEndpoints.splash) {
      return null;
    }

    // Any non-[AuthAuthenticated] state cannot access protected routes
    if (!isAuthenticated && !publicRoutes.contains(location)) {
      return RouteEndpoints.login;
    }

    // Authenticated users should not stay on auth/onboarding screens
    if (isAuthenticated &&
        (location == RouteEndpoints.login ||
            location == RouteEndpoints.register ||
            location == RouteEndpoints.forgotPassword ||
            location == RouteEndpoints.otpVerification ||
            location == RouteEndpoints.resetPassword)) {
      return RouteEndpoints.dashboard;
    }

    return null;
  }
}

CustomTransitionPage<void> fadeTransitionPage({
  required Widget child,
  required String title,
}) {
  return CustomTransitionPage<void>(
    key: ValueKey(title),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
