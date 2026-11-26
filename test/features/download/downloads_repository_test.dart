import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/features/download/data/downloads_repository.dart';
import 'package:nombra/features/download/domain/download_models.dart';
import 'package:nombra/features/rules/domain/storage_root.dart';

void main() {
  final now = DateTime(2026, 11, 25, 12);

  DownloadItem item(
    String id, {
    required DateTime createdAt,
    DownloadStatus status = DownloadStatus.done,
    DateTime? finishedAt,
  }) => DownloadItem(
    id: id,
    fileName: '$id.pdf',
    status: status,
    plan: DownloadPlan(folder: DestinationFolder(StorageRoot.download)),
    createdAt: createdAt,
    finishedAt: finishedAt,
  );

  test('keeps at most historyMaxItems, newest first', () {
    final items = [
      for (var i = 0; i < historyMaxItems + 10; i++) item('d$i', createdAt: now.subtract(Duration(hours: i))),
    ];
    final kept = trimHistory(items, now);
    expect(kept, hasLength(historyMaxItems));
    expect(kept.first.id, 'd0');
  });

  test('drops finished and failed items older than the maximum age', () {
    final old = now.subtract(historyMaxAge + const Duration(days: 1));
    final kept = trimHistory([
      item('recent', createdAt: now.subtract(const Duration(days: 3))),
      item('old-done', createdAt: old),
      item('old-failed', createdAt: old, status: DownloadStatus.failed),
    ], now);
    expect(kept.map((i) => i.id), ['recent']);
  });

  test('the age is counted from when the item finished, if it did', () {
    final old = now.subtract(historyMaxAge + const Duration(days: 30));
    final kept = trimHistory([item('late', createdAt: old, finishedAt: now.subtract(const Duration(days: 1)))], now);
    expect(kept, hasLength(1));
  });

  test('a download still in flight is never dropped for its age', () {
    final old = now.subtract(historyMaxAge + const Duration(days: 10));
    final kept = trimHistory([item('running', createdAt: old, status: DownloadStatus.running)], now);
    expect(kept, hasLength(1));
  });
}
