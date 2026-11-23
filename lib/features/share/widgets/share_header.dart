import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../rules/domain/file_kind.dart';
import '../domain/share_payload.dart';

IconData iconForKind(FileKind kind) => switch (kind) {
  FileKind.image => Icons.image_outlined,
  FileKind.video => Icons.movie_outlined,
  FileKind.audio => Icons.audiotrack_outlined,
  FileKind.document => Icons.description_outlined,
  FileKind.other => Icons.insert_drive_file_outlined,
};

/// Icon, title and a one-line description of what is being saved.
class ShareHeader extends StatelessWidget {
  const ShareHeader({required this.items, super.key});

  final List<ShareItem> items;

  String _subtitle(AppLocalizations l10n, String locale) {
    if (items.length > 1) return l10n.shareFileCount(items.length);
    final item = items.first;
    if (item.isUrl) return item.url!;
    final size = item.size;
    return size == null ? item.name : '${item.name} · ${formatBytes(size, locale)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final first = items.first;
    return Row(
      spacing: AppSpacing.md,
      children: [
        Container(
          width: AppSize.thumb,
          height: AppSize.thumb,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Icon(
            first.isUrl ? Icons.link : iconForKind(first.kind),
            size: AppIconSize.md,
            color: colors.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xxs,
            children: [
              Text(l10n.shareTitle, style: context.text.titleLarge?.copyWith(fontSize: AppFontSize.title)),
              Text(
                _subtitle(l10n, Localizations.localeOf(context).toString()),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.monoStyles.monoSmall.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
