import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:account_ledger/core/constants/app_colors.dart';

class AppFonts {
  AppFonts._();

  static TextStyle _buildTextStyle({
    required double fontSize,
    required Color color,
    required FontWeight fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize.sp,
      color: color,
      fontWeight: fontWeight,
      fontFamily: "Poppins",
    );
  }

  static TextStyle get primary10 => _buildTextStyle(
    fontSize: 10,
    color: AppColors.primary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get primary12 => _buildTextStyle(
    fontSize: 12,
    color: AppColors.primary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get primary14 => _buildTextStyle(
    fontSize: 14,
    color: AppColors.primary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get primary16 => _buildTextStyle(
    fontSize: 16,
    color: AppColors.primary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get primary18 => _buildTextStyle(
    fontSize: 18,
    color: AppColors.primary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get primary20 => _buildTextStyle(
    fontSize: 20,
    color: AppColors.primary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get primary22 => _buildTextStyle(
    fontSize: 22,
    color: AppColors.primary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get primary24 => _buildTextStyle(
    fontSize: 24,
    color: AppColors.primary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get primary26 => _buildTextStyle(
    fontSize: 26,
    color: AppColors.primary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get primary28 => _buildTextStyle(
    fontSize: 28,
    color: AppColors.primary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get primary30 => _buildTextStyle(
    fontSize: 30,
    color: AppColors.primary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get primary32 => _buildTextStyle(
    fontSize: 32,
    color: AppColors.primary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get primary34 => _buildTextStyle(
    fontSize: 34,
    color: AppColors.primary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get primary36 => _buildTextStyle(
    fontSize: 36,
    color: AppColors.primary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get primary38 => _buildTextStyle(
    fontSize: 38,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  // Medium weight
  static TextStyle get mediumPrimary12 => _buildTextStyle(
    fontSize: 12,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumPrimary14 => _buildTextStyle(
    fontSize: 14,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumPrimary16 => _buildTextStyle(
    fontSize: 16,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumPrimary18 => _buildTextStyle(
    fontSize: 18,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumPrimary20 => _buildTextStyle(
    fontSize: 20,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumPrimary22 => _buildTextStyle(
    fontSize: 22,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumPrimary24 => _buildTextStyle(
    fontSize: 24,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumPrimary26 => _buildTextStyle(
    fontSize: 26,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumPrimary28 => _buildTextStyle(
    fontSize: 28,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumPrimary30 => _buildTextStyle(
    fontSize: 30,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumPrimary32 => _buildTextStyle(
    fontSize: 32,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumPrimary34 => _buildTextStyle(
    fontSize: 34,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumPrimary36 => _buildTextStyle(
    fontSize: 36,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumPrimary38 => _buildTextStyle(
    fontSize: 38,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  // Bold weight
  static TextStyle get boldprimary12 => _buildTextStyle(
    fontSize: 12,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldprimary14 => _buildTextStyle(
    fontSize: 14,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldprimary16 => _buildTextStyle(
    fontSize: 16,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldprimary18 => _buildTextStyle(
    fontSize: 18,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldprimary20 => _buildTextStyle(
    fontSize: 20,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldprimary22 => _buildTextStyle(
    fontSize: 22,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldprimary24 => _buildTextStyle(
    fontSize: 24,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldprimary26 => _buildTextStyle(
    fontSize: 26,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldprimary28 => _buildTextStyle(
    fontSize: 28,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldprimary30 => _buildTextStyle(
    fontSize: 30,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldprimary32 => _buildTextStyle(
    fontSize: 32,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldprimary34 => _buildTextStyle(
    fontSize: 34,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldprimary36 => _buildTextStyle(
    fontSize: 36,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldprimary38 => _buildTextStyle(
    fontSize: 38,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  // Medium weight
  static TextStyle get mediumBlack10 => _buildTextStyle(
    fontSize: 10,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumBlack12 => _buildTextStyle(
    fontSize: 12,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumBlack14 => _buildTextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumBlack16 => _buildTextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumBlack18 => _buildTextStyle(
    fontSize: 18,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumBlack20 => _buildTextStyle(
    fontSize: 20,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumBlack22 => _buildTextStyle(
    fontSize: 22,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumBlack24 => _buildTextStyle(
    fontSize: 24,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumBlack26 => _buildTextStyle(
    fontSize: 26,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumBlack28 => _buildTextStyle(
    fontSize: 28,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumBlack30 => _buildTextStyle(
    fontSize: 30,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumBlack32 => _buildTextStyle(
    fontSize: 32,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumBlack34 => _buildTextStyle(
    fontSize: 34,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumBlack36 => _buildTextStyle(
    fontSize: 36,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumBlack38 => _buildTextStyle(
    fontSize: 38,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  // Bold weight
  static TextStyle get boldBlack10 => _buildTextStyle(
    fontSize: 10,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get boldBlack12 => _buildTextStyle(
    fontSize: 12,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldBlack14 => _buildTextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldBlack16 => _buildTextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldBlack18 => _buildTextStyle(
    fontSize: 18,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldBlack20 => _buildTextStyle(
    fontSize: 20,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldBlack22 => _buildTextStyle(
    fontSize: 22,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldBlack24 => _buildTextStyle(
    fontSize: 24,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldBlack26 => _buildTextStyle(
    fontSize: 26,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldBlack28 => _buildTextStyle(
    fontSize: 28,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldBlack30 => _buildTextStyle(
    fontSize: 30,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldBlack32 => _buildTextStyle(
    fontSize: 32,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldBlack34 => _buildTextStyle(
    fontSize: 34,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldBlack36 => _buildTextStyle(
    fontSize: 36,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldBlack38 => _buildTextStyle(
    fontSize: 38,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  // ==================== Grey Text Styles ====================

  // Normal weight
  static TextStyle get grey10 => _buildTextStyle(
    fontSize: 10,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );
  static TextStyle get grey11 => _buildTextStyle(
    fontSize: 11,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get grey12 => _buildTextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get grey13 => _buildTextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );
  static TextStyle get grey14 => _buildTextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get grey16 => _buildTextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get grey18 => _buildTextStyle(
    fontSize: 18,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get grey20 => _buildTextStyle(
    fontSize: 20,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get grey22 => _buildTextStyle(
    fontSize: 22,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get grey24 => _buildTextStyle(
    fontSize: 24,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get grey26 => _buildTextStyle(
    fontSize: 26,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get grey28 => _buildTextStyle(
    fontSize: 28,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get grey30 => _buildTextStyle(
    fontSize: 30,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get grey32 => _buildTextStyle(
    fontSize: 32,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get grey34 => _buildTextStyle(
    fontSize: 34,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get grey36 => _buildTextStyle(
    fontSize: 36,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get grey38 => _buildTextStyle(
    fontSize: 38,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  // Medium weight
  static TextStyle get mediumGrey10 => _buildTextStyle(
    fontSize: 10,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumGrey12 => _buildTextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumGrey14 => _buildTextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumGrey16 => _buildTextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumGrey18 => _buildTextStyle(
    fontSize: 18,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumGrey20 => _buildTextStyle(
    fontSize: 20,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumGrey22 => _buildTextStyle(
    fontSize: 22,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumGrey24 => _buildTextStyle(
    fontSize: 24,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumGrey26 => _buildTextStyle(
    fontSize: 26,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumGrey28 => _buildTextStyle(
    fontSize: 28,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumGrey30 => _buildTextStyle(
    fontSize: 30,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumGrey32 => _buildTextStyle(
    fontSize: 32,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumGrey34 => _buildTextStyle(
    fontSize: 34,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumGrey36 => _buildTextStyle(
    fontSize: 36,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumGrey38 => _buildTextStyle(
    fontSize: 38,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  // Bold weight
  static TextStyle get boldGrey12 => _buildTextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldGrey14 => _buildTextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldGrey16 => _buildTextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldGrey18 => _buildTextStyle(
    fontSize: 18,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldGrey20 => _buildTextStyle(
    fontSize: 20,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldGrey22 => _buildTextStyle(
    fontSize: 22,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldGrey24 => _buildTextStyle(
    fontSize: 24,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldGrey26 => _buildTextStyle(
    fontSize: 26,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldGrey28 => _buildTextStyle(
    fontSize: 28,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldGrey30 => _buildTextStyle(
    fontSize: 30,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldGrey32 => _buildTextStyle(
    fontSize: 32,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldGrey34 => _buildTextStyle(
    fontSize: 34,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldGrey36 => _buildTextStyle(
    fontSize: 36,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldGrey38 => _buildTextStyle(
    fontSize: 38,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  // ==================== White Text Styles ====================

  // Normal weight
  static TextStyle get white10 => _buildTextStyle(
    fontSize: 10,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );
  static TextStyle get white11 => _buildTextStyle(
    fontSize: 11,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get white12 => _buildTextStyle(
    fontSize: 12,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get white13 => _buildTextStyle(
    fontSize: 13,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );
  static TextStyle get white14 => _buildTextStyle(
    fontSize: 14,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get white16 => _buildTextStyle(
    fontSize: 16,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get white18 => _buildTextStyle(
    fontSize: 18,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get white20 => _buildTextStyle(
    fontSize: 20,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get white22 => _buildTextStyle(
    fontSize: 22,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get white24 => _buildTextStyle(
    fontSize: 24,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get white26 => _buildTextStyle(
    fontSize: 26,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get white28 => _buildTextStyle(
    fontSize: 28,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get white30 => _buildTextStyle(
    fontSize: 30,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get white32 => _buildTextStyle(
    fontSize: 32,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get white34 => _buildTextStyle(
    fontSize: 34,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get white36 => _buildTextStyle(
    fontSize: 36,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get white38 => _buildTextStyle(
    fontSize: 38,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w700,
  );

  // Medium weight
  static TextStyle get mediumWhite10 => _buildTextStyle(
    fontSize: 10,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumWhite12 => _buildTextStyle(
    fontSize: 12,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumWhite14 => _buildTextStyle(
    fontSize: 14,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumWhite16 => _buildTextStyle(
    fontSize: 16,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumWhite18 => _buildTextStyle(
    fontSize: 18,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumWhite20 => _buildTextStyle(
    fontSize: 20,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumWhite22 => _buildTextStyle(
    fontSize: 22,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumWhite24 => _buildTextStyle(
    fontSize: 24,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumWhite26 => _buildTextStyle(
    fontSize: 26,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumWhite28 => _buildTextStyle(
    fontSize: 28,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumWhite30 => _buildTextStyle(
    fontSize: 30,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumWhite32 => _buildTextStyle(
    fontSize: 32,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumWhite34 => _buildTextStyle(
    fontSize: 34,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumWhite36 => _buildTextStyle(
    fontSize: 36,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get mediumWhite38 => _buildTextStyle(
    fontSize: 38,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
  );

  // Bold weight
  static TextStyle get boldWhite12 => _buildTextStyle(
    fontSize: 12,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldWhite14 => _buildTextStyle(
    fontSize: 14,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldWhite16 => _buildTextStyle(
    fontSize: 16,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldWhite18 => _buildTextStyle(
    fontSize: 18,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldWhite20 => _buildTextStyle(
    fontSize: 20,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldWhite22 => _buildTextStyle(
    fontSize: 22,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldWhite24 => _buildTextStyle(
    fontSize: 24,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldWhite26 => _buildTextStyle(
    fontSize: 26,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldWhite28 => _buildTextStyle(
    fontSize: 28,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldWhite30 => _buildTextStyle(
    fontSize: 30,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldWhite32 => _buildTextStyle(
    fontSize: 32,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldWhite34 => _buildTextStyle(
    fontSize: 34,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldWhite36 => _buildTextStyle(
    fontSize: 36,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get boldWhite38 => _buildTextStyle(
    fontSize: 38,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w700,
  );
}
