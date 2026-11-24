// Design tokens. scripts/check_styles.dart fails when a screen uses a number
// outside these scales. Colors come only from Theme.of(context).colorScheme.

abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double tight = 6;
  static const double sm = 8;
  static const double snug = 10;
  static const double md = 12;
  static const double cozy = 14;
  static const double lg = 16;
  static const double roomy = 18;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

abstract final class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;
  static const double sheet = 28;
  static const double pill = 999;
}

abstract final class AppIconSize {
  static const double sm = 16;
  static const double base = 20;
  static const double md = 24;
  static const double lg = 32;
}

abstract final class AppFontSize {
  static const double xs = 11;
  static const double sm = 12;
  static const double caption = 13;
  static const double md = 14;
  static const double body = 15;
  static const double lg = 16;
  static const double title = 18;
  static const double xl = 20;
  static const double headline = 22;
  static const double xxl = 28;
}

/// Fixed component dimensions, in dp.
abstract final class AppSize {
  static const double control = 48;
  static const double button = 52;
  static const double fab = 56;
  static const double navBar = 72;
  static const double tile = 36;
  static const double thumb = 52;

  /// The app logo next to a title.
  static const double logo = 32;
  static const double progress = 6;
  static const double handleWidth = 36;
  static const double handleHeight = 4;
  static const double dragHandle = 24;
}

/// Minimum touch target, in dp.
const double minTouchTarget = 48;

/// Layout rules shared by every screen, so spacing and shape feel the same everywhere. Use these instead of picking
/// a value from the scales above.
abstract final class AppLayout {
  /// Space between the screen edge and the content of a page or a sheet's card row.
  static const double gutter = AppSpacing.lg;

  /// Space between the blocks of a page, and between the blocks inside a card.
  static const double sectionGap = AppSpacing.lg;

  /// Space between the items of a list (rules, downloads).
  static const double itemGap = AppSpacing.sm;

  /// Space between a field label and its control (and between a control and its hint).
  static const double labelGap = AppSpacing.sm;

  /// Space between the edge of a card and its content.
  static const double cardPadding = AppSpacing.lg;

  /// Corner radius of cards and large surfaces.
  static const double cardRadius = AppRadius.xl;

  /// Corner radius of controls: buttons, fields, boxes inside a card.
  static const double controlRadius = AppRadius.lg;

  /// Horizontal space of a bottom sheet.
  static const double sheetGutter = AppSpacing.xl;

  /// Space between buttons in a row.
  static const double buttonGap = AppSpacing.md;
}
