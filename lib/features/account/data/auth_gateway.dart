import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/account_models.dart';

/// Why signing in did not finish.
enum SignInFailure { cancelled, failed }

class SignInException implements Exception {
  const SignInException(this.failure);

  final SignInFailure failure;
}

/// Sign-in with a Google account, isolated so it can be faked in tests.
abstract interface class AuthGateway {
  /// Whether this build has Firebase (a `google-services.json` for its flavor).
  bool get isAvailable;

  AccountUser? get currentUser;

  /// The signed-in person, or null; emits again when it changes.
  Stream<AccountUser?> get userChanges;

  /// Opens the Google account picker; throws [SignInException] when it is cancelled or fails.
  Future<AccountUser> signInWithGoogle();

  Future<void> signOut();
}

/// Used when Firebase did not start: nobody can sign in.
class UnavailableAuthGateway implements AuthGateway {
  const UnavailableAuthGateway();

  @override
  bool get isAvailable => false;

  @override
  AccountUser? get currentUser => null;

  @override
  Stream<AccountUser?> get userChanges => Stream.value(null);

  @override
  Future<AccountUser> signInWithGoogle() => Future.error(const SignInException(SignInFailure.failed));

  @override
  Future<void> signOut() async {}
}

class FirebaseAuthGateway implements AuthGateway {
  FirebaseAuthGateway({FirebaseAuth? auth, GoogleSignIn? google})
    : _auth = auth ?? FirebaseAuth.instance,
      _google = google ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _google;
  Future<void>? _initialized;

  @override
  bool get isAvailable => true;

  static AccountUser? _toUser(User? user) => user == null
      ? null
      : AccountUser(uid: user.uid, email: user.email, displayName: user.displayName, photoUrl: user.photoURL);

  @override
  AccountUser? get currentUser => _toUser(_auth.currentUser);

  @override
  Stream<AccountUser?> get userChanges => _auth.userChanges().map(_toUser);

  @override
  Future<AccountUser> signInWithGoogle() async {
    try {
      await (_initialized ??= _google.initialize());
      final account = await _google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw const SignInException(SignInFailure.failed);
      final result = await _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
      final user = _toUser(result.user);
      if (user == null) throw const SignInException(SignInFailure.failed);
      return user;
    } on GoogleSignInException catch (error) {
      throw SignInException(
        error.code == GoogleSignInExceptionCode.canceled ? SignInFailure.cancelled : SignInFailure.failed,
      );
    } on FirebaseAuthException {
      throw const SignInException(SignInFailure.failed);
    }
  }

  @override
  Future<void> signOut() async {
    await (_initialized ??= _google.initialize());
    await _google.signOut();
    await _auth.signOut();
  }
}

/// Whether Firebase started; overridden in `main()` with what `initFirebase` returned.
final firebaseAvailableProvider = Provider<bool>((ref) => false);

final authGatewayProvider = Provider<AuthGateway>(
  (ref) => ref.watch(firebaseAvailableProvider) ? FirebaseAuthGateway() : const UnavailableAuthGateway(),
);

/// The signed-in person (null when nobody is).
final accountUserProvider = StreamProvider<AccountUser?>((ref) async* {
  final auth = ref.watch(authGatewayProvider);
  yield auth.currentUser;
  yield* auth.userChanges;
});
