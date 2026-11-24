import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nombra/app/app.dart';
import 'package:nombra/core/l10n/current_l10n.dart';
import 'package:nombra/features/download/data/downloads_notifier.dart';
import 'package:nombra/features/download/domain/download_models.dart';
import 'package:nombra/features/rules/data/rules_notifier.dart';
import 'package:nombra/features/rules/domain/storage_root.dart';
import 'package:nombra/features/settings/app_settings.dart';
import 'package:nombra/features/settings/settings_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../helpers/fakes.dart';

Future<ProviderContainer> pumpSettings(WidgetTester tester, TestEnvironment env) async {
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

  testWidgets('shows the sections and the app version', (tester) async {
    await pumpSettings(tester, env);
    expect(find.text('Apariencia'), findsOneWidget);
    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Modo de nombrado'), findsOneWidget);
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

  testWidgets('the naming mode and the default folder can be changed', (tester) async {
    final container = await pumpSettings(tester, env);
    await tester.tap(find.text('Rápida'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).mode, NamingMode.quick);

    await tester.tap(find.text('Cambiar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Documents'));
    await tester.pump();
    await tester.tap(find.text('Usar esta carpeta'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).lastFolder, DestinationFolder(StorageRoot.documents));
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
    await tester.tap(find.text('Borrar todas las reglas'));
    await tester.pumpAndSettle();
    expect(find.text('Se eliminan 4 reglas. No se puede deshacer.'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(container.read(rulesProvider), hasLength(4));

    await tester.tap(find.text('Borrar todas las reglas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    expect(container.read(rulesProvider), isEmpty);
  });

  testWidgets('clearing the history keeps downloads still in flight', (tester) async {
    final finished = DownloadItem(
      id: 'old',
      fileName: 'a.pdf',
      status: DownloadStatus.done,
      plan: DownloadPlan(folder: DestinationFolder(StorageRoot.download)),
      createdAt: DateTime(2026),
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
