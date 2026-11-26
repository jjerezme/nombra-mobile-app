import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:nombra/features/account/data/auth_gateway.dart';
import 'package:nombra/features/account/data/backup_gateway.dart';
import 'package:nombra/features/account/data/backup_sync.dart';
import 'package:nombra/features/account/domain/account_models.dart';

const AccountUser testUser = AccountUser(uid: 'u1', email: 'ana@ejemplo.com', displayName: 'Ana Pérez');

class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({this.isAvailable = true, AccountUser? signedIn}) : _current = signedIn;

  @override
  final bool isAvailable;

  AccountUser? _current;
  final StreamController<AccountUser?> _changes = StreamController<AccountUser?>.broadcast();

  /// What the next [signInWithGoogle] does when it should not succeed.
  SignInFailure? failWith;

  /// When set, sign-in and sign-out wait for it, so a test can look at the screen while they run.
  Completer<void>? gate;

  @override
  AccountUser? get currentUser => _current;

  @override
  Stream<AccountUser?> get userChanges => _changes.stream;

  void emit(AccountUser? user) {
    _current = user;
    _changes.add(user);
  }

  @override
  Future<AccountUser> signInWithGoogle() async {
    await gate?.future;
    final failure = failWith;
    if (failure != null) throw SignInException(failure);
    emit(testUser);
    return testUser;
  }

  @override
  Future<void> signOut() async {
    await gate?.future;
    emit(null);
  }

  bool failDeleteAccount = false;
  bool isDeleted = false;

  @override
  Future<void> reauthenticate() async {
    await gate?.future;
    final failure = failWith;
    if (failure != null) throw SignInException(failure);
  }

  @override
  Future<void> deleteAccount() async {
    if (failDeleteAccount) throw StateError('offline');
    isDeleted = true;
    emit(null);
  }
}

class FakeBackupGateway implements BackupGateway {
  final Map<String, RulesBackup> stored = {};
  final List<({String uid, String rulesJson, String writer})> saves = [];
  final List<String> deleted = [];
  final StreamController<RulesBackup?> _changes = StreamController<RulesBackup?>.broadcast();
  bool failSave = false;
  bool failFetch = false;
  bool failDelete = false;

  /// When set, deleting waits for it.
  Completer<void>? deleteGate;

  /// A write made from another device: it is stored and reported to the listeners.
  void remoteWrite(String uid, String rulesJson, {String writer = 'other-device'}) {
    final backup = RulesBackup(rulesJson: rulesJson, writer: writer, updatedAt: DateTime.now());
    stored[uid] = backup;
    _changes.add(backup);
  }

  @override
  Future<RulesBackup?> fetch(String uid) async {
    if (failFetch) throw StateError('offline');
    return stored[uid];
  }

  @override
  Stream<RulesBackup?> watch(String uid) => _changes.stream;

  @override
  Future<void> save(String uid, {required String rulesJson, required String writer}) async {
    if (failSave) throw StateError('offline');
    saves.add((uid: uid, rulesJson: rulesJson, writer: writer));
    stored[uid] = RulesBackup(rulesJson: rulesJson, writer: writer, updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(String uid) async {
    await deleteGate?.future;
    if (failDelete) throw StateError('offline');
    deleted.add(uid);
    stored.remove(uid);
  }
}

/// Overrides that put the fake account and backup in place, with no wait before the rules are sent.
List<Override> accountOverrides(FakeAuthGateway auth, FakeBackupGateway backup) => [
  authGatewayProvider.overrideWithValue(auth),
  backupGatewayProvider.overrideWithValue(backup),
  backupDebounceProvider.overrideWithValue(Duration.zero),
  backupDeviceIdProvider.overrideWithValue('this-device'),
];
