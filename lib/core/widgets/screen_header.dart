import 'package:material_ui/material_ui.dart';

import '../constants/tokens.dart';
import '../theme/app_theme.dart';

/// Padding of a scrolling page. The title of [ScreenHeader] sits [AppSpacing.xs] further in, so it lines up with the
/// text inside the cards below it.
abstract final class AppPage {
  /// Page that starts with a plain title (the tabs).
  static const EdgeInsets padding = EdgeInsets.fromLTRB(
    AppLayout.gutter,
    AppSpacing.xl,
    AppLayout.gutter,
    AppSpacing.xxl,
  );

  /// Page that starts with the back/actions row of [ScreenHeader], which already has its own height.
  static const EdgeInsets paddingWithBack = EdgeInsets.fromLTRB(
    AppLayout.gutter,
    AppSpacing.xs,
    AppLayout.gutter,
    AppSpacing.xxl,
  );
}

/// Title of a screen: the same size, position and spacing everywhere. A detail screen adds a back button on the left
/// and an action on the right, in a row above the title.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
    this.onBack,
    this.backTooltip,
    this.action,
  });

  final String title;
  final String? subtitle;

  /// A mark on the right of the title (the logo, on the first screen). The title stays where it is on every screen.
  final Widget? trailing;

  /// Shows the back button when set; [backTooltip] is its label.
  final VoidCallback? onBack;
  final String? backTooltip;

  /// A button on the right of the back row (for example "Save").
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle;
    final hasRow = onBack != null || action != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasRow)
          Row(
            children: [
              if (onBack != null)
                // Flush with the left edge of the content, like the rest of the components.
                IconButton(
                  onPressed: onBack,
                  tooltip: backTooltip,
                  icon: const Icon(Icons.arrow_back),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  constraints: const BoxConstraints.tightFor(width: minTouchTarget, height: minTouchTarget),
                ),
              const Spacer(),
              ?action,
            ],
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xs, 0, AppSpacing.xs, AppLayout.sectionGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xs,
            children: [
              if (trailing == null)
                Text(title, style: context.text.headlineSmall)
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.md,
                  children: [
                    Expanded(child: Text(title, style: context.text.headlineSmall)),
                    ?trailing,
                  ],
                ),
              if (subtitleText != null)
                Text(subtitleText, style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Title of a group of content, above its card: same style on every screen. [action] goes on the right.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: action == null ? 0 : minTouchTarget),
        child: Row(
          children: [
            Expanded(child: Text(title, style: context.text.titleMedium)),
            ?action,
          ],
        ),
      ),
    );
  }
}

/// A [SectionTitle] followed by its content, with the standard gap between them.
class AppSection extends StatelessWidget {
  const AppSection({required this.title, required this.child, super.key, this.action});

  final String title;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppLayout.labelGap,
      children: [
        SectionTitle(title, action: action),
        child,
      ],
    );
  }
}
