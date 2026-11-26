import 'dart:io';

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
    final thumbnailPath = items.length == 1 && first.kind == FileKind.image ? first.path : null;
    return Row(
      spacing: AppSpacing.md,
      children: [
        // A shared image shows its own thumbnail; anything else shows the icon of its kind.
        Container(
          width: AppSize.thumb,
          height: AppSize.thumb,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppLayout.controlRadius),
          ),
          child: thumbnailPath == null
              ? _KindIcon(item: first)
              : Image.file(
                  File(thumbnailPath),
                  fit: BoxFit.cover,
                  // Decoded at thumbnail size, not at the size of the photo.
                  cacheWidth: AppSize.thumb.toInt() * 3,
                  errorBuilder: (context, error, stackTrace) => _KindIcon(item: first),
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
                style: context.monoStyles.monoSmall.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KindIcon extends StatelessWidget {
  const _KindIcon({required this.item});

  final ShareItem item;

  @override
  Widget build(BuildContext context) {
    return Icon(
      item.isUrl ? Icons.link : iconForKind(item.kind),
      size: AppIconSize.md,
      color: context.colors.onSurfaceVariant,
    );
  }
}
