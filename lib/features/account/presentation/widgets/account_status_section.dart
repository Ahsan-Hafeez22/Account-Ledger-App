import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountStatusSection extends StatelessWidget {
  final String currentStatus;
  final bool isSubmitting;
  final void Function(String) onChangeStatus;
  final VoidCallback onReload;
  final Brightness brightness;

  const AccountStatusSection({
    super.key,
    required this.currentStatus,
    required this.isSubmitting,
    required this.onChangeStatus,
    required this.onReload,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final isFrozen = currentStatus == 'FROZEN';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account Status', style: context.appFonts.boldBlack16),
        6.0.height,
        Text(
          isFrozen
              ? 'Your account is temporarily frozen. It will unlock automatically after 1 hour.'
              : 'Control how your wallet operates. Changes take effect immediately.',
          style: context.appFonts.grey14,
        ),
        16.0.height,

        if (isFrozen) ...[
          // ── Frozen state — show frozen card + reload ──
          _StatusOptionCard(
            option: StatusOption.frozen,
            isSelected: true,
            isSubmitting: isSubmitting,
            onTap: null, // not tappable
            brightness: brightness,
          ),
          12.0.height,
          _ReloadButton(
            isSubmitting: isSubmitting,
            onReload: onReload,
            brightness: brightness,
          ),
        ] else ...[
          // ── Normal state — show ACTIVE and CLOSED only ──
          ...StatusOption.values
              .where((opt) => opt != StatusOption.frozen)
              .map(
                (opt) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _StatusOptionCard(
                    option: opt,
                    isSelected: currentStatus == opt.key,
                    isSubmitting: isSubmitting,
                    onTap: () => onChangeStatus(opt.key),
                    brightness: brightness,
                  ),
                ),
              ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────
// Reload Button
// ─────────────────────────────────────────
class _ReloadButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onReload;
  final Brightness brightness;

  const _ReloadButton({
    required this.isSubmitting,
    required this.onReload,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isSubmitting ? null : onReload,
        icon: isSubmitting
            ? SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Icon(Icons.refresh_rounded, size: 18.w),
        label: Text(
          isSubmitting ? 'Checking status...' : 'Reload account status',
          style: context.appFonts.boldBlack14,
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: AppColors.borderColor(brightness)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Status Option Enum
// ─────────────────────────────────────────
enum StatusOption {
  active(
    key: 'ACTIVE',
    label: 'Active',
    description: 'Full access. All transactions and operations are enabled.',
    icon: Icons.check_circle_rounded,
    color: Color(0xFF34C759),
    riskLabel: 'Normal',
  ),
  frozen(
    key: 'FROZEN',
    label: 'Frozen',
    description:
        'Temporarily suspended due to too many incorrect PIN attempts.',
    icon: Icons.ac_unit_rounded,
    color: Color(0xFF007AFF),
    riskLabel: 'Temporary',
  ),
  closed(
    key: 'CLOSED',
    label: 'Closed',
    description: 'Permanently disables the wallet. This cannot be undone.',
    icon: Icons.cancel_rounded,
    color: Color(0xFFFF3B30),
    riskLabel: 'Permanent',
  );

  final String key;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final String riskLabel;

  const StatusOption({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.riskLabel,
  });
}

// ─────────────────────────────────────────
// Status Option Card
// ─────────────────────────────────────────
class _StatusOptionCard extends StatelessWidget {
  final StatusOption option;
  final bool isSelected;
  final bool isSubmitting;
  final VoidCallback? onTap; // nullable — frozen card is not tappable
  final Brightness brightness;

  const _StatusOptionCard({
    required this.option,
    required this.isSelected,
    required this.isSubmitting,
    required this.onTap,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.cardColor(brightness);
    final border = AppColors.borderColor(brightness);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? option.color.withValues(
                alpha: brightness == Brightness.dark ? 0.14 : 0.07,
              )
            : cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? option.color.withValues(alpha: 0.6) : border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (isSubmitting || onTap == null) ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                // Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: option.color.withValues(
                      alpha: isSelected
                          ? (brightness == Brightness.dark ? 0.28 : 0.18)
                          : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(option.icon, color: option.color, size: 20.w),
                ),
                14.0.width,

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            option.label,
                            style: context.appFonts.boldBlack14,
                          ),
                          6.0.width,
                          _RiskLabel(
                            label: option.riskLabel,
                            color: option.color,
                          ),
                        ],
                      ),
                      4.0.height,
                      Text(option.description, style: context.appFonts.grey12),
                    ],
                  ),
                ),

                // Radio indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? option.color : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? option.color
                          : AppColors.borderColor(brightness),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          size: 12.w,
                          color: Colors.white,
                        )
                      : null,
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
// Risk label chip
// ─────────────────────────────────────────
class _RiskLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _RiskLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
