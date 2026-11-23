import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nombra/app/app.dart';
import 'package:nombra/features/download/data/downloads_notifier.dart';
import 'package:nombra/features/rules/data/rules_notifier.dart';
import 'package:nombra/features/settings/app_settings.dart';

import '../helpers/fakes.dart';

const String _url = 'https://cdn.ejemplo.com/docs/Informe%20Q3%20FINAL%20(2).pdf';

Future<ProviderContainer> pumpApp(WidgetTester tester, TestEnvironment env) async {
  tester.view
    ..physicalSize = const Size(1170, 4000)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  tester.platformDispatcher
    ..localeTestValue = const Locale('es')
    ..localesTestValue = const [Locale('es')];
  addTearDown(tester.platformDispatcher.clearLocaleTestValue);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(ProviderScope(overrides: env.overrides, child: const NombraApp()));
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
}

Future<void> tapDownload(WidgetTester tester) async {
  await tester.tap(find.text('Descargar').first);
  // A pending download shows an indeterminate progress bar, which never settles.
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  late TestEnvironment env;

  setUp(() async => env = await TestEnvironment.create());

  testWidgets('Home shows the empty state and the saved rules', (tester) async {
    await pumpApp(tester, env);
    expect(find.text('URL del archivo'), findsOneWidget);
    expect(find.text('Fecha + nombre'), findsOneWidget);
    expect(find.text('Aún no hay descargas', skipOffstage: false), findsOneWidget);
    expect(find.text('Pega una URL para ver el nombre'), findsOneWidget);
  });

  testWidgets('typing a URL previews the final name and downloading enqueues it', (tester) async {
    final container = await pumpApp(tester, env);
    await tester.enterText(find.byType(TextField).first, _url);
    await tester.pumpAndSettle();
    expect(find.textContaining('_Informe Q3 FINAL (2).pdf'), findsOneWidget);
    expect(find.text('/Download/Nombra'), findsOneWidget);

    await tapDownload(tester);

    expect(env.engine.enqueued, hasLength(1));
    expect(env.engine.enqueued.single.url, _url);
    expect(container.read(downloadsProvider), hasLength(1));
    expect(find.text('En espera…', skipOffstage: false), findsOneWidget);
  });

  testWidgets('an invalid URL shows an error and does not download', (tester) async {
    await pumpApp(tester, env);
    await tester.enterText(find.byType(TextField).first, 'esto no es una url');
    await tapDownload(tester);
    await tester.pumpAndSettle();
    expect(find.text('Introduce una URL http o https válida'), findsOneWidget);
    expect(env.engine.enqueued, isEmpty);
  });

  testWidgets('quick mode names the file with prefix and suffix', (tester) async {
    final container = await pumpApp(tester, env);
    await tester.tap(find.text('Rápida'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).mode, NamingMode.quick);

    await tester.enterText(find.byType(TextField).first, _url);
    await tester.enterText(find.byType(TextField).at(1), 'acme_');
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).prefix, 'acme_');
    expect(find.text('acme_Informe Q3 FINAL (2).pdf'), findsOneWidget);
  });

  testWidgets('choosing a rule changes the folder and is remembered', (tester) async {
    final container = await pumpApp(tester, env);
    await tester.enterText(find.byType(TextField).first, _url);
    await tester.tap(find.text('Facturas'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).lastRuleId, 'invoices');
    expect(find.text('/Documents/Facturas'), findsOneWidget);
    expect(find.textContaining('Factura_'), findsWidgets);
  });

  testWidgets('Rules lists the seed rules and a rule can be switched off', (tester) async {
    final container = await pumpApp(tester, env);
    await tester.tap(find.text('Reglas'));
    await tester.pumpAndSettle();
    expect(find.text('Predeterminada'), findsOneWidget);
    expect(find.text('Original'), findsOneWidget);

    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();
    expect(container.read(rulesProvider)[1].isEnabled, isFalse);
  });

  testWidgets('a new rule can be created from the editor', (tester) async {
    final container = await pumpApp(tester, env);
    await tester.tap(find.text('Reglas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nueva regla'));
    await tester.pumpAndSettle();
    expect(find.text('Patrón'), findsOneWidget);

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Escribe un nombre'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Mi regla');
    await tester.tap(find.text('{n:3}'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    final created = container.read(rulesProvider).last;
    expect(created.name, 'Mi regla');
    expect(created.tokens, ['{date}', '_', '{name}', '{n:3}']);
    expect(find.text('Reglas'), findsWidgets);
  });
}
