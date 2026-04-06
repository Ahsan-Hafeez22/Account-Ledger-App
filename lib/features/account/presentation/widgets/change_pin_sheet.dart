import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/constants/app_spacing.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/core/utils/validators.dart';
import 'package:account_ledger/features/account/presentation/bloc/account_bloc.dart';
import 'package:account_ledger/shared/widgets/custom_button.dart';
import 'package:account_ledger/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChangePinSheet extends StatefulWidget {
  final Brightness brightness;
  final VoidCallback? onDismiss;

  const ChangePinSheet({super.key, required this.brightness, this.onDismiss});

  @override
  State<ChangePinSheet> createState() => _ChangePinSheetState();
}

class _ChangePinSheetState extends State<ChangePinSheet> {
  final _formKey = GlobalKey<FormState>();
  final _oldPin = TextEditingController();
  final _newPin = TextEditingController();
  final _confirmPin = TextEditingController();

  @override
  void dispose() {
    _oldPin.dispose();
    _newPin.dispose();
    _confirmPin.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AccountBloc>().add(
      ChangeAccountPinRequested(oldPin: _oldPin.text, newPin: _newPin.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = widget.brightness;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(brightness),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.borderColor(brightness)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 28.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.dividerColor(brightness),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                18.0.height,

                // Header
                Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F8EF7).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        color: const Color(0xFF4F8EF7),
                        size: 20.w,
                      ),
                    ),
                    14.0.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Change PIN', style: context.appFonts.boldBlack20),
                        4.0.height,
                        Text(
                          'Enter your current and new PIN.',
                          style: context.appFonts.grey14,
                        ),
                      ],
                    ),
                  ],
                ),

                AppSpacing.lg.height,

                // Security notice
                _SecurityNotice(brightness: brightness),

                AppSpacing.lg.height,

                // Fields
                CustomTextField(
                  controller: _oldPin,
                  label: 'Current PIN',
                  hint: '4 digits',
                  isPassword: true,
                  pinCodeField: true,
                  keyboardType: TextInputType.number,
                  validator: Validators.accountPin,
                ),
                AppSpacing.md.height,
                CustomTextField(
                  controller: _newPin,
                  label: 'New PIN',
                  hint: '4 digits',
                  isPassword: true,
                  pinCodeField: true,
                  keyboardType: TextInputType.number,
                  validator: Validators.accountPin,
                ),
                AppSpacing.md.height,
                CustomTextField(
                  controller: _confirmPin,
                  label: 'Confirm New PIN',
                  hint: 'Re-enter new PIN',
                  isPassword: true,
                  pinCodeField: true,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final base = Validators.accountPin(v);
                    if (base != null) return base;
                    if ((v ?? '').trim() != _newPin.text.trim()) {
                      return 'PINs do not match';
                    }
                    return null;
                  },
                ),

                AppSpacing.lg.height,

                BlocBuilder<AccountBloc, AccountState>(
                  buildWhen: (p, n) =>
                      (p is AccountLoaded) != (n is AccountLoaded) ||
                      (p is AccountLoaded &&
                          n is AccountLoaded &&
                          p.isSubmitting != n.isSubmitting),
                  builder: (context, state) {
                    final loading =
                        state is AccountLoaded && state.isSubmitting;
                    return CustomButton(
                      text: 'Update PIN',
                      isLoading: loading,
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

// ─────────────────────────────────────────
// Security notice banner
// ─────────────────────────────────────────
class _SecurityNotice extends StatelessWidget {
  final Brightness brightness;

  const _SecurityNotice({required this.brightness});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9F0A).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF9F0A).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16.w,
            color: const Color(0xFFFF9F0A),
          ),
          10.0.width,
          Expanded(
            child: Text(
              'Never share your PIN with anyone. Our team will never ask for it.',
              style: context.appFonts.grey12.copyWith(
                color: const Color(0xFFFF9F0A).withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
