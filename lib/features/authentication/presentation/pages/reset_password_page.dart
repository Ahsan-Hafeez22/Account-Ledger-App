import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/core/utils/custom_snack_bar.dart';
import 'package:account_ledger/core/utils/validators.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String resetToken;

  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _passwordController2.dispose();
  }

  void _submit() {
    if (!(key.currentState?.validate() ?? false)) return;
    if (widget.resetToken.isEmpty) {
      CustomSnackBar.show(
        context,
        message: 'Reset session is invalid. Request a new OTP.',
        type: SnackBarType.error,
      );
      return;
    }
    context.read<AuthBloc>().add(
      AuthResetPasswordRequested(
        resetToken: widget.resetToken,
        password: _passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                40.0.height,
                Center(
                  child: Text(
                    'Enter New Password',
                    style: context.appFonts.boldBlack24,
                    textAlign: TextAlign.center,
                  ),
                ),
                5.0.height,
                Center(
                  child: Text(
                    'Verification complete. Choose a strong password and confirm it to finish.',
                    style: context.appFonts.grey14,
                    textAlign: TextAlign.center,
                  ),
                ),
                20.0.height,
                Center(child: Icon(Icons.wallet, size: 200.h)),
                40.0.height,
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter Password',
                  isPassword: true,
                  validator: Validators.password,
                ),
                10.0.height,
                CustomTextField(
                  controller: _passwordController2,
                  label: 'Confirm Password',
                  hint: 'Enter Confirm Password',
                  isPassword: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                30.0.height,
                BlocConsumer<AuthBloc, AuthState>(
                  listenWhen: (previous, current) =>
                      current is AuthPasswordResetSuccess ||
                      (current is AuthFailure && previous is AuthLoading),
                  listener: (context, state) {
                    if (state is AuthPasswordResetSuccess) {
                      CustomSnackBar.show(
                        context,
                        message:
                            'Password reset successfully. Please log in with your new password.',
                        type: SnackBarType.success,
                      );
                      context.go(RouteEndpoints.login);
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
                      text: 'Change',
                      isLoading: state is AuthLoading,
                      onPressed: _submit,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
