import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nombra/features/download/data/downloads_notifier.dart';
import 'package:nombra/features/download/domain/download_models.dart';
import 'package:nombra/features/settings/app_settings.dart';
import 'package:nombra/features/share/data/share_channel.dart';
import 'package:nombra/features/share/domain/share_payload.dart';
import 'package:nombra/features/share/share_app.dart';

import '../../helpers/fakes.dart';

class FakeShareChannel extends ShareChannel {
  FakeShareChannel(this.data);

  final SharePayload data;
  bool isClosed = false;
  bool isMinimized = false;

  @override
  Future<SharePayload> payload() async => data;

  @override
  Future<void> minimize() async => isMinimized = true;

  @override
  Future<void> close() async => isClosed = true;
}

Future<(ProviderContainer, FakeShareChannel)> pumpShare(
  WidgetTester tester,
  TestEnvironment env,
  SharePayload payload,
) async {
  tester.view
    ..physicalSize = const Size(1170, 4000)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  tester.platformDispatcher
    ..localeTestValue = const Locale('es')
    ..localesTestValue = const [Locale('es')];
  addTearDown(tester.platformDispatcher.clearLocaleTestValue);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final channel = FakeShareChannel(payload);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...env.overrides, shareChannelProvider.overrideWithValue(channel)],
      child: const ShareApp(),
    ),
  );
  await tester.pumpAndSettle();
  return (ProviderScope.containerOf(tester.element(find.byType(MaterialApp))), channel);
}

const SharePayload _linkPayload = SharePayload(
  text: 'Mira esto: https://cdn.ejemplo.com/docs/Informe%20Q3.pdf gracias',
);

void main() {
  late TestEnvironment env;

  setUp(() async => env = await TestEnvironment.create(preferences: storedRules(sampleRules())));

  testWidgets('a shared link shows the sheet with the proposed name and saves it', (tester) async {
    final (container, channel) = await pumpShare(tester, env, _linkPayload);
    expect(find.text('Guardar con Nombra'), findsOneWidget);
    expect(find.text('Nombre final'), findsOneWidget);
    expect(find.text('.pdf'), findsOneWidget);
    expect(find.text('https://cdn.ejemplo.com/docs/Informe%20Q3.pdf'), findsOneWidget);

    await tester.tap(find.text('Guardar'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(env.engine.enqueued.single.url, 'https://cdn.ejemplo.com/docs/Informe%20Q3.pdf');
    expect(container.read(downloadsProvider).single.status, DownloadStatus.queued);
    expect(find.text('Cerrar'), findsOneWidget);

    await tester.tap(find.text('Cerrar'));
    expect(channel.isClosed, isTrue);
  });

  testWidgets('text without a link or files says there is nothing to save', (tester) async {
    await pumpShare(tester, env, const SharePayload(text: 'hola'));
    expect(find.text('No hay un enlace ni archivos para guardar.'), findsOneWidget);
    expect(find.text('Guardar'), findsNothing);
  });

  testWidgets('a name typed by hand is kept, with the extension', (tester) async {
    final (container, _) = await pumpShare(tester, env, _linkPayload);
    await tester.enterText(find.byType(TextFormField), 'mi-nombre');
    await tester.pump();
    await tester.tap(find.text('Guardar'));
    await tester.pump(const Duration(milliseconds: 200));
    final plan = container.read(downloadsProvider).single.plan;
    expect(plan.fixedFileName, 'mi-nombre.pdf');
  });

  testWidgets('"remember as default" stores the rule for that kind of file', (tester) async {
    final (container, _) = await pumpShare(tester, env, _linkPayload);
    expect(find.text('Recordar como predeterminada para documentos'), findsOneWidget);
    await tester.tap(find.text('Guardar'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(container.read(settingsProvider).defaultRuleByKind['document'], 'date-name');
  });

  testWidgets('saving sends the sheet to the background while the download goes on', (tester) async {
    final (container, channel) = await pumpShare(tester, env, _linkPayload);
    await tester.tap(find.text('Guardar'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(channel.isMinimized, isTrue);
    expect(env.engine.enqueued, hasLength(1));
    expect(container.read(downloadsProvider).single.status, DownloadStatus.queued);
    // Still downloading: the hidden activity must stay alive to finish the save.
    expect(channel.isClosed, isFalse);
  });

  testWidgets('the hidden activity closes once the save has failed', (tester) async {
    env.engine.enqueueResult = false;
    final (_, channel) = await pumpShare(tester, env, _linkPayload);
    await tester.tap(find.text('Guardar'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(channel.isMinimized, isTrue);
    expect(channel.isClosed, isTrue);
  });

  testWidgets('without a rule the file is saved with its original name', (tester) async {
    env = await TestEnvironment.create(
      preferences: {
        ...storedRules(sampleRules()),
        'settings': jsonEncode(AppSettings(mode: NamingMode.none).toJson()),
      },
    );
    final (container, _) = await pumpShare(tester, env, _linkPayload);
    expect(find.text('Fecha + nombre'), findsNothing);
    expect(find.textContaining('Recordar como predeterminada'), findsNothing);

    await tester.tap(find.text('Guardar'));
    await tester.pump(const Duration(milliseconds: 200));
    final item = container.read(downloadsProvider).single;
    expect(item.plan.rule, isNull);
    expect(container.read(settingsProvider).defaultRuleByKind, isEmpty);
  });

  testWidgets('several files show a count instead of a name field', (tester) async {
    await pumpShare(
      tester,
      env,
      const SharePayload(
        files: [
          SharedFile(path: '/cache/a.jpg', name: 'a.jpg', mimeType: 'image/jpeg', size: 1000),
          SharedFile(path: '/cache/b.jpg', name: 'b.jpg', mimeType: 'image/jpeg', size: 2000),
        ],
      ),
    );
    expect(find.text('2 archivos'), findsOneWidget);
    expect(find.text('Nombre final'), findsNothing);
    expect(find.text('Recordar como predeterminada para imágenes'), findsOneWidget);
  });

  testWidgets('cancel closes the sheet without downloading', (tester) async {
    final (_, channel) = await pumpShare(tester, env, _linkPayload);
    await tester.tap(find.text('Cancelar'));
    expect(channel.isClosed, isTrue);
    expect(env.engine.enqueued, isEmpty);
  });
}
