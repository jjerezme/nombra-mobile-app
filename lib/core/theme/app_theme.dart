import 'package:material_ui/material_ui.dart';

import '../constants/tokens.dart';

abstract final class AppFonts {
  static const String sans = 'IBMPlexSans';
  static const String mono = 'JetBrainsMono';
}

FontWeight _fontWeight(double weight) => FontWeight.values[(weight ~/ 100) - 1];

// The fonts are variable files: the weight axis is set explicitly.
TextStyle _style(String family, double size, double weight, {double? height, double? letterSpacing}) => TextStyle(
  fontFamily: family,
  fontSize: size,
  fontWeight: _fontWeight(weight),
  fontVariations: [FontVariation.weight(weight)],
  height: height,
  letterSpacing: letterSpacing,
);

/// Monospaced styles used for file names, patterns and paths.
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({required this.mono, required this.monoSmall, required this.monoLarge});

  final TextStyle mono;
  final TextStyle monoSmall;
  final TextStyle monoLarge;

  static final AppTextStyles standard = AppTextStyles(
    mono: _style(AppFonts.mono, AppFontSize.caption, 500),
    monoSmall: _style(AppFonts.mono, AppFontSize.sm, 400),
    monoLarge: _style(AppFonts.mono, AppFontSize.body, 500),
  );

  @override
  AppTextStyles copyWith({TextStyle? mono, TextStyle? monoSmall, TextStyle? monoLarge}) => AppTextStyles(
    mono: mono ?? this.mono,
    monoSmall: monoSmall ?? this.monoSmall,
    monoLarge: monoLarge ?? this.monoLarge,
  );

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) return this;
    return AppTextStyles(
      mono: TextStyle.lerp(mono, other.mono, t)!,
      monoSmall: TextStyle.lerp(monoSmall, other.monoSmall, t)!,
      monoLarge: TextStyle.lerp(monoLarge, other.monoLarge, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  AppTextStyles get monoStyles => Theme.of(this).extension<AppTextStyles>()!;
}

/// Single source of the app's light and dark themes.
abstract final class AppTheme {
  static const ColorScheme _light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0B6E5F),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE1EFEB),
    onPrimaryContainer: Color(0xFF08564A),
    secondary: Color(0xFF4A5058),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFEEF5F3),
    onSecondaryContainer: Color(0xFF3F5A54),
    tertiary: Color(0xFF3A3F45),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFA4400F),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFBEDE6),
    onErrorContainer: Color(0xFFA4400F),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF15171A),
    onSurfaceVariant: Color(0xFF4A5058),
    outline: Color(0xFFC9CECA),
    outlineVariant: Color(0xFFD5D9D6),
    shadow: Color(0xFF15171A),
    scrim: Color(0xFF0F1113),
    inverseSurface: Color(0xFF15171A),
    onInverseSurface: Color(0xFFFFFFFF),
    inversePrimary: Color(0xFF9FE3D3),
    surfaceContainerLowest: Color(0xFFFAFBFA),
    surfaceContainerLow: Color(0xFFF5F6F4),
    surfaceContainer: Color(0xFFEEF0EE),
    surfaceContainerHigh: Color(0xFFE3E7E4),
    surfaceContainerHighest: Color(0xFFEEF0EE),
  );

  static const ColorScheme _dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF5FD0BC),
    onPrimary: Color(0xFF00382F),
    primaryContainer: Color(0xFF0B4A40),
    onPrimaryContainer: Color(0xFFB5EFE3),
    secondary: Color(0xFFB9C0C6),
    onSecondary: Color(0xFF1B1F22),
    secondaryContainer: Color(0xFF1D2A27),
    onSecondaryContainer: Color(0xFFB5D6CE),
    tertiary: Color(0xFFD0D5D9),
    onTertiary: Color(0xFF1B1F22),
    error: Color(0xFFFFB59A),
    onError: Color(0xFF561E00),
    errorContainer: Color(0xFF4A2410),
    onErrorContainer: Color(0xFFFFB59A),
    surface: Color(0xFF1B1F1E),
    onSurface: Color(0xFFE6E9E7),
    onSurfaceVariant: Color(0xFFB9C0C6),
    outline: Color(0xFF5A615F),
    outlineVariant: Color(0xFF3B4240),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE6E9E7),
    onInverseSurface: Color(0xFF15171A),
    inversePrimary: Color(0xFF0B6E5F),
    surfaceContainerLowest: Color(0xFF151918),
    surfaceContainerLow: Color(0xFF111413),
    surfaceContainer: Color(0xFF262B2A),
    surfaceContainerHigh: Color(0xFF2E3433),
    surfaceContainerHighest: Color(0xFF262B2A),
  );

  static ThemeData get light => _build(_light);

  static ThemeData get dark => _build(_dark);

  static ThemeData _build(ColorScheme scheme) {
    final textTheme = TextTheme(
      headlineSmall: _style(AppFonts.sans, AppFontSize.headline, 700, letterSpacing: -0.3),
      titleLarge: _style(AppFonts.sans, AppFontSize.title, 700),
      titleMedium: _style(AppFonts.sans, AppFontSize.body, 700),
      titleSmall: _style(AppFonts.sans, AppFontSize.md, 700),
      labelLarge: _style(AppFonts.sans, AppFontSize.lg, 600),
      labelMedium: _style(AppFonts.sans, AppFontSize.caption, 600),
      labelSmall: _style(AppFonts.sans, AppFontSize.sm, 500),
      bodyLarge: _style(AppFonts.sans, AppFontSize.body, 400),
      bodyMedium: _style(AppFonts.sans, AppFontSize.md, 400),
      bodySmall: _style(AppFonts.sans, AppFontSize.sm, 400, height: 1.4),
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      fontFamily: AppFonts.sans,
      scaffoldBackgroundColor: scheme.surfaceContainerLow,
      // Soft shadows, as in the design (raised segment, floating button).
      shadowColor: scheme.shadow.withValues(alpha: 0.25),
      extensions: [AppTextStyles.standard],
      // Sheets (folder picker) use the surface color, not the page color: against the dark scrim they would
      // otherwise melt into the background. The handle gives the title room under the top edge.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent, // style-ok
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: scheme.surfaceContainerLow,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSize.button),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppLayout.controlRadius)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSize.button),
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppLayout.controlRadius)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: AppFontSize.md),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(scheme.onPrimary),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? scheme.primary : scheme.outline,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? scheme.primary : null;
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        extendedTextStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppLayout.controlRadius)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppSize.navBar,
        backgroundColor: scheme.surface,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(color: states.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant);
        }),
      ),
    );
  }
}
