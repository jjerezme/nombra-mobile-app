import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nombra/core/widgets/pill_choice.dart';
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

  setUp(
    () async => env = await TestEnvironment.create(
      preferences: {
        ...storedRules(sampleRules()),
        'settings': jsonEncode(AppSettings(mode: NamingMode.saved).toJson()),
      },
    ),
  );

  testWidgets('a shared link shows the sheet with the proposed name and saves it', (tester) async {
    final (container, channel) = await pumpShare(tester, env, _linkPayload);
    expect(find.text('Guardar con Nombra'), findsOneWidget);
    expect(find.text('Nombre final'), findsOneWidget);
    expect(find.textContaining('_Informe Q3.pdf'), findsOneWidget);
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

  testWidgets('a shared plain http link says only https links can be saved', (tester) async {
    await pumpShare(tester, env, const SharePayload(text: 'mira http://cdn.ejemplo.com/a.pdf'));
    expect(find.text('Solo se pueden guardar enlaces https (cifrados).'), findsOneWidget);
    expect(find.text('Guardar'), findsNothing);
  });

  testWidgets('the final name is read only: the rule decides it', (tester) async {
    final (container, _) = await pumpShare(tester, env, _linkPayload);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byType(SelectableText), findsOneWidget);
    // SelectableText is an EditableText that cannot be edited.
    expect(tester.widget<EditableText>(find.byType(EditableText)).readOnly, isTrue);

    await tester.tap(find.text('Guardar'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(container.read(downloadsProvider).single.plan.fixedFileName, isNull);
  });

  testWidgets('a long final name continues on the next line', (tester) async {
    final longName = '${'a' * 90}.pdf';
    await pumpShare(
      tester,
      env,
      SharePayload(
        files: [SharedFile(path: '/cache/$longName', name: longName, mimeType: 'application/pdf')],
      ),
    );
    final text = find.byType(SelectableText);
    expect(tester.getSize(text).height, greaterThan(40)); // more than one line
    expect(
      tester.getSize(text).width,
      lessThanOrEqualTo(tester.view.physicalSize.width / tester.view.devicePixelRatio),
    );
  });

  testWidgets('a shared image shows its thumbnail in the title; other files show an icon', (tester) async {
    await pumpShare(
      tester,
      env,
      const SharePayload(
        files: [SharedFile(path: '/cache/foto.jpg', name: 'foto.jpg', mimeType: 'image/jpeg')],
      ),
    );
    expect(find.byType(Image), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<ResizeImage>());
    expect(image.fit, BoxFit.cover);
  });

  testWidgets('Guardar and Cancelar are pinned below the scrolling content', (tester) async {
    await pumpShare(tester, env, _linkPayload);
    for (final label in ['Guardar', 'Cancelar']) {
      expect(find.descendant(of: find.byType(SingleChildScrollView), matching: find.text(label)), findsNothing);
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('a document has no thumbnail', (tester) async {
    await pumpShare(
      tester,
      env,
      const SharePayload(
        files: [SharedFile(path: '/cache/a.pdf', name: 'a.pdf', mimeType: 'application/pdf')],
      ),
    );
    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.description_outlined), findsOneWidget);
  });

  testWidgets('a rule tapped on the sheet is used and becomes the last one used', (tester) async {
    final (container, _) = await pumpShare(tester, env, _linkPayload);
    expect(find.textContaining('Usar esta regla siempre'), findsNothing);
    await tester.ensureVisible(find.widgetWithText(PillChoice, 'Original'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(PillChoice, 'Original'));
    await tester.pumpAndSettle();
    expect(tester.widget<PillChoice>(find.widgetWithText(PillChoice, 'Original')).isSelected, isTrue);
    expect(tester.widget<PillChoice>(find.widgetWithText(PillChoice, 'Fecha + nombre')).isSelected, isFalse);
    await tester.tap(find.text('Guardar'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(container.read(downloadsProvider).single.plan.rule?.id, 'original');
    expect(container.read(settingsProvider).lastRuleId, 'original');
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
    expect(find.textContaining('Usar esta regla siempre'), findsNothing);

    await tester.tap(find.text('Guardar'));
    await tester.pump(const Duration(milliseconds: 200));
    final item = container.read(downloadsProvider).single;
    expect(item.plan.rule, isNull);
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
  });

  testWidgets('cancel closes the sheet without downloading', (tester) async {
    final (_, channel) = await pumpShare(tester, env, _linkPayload);
    await tester.tap(find.text('Cancelar'));
    expect(channel.isClosed, isTrue);
    expect(env.engine.enqueued, isEmpty);
  });
}
