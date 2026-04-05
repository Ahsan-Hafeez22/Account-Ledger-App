import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists [ThemeMode] so the user’s choice survives restarts.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(ThemeMode.system) {
    _restore();
  }

  final SharedPreferences _prefs;
  static const String _storageKey = 'app_theme_mode';

  void _restore() {
    final stored = _prefs.getString(_storageKey);
    switch (stored) {
      case 'dark':
        emit(ThemeMode.dark);
        break;
      case 'light':
        emit(ThemeMode.light);
        break;
      default:
        emit(ThemeMode.system);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    await _prefs.setString(_storageKey, mode.name);
  }

  /// Settings switch: explicit light vs dark (not system).
  Future<void> setDarkModeEnabled(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  /// Whether the switch should look “on” (dark UI visible).
  bool isDarkActiveFor(BuildContext context) {
    if (state == ThemeMode.dark) return true;
    if (state == ThemeMode.light) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }
}
