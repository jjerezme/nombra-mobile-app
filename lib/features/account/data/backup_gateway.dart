import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/account_models.dart';
import 'auth_gateway.dart';

/// The cloud copy of a person's rules, isolated so it can be faked in tests.
abstract interface class BackupGateway {
  Future<RulesBackup?> fetch(String uid);

  /// The backup as it changes. Writes made by this same device that are still pending are not reported.
  Stream<RulesBackup?> watch(String uid);

  Future<void> save(String uid, {required String rulesJson, required String writer});

  /// Deletes the backup of [uid] from the cloud.
  Future<void> delete(String uid);
}

class UnavailableBackupGateway implements BackupGateway {
  const UnavailableBackupGateway();

  @override
  Future<RulesBackup?> fetch(String uid) async => null;

  @override
  Stream<RulesBackup?> watch(String uid) => const Stream.empty();

  @override
  Future<void> save(String uid, {required String rulesJson, required String writer}) async {}

  @override
  Future<void> delete(String uid) async {}
}

/// One document per person, `users/{uid}`; the rules are one JSON string so they come back exactly as they went.
class FirestoreBackupGateway implements BackupGateway {
  FirestoreBackupGateway([FirebaseFirestore? firestore]) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) => _firestore.collection('users').doc(uid);

  static RulesBackup? _read(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    final json = data?['rulesJson'];
    if (data == null || json is! String) return null;
    return RulesBackup(
      rulesJson: json,
      writer: data['writer'] as String? ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Future<RulesBackup?> fetch(String uid) async => _read(await _doc(uid).get());

  @override
  Stream<RulesBackup?> watch(String uid) =>
      _doc(uid).snapshots().where((snapshot) => !snapshot.metadata.hasPendingWrites).map(_read);

  @override
  Future<void> save(String uid, {required String rulesJson, required String writer}) =>
      _doc(uid).set({'rulesJson': rulesJson, 'writer': writer, 'schema': 1, 'updatedAt': FieldValue.serverTimestamp()});

  @override
  Future<void> delete(String uid) => _doc(uid).delete();
}

final backupGatewayProvider = Provider<BackupGateway>(
  (ref) => ref.watch(firebaseAvailableProvider) ? FirestoreBackupGateway() : const UnavailableBackupGateway(),
);
