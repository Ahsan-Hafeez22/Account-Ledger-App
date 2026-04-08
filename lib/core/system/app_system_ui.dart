import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Resolves [ThemeMode] to the UI [Brightness] (handles [ThemeMode.system]).
abstract final class AppSystemUi {
  AppSystemUi._();

  /// Effective brightness for styling system chrome (status / navigation bar).
  static Brightness effectiveBrightness(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  /// Status + navigation bar icons readable on scaffold:
  /// light UI → **dark** icons; dark UI → **light** icons.
  ///
  /// Explicit [Brightness] values avoid presets that some Android versions
  /// apply opposite to Material docs.
  static SystemUiOverlayStyle overlayStyleForUiBrightness(Brightness uiBrightness) {
    final isDark = uiBrightness == Brightness.dark;
    if (isDark) {
      return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        // Some OEMs invert Flutter’s mapping; `.dark` here yields light icons on dark UI.
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.darkSurface,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: true,
      );
    }
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // `.light` here yields dark icons on light UI (readable on white scaffold).
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: true,
    );
  }

  /// Pushes overlay style to the platform (use when theme or system brightness changes).
  static void applyThemeMode(ThemeMode mode) {
    SystemChrome.setSystemUIOverlayStyle(
      overlayStyleForUiBrightness(effectiveBrightness(mode)),
    );
  }
}
