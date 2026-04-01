import 'package:account_ledger/core/constants/app_assets.dart';
import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/constants/app_spacing.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/core/extensions/widget_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class SocialButtonsRow extends StatelessWidget {
  static const _socials = [(label: 'Google'), (label: 'Facebook')];

  const SocialButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _socials
          .expand(
            (s) => [
              Expanded(child: _SocialButton(label: s.label)),
              if (s != _socials.last) 8.0.width,
            ],
          )
          .toList(),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;

  const _SocialButton({required this.label});

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
            label == 'Google'
                ? SvgPicture.asset(AppAssets.googleIcon, height: 18.r)
                : Icon(
                    Icons.facebook_rounded,
                    size: 22.r,
                    color: Colors.blueAccent,
                  ),
            10.0.width,
            Text(label, style: AppFonts.mediumBlack14),
          ],
        ).paddingSymmetric(h: 16, v: 12),
      ),
    );
  }
}
