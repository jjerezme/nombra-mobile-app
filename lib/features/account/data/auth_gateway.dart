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

  /// Asks the person to pick their Google account again, which Firebase needs before deleting the account. Throws
  /// [SignInException] when it is cancelled or fails.
  Future<void> reauthenticate();

  /// Deletes the account of the signed-in person and leaves it. Call [reauthenticate] first.
  Future<void> deleteAccount();
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

  @override
  Future<void> reauthenticate() => Future.error(const SignInException(SignInFailure.failed));

  @override
  Future<void> deleteAccount() async {}
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

  /// Runs [body], turning what Google and Firebase throw into a [SignInException].
  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      await (_initialized ??= _google.initialize());
      return await body();
    } on GoogleSignInException catch (error) {
      throw SignInException(
        error.code == GoogleSignInExceptionCode.canceled ? SignInFailure.cancelled : SignInFailure.failed,
      );
    } on FirebaseAuthException {
      throw const SignInException(SignInFailure.failed);
    }
  }

  Future<OAuthCredential> _googleCredential() async {
    final account = await _google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) throw const SignInException(SignInFailure.failed);
    return GoogleAuthProvider.credential(idToken: idToken);
  }

  @override
  Future<AccountUser> signInWithGoogle() => _guard(() async {
    final result = await _auth.signInWithCredential(await _googleCredential());
    final user = _toUser(result.user);
    if (user == null) throw const SignInException(SignInFailure.failed);
    return user;
  });

  @override
  Future<void> reauthenticate() => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) throw const SignInException(SignInFailure.failed);
    await user.reauthenticateWithCredential(await _googleCredential());
  });

  @override
  Future<void> deleteAccount() async {
    await (_initialized ??= _google.initialize());
    await _auth.currentUser?.delete();
    await _google.signOut();
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
