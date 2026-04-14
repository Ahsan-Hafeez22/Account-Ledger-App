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
  /// light UI → dark icons; dark UI → light icons.
  ///
  /// Matches [SystemUiOverlayStyle.light] / [SystemUiOverlayStyle.dark] semantics
  /// (`statusBarIconBrightness`: light = light-colored icons for dark backgrounds).
  static SystemUiOverlayStyle overlayStyleForUiBrightness(Brightness uiBrightness) {
    final isDark = uiBrightness == Brightness.dark;
    if (isDark) {
      return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.darkSurface,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: true,
      );
    }
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
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
