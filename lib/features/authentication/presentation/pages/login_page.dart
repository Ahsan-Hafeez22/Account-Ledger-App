import 'dart:developer';

import 'package:account_ledger/core/utils/custom_snack_bar.dart';
import 'package:account_ledger/core/utils/validators.dart';
import 'package:account_ledger/features/authentication/presentation/widget/app_logo_container.dart';
import 'package:account_ledger/features/authentication/presentation/widget/social_button_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/constants/app_spacing.dart';
import 'package:account_ledger/core/constants/app_strings.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/core/utils/app_utils.dart';
import 'package:account_ledger/shared/widgets/custom_button.dart';
import 'package:account_ledger/shared/widgets/custom_text_field.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? lastPressedAt;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          AppUtils.handleBackPress(
            lastPressedAt: lastPressedAt,
            updateLastPressedAt: (time) => lastPressedAt = time,
            context: context,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  20.0.height,
                  AppLogo(),
                  40.0.height,
                  Text('Log In', style: context.appFonts.boldBlack24),
                  4.0.height,
                  Text(
                    'Access your account and take control of your finances.',
                    style: context.appFonts.grey14,
                  ),
                  32.0.height,
                  CustomTextField(
                    controller: _emailController,
                    label: AppStrings.email,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  AppSpacing.xl.height,
                  CustomTextField(
                    controller: _passwordController,
                    label: AppStrings.password,
                    hint: 'Enter your password',
                    isPassword: true,
                    validator: Validators.password,
                  ),
                  4.0.height,
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          context.push(RouteEndpoints.forgotPassword),
                      child: Text(
                        AppStrings.forgotPassword,
                        style: AppFonts.mediumPrimary14,
                      ),
                    ),
                  ),
                  10.0.height,
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthAuthenticated) {
                        CustomSnackBar.show(
                          context,
                          message: "Login Success",
                          type: SnackBarType.success,
                        );
                        context.go(RouteEndpoints.dashboard);
                      } else if (state is AuthFailure) {
                        log("Error: ${state.message}");
                        CustomSnackBar.show(
                          context,
                          message: state.message,
                          type: SnackBarType.error,
                        );
                      }
                    },
                    builder: (context, state) {
                      return CustomButton(
                        isLoading: state is AuthLoading,
                        text: 'Login',
                        onPressed: _onSubmit,
                      );
                    },
                  ),
                  AppSpacing.lg.height,
                  SocialButtonsRow(),
                  AppSpacing.md.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?", style: context.appFonts.grey14),
                      TextButton(
                        onPressed: () => context.push(RouteEndpoints.register),
                        child: Text(
                          AppStrings.signUp,
                          style: AppFonts.mediumPrimary14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
