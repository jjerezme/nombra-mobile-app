import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nombra/app/app.dart';
import 'package:nombra/core/environment.dart';
import 'package:nombra/core/l10n/current_l10n.dart';
import 'package:nombra/core/providers.dart';
import 'package:nombra/features/developer/developer_screen.dart';
import 'package:nombra/features/developer/domain/dev_info.dart';
import 'package:nombra/features/download/data/downloads_notifier.dart';
import 'package:nombra/features/download/domain/download_models.dart';
import 'package:nombra/features/rules/data/rules_notifier.dart';
import 'package:nombra/features/rules/domain/storage_root.dart';
import 'package:nombra/features/settings/app_settings.dart';
import 'package:nombra/features/settings/settings_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../helpers/fakes.dart';

Future<ProviderContainer> pumpSettings(
  WidgetTester tester,
  TestEnvironment env, {
  AppEnvironment environment = AppEnvironment.development,
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
        appEnvironmentProvider.overrideWithValue(environment),
        developerInfoProvider.overrideWith(
          (ref, facts) async => const [
            InfoSection('app', [InfoRow('Version', '9.9')]),
          ],
        ),
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

ThemeMode appThemeMode(WidgetTester tester) => tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

void main() {
  late TestEnvironment env;

  setUp(() async => env = await TestEnvironment.create(preferences: storedRules(sampleRules())));

  testWidgets('the developer mode opens in development, with its tools and sections', (tester) async {
    await pumpSettings(tester, env);
    await tester.ensureVisible(find.text('Modo desarrollador'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modo desarrollador'));
    await tester.pumpAndSettle();
    expect(find.text('Copiar informe'), findsOneWidget);
    await tester.tap(find.text('Aplicación'));
    await tester.pumpAndSettle();
    expect(find.text('9.9'), findsOneWidget);
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied.add((call.arguments as Map)['text'] as String);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.tap(find.text('Copiar informe'));
    await tester.pumpAndSettle();
    expect(copied.single, contains('Version: 9.9'));
    expect(find.text('Informe copiado'), findsOneWidget);
  });

  testWidgets('production has no developer mode', (tester) async {
    await pumpSettings(tester, env, environment: AppEnvironment.production);
    expect(find.text('Modo desarrollador'), findsNothing);
  });

  testWidgets('shows the sections and the app version', (tester) async {
    await pumpSettings(tester, env);
    expect(find.text('Apariencia'), findsOneWidget);
    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Modo de nombrado'), findsNothing); // the mode is chosen in Descargar, not here
    expect(find.text('Carpeta predeterminada'), findsOneWidget);
    expect(find.text('/Download'), findsOneWidget);
    expect(find.text('Versión 1.2.3 (45)'), findsOneWidget);
  });

  testWidgets('the theme is applied and stored', (tester) async {
    final container = await pumpSettings(tester, env);
    expect(appThemeMode(tester), ThemeMode.system);

    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).themeMode, AppThemeMode.dark);
    expect(appThemeMode(tester), ThemeMode.dark);
    expect(env.preferences.getString('settings'), contains('"themeMode":"dark"'));
  });

  testWidgets('the language changes the texts right away and is stored', (tester) async {
    final container = await pumpSettings(tester, env);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(container.read(settingsProvider).languageCode, 'en');
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Idioma'), findsNothing);
    expect(currentL10n().appName, 'Nombra');
    expect(currentL10n().navRules, 'Rules');

    await tester.tap(find.text('System').last);
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).languageCode, isNull);
    expect(find.text('Apariencia'), findsOneWidget);
  });

  testWidgets('the default folder can be changed', (tester) async {
    final container = await pumpSettings(tester, env);
    await tester.tap(find.text('Cambiar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Documents'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usar esta carpeta'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).lastFolder, DestinationFolder(StorageRoot.documents));
  });

  testWidgets('the base folders are chips in one row that scrolls sideways', (tester) async {
    final container = await pumpSettings(tester, env);
    await tester.tap(find.text('Cambiar'));
    await tester.pumpAndSettle();

    final row = find.byWidgetPredicate(
      (widget) => widget is SingleChildScrollView && widget.scrollDirection == Axis.horizontal,
    );
    expect(row, findsOneWidget);
    final top = tester.getTopLeft(find.text('Download')).dy;
    for (final folder in ['Documents', 'Pictures', 'Movies', 'Music']) {
      await tester.ensureVisible(find.text(folder));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text(folder)).dy, top, reason: '$folder is on the same row');
    }

    await tester.tap(find.text('Music'));
    await tester.pumpAndSettle();
    // The resulting path is shown in the same info box as "Se guardará como".
    expect(find.text('Se guardará en'), findsOneWidget);
    expect(find.text('/Music'), findsOneWidget);
    await tester.tap(find.text('Usar esta carpeta'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).lastFolder, DestinationFolder(StorageRoot.music));
  });

  testWidgets('the default folder starts blank, without a placeholder', (tester) async {
    await pumpSettings(tester, env);
    await tester.tap(find.text('Cambiar'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);
    expect(field.decoration!.hintText, isNull);
  });

  testWidgets('the folder sheet stays above the Android navigation bar', (tester) async {
    await pumpSettings(tester, env);
    // 48 logical pixels of system navigation bar (the test view is 3x).
    tester.view
      ..viewPadding = const FakeViewPadding(bottom: 144)
      ..padding = const FakeViewPadding(bottom: 144);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cambiar'));
    await tester.pumpAndSettle();

    final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final buttonBottom = tester.getBottomLeft(find.text('Usar esta carpeta')).dy;
    expect(buttonBottom, lessThanOrEqualTo(screenHeight - 48));
  });

  testWidgets('deleting all rules asks first and then empties the list', (tester) async {
    final container = await pumpSettings(tester, env);
    await tester.ensureVisible(find.text('Borrar todas las reglas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borrar todas las reglas'));
    await tester.pumpAndSettle();
    expect(find.text('Se eliminan 4 reglas. No se puede deshacer.'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(container.read(rulesProvider), hasLength(4));

    await tester.ensureVisible(find.text('Borrar todas las reglas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borrar todas las reglas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    expect(container.read(rulesProvider), isEmpty);
  });

  group('recent files', () {
    Future<void> withHistory() async {
      final finished = DownloadItem(
        id: 'old',
        fileName: 'a.pdf',
        status: DownloadStatus.done,
        plan: DownloadPlan(folder: DestinationFolder(StorageRoot.download)),
        createdAt: DateTime.now(),
      );
      env = await TestEnvironment.create(
        preferences: {
          ...storedRules(sampleRules()),
          'downloads': jsonEncode([finished.toJson()]),
        },
      );
    }

    Future<void> openDownload(WidgetTester tester) async {
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Descargar')));
      await tester.pumpAndSettle();
    }

    testWidgets('can be cleared from the Download tab, after asking', (tester) async {
      await withHistory();
      await pumpSettings(tester, env);
      await openDownload(tester);
      expect(find.text('a.pdf'), findsOneWidget);

      await tester.tap(find.text('Borrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('a.pdf'), findsOneWidget);

      await tester.tap(find.text('Borrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();
      expect(find.text('a.pdf'), findsNothing);
      expect(find.text('Aún no hay descargas'), findsOneWidget);
      expect(find.text('Borrar'), findsNothing);
    });

    testWidgets('a setting hides them, and shows them again', (tester) async {
      await withHistory();
      final container = await pumpSettings(tester, env);
      expect(container.read(settingsProvider).showRecents, isTrue);

      await tester.tap(find.text('Mostrar archivos recientes'));
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider).showRecents, isFalse);

      await openDownload(tester);
      expect(find.text('Recientes'), findsNothing);
      expect(find.text('a.pdf'), findsNothing);
      // The history is kept, only hidden.
      expect(container.read(downloadsProvider), hasLength(1));

      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Ajustes')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mostrar archivos recientes'));
      await tester.pumpAndSettle();
      await openDownload(tester);
      expect(find.text('a.pdf'), findsOneWidget);
    });

    testWidgets('a long file name continues on the next line instead of being cut', (tester) async {
      final longName = '${'b' * 80}.pdf';
      final finished = DownloadItem(
        id: 'old',
        fileName: longName,
        status: DownloadStatus.done,
        plan: DownloadPlan(folder: DestinationFolder(StorageRoot.download)),
        createdAt: DateTime.now(),
      );
      env = await TestEnvironment.create(
        preferences: {
          ...storedRules(sampleRules()),
          'downloads': jsonEncode([finished.toJson()]),
        },
      );
      await pumpSettings(tester, env);
      await openDownload(tester);

      final name = find.text(longName);
      expect(tester.widget<Text>(name).maxLines, isNull);
      expect(tester.getSize(name).height, greaterThan(30));
    });

    testWidgets('downloads in progress are shown even when recents are hidden', (tester) async {
      final container = await pumpSettings(tester, env);
      container.read(settingsProvider.notifier).setShowRecents(isShown: false);
      await container
          .read(downloadsProvider.notifier)
          .start(
            DownloadPlan(url: 'https://x.com/b.pdf', folder: DestinationFolder(StorageRoot.download)),
            displayName: 'b.pdf',
          );
      await tester.pump(const Duration(milliseconds: 200));
      // A download in progress shows an endless progress bar, so the page never settles.
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Descargar')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('b.pdf'), findsOneWidget);
    });
  });

  testWidgets('clearing the history keeps downloads still in flight', (tester) async {
    final finished = DownloadItem(
      id: 'old',
      fileName: 'a.pdf',
      status: DownloadStatus.done,
      plan: DownloadPlan(folder: DestinationFolder(StorageRoot.download)),
      createdAt: DateTime.now(),
    );
    env = await TestEnvironment.create(
      preferences: {
        ...storedRules(sampleRules()),
        'downloads': jsonEncode([finished.toJson()]),
      },
    );
    final container = await pumpSettings(tester, env);
    final running = await container
        .read(downloadsProvider.notifier)
        .start(
          DownloadPlan(url: 'https://x.com/b.pdf', folder: DestinationFolder(StorageRoot.download)),
          displayName: 'b.pdf',
        );
    expect(container.read(downloadsProvider).map((item) => item.id), containsAll(['old', running]));

    await tester.tap(find.text('Borrar historial de descargas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(container.read(downloadsProvider).map((item) => item.id), [running]);
  });

  test('the quick sequence goes on while the pattern stays the same', () {
    final container = env.container();
    final notifier = container.read(settingsProvider.notifier)..setQuickTokens(['Foto_', '{n:3}']);
    final signature = container.read(settingsProvider).quickSignature;

    expect(container.read(settingsProvider).nextQuickNumber, 1);
    expect(notifier.takeQuickNumber(signature), 1);
    expect(notifier.takeQuickNumber(signature), 2);
    expect(container.read(settingsProvider).nextQuickNumber, 3);

    notifier.setQuickTokens(['Otra_', '{n:3}']); // another pattern: the saved number no longer applies
    expect(container.read(settingsProvider).nextQuickNumber, 1);
    notifier.setQuickNext(40);
    expect(container.read(settingsProvider).nextQuickNumber, 40);
  });

  test('the settings survive a round trip and ignore unknown values', () {
    final restored = AppSettings.fromJson(AppSettings(languageCode: 'en', themeMode: AppThemeMode.light).toJson());
    expect(restored.languageCode, 'en');
    expect(restored.themeMode, AppThemeMode.light);

    final odd = AppSettings.fromJson({'languageCode': 'xx', 'themeMode': 'purple'});
    expect(odd.languageCode, isNull);
    expect(odd.themeMode, AppThemeMode.system);
  });
}
