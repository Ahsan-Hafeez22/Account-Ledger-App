import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/core/utils/custom_snack_bar.dart';
import 'package:account_ledger/core/utils/validators.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/shared/widgets/app_back_button.dart';
import 'package:account_ledger/shared/widgets/custom_button.dart';
import 'package:account_ledger/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> forgotPassword() async {
    if (!(_key.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
      AuthForgotPasswordRequested(email: emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: AppBackButton(
          onPress: () => GoRouter.of(context).go(RouteEndpoints.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _key,
              child: Column(
                children: [
                  40.0.height,

                  Text("Forgot Password", style: context.appFonts.boldBlack26),
                  5.0.height,
                  Text(
                    "Don't worry! It occurs. Please enter the email address linked with your account",
                    style: context.appFonts.grey14,
                    textAlign: TextAlign.center,
                  ),
                  20.0.height,
                  Center(
                    child: Icon(
                      Icons.wallet,
                      size: 200.h,
                      color: AppColors.primary,
                    ),
                  ),
                  40.0.height,
                  CustomTextField(
                    controller: emailController,
                    label: 'Email',
                    hint: 'Enter email',
                    validator: Validators.email,
                  ),
                  30.0.height,
                  BlocConsumer<AuthBloc, AuthState>(
                    listenWhen: (previous, current) =>
                        current is AuthForgotPasswordOtpSent ||
                        (current is AuthFailure && previous is AuthLoading),
                    listener: (context, state) {
                      if (state is AuthForgotPasswordOtpSent) {
                        CustomSnackBar.show(
                          context,
                          message: state.message,
                          type: SnackBarType.info,
                        );
                        context.push(
                          RouteEndpoints.otpVerification,
                          extra: {
                            'signUp': false,
                            'email': state.email,
                          },
                        );
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
                        text: 'Send OTP',
                        onPressed: forgotPassword,
                      );
                    },
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
