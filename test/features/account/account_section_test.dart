import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nombra/app/app.dart';
import 'package:nombra/core/l10n/current_l10n.dart';
import 'package:nombra/core/widgets/info_box.dart';
import 'package:nombra/features/account/data/auth_gateway.dart';
import 'package:nombra/features/rules/data/rules_notifier.dart';
import 'package:nombra/features/settings/settings_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../helpers/account_fakes.dart';
import '../../helpers/fakes.dart';

Future<ProviderContainer> pumpSettings(
  WidgetTester tester,
  TestEnvironment env, {
  required FakeAuthGateway auth,
  required FakeBackupGateway backup,
}) async {
  tester.view
    ..physicalSize = const Size(1170, 4000)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  tester.platformDispatcher
    ..localeTestValue = const Locale('es')
    ..localesTestValue = const [Locale('es')];
  addTearDown(tester.platformDispatcher.clearLocaleTestValue);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  addTearDown(() => languageOverride = null);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...env.overrides,
        ...accountOverrides(auth, backup),
        packageInfoProvider.overrideWith(
          (ref) async => PackageInfo(appName: 'Nombra', packageName: 'x', version: '1.2.3', buildNumber: '45'),
        ),
      ],
      child: const NombraApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Ajustes'));
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
}

void main() {
  late TestEnvironment env;
  late FakeBackupGateway backup;

  setUp(() async {
    env = await TestEnvironment.create(preferences: storedRules(sampleRules()));
    backup = FakeBackupGateway();
  });

  testWidgets('without Firebase the section says backup is not available and offers no sign-in', (tester) async {
    await pumpSettings(tester, env, auth: FakeAuthGateway(isAvailable: false), backup: backup);
    expect(find.text('Cuenta'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(InfoBox),
        matching: find.text('El respaldo no está disponible en esta compilación.'),
      ),
      findsOneWidget,
    );
    expect(find.text('Continuar con Google'), findsNothing);
  });

  testWidgets('signed out: explains the backup and signs in with Google, which uploads the rules', (tester) async {
    await pumpSettings(tester, env, auth: FakeAuthGateway(), backup: backup);
    expect(find.textContaining('respaldar tus reglas'), findsOneWidget);
    await tester.tap(find.text('Continuar con Google'));
    await tester.pumpAndSettle();
    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text('ana@ejemplo.com'), findsOneWidget);
    expect(find.text('Reglas respaldadas'), findsOneWidget);
    expect(backup.saves, hasLength(1));
    expect(find.text('Continuar con Google'), findsNothing);
  });

  testWidgets('a cancelled sign-in says nothing; a failed one shows a message', (tester) async {
    final auth = FakeAuthGateway()..failWith = SignInFailure.cancelled;
    await pumpSettings(tester, env, auth: auth, backup: backup);
    await tester.tap(find.text('Continuar con Google'));
    await tester.pumpAndSettle();
    expect(find.text('No se pudo iniciar sesión. Inténtalo de nuevo.'), findsNothing);
    expect(find.text('Continuar con Google'), findsOneWidget);

    auth.failWith = SignInFailure.failed;
    await tester.tap(find.text('Continuar con Google'));
    await tester.pumpAndSettle();
    expect(find.text('No se pudo iniciar sesión. Inténtalo de nuevo.'), findsOneWidget);
  });

  testWidgets('a backup error shows a retry button that tries again', (tester) async {
    backup.failFetch = true;
    await pumpSettings(
      tester,
      env,
      auth: FakeAuthGateway(signedIn: testUser),
      backup: backup,
    );
    expect(find.text('No se pudo respaldar tus reglas. Revisa tu conexión.'), findsOneWidget);
    backup.failFetch = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Reglas respaldadas'), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);
  });

  testWidgets('sign out keeps the local rules and the cloud copy', (tester) async {
    final container = await pumpSettings(
      tester,
      env,
      auth: FakeAuthGateway(signedIn: testUser),
      backup: backup,
    );
    final rules = container.read(rulesProvider).length;
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Continuar con Google'), findsOneWidget);
    expect(container.read(rulesProvider), hasLength(rules));
    expect(backup.deleted, isEmpty);
  });

  testWidgets('deleting the backup asks first, then removes it from the cloud and signs out', (tester) async {
    await pumpSettings(
      tester,
      env,
      auth: FakeAuthGateway(signedIn: testUser),
      backup: backup,
    );
    await tester.tap(find.text('Borrar respaldo y cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('¿Borrar el respaldo?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(backup.deleted, isEmpty);

    await tester.tap(find.text('Borrar respaldo y cerrar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    expect(backup.deleted, [testUser.uid]);
    expect(find.text('Continuar con Google'), findsOneWidget);
  });

  group('while an action runs', () {
    testWidgets('signing in shows progress with its name and disables the button until it ends', (tester) async {
      final auth = FakeAuthGateway()..gate = Completer<void>();
      await pumpSettings(tester, env, auth: auth, backup: backup);
      await tester.tap(find.text('Continuar con Google'));
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Iniciando sesión…'), findsOneWidget);
      expect(tester.widget<AbsorbPointer>(find.byType(AbsorbPointer).last).absorbing, isTrue);

      auth.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Iniciando sesión…'), findsNothing);
      expect(find.text('Ana Pérez'), findsOneWidget);
    });

    testWidgets('signing out shows progress and then the signed-out view', (tester) async {
      final auth = FakeAuthGateway(signedIn: testUser)..gate = Completer<void>();
      await pumpSettings(tester, env, auth: auth, backup: backup);
      await tester.tap(find.text('Cerrar sesión'));
      await tester.pump();
      expect(find.text('Cerrando sesión…'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      auth.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Continuar con Google'), findsOneWidget);
    });

    testWidgets('deleting the backup shows progress, and a failure ends it with a message', (tester) async {
      backup
        ..deleteGate = Completer<void>()
        ..failDelete = true;
      await pumpSettings(
        tester,
        env,
        auth: FakeAuthGateway(signedIn: testUser),
        backup: backup,
      );
      await tester.tap(find.text('Borrar respaldo y cerrar sesión'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar'));
      await tester.pump();
      expect(find.text('Borrando el respaldo…'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      backup.deleteGate!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('No se pudo borrar el respaldo. Revisa tu conexión.'), findsOneWidget);
    });
  });

  group('deleting the account', () {
    Future<void> confirmDelete(WidgetTester tester) async {
      await tester.tap(find.text('Eliminar cuenta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();
    }

    testWidgets('removes the backup and the account', (tester) async {
      final auth = FakeAuthGateway(signedIn: testUser);
      await pumpSettings(tester, env, auth: auth, backup: backup);
      await confirmDelete(tester);
      expect(auth.isDeleted, isTrue);
      expect(backup.deleted, [testUser.uid]);
      expect(find.text('Continuar con Google'), findsOneWidget);
      expect(find.text('Tu cuenta se eliminó.'), findsOneWidget);
    });

    testWidgets('deletes nothing when the Google picker is cancelled', (tester) async {
      final auth = FakeAuthGateway(signedIn: testUser)..failWith = SignInFailure.cancelled;
      await pumpSettings(tester, env, auth: auth, backup: backup);
      await confirmDelete(tester);
      expect(auth.isDeleted, isFalse);
      expect(backup.deleted, isEmpty);
      expect(find.text('No se pudo eliminar la cuenta. Revisa tu conexión.'), findsNothing);
    });

    testWidgets('says so when it fails', (tester) async {
      final auth = FakeAuthGateway(signedIn: testUser)..failDeleteAccount = true;
      await pumpSettings(tester, env, auth: auth, backup: backup);
      await confirmDelete(tester);
      expect(auth.isDeleted, isFalse);
      expect(find.text('No se pudo eliminar la cuenta. Revisa tu conexión.'), findsOneWidget);
    });
  });

  testWidgets('the Google button carries the Google G logo', (tester) async {
    await pumpSettings(tester, env, auth: FakeAuthGateway(), backup: backup);
    final image = tester.widget<Image>(find.descendant(of: find.byType(OutlinedButton), matching: find.byType(Image)));
    expect((image.image as AssetImage).assetName, 'assets/images/google_g.png');
  });
}
