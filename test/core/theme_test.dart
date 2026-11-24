import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nombra/core/theme/app_theme.dart';

void main() {
  for (final (name, theme) in [('light', AppTheme.light), ('dark', AppTheme.dark)]) {
    test('$name: a switch that is off has a dark thumb and an outlined track, so it does not look disabled', () {
      final scheme = theme.colorScheme;
      final switchTheme = theme.switchTheme;
      const off = <WidgetState>{};
      const on = {WidgetState.selected};

      expect(switchTheme.thumbColor?.resolve(off), scheme.onSurfaceVariant);
      expect(switchTheme.trackOutlineColor?.resolve(off), scheme.onSurfaceVariant);
      expect(switchTheme.trackColor?.resolve(on), scheme.primary);
      expect(switchTheme.thumbColor?.resolve(on), scheme.onPrimary);
    });
  }
}
