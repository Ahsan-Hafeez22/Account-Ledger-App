import 'dart:developer';

import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
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

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      log('Change Password Pressed');
      context.read<AuthBloc>().add(
        AuthChangePasswordRequested(
          oldPassword: _currentPassword.text.trim(),
          newPassword: _newPassword.text.trim(),
        ),
      );
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _confirmPassword.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: AppBackButton(onPress: () => context.pop()),
        title: Text('Security Settings', style: context.appFonts.boldBlack26),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.0.height,
                Text('Change Password', style: context.appFonts.boldBlack20),
                Text(
                  'To update your password, please enter your current password and choose a new one.',
                  style: context.appFonts.grey12,
                ),
                50.0.height,

                CustomTextField(
                  controller: _currentPassword,
                  label: 'Current Password',
                  hint: 'Enter your password',
                  isPassword: true,
                  validator: Validators.password,
                ),
                10.0.height,
                CustomTextField(
                  controller: _newPassword,
                  label: 'New Password',
                  hint: 'Enter your password',
                  isPassword: true,
                  validator: Validators.password,
                ),
                10.0.height,

                CustomTextField(
                  controller: _confirmPassword,
                  label: 'Confirm Password',
                  hint: 'Enter your password',
                  isPassword: true,
                  validator: _validateConfirmPassword,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthChangePasswordSuccess) {
            CustomSnackBar.show(
              context,
              message: 'Password changed successfully!',
              type: SnackBarType.success,
            );
            context.pop();
          } else if (state is AuthFailure) {
            CustomSnackBar.show(
              context,
              message: state.message,
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          return Container(
            margin: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
            child: CustomButton(
              text: 'Confirm',
              isLoading: state is AuthLoading,
              onPressed: _onSubmit,
            ),
          );
        },
      ),
    );
  }
}
