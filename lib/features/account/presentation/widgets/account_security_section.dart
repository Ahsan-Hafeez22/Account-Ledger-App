import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountSecuritySection extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onChangePin;
  final Brightness brightness;

  const AccountSecuritySection({
    super.key,
    required this.isSubmitting,
    required this.onChangePin,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'Security'),
        10.0.height,
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor(brightness),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderColor(brightness)),
          ),
          child: Column(
            children: [
              _SecurityTile(
                icon: Icons.pin_rounded,
                iconColor: const Color(0xFF4F8EF7),
                iconBg: const Color(0xFF4F8EF7),
                title: 'Change PIN',
                subtitle: 'Update your wallet access PIN',
                trailing: _ArrowTrailing(
                  brightness: brightness,
                  disabled: isSubmitting,
                ),
                onTap: isSubmitting ? null : onChangePin,
                brightness: brightness,
              ),

              _Separator(brightness: brightness),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Individual Security Tile
// ─────────────────────────────────────────
class _SecurityTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final Brightness brightness;
  final bool isLast;

  const _SecurityTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    required this.brightness,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(18),
          bottom: isLast ? const Radius.circular(18) : Radius.zero,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: iconBg.withValues(
                    alpha: brightness == Brightness.dark ? 0.2 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20.w),
              ),
              14.0.width,

              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.appFonts.boldBlack14),
                    3.0.height,
                    Text(subtitle, style: context.appFonts.grey12),
                  ],
                ),
              ),

              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Arrow trailing (active tiles)
// ─────────────────────────────────────────
class _ArrowTrailing extends StatelessWidget {
  final Brightness brightness;
  final bool disabled;

  const _ArrowTrailing({required this.brightness, required this.disabled});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      size: 20.w,
      color: disabled
          ? AppColors.hintTextColor(brightness)
          : AppColors.secondaryTextColor(brightness),
    );
  }
}

// ─────────────────────────────────────────
// Coming soon badge (inactive tiles)
// ─────────────────────────────────────────
class _ComingSoonBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Soon',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Separator between tiles
// ─────────────────────────────────────────
class _Separator extends StatelessWidget {
  final Brightness brightness;

  const _Separator({required this.brightness});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 70.w),
      child: Divider(height: 1, color: AppColors.dividerColor(brightness)),
    );
  }
}

// ─────────────────────────────────────────
// Section label
// ─────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: context.appFonts.boldBlack16);
  }
}
