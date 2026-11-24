import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/format.dart';
import '../../../core/relative_time.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../rules/domain/file_kind.dart';
import '../domain/download_models.dart';

String kindLabel(AppLocalizations l10n, FileKind kind) => switch (kind) {
  FileKind.image => l10n.kindImage,
  FileKind.video => l10n.kindVideo,
  FileKind.audio => l10n.kindAudio,
  FileKind.document => l10n.kindDocument,
  FileKind.other => l10n.kindOther,
};

String errorMessage(AppLocalizations l10n, DownloadItem item) => switch (item.error) {
  DownloadError.notFound => l10n.homeNotFound,
  DownloadError.http => item.httpCode == null ? l10n.homeFailed : l10n.homeFailedHttp(item.httpCode!),
  DownloadError.save => l10n.homeFailedSave,
  DownloadError.failed || null => l10n.homeFailed,
};

/// One row of the recent downloads: progress, saved, or failed.
class DownloadTile extends StatelessWidget {
  const DownloadTile({required this.item, required this.onRetry, super.key});

  final DownloadItem item;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (item.status) {
      DownloadStatus.done => _ResultTile(item: item, isError: false, onRetry: onRetry),
      DownloadStatus.failed => _ResultTile(item: item, isError: true, onRetry: onRetry),
      _ => _ProgressTile(item: item),
    };
  }
}

/// Progress text: "48,2 de 77,6 MB · 3,1 MB/s", or a waiting / saving message.
String progressDetail(AppLocalizations l10n, DownloadItem item, String locale) {
  if (item.status == DownloadStatus.finalizing) return l10n.homeFinishing;
  final received = item.receivedBytes;
  final speed = item.speedMegabytes;
  if (received == null || speed == null) return l10n.homeWaiting;
  final receivedText = formatBytes(received, locale);
  final speedText = formatSpeed(speed, locale);
  final total = item.totalBytes;
  return total == null
      ? l10n.homeProgressNoTotal(receivedText, speedText)
      : l10n.homeProgress(receivedText, formatBytes(total, locale), speedText);
}

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({required this.item});

  final DownloadItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final isIndeterminate = item.status != DownloadStatus.running || item.progress <= 0;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.sm,
        children: [
          Row(
            spacing: AppSpacing.sm,
            children: [
              Expanded(
                child: Text(
                  item.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.monoStyles.mono,
                ),
              ),
              if (!isIndeterminate)
                Text(
                  '${(item.progress * 100).round()} %',
                  style: context.text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: isIndeterminate ? null : item.progress,
              minHeight: AppSize.progress,
              color: colors.primary,
              backgroundColor: colors.surfaceContainerHigh,
            ),
          ),
          Text(
            progressDetail(l10n, item, Localizations.localeOf(context).toString()),
            style: context.text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.item, required this.isError, required this.onRetry});

  final DownloadItem item;
  final bool isError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final fallback = item.fallbackKind;
    final subtitle = isError
        ? errorMessage(l10n, item)
        : [
            l10n.homeSavedIn(item.folderPath, relativeTime(l10n, item.finishedAt ?? item.createdAt, DateTime.now())),
            if (fallback != null) l10n.homeFallbackDownload(kindLabel(l10n, fallback)),
          ].join('\n');
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        spacing: AppSpacing.md,
        children: [
          Container(
            width: AppSize.tile,
            height: AppSize.tile,
            decoration: BoxDecoration(
              color: isError ? colors.errorContainer : colors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              isError ? Icons.error_outline : Icons.check,
              size: AppIconSize.base,
              color: isError ? colors.error : colors.primary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.monoStyles.mono),
                Text(
                  subtitle,
                  style: context.text.bodySmall?.copyWith(color: isError ? colors.error : colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (isError && item.plan.url != null) TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
