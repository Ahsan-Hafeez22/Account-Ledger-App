import 'package:flutter/material.dart';

/// Central palette. Prefer [Theme.of(context).colorScheme] in widgets when possible;
/// use [AppColors] helpers below when you only have [Brightness] or need fixed accents.
abstract final class AppColors {
  // ─── Brand (same in light & dark) ─────────────────────────────────────────
  static const Color primary = Color(0xFF2EBD9E);
  static const Color secondary = Color(0xFF03DAC5);

  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // ─── Light mode ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF3F2F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1D212B);
  static const Color textSecondary = Color(0xFF7C8393);
  static const Color textHint = Color(0xFF9CA3AF);

  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // ─── Dark mode (Material 3–style depth) ───────────────────────────────────
  /// App scaffold / root background (behind nav & sheets).
  static const Color darkBackground = Color(0xFF0F1115);

  /// Cards, bottom sheets, nav bars.
  static const Color darkSurface = Color(0xFF1A1D24);

  /// Elevated cards / nested panels.
  static const Color darkCard = Color(0xFF242830);

  /// Subtle hover / divider on dark surfaces.
  static const Color darkSurfaceHighlight = Color(0xFF2E323C);

  static const Color darkTextPrimary = Color(0xFFE8EAED);
  static const Color darkTextSecondary = Color(0xFFB0B8C4);
  static const Color darkTextHint = Color(0xFF7C8496);

  static const Color darkBorder = Color(0xFF3D424D);
  static const Color darkDivider = Color(0xFF2A2E38);

  /// Slightly brighter primary on dark for small icons / chips.
  static const Color darkPrimaryTint = Color(0xFF4DD4B8);

  // ─── Shared / accents ──────────────────────────────────────────────────────
  static const Color disableColor = Color(0xFF9CA3AF);

  static const Color income = Color(0xFF4CAF50);
  static const Color expense = Color(0xFFE53935);
  static const Color housing = Color(0xFF6C63FF);
  static const Color food = Color(0xFFFF6B6B);
  static const Color transport = Color(0xFF4ECDC4);
  static const Color entertainment = Color(0xFFFFE66D);
  static const Color health = Color(0xFF95E1D3);
  static const Color other = Color(0xFFA8A8A8);

  static const Color accentPink = Color(0xFFE94E77);
  static const Color blackColor = Color(0xFF000000);
  static const Color whiteColor = Color(0xFFFFFFFF);

  static const Color privacyIconBg = Color(0xFFE94E77);
  static const Color securityIconBg = Color(0xFFF06292);
  static const Color accountIconBg = Color(0xFF66BB6A);
  static const Color helpIconBg = Color(0xFF4DB6AC);
  static const Color aboutIconBg = Color(0xFF80CBC4);
  static const Color notificationColor = Color(0xFFFF0000);

  // ─── Theme-aware helpers (Brightness) ─────────────────────────────────────
  static Color scaffoldBackground(Brightness brightness) =>
      brightness == Brightness.dark ? darkBackground : background;

  static Color surfaceColor(Brightness brightness) =>
      brightness == Brightness.dark ? darkSurface : surface;

  static Color cardColor(Brightness brightness) =>
      brightness == Brightness.dark ? darkCard : card;

  static Color primaryTextColor(Brightness brightness) =>
      brightness == Brightness.dark ? darkTextPrimary : textPrimary;

  static Color secondaryTextColor(Brightness brightness) =>
      brightness == Brightness.dark ? darkTextSecondary : textSecondary;

  static Color hintTextColor(Brightness brightness) =>
      brightness == Brightness.dark ? darkTextHint : textHint;

  static Color borderColor(Brightness brightness) =>
      brightness == Brightness.dark ? darkBorder : border;

  static Color dividerColor(Brightness brightness) =>
      brightness == Brightness.dark ? darkDivider : divider;
}
