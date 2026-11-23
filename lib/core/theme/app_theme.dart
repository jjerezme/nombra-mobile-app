import 'package:material_ui/material_ui.dart';

import '../constants/tokens.dart';

/// Single source of the app's light and dark themes.
abstract final class AppTheme {
  static const Color _seed = Color(0xFF3F51B5);

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: AppFontSize.xxl,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(fontSize: AppFontSize.lg),
      ),
    );
  }
}
