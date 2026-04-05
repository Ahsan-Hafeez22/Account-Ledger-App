import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:account_ledger/core/constants/app_colors.dart';

part 'app_fonts_adaptive.dart';

/// Typography helpers.
///
/// - **Theme-aware** (light/dark): `context.appFonts.black12`, `.grey14`, `.boldBlack24`, …
/// - **Brand / fixed**: `AppFonts.primary14`, `AppFonts.mediumWhite16`, …
class AppFonts {
  AppFonts._();

  static const String appFontFamily = 'Poppins';

  /// Poppins styles for [ThemeData] / `InputDecorationTheme` / `AppBarTheme`
  /// (logical sizes; no `.sp` so theme text scaling behaves predictably).
  static TextStyle themeText({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: appFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// Shared by static styles and [AppFontsRef] (library-private for [part] file).
  static TextStyle _buildTextStyle({
    required double fontSize,
    required Color color,
    required FontWeight fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize.sp,
      color: color,
      fontWeight: fontWeight,
      fontFamily: appFontFamily,
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
    fontWeight: FontWeight.bold,
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
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldprimary14 => _buildTextStyle(
    fontSize: 14,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldprimary16 => _buildTextStyle(
    fontSize: 16,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldprimary18 => _buildTextStyle(
    fontSize: 18,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldprimary20 => _buildTextStyle(
    fontSize: 20,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldprimary22 => _buildTextStyle(
    fontSize: 22,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldprimary24 => _buildTextStyle(
    fontSize: 24,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldprimary26 => _buildTextStyle(
    fontSize: 26,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldprimary28 => _buildTextStyle(
    fontSize: 28,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldprimary30 => _buildTextStyle(
    fontSize: 30,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldprimary32 => _buildTextStyle(
    fontSize: 32,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldprimary34 => _buildTextStyle(
    fontSize: 34,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldprimary36 => _buildTextStyle(
    fontSize: 36,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldprimary38 => _buildTextStyle(
    fontSize: 38,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
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
    fontWeight: FontWeight.bold,
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
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldWhite14 => _buildTextStyle(
    fontSize: 14,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldWhite16 => _buildTextStyle(
    fontSize: 16,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldWhite18 => _buildTextStyle(
    fontSize: 18,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldWhite20 => _buildTextStyle(
    fontSize: 20,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldWhite22 => _buildTextStyle(
    fontSize: 22,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldWhite24 => _buildTextStyle(
    fontSize: 24,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldWhite26 => _buildTextStyle(
    fontSize: 26,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldWhite28 => _buildTextStyle(
    fontSize: 28,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldWhite30 => _buildTextStyle(
    fontSize: 30,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldWhite32 => _buildTextStyle(
    fontSize: 32,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldWhite34 => _buildTextStyle(
    fontSize: 34,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldWhite36 => _buildTextStyle(
    fontSize: 36,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get boldWhite38 => _buildTextStyle(
    fontSize: 38,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.bold,
  );
}
