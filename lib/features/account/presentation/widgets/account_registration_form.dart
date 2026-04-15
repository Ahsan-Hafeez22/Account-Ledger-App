import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/constants/app_spacing.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/core/utils/validators.dart';
import 'package:account_ledger/shared/widgets/custom_button.dart';
import 'package:account_ledger/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountRegistrationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController pinController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const AccountRegistrationForm({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.pinController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            120.0.height,

            // Icon + heading
            _RegistrationHeader(brightness: brightness),

            36.0.height,

            // Fields
            CustomTextField(
              controller: titleController,
              label: 'Account title',
              hint: 'e.g. My Wallet',
              validator: (v) => Validators.required(v, 'Account title'),
            ),
            AppSpacing.xl.height,
            CustomTextField(
              controller: pinController,
              label: 'PIN code',
              hint: '4 digits',
              isPassword: true,
              pinCodeField: true,
              keyboardType: TextInputType.number,
              validator: Validators.accountPin,
            ),

            16.0.height,

            // Info note
            _SetupNote(brightness: brightness),

            AppSpacing.xl.height,

            CustomButton(
              text: 'Create Account',
              isLoading: isSubmitting,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Header with icon
// ─────────────────────────────────────────
class _RegistrationHeader extends StatelessWidget {
  final Brightness brightness;

  const _RegistrationHeader({required this.brightness});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54.w,
          height: 54.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F2057), Color(0xFF1A3A8F)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2057).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 26.w,
          ),
        ),

        20.0.height,

        Text('Create Wallet', style: context.appFonts.boldBlack24),
        8.0.height,
        Text(
          'Set up your personal wallet to start managing transactions. '
          'Currency and account number are assigned automatically.',
          style: context.appFonts.grey14,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Setup info note
// ─────────────────────────────────────────
class _SetupNote extends StatelessWidget {
  final Brightness brightness;

  const _SetupNote({required this.brightness});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 16.w, color: AppColors.primary),
          10.0.width,
          Expanded(
            child: Text(
              'Your PIN secures all wallet operations. Choose something memorable but not obvious.',
              style: context.appFonts.grey12.copyWith(
                color: AppColors.primary.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
