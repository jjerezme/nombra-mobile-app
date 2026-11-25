import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/download_models.dart';

const String _downloadsKey = 'downloads';

/// Most items the history keeps.
const int historyMaxItems = 50;

/// Finished and failed items older than this are dropped from the history.
const Duration historyMaxAge = Duration(days: 90);

/// The history as it is kept: newest first, at most [historyMaxItems], and without finished or failed items older than
/// [historyMaxAge]. Downloads still in flight are never dropped for their age.
List<DownloadItem> trimHistory(List<DownloadItem> items, DateTime now) {
  final oldest = now.subtract(historyMaxAge);
  return items
      .where((item) => item.isActive || (item.finishedAt ?? item.createdAt).isAfter(oldest))
      .take(historyMaxItems)
      .toList();
}

/// Reads and writes the download history in `shared_preferences`.
class DownloadsRepository {
  const DownloadsRepository(this._ref);

  final Ref _ref;

  List<DownloadItem> load() {
    final raw = _ref.read(sharedPreferencesProvider).getString(_downloadsKey);
    if (raw == null) return const [];
    try {
      final items = (jsonDecode(raw) as List<dynamic>)
          .map((json) => DownloadItem.fromJson(json as Map<String, dynamic>))
          .toList();
      return trimHistory(items, DateTime.now());
    } on Object {
      return const [];
    }
  }

  /// Saves [items] (already trimmed by [trimHistory]).
  void save(List<DownloadItem> items) {
    _ref
        .read(sharedPreferencesProvider)
        .setString(_downloadsKey, jsonEncode(items.map((item) => item.toJson()).toList()));
  }
}

final downloadsRepositoryProvider = Provider<DownloadsRepository>(DownloadsRepository.new);
