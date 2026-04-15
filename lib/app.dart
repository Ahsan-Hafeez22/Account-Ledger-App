import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:account_ledger/core/configs/app_config.dart';
import 'package:account_ledger/core/dependency_injection/service_locator.dart';
import 'package:account_ledger/core/service/notification_service.dart';
import 'package:account_ledger/core/system/app_system_ui.dart';
import 'package:account_ledger/core/theme/theme_cubit.dart';
import 'package:account_ledger/features/account/presentation/bloc/account_bloc.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:account_ledger/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:account_ledger/core/routes/app_router.dart';

class AccountLedger extends StatefulWidget {
  const AccountLedger({super.key});

  @override
  State<AccountLedger> createState() => _AccountLedgerState();
}

class _AccountLedgerState extends State<AccountLedger> with WidgetsBindingObserver {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authBloc = sl<AuthBloc>();
    _appRouter = AppRouter(authBloc: _authBloc);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      AppSystemUi.applyThemeMode(sl<ThemeCubit>().state);
      // Initialize notifications and request permission if disabled.
      try {
        await sl<NotificationService>().init(
          router: _appRouter.router,
          requestPermission: true,
        );
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When returning to foreground, reconcile once (covers background/offline cases)
    // without any periodic polling.
    if (state == AppLifecycleState.resumed) {
      try {
        sl<NotificationBloc>().add(const NotificationsRefreshRequested());
      } catch (_) {}
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (!mounted) return;
    if (sl<ThemeCubit>().state == ThemeMode.system) {
      AppSystemUi.applyThemeMode(ThemeMode.system);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _authBloc),
            BlocProvider.value(value: sl<ThemeCubit>()),
            BlocProvider(create: (_) => sl<AccountBloc>()),
            BlocProvider(create: (_) => sl<TransactionBloc>()),
            BlocProvider.value(value: sl<NotificationBloc>()),
          ],
          child: BlocListener<ThemeCubit, ThemeMode>(
            listenWhen: (prev, next) => prev != next,
            listener: (_, mode) => AppSystemUi.applyThemeMode(mode),
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              buildWhen: (prev, next) => prev != next,
              builder: (context, themeMode) {
                final overlay = AppSystemUi.overlayStyleForUiBrightness(
                  AppSystemUi.effectiveBrightness(themeMode),
                );
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: overlay,
                  child: MaterialApp.router(
                    title: 'Account Ledger',
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeMode,
                    debugShowCheckedModeBanner: false,
                    routerConfig: _appRouter.router,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
