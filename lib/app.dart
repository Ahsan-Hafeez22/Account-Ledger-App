import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:account_ledger/core/configs/app_config.dart';
import 'package:account_ledger/core/dependency_injection/service_locator.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/core/routes/app_router.dart';

class AccountLedger extends StatefulWidget {
  const AccountLedger({super.key});

  @override
  State<AccountLedger> createState() => _AccountLedgerState();
}

class _AccountLedgerState extends State<AccountLedger> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _appRouter = AppRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider.value(
          value: _authBloc,
          child: MaterialApp.router(
            title: 'Account Ledger',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: _appRouter.router,
          ),
        );
      },
    );
  }
}
