import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../rules/data/rules_notifier.dart';
import '../../rules/domain/rename_rule.dart';
import '../domain/account_models.dart';
import '../domain/rules_merge.dart';
import 'auth_gateway.dart';
import 'backup_gateway.dart';

const String _deviceIdKey = 'deviceId';

/// Identifies this install in the backup, so it ignores the echo of its own writes. Kept in the preferences.
final backupDeviceIdProvider = Provider<String>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  final saved = preferences.getString(_deviceIdKey);
  if (saved != null) return saved;
  final created = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  preferences.setString(_deviceIdKey, created);
  return created;
});

/// How long after the last change the rules are sent; a change in quick succession goes in one write.
final backupDebounceProvider = Provider<Duration>((ref) => const Duration(seconds: 2));

/// Keeps the rules of the signed-in person in the cloud, automatically.
///
/// When someone signs in, the rules of this device and of the cloud are merged ([mergeRules]) once. From then on the
/// last write wins: a change here is sent after a short pause, and a change made on another device replaces the local
/// rules. Nothing is sent while nobody is signed in.
class BackupSync extends Notifier<SyncState> {
  StreamSubscription<RulesBackup?>? _remote;
  Timer? _debounce;
  String? _uid;

  /// The rules as last sent or received: a local change equal to it has nothing to send.
  String _syncedJson = '';

  @override
  SyncState build() {
    ref.onDispose(_stop);
    ref.listen(accountUserProvider, (_, next) => _onUser(next.value), fireImmediately: true);
    ref.listen(rulesProvider, (_, next) => _onLocalChange(next));
    return const SyncState();
  }

  BackupGateway get _gateway => ref.read(backupGatewayProvider);

  void _onUser(AccountUser? user) {
    if (user?.uid == _uid) return;
    _stop();
    if (user == null) {
      state = const SyncState();
    } else {
      unawaited(_start(user.uid));
    }
  }

  void _stop() {
    _debounce?.cancel();
    _debounce = null;
    unawaited(_remote?.cancel());
    _remote = null;
    _uid = null;
    _syncedJson = '';
  }

  Future<void> _start(String uid) async {
    _uid = uid;
    state = state.copyWith(phase: SyncPhase.syncing);
    try {
      final remote = await _gateway.fetch(uid);
      if (!ref.mounted || _uid != uid) return;
      final local = ref.read(rulesProvider);
      var needsUpload = local.isNotEmpty;
      if (remote != null) {
        final remoteRules = sortedByName(decodeRules(remote.rulesJson) ?? const []);
        final merged = sortedByName(mergeRules(local, remoteRules));
        final mergedJson = encodeRules(merged);
        needsUpload = mergedJson != encodeRules(remoteRules);
        // Marked as synced before the rules change, so the change is not taken for something to send.
        _syncedJson = mergedJson;
        if (mergedJson != encodeRules(local)) ref.read(rulesProvider.notifier).replaceAll(merged);
      }
      if (needsUpload) {
        await _upload();
      } else {
        if (remote == null) _syncedJson = encodeRules(local);
        state = SyncState(phase: SyncPhase.upToDate, lastSyncedAt: DateTime.now());
      }
      if (!ref.mounted || _uid != uid) return;
      _remote = _gateway
          .watch(uid)
          .listen(_onRemote, onError: (Object _) => state = state.copyWith(phase: SyncPhase.error));
    } on Object {
      if (ref.mounted && _uid == uid) state = state.copyWith(phase: SyncPhase.error);
    }
  }

  void _onRemote(RulesBackup? backup) {
    if (backup == null || backup.writer == ref.read(backupDeviceIdProvider)) return;
    final rules = decodeRules(backup.rulesJson);
    if (rules == null) return;
    final json = encodeRules(sortedByName(rules));
    if (json == encodeRules(ref.read(rulesProvider))) return;
    _syncedJson = json;
    ref.read(rulesProvider.notifier).replaceAll(rules);
    state = SyncState(phase: SyncPhase.upToDate, lastSyncedAt: DateTime.now());
  }

  void _onLocalChange(List<RenameRule> rules) {
    if (_uid == null || encodeRules(rules) == _syncedJson) return;
    _debounce?.cancel();
    state = state.copyWith(phase: SyncPhase.syncing);
    _debounce = Timer(ref.read(backupDebounceProvider), _upload);
  }

  Future<void> _upload() async {
    final uid = _uid;
    if (uid == null) return;
    final json = encodeRules(ref.read(rulesProvider));
    try {
      await _gateway.save(uid, rulesJson: json, writer: ref.read(backupDeviceIdProvider));
      if (!ref.mounted || _uid != uid) return;
      _syncedJson = json;
      state = SyncState(phase: SyncPhase.upToDate, lastSyncedAt: DateTime.now());
    } on Object {
      if (ref.mounted && _uid == uid) state = state.copyWith(phase: SyncPhase.error);
    }
  }

  /// Tries again after an error.
  Future<void> retry() async {
    final uid = _uid;
    if (uid == null) return;
    _stop();
    await _start(uid);
  }

  /// Runs [body] while the screen shows [action] as in progress.
  Future<void> _perform(AccountAction action, Future<void> Function() body) async {
    state = state.copyWith(action: action);
    try {
      await body();
    } finally {
      if (ref.mounted) state = state.copyWith(clearAction: true);
    }
  }

  /// Opens the Google account picker. Throws [SignInException] when it is cancelled or fails.
  Future<void> signIn() => _perform(AccountAction.signIn, () async {
    await ref.read(authGatewayProvider).signInWithGoogle();
  });

  /// Leaves the account; the backup stays in the cloud and the local rules stay on the device.
  Future<void> signOut() => _perform(AccountAction.signOut, () => ref.read(authGatewayProvider).signOut());

  /// Deletes the backup from the cloud and leaves the account; the local rules stay on the device.
  Future<void> deleteBackupAndSignOut() => _perform(AccountAction.deleteBackup, () async {
    final uid = _uid;
    if (uid != null) {
      _stop();
      await _gateway.delete(uid);
    }
    await ref.read(authGatewayProvider).signOut();
  });
}

final backupSyncProvider = NotifierProvider<BackupSync, SyncState>(BackupSync.new);
