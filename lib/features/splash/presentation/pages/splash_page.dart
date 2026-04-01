import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_strings.dart';
import 'package:account_ledger/core/dependency_injection/service_locator.dart';
import 'package:account_ledger/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:account_ledger/features/authentication/data/datasources/token_storage_datasource.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final tokenStorage = sl<TokenStorageDataSource>();
    // Capture bloc reference before navigating away (widget will unmount).
    final authBloc = context.read<AuthBloc>();

    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      if (mounted) context.go(RouteNames.login);
      return;
    }

    if (mounted) {
      context.go(RouteNames.dashboard);
    }

    // Source of truth: fetch latest user. If access token is expired, the
    // interceptor will refresh + retry automatically.
    try {
      final fresh = await sl<AuthRemoteDatasource>().getUser();
      authBloc.add(AuthUserLoaded(fresh.toEntity()));
    } catch (_) {
      // If the refresh token is also expired, the interceptor will trigger
      // onUnauthorized, which clears tokens+cache and the router redirects.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
