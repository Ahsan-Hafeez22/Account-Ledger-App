import 'package:account_ledger/core/extensions/string_extensions.dart';
import 'package:account_ledger/core/extensions/widget_extensions.dart';
import 'package:account_ledger/core/utils/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:account_ledger/core/constants/app_colors.dart';
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

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    if (!value.isValidEmail) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Minimum 6 characters';
    return null;
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
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  20.0.height,
                  _AppLogo(),
                  40.0.height,
                  Text('Log In', style: AppFonts.boldBlack24),
                  4.0.height,
                  Text(
                    'Access your account and take control of your finances.',
                    style: AppFonts.grey14,
                  ),
                  32.0.height,
                  CustomTextField(
                    controller: _emailController,
                    label: AppStrings.email,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  AppSpacing.xl.height,
                  CustomTextField(
                    controller: _passwordController,
                    label: AppStrings.password,
                    hint: 'Enter your password',
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  4.0.height,
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
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
                        // context.go(RouteNames.analytics);
                      } else if (state is AuthFailure) {
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
                  AppSpacing.xxl.height,
                  _Divider(),
                  AppSpacing.xxl.height,
                  _SocialButtonsRow(),
                  AppSpacing.xxxl.height,
                  _SignUpPrompt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        height: 100.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wallet_rounded, size: 45.sp, color: Colors.white),
            10.0.width,
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Account Ledger\n',
                    style: AppFonts.boldWhite24,
                  ),
                  TextSpan(
                    text: 'Your Digital Wallet',
                    style: AppFonts.white12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.divider)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('Or continue with', style: AppFonts.grey14),
        ),
        Expanded(child: Container(height: 1, color: AppColors.divider)),
      ],
    );
  }
}

class _SocialButtonsRow extends StatelessWidget {
  static const _socials = [
    (label: 'Google', icon: Icons.g_mobiledata_rounded),
    (label: 'Facebook', icon: Icons.facebook_rounded),
    // (label: 'Apple', icon: Icons.apple_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _socials
          .expand(
            (s) => [
              Expanded(
                child: _SocialButton(label: s.label, icon: s.icon),
              ),
              if (s != _socials.last) 8.0.width,
            ],
          )
          .toList(),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SocialButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
          color: AppColors.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: AppColors.textPrimary),
            10.0.width,
            Text(label, style: AppFonts.mediumBlack14),
          ],
        ).paddingSymmetric(h: 16, v: 12),
      ),
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?", style: AppFonts.grey14),
        TextButton(
          onPressed: () => context.push(RouteNames.register),
          child: Text(AppStrings.signUp, style: AppFonts.mediumPrimary14),
        ),
      ],
    );
  }
}
