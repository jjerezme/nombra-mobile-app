import 'package:material_ui/material_ui.dart';

import '../constants/tokens.dart';

/// The Nombra "N" mark, drawn from `assets/images/logo.png`. Decorative: the name of the app is always next to it.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = AppSize.logo});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.high,
      excludeFromSemantics: true,
    );
  }
}
