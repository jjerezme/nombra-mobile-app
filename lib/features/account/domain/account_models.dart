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

/// What the person asked for and is still running; the account screen shows it with a progress indicator.
enum AccountAction { signIn, signOut, deleteBackup, deleteAccount }

class SyncState {
  const SyncState({this.phase = SyncPhase.off, this.lastSyncedAt, this.action});

  final SyncPhase phase;
  final DateTime? lastSyncedAt;

  /// Null when nothing is running.
  final AccountAction? action;

  bool get isBusy => action != null;

  SyncState copyWith({SyncPhase? phase, DateTime? lastSyncedAt, AccountAction? action, bool clearAction = false}) =>
      SyncState(
        phase: phase ?? this.phase,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        action: clearAction ? null : action ?? this.action,
      );
}
