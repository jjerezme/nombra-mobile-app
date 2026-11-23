// Design tokens. scripts/check_styles.dart fails when a screen uses a number
// outside these scales. Colors come only from Theme.of(context).colorScheme.

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

abstract final class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double pill = 999;
}

abstract final class AppIconSize {
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
}

abstract final class AppFontSize {
  static const double sm = 12;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
}

/// Minimum touch target, in dp.
const double minTouchTarget = 48;
