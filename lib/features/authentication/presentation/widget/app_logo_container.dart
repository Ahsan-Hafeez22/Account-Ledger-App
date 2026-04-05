import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/constants/app_spacing.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        height: 100.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wallet_rounded,
              size: 45.sp,
              color: AppColors.whiteColor,
            ),
            10.0.width,
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Account Ledger\n',
                    style: AppFonts.boldWhite24,
                  ),
                  TextSpan(
                    text: 'Your Digital Wallet',
                    style: AppFonts.white12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
