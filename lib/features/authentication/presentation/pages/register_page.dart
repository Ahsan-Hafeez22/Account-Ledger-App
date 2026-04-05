import 'package:account_ledger/core/utils/validators.dart';
import 'package:account_ledger/features/authentication/presentation/widget/social_button_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/constants/app_spacing.dart';
import 'package:account_ledger/core/constants/app_strings.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/core/extensions/string_extensions.dart';
import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/core/utils/custom_snack_bar.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/shared/widgets/custom_button.dart';
import 'package:account_ledger/shared/widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currencyController = TextEditingController(text: 'PKR');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _dateOfBirth;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currencyController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final dob = _dateOfBirth;
    if (dob == null) {
      CustomSnackBar.show(
        context,
        message: 'Please select your date of birth',
        type: SnackBarType.warning,
      );
      return;
    }
    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: "+92${_phoneController.text.trim()}",
        defaultCurrency: _currencyController.text.trim().toUpperCase(),
        dateOfBirth: dob,
        password: _passwordController.text.trim(),
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: GoRouter.of(context).pop,
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Icon(Icons.arrow_back_rounded),
                  ),
                ),
                20.0.height,
                Text(
                  'Create your Swift Ledger account',
                  style: context.appFonts.boldBlack24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to build better money habits, visualize your progress, and unlock AI-powered financial insights.',
                  style: context.appFonts.grey14,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _nameController,
                  label: 'Full name',
                  hint: 'John Doe',
                  validator: Validators.name,
                ),
                const SizedBox(height: AppSpacing.xl),
                CustomTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.xl),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone',
                  hint: '+923001234567',
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: AppSpacing.xl),
                CustomTextField(
                  controller: _currencyController,
                  label: 'Currency',
                  readOnly: true,

                  hint: 'PKR',
                  // validator: _validateCurrency,
                ),
                const SizedBox(height: AppSpacing.xl),
                InkWell(
                  onTap: _pickDateOfBirth,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of birth',
                      border: UnderlineInputBorder(),
                    ),
                    child: Text(
                      _dateOfBirth == null
                          ? 'Select date'
                          : '${_dateOfBirth!.year.toString().padLeft(4, '0')}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: _dateOfBirth == null
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                CustomTextField(
                  controller: _passwordController,
                  label: AppStrings.password,
                  hint: 'Create a strong password',
                  isPassword: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSpacing.xl),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm password',
                  hint: 'Re-enter your password',
                  isPassword: true,
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: AppSpacing.xxl),
                BlocConsumer<AuthBloc, AuthState>(
                  listenWhen: (previous, current) =>
                      current is AuthAuthenticated ||
                      current is AuthRegistrationOtpSent ||
                      (current is AuthFailure && previous is AuthLoading),
                  listener: (context, state) {
                    if (state is AuthRegistrationOtpSent) {
                      CustomSnackBar.show(
                        context,
                        message: state.message,
                        type: SnackBarType.success,
                      );
                      context.push(
                        RouteEndpoints.otpVerification,
                        extra: {'signUp': true, 'email': state.email},
                      );
                    } else if (state is AuthAuthenticated) {
                      CustomSnackBar.show(
                        context,
                        message: 'Sign Up Success',
                        type: SnackBarType.success,
                      );
                      context.go(RouteEndpoints.dashboard);
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
                      text: 'Sign Up',
                      onPressed: _onSubmit,
                    );
                  },
                ),
                10.0.height,
                Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: AppColors.divider),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text('Or continue with', style: context.appFonts.grey12),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Container(height: 1, color: AppColors.divider),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                SocialButtonsRow(),
                const SizedBox(height: AppSpacing.xxxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: context.appFonts.grey14),
                    TextButton(
                      onPressed: () => context.go(RouteEndpoints.login),
                      child: Text(
                        AppStrings.signIn,
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
    );
  }
}
