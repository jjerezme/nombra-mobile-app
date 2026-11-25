/// The person signed in with Google.
class AccountUser {
  const AccountUser({required this.uid, this.email, this.displayName, this.photoUrl});

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  /// What the account screen calls the person: the name, else the e-mail.
  String get label => (displayName?.trim().isNotEmpty ?? false) ? displayName!.trim() : (email ?? '');
}

/// The rules as they are stored in the cloud: the whole list as JSON, and who wrote it last.
class RulesBackup {
  const RulesBackup({required this.rulesJson, required this.writer, this.updatedAt});

  final String rulesJson;

  /// Id of the device that wrote it, so a device ignores the echo of its own write.
  final String writer;
  final DateTime? updatedAt;
}

/// Where the automatic backup stands.
enum SyncPhase { off, syncing, upToDate, error }

class SyncState {
  const SyncState({this.phase = SyncPhase.off, this.lastSyncedAt});

  final SyncPhase phase;
  final DateTime? lastSyncedAt;

  SyncState copyWith({SyncPhase? phase, DateTime? lastSyncedAt}) =>
      SyncState(phase: phase ?? this.phase, lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt);
}
