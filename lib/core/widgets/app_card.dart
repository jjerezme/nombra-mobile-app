import 'package:material_ui/material_ui.dart';

import '../constants/tokens.dart';

/// The Material 3 [Card] with the app's padding (the card shape and color come from the theme). It groups related
/// content; with [onTap] the whole card is tappable.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppLayout.cardPadding),
    this.color,
    this.onTap,
  });

  /// A card whose content is a column of blocks separated by the standard gap.
  AppCard.stack({required List<Widget> children, Key? key, EdgeInsetsGeometry? padding, Color? color})
    : this(
        key: key,
        padding: padding ?? const EdgeInsets.all(AppLayout.cardPadding),
        color: color,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: AppLayout.sectionGap, children: children),
      );

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  /// Makes the whole card tappable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Card(
      color: color,
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
