part of 'app_fonts.dart';

/// Theme-aware “black” / “grey” typography (sizes + weights match legacy `AppFonts.*`).
///
/// Use **`context.appFonts.boldBlack24`** (etc.) so colors follow light/dark [Theme].
/// Brand [AppFonts.primary*] and on-brand [AppFonts.white*] stay static on [AppFonts].
class AppFontsRef {
  AppFontsRef(this._context);
  final BuildContext _context;

  Brightness get _b => Theme.of(_context).brightness;

  Color get _ink => AppColors.primaryTextColor(_b);
  Color get _muted => AppColors.secondaryTextColor(_b);

  TextStyle _ts(double fontSize, FontWeight fontWeight, Color color) {
    return AppFonts._buildTextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  TextStyle _nInk(double s) => _ts(s, FontWeight.normal, _ink);
  TextStyle _mInk(double s) => _ts(s, FontWeight.w500, _ink);
  TextStyle _bInk(double s) => _ts(s, FontWeight.bold, _ink);
  TextStyle _nMuted(double s) => _ts(s, FontWeight.normal, _muted);
  TextStyle _mMuted(double s) => _ts(s, FontWeight.w500, _muted);
  TextStyle _bMuted(double s) => _ts(s, FontWeight.bold, _muted);

  TextStyle get mediumBlack10 => _mInk(10);
  TextStyle get mediumBlack12 => _mInk(12);
  TextStyle get mediumBlack14 => _mInk(14);
  TextStyle get mediumBlack16 => _mInk(16);
  TextStyle get mediumBlack18 => _mInk(18);
  TextStyle get mediumBlack20 => _mInk(20);
  TextStyle get mediumBlack22 => _mInk(22);
  TextStyle get mediumBlack24 => _mInk(24);
  TextStyle get mediumBlack26 => _mInk(26);
  TextStyle get mediumBlack28 => _mInk(28);
  TextStyle get mediumBlack30 => _mInk(30);
  TextStyle get mediumBlack32 => _mInk(32);
  TextStyle get mediumBlack34 => _mInk(34);
  TextStyle get mediumBlack36 => _mInk(36);
  TextStyle get mediumBlack38 => _mInk(38);

  TextStyle get black10 => _nInk(10);
  TextStyle get black12 => _nInk(12);
  TextStyle get black14 => _nInk(14);
  TextStyle get black16 => _nInk(16);
  TextStyle get black18 => _nInk(18);
  TextStyle get black20 => _nInk(20);
  TextStyle get black22 => _nInk(22);
  TextStyle get black24 => _nInk(24);
  TextStyle get black26 => _nInk(26);
  TextStyle get black28 => _nInk(28);
  TextStyle get black30 => _nInk(30);
  TextStyle get black32 => _nInk(32);
  TextStyle get black34 => _nInk(34);
  TextStyle get black36 => _nInk(36);
  TextStyle get black38 => _nInk(38);

  TextStyle get boldBlack10 => _bInk(10);
  TextStyle get boldBlack12 => _bInk(12);
  TextStyle get boldBlack14 => _bInk(14);
  TextStyle get boldBlack16 => _bInk(16);
  TextStyle get boldBlack18 => _bInk(18);
  TextStyle get boldBlack20 => _bInk(20);
  TextStyle get boldBlack22 => _bInk(22);
  TextStyle get boldBlack24 => _bInk(24);
  TextStyle get boldBlack26 => _bInk(26);
  TextStyle get boldBlack28 => _bInk(28);
  TextStyle get boldBlack30 => _bInk(30);
  TextStyle get boldBlack32 => _bInk(32);
  TextStyle get boldBlack34 => _bInk(34);
  TextStyle get boldBlack36 => _bInk(36);
  TextStyle get boldBlack38 => _bInk(38);

  TextStyle get grey10 => _nMuted(10);
  TextStyle get grey11 => _nMuted(11);
  TextStyle get grey12 => _nMuted(12);
  TextStyle get grey13 => _nMuted(13);
  TextStyle get grey14 => _nMuted(14);
  TextStyle get grey16 => _nMuted(16);
  TextStyle get grey18 => _nMuted(18);
  TextStyle get grey20 => _nMuted(20);
  TextStyle get grey22 => _nMuted(22);
  TextStyle get grey24 => _nMuted(24);
  TextStyle get grey26 => _nMuted(26);
  TextStyle get grey28 => _nMuted(28);
  TextStyle get grey30 => _nMuted(30);
  TextStyle get grey32 => _nMuted(32);
  TextStyle get grey34 => _nMuted(34);
  TextStyle get grey36 => _nMuted(36);
  TextStyle get grey38 => _bMuted(38);

  TextStyle get mediumGrey10 => _mMuted(10);
  TextStyle get mediumGrey12 => _mMuted(12);
  TextStyle get mediumGrey14 => _mMuted(14);
  TextStyle get mediumGrey16 => _mMuted(16);
  TextStyle get mediumGrey18 => _mMuted(18);
  TextStyle get mediumGrey20 => _mMuted(20);
  TextStyle get mediumGrey22 => _mMuted(22);
  TextStyle get mediumGrey24 => _mMuted(24);
  TextStyle get mediumGrey26 => _mMuted(26);
  TextStyle get mediumGrey28 => _mMuted(28);
  TextStyle get mediumGrey30 => _mMuted(30);
  TextStyle get mediumGrey32 => _mMuted(32);
  TextStyle get mediumGrey34 => _mMuted(34);
  TextStyle get mediumGrey36 => _mMuted(36);
  TextStyle get mediumGrey38 => _mMuted(38);

  TextStyle get boldGrey12 => _bMuted(12);
  TextStyle get boldGrey14 => _bMuted(14);
  TextStyle get boldGrey16 => _bMuted(16);
  TextStyle get boldGrey18 => _bMuted(18);
  TextStyle get boldGrey20 => _bMuted(20);
  TextStyle get boldGrey22 => _bMuted(22);
  TextStyle get boldGrey24 => _bMuted(24);
  TextStyle get boldGrey26 => _bMuted(26);
  TextStyle get boldGrey28 => _bMuted(28);
  TextStyle get boldGrey30 => _bMuted(30);
  TextStyle get boldGrey32 => _bMuted(32);
  TextStyle get boldGrey34 => _bMuted(34);
  TextStyle get boldGrey36 => _bMuted(36);
  TextStyle get boldGrey38 => _bMuted(38);
}

extension AppFontsContextX on BuildContext {
  /// Theme-aware body/heading styles (`black*`, `grey*`, `mediumBlack*`, …).
  AppFontsRef get appFonts => AppFontsRef(this);
}

extension ContextThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get scheme => Theme.of(this).colorScheme;

  Color get scaffoldBg => Theme.of(this).scaffoldBackgroundColor;

  Color get surfaceBg => Theme.of(this).colorScheme.surface;
}
