import 'dart:async';

import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/core/utils/custom_snack_bar.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/shared/widgets/custom_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

/// OTP for **sign-up** or **forgot-password** (reset flow).
class OtpVerificationPage extends StatefulWidget {
  final String email;
  final bool comingFromSignUp;

  const OtpVerificationPage({
    super.key,
    this.comingFromSignUp = false,
    required this.email,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const int _otpLength = 4;

  final PinInputController _pinController = PinInputController();
  bool isButtonEnabled = false;
  bool canResend = false;

  Timer? _timer;
  int _start = 60;

  String _maskedEmail(String email) {
    final e = email.trim();
    if (e.isEmpty) return 'your email';
    final at = e.indexOf('@');
    if (at <= 1) return e;
    final local = e.substring(0, at);
    final domain = e.substring(at);
    if (local.length <= 2) return e;
    return '${local[0]}***${local.substring(local.length - 1)}$domain';
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  void startTimer() {
    _timer?.cancel();
    canResend = false;
    _start = 60;
    setState(() {});

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_start > 0) {
          _start--;
        } else {
          canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String get timerText {
    final minutes = (_start ~/ 60).toString().padLeft(2, '0');
    final seconds = (_start % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onResendTap() {
    if (!canResend) return;
    _pinController.clear();
    setState(() => isButtonEnabled = false);
    if (widget.comingFromSignUp) {
      context.read<AuthBloc>().add(
        AuthResendRegistrationOtpRequested(email: widget.email),
      );
    } else {
      context.read<AuthBloc>().add(
        AuthResendForgotPasswordOtpRequested(email: widget.email),
      );
    }
    startTimer();
  }

  void _onVerify() {
    final otp = _pinController.text;
    if (otp.length != _otpLength) return;
    if (widget.comingFromSignUp) {
      context.read<AuthBloc>().add(
        AuthVerifyRegistrationOtpRequested(email: widget.email, otp: otp),
      );
    } else {
      context.read<AuthBloc>().add(
        AuthVerifyResetOtpRequested(email: widget.email, otp: otp),
      );
    }
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
          child: Column(
            children: [
              40.0.height,
              Text('Verification Code', style: context.appFonts.boldBlack24),
              5.0.height,
              Text(
                'Enter the $_otpLength-digit code sent to ${_maskedEmail(widget.email)}',
                style: context.appFonts.grey16,
                textAlign: TextAlign.center,
              ),
              80.0.height,

              // ── v9 Material PIN field ───────────────────────────────────────
              // Automatically reads MaterialPinThemeExtension from ThemeData —
              // the light/dark themes you defined in main.dart apply here with
              // no extra configuration needed.
              MaterialPinField(
                length: _otpLength,
                pinController: _pinController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() => isButtonEnabled = value.length == _otpLength);
                },
                onCompleted: (_) => _onVerify(),
              ),

              // ───────────────────────────────────────────────────────────────
              20.0.height,
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Code expires in ',
                      style: context.appFonts.mediumBlack14,
                    ),
                    TextSpan(text: timerText, style: context.appFonts.boldBlack16),
                  ],
                ),
              ),
              30.0.height,
              BlocConsumer<AuthBloc, AuthState>(
                listenWhen: (previous, current) =>
                    (current is AuthAuthenticated && widget.comingFromSignUp) ||
                    (current is AuthResetOtpVerified &&
                        !widget.comingFromSignUp) ||
                    current is AuthOtpResent ||
                    (current is AuthFailure && previous is AuthLoading),
                listener: (context, state) {
                  if (state is AuthAuthenticated && widget.comingFromSignUp) {
                    CustomSnackBar.show(
                      context,
                      message: 'Account created successfully.',
                      type: SnackBarType.success,
                    );
                    context.go(RouteEndpoints.dashboard);
                  } else if (state is AuthResetOtpVerified &&
                      !widget.comingFromSignUp) {
                    context.push(
                      RouteEndpoints.resetPassword,
                      extra: {
                        'email': state.email,
                        'resetToken': state.resetToken,
                      },
                    );
                  } else if (state is AuthOtpResent) {
                    CustomSnackBar.show(
                      context,
                      message: state.message,
                      type: SnackBarType.success,
                    );
                  } else if (state is AuthFailure) {
                    CustomSnackBar.show(
                      context,
                      message: state.message,
                      type: SnackBarType.error,
                      position: SnackBarPosition.top,
                    );
                    _pinController.clear();
                    setState(() => isButtonEnabled = false);
                  }
                },
                builder: (context, state) {
                  return CustomButton(
                    text: 'Verify',
                    isLoading: state is AuthLoading,
                    onPressed: isButtonEnabled ? _onVerify : () {},
                  );
                },
              ),
              30.0.height,
              RichText(
                text: TextSpan(
                  text: 'Did not receive OTP? ',
                  style: context.appFonts.black14,
                  children: [
                    TextSpan(
                      text: 'Resend code',
                      style: AppFonts.primary14.copyWith(
                        decoration: TextDecoration.underline,
                        color: canResend
                            ? AppColors.primary
                            : AppColors.disableColor,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = _onResendTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
