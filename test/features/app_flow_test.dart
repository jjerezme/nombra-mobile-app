import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nombra/app/app.dart';
import 'package:nombra/app/router.dart';
import 'package:nombra/core/constants/tokens.dart';
import 'package:nombra/core/widgets/app_card.dart';
import 'package:nombra/core/widgets/app_logo.dart';
import 'package:nombra/core/widgets/info_box.dart';
import 'package:nombra/core/widgets/pill_choice.dart';
import 'package:nombra/core/widgets/screen_header.dart';
import 'package:nombra/features/naming/widgets/destination_card.dart';
import 'package:nombra/features/rules/widgets/rule_card.dart';
import 'package:nombra/core/widgets/segmented_toggle.dart';
import 'package:nombra/features/rules/domain/rename_rule.dart';
import 'package:nombra/features/rules/domain/storage_root.dart';
import 'package:nombra/features/download/data/downloads_notifier.dart';
import 'package:nombra/features/download/domain/download_models.dart';
import 'package:nombra/features/rules/data/rules_notifier.dart';
import 'package:nombra/features/settings/app_settings.dart';

import '../helpers/fakes.dart';

const String _url = 'https://cdn.ejemplo.com/docs/Informe%20Q3%20FINAL%20(2).pdf';

/// Taps a chip of the row of rules, scrolling the row until it is in view.
Future<void> tapChip(WidgetTester tester, String label) async {
  final chip = find.widgetWithText(PillChoice, label);
  await tester.ensureVisible(chip);
  await tester.pump();
  await tester.tap(chip);
}

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

/// Adds a number token from the palette; the digits dialog keeps its default of 3 digits.
Future<void> addCounter(WidgetTester tester) async {
  await tester.tap(find.text('{n}'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Aceptar'));
  await tester.pumpAndSettle();
}

Future<void> tapDownload(WidgetTester tester) async {
  await tester.tap(find.text('Descargar').first);
  // A pending download shows an indeterminate progress bar, which never settles.
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  late TestEnvironment env;

  // Most tests start with a saved rule in use; the default (no rule) has its own test.
  setUp(
    () async => env = await TestEnvironment.create(
      preferences: {
        ...storedRules(sampleRules()),
        'settings': jsonEncode(AppSettings(mode: NamingMode.saved).toJson()),
      },
    ),
  );

  testWidgets('Home shows the logo next to the app name', (tester) async {
    await pumpApp(tester, env);
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('Nombra'), findsWidgets);
  });

  testWidgets('Home shows the empty state and the saved rules', (tester) async {
    await pumpApp(tester, env);
    expect(find.text('URL del archivo'), findsOneWidget);
    expect(find.text('Fecha + nombre'), findsOneWidget);
    expect(find.text('Aún no hay descargas', skipOffstage: false), findsOneWidget);
    expect(find.byType(InfoBox), findsNothing);
  });

  group('a saved download in the list', () {
    final saved = DownloadItem(
      id: 'd1',
      fileName: 'factura_0231.pdf',
      status: DownloadStatus.done,
      plan: DownloadPlan(folder: DestinationFolder(StorageRoot.documents, 'Facturas')),
      createdAt: DateTime(2026, 11, 24, 12),
      folderPath: '/Documents/Facturas',
      finishedAt: DateTime(2026, 11, 24, 12),
    );

    setUp(
      () async => env = await TestEnvironment.create(
        preferences: {
          ...storedRules(sampleRules()),
          'downloads': jsonEncode([saved.toJson()]),
        },
      ),
    );

    testWidgets('can be opened from its menu', (tester) async {
      await pumpApp(tester, env);
      await tester.tap(find.byTooltip('Más acciones'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(env.gateway.opened, ['/storage/emulated/0/Documents/Facturas/factura_0231.pdf']);
    });

    testWidgets('says so when the file cannot be opened', (tester) async {
      env.gateway.failOpen = true;
      await pumpApp(tester, env);
      await tester.tap(find.byTooltip('Más acciones'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No se pudo abrir el archivo'), findsOneWidget);
    });

    testWidgets('can be removed from the list, and the file stays', (tester) async {
      final container = await pumpApp(tester, env);
      await tester.tap(find.byTooltip('Más acciones'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quitar de la lista'));
      await tester.pumpAndSettle();
      expect(container.read(downloadsProvider), isEmpty);
      expect(find.text('factura_0231.pdf'), findsNothing);
      expect(env.gateway.opened, isEmpty);
    });
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

  testWidgets('the file can be saved without any rule, with a saved rule, or with a custom pattern', (tester) async {
    final container = await pumpApp(tester, env);
    // With a rule applied the chips are the custom pattern and the saved rules: there is no "none" chip.
    for (final mode in ['Personalizado', 'Fecha + nombre']) {
      expect(find.text(mode), findsOneWidget);
    }
    expect(find.text('Ninguna'), findsNothing);
    await tapChip(tester, 'Fecha + nombre');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, _url);
    await tester.tap(find.text('Aplicar una regla'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).mode, NamingMode.none);
    expect(find.widgetWithText(PillChoice, 'Fecha + nombre'), findsNothing); // the chips go away
    expect(find.text('El archivo se guarda con su nombre original, sin aplicar ninguna regla.'), findsOneWidget);
    expect(find.text('Informe Q3 FINAL (2).pdf'), findsOneWidget);
    expect(find.text('/Download'), findsOneWidget);

    await tapDownload(tester);
    expect(env.engine.enqueued, hasLength(1));
    expect(container.read(downloadsProvider).single.plan.rule, isNull);
    expect(container.read(downloadsProvider).single.fileName, 'Informe Q3 FINAL (2).pdf');

    // A download in progress keeps an endless progress bar, so the page is pumped, not settled.
    // Applying a rule again brings back the last one used.
    await tester.tap(find.text('Aplicar una regla'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(settingsProvider).mode, NamingMode.saved);
    expect(container.read(settingsProvider).lastRuleId, 'date-name');
    await tapChip(tester, 'Personalizado');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Patrón'), findsOneWidget);
  });

  testWidgets('quick mode builds the name with tokens, like a rule', (tester) async {
    final container = await pumpApp(tester, env);
    await tester.tap(find.text('Personalizado'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).mode, NamingMode.quick);
    expect(find.text('Patrón'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, _url);
    expect(find.text('_'), findsOneWidget);
    await tester.tap(find.text('_'));
    await tester.pump();
    await tester.tap(find.text('{date}'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).quickTokens, ['{name}', '_', '{date}']);
    expect(find.textContaining('Informe Q3 FINAL (2)_20'), findsOneWidget);
  });

  testWidgets('the quick pattern is kept, it is not saved as a rule', (tester) async {
    final container = await pumpApp(tester, env);
    await tester.tap(find.text('Personalizado'));
    await tester.pumpAndSettle();
    await addCounter(tester);
    await tester.pumpAndSettle();
    expect(container.read(rulesProvider), hasLength(4));
    expect(env.preferences.getString('settings'), contains('"quickTokens":["{name}","{n:3}"]'));
  });

  testWidgets('the sequential number can be set by hand and starts again when the pattern changes', (tester) async {
    final container = await pumpApp(tester, env);
    await tester.tap(find.text('Personalizado'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, _url);
    await addCounter(tester);
    await tester.pumpAndSettle();
    expect(find.text('Informe Q3 FINAL (2)001.pdf'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), '25');
    await tester.pumpAndSettle();
    expect(find.text('Informe Q3 FINAL (2)025.pdf'), findsOneWidget);
    expect(container.read(settingsProvider).quickNext, 25);

    await tester.enterText(find.byType(TextField).at(1), '0');
    await tester.pumpAndSettle();
    expect(find.text('Escribe un número entero mayor que 0'), findsOneWidget);
    expect(container.read(settingsProvider).quickNext, 25);

    await tester.enterText(find.byType(TextField).at(1), '25');
    await tester.pumpAndSettle();
    await tester.tap(find.text('-'));
    await tester.pumpAndSettle();
    expect(find.text('Informe Q3 FINAL (2)001-.pdf'), findsOneWidget);
    expect(container.read(settingsProvider).nextQuickNumber, 1);
    expect(tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text, '1');
  });

  testWidgets('a button starts the sequential number again at 1', (tester) async {
    final container = await pumpApp(tester, env);
    await tester.tap(find.text('Personalizado'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, _url);
    await addCounter(tester);
    await tester.pumpAndSettle();

    final reset = find.widgetWithIcon(IconButton, Icons.restart_alt);
    expect(tester.widget<IconButton>(reset).onPressed, isNull, reason: 'already at 1');

    await tester.enterText(find.byType(TextField).at(1), '25');
    await tester.pumpAndSettle();
    expect(find.text('Informe Q3 FINAL (2)025.pdf'), findsOneWidget);

    await tester.tap(reset);
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).nextQuickNumber, 1);
    expect(tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text, '1');
    expect(find.text('Informe Q3 FINAL (2)001.pdf'), findsOneWidget);
  });

  testWidgets('choosing a rule changes the folder and is remembered', (tester) async {
    final container = await pumpApp(tester, env);
    await tester.enterText(find.byType(TextField).first, _url);
    await tapChip(tester, 'Facturas');
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).lastRuleId, 'invoices');
    expect(find.text('/Documents/Facturas'), findsOneWidget);
    expect(find.textContaining('Factura_'), findsWidgets);
  });

  testWidgets('the folder shows only the icon and the path: no tag about where it comes from', (tester) async {
    await pumpApp(tester, env);
    await tester.enterText(find.byType(TextField).first, _url);
    await tapChip(tester, 'Facturas');
    await tester.pumpAndSettle();
    expect(find.text('/Documents/Facturas'), findsOneWidget);
    for (final text in ['De la regla', 'Última usada', 'Elegida']) {
      expect(find.text(text), findsNothing);
    }
    expect(find.textContaining('Guardar en'), findsNothing);
  });

  testWidgets('with nothing configured, no rule is applied and the chips are hidden', (tester) async {
    final clean = await TestEnvironment.create(preferences: storedRules(sampleRules()));
    final container = await pumpApp(tester, clean);
    expect(container.read(settingsProvider).mode, NamingMode.none);
    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isFalse);
    expect(find.byType(PillChoice), findsNothing);
    // The explanation is an info box, not part of the switch label.
    expect(
      find.descendant(
        of: find.byType(InfoBox),
        matching: find.text('El archivo se guarda con su nombre original, sin aplicar ninguna regla.'),
      ),
      findsOneWidget,
    );

    // With no rule used before, applying one starts with the custom pattern.
    await tester.tap(find.text('Aplicar una regla'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).mode, NamingMode.quick);
    // The note is replaced by the rule chips.
    expect(find.text('El archivo se guarda con su nombre original, sin aplicar ninguna regla.'), findsNothing);
    expect(find.widgetWithText(PillChoice, 'Personalizado'), findsOneWidget);
    expect(find.widgetWithText(PillChoice, 'Fecha + nombre'), findsOneWidget);
  });

  testWidgets('Home has an "Agregar" chip, apart from the rules, that opens the new rule screen', (tester) async {
    await pumpApp(tester, env);
    expect(find.widgetWithText(PillChoice, 'Agregar'), findsOneWidget);
    expect(find.text('Editar reglas'), findsNothing);
    // Same height as the rule chips, so it does not look smaller than them.
    final addHeight = tester.getSize(find.widgetWithText(PillChoice, 'Agregar')).height;
    expect(addHeight, tester.getSize(find.widgetWithText(PillChoice, 'Fecha + nombre')).height);

    // The chips are one row that scrolls sideways: "Agregar" is the last one.
    await tester.ensureVisible(find.widgetWithText(PillChoice, 'Agregar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(PillChoice, 'Agregar'));
    await tester.pumpAndSettle();
    expect(find.text('Patrón'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
  });

  testWidgets('leaving the app closes the keyboard, so it does not come back with its space reserved', (tester) async {
    await pumpApp(tester, env);
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.hasPrimaryFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(tester.testTextInput.isVisible, isFalse);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
  });

  testWidgets('Rules lists the seed rules, with no switch to turn one off', (tester) async {
    await pumpApp(tester, env);
    await tester.tap(find.text('Reglas'));
    await tester.pumpAndSettle();
    expect(find.text('Predeterminada'), findsOneWidget);
    expect(find.text('Original'), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
  });

  testWidgets('in a rule card each icon is centered on the first line of its text', (tester) async {
    await pumpApp(tester, env);
    await tester.tap(find.text('Reglas'));
    await tester.pumpAndSettle();
    final card = find.byType(RuleCard).first;
    final rule = tester.widget<RuleCard>(card).rule;
    final pattern = find.descendant(
      of: card,
      matching: find.byWidgetPredicate((widget) => widget is Text && widget.data == rule.pattern),
    );
    final icon = find.descendant(of: card, matching: find.byIcon(Icons.data_array));
    expect(pattern, findsOneWidget);
    expect(tester.getCenter(icon).dy, closeTo(tester.getCenter(pattern).dy, 0.5));
    final folderIcon = find.descendant(of: card, matching: find.byIcon(Icons.folder_outlined));
    final folderText = find.descendant(of: card, matching: find.textContaining('/'));
    expect(tester.getCenter(folderIcon).dy, closeTo(tester.getCenter(folderText.first).dy, 0.5));
  });

  testWidgets('the folder is shown and changed with the same component on every screen', (tester) async {
    await pumpApp(tester, env);
    expect(find.byType(DestinationCard), findsOneWidget); // Download
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.byType(DestinationCard), findsOneWidget);
    await tester.tap(find.text('Reglas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nueva regla'));
    await tester.pumpAndSettle();
    expect(find.byType(DestinationCard), findsOneWidget); // rule editor
  });

  testWidgets('the name preview is hidden until the URL is valid, then shows below the folder', (tester) async {
    await pumpApp(tester, env);
    expect(find.byType(InfoBox), findsNothing);
    await tester.enterText(find.byType(TextField).first, 'esto no es una url');
    await tester.pump();
    expect(find.byType(InfoBox), findsNothing);

    await tester.enterText(find.byType(TextField).first, _url);
    await tester.pump();
    final folder = tester.getTopLeft(find.byType(DestinationCard)).dy;
    final preview = tester.getTopLeft(find.byType(InfoBox)).dy;
    expect(preview, greaterThan(folder));
  });

  testWidgets('a new rule starts with the default folder of Settings; Download if none was set', (tester) async {
    final container = await pumpApp(tester, env);
    await tester.tap(find.text('Reglas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nueva regla'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(DestinationCard), matching: find.text('/Download')), findsOneWidget);
    expect(find.descendant(of: find.byType(DestinationCard), matching: find.text('Cambiar')), findsOneWidget);
    expect(find.descendant(of: find.byType(DestinationCard), matching: find.byIcon(Icons.close)), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    container.read(settingsProvider.notifier).setLastFolder(DestinationFolder(StorageRoot.documents, 'Trabajo'));
    await tester.tap(find.text('Nueva regla'));
    await tester.pumpAndSettle();
    expect(find.text('/Documents/Trabajo'), findsOneWidget);
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
    expect(find.text('Este campo es obligatorio'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Mi regla');
    await addCounter(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    final created = container.read(rulesProvider).firstWhere((rule) => rule.name == 'Mi regla');
    expect(created.name, 'Mi regla');
    expect(created.tokens, ['{date}', '_', '{name}', '{n:3}']);
    expect(find.text('Reglas'), findsWidgets);
  });

  group('with no rules', () {
    setUp(() async => env = await TestEnvironment.create());

    testWidgets('Home offers to create a rule and still names the file after the original', (tester) async {
      await pumpApp(tester, env);
      await tester.tap(find.text('Aplicar una regla'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(PillChoice, 'Agregar'), findsOneWidget);
      await tester.tap(find.text('Aplicar una regla'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, _url);
      await tester.pumpAndSettle();
      expect(find.textContaining('Informe Q3 FINAL (2).pdf'), findsOneWidget);
    });

    testWidgets('Rules shows an empty state', (tester) async {
      await pumpApp(tester, env);
      await tester.tap(find.text('Reglas'));
      await tester.pumpAndSettle();
      expect(find.text('Aún no tienes reglas'), findsOneWidget);
    });
  });

  Future<void> openEditor(WidgetTester tester) async {
    await tester.tap(find.text('Reglas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nueva regla'));
    await tester.pumpAndSettle();
  }

  group('navigation', () {
    testWidgets('back from the Rules tab returns to Download instead of closing the app', (tester) async {
      await pumpApp(tester, env);
      await tester.tap(find.text('Reglas'));
      await tester.pumpAndSettle();
      expect(find.text('Nueva regla'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('URL del archivo'), findsOneWidget);
    });

    testWidgets('the editor back arrow returns to Rules when nothing changed', (tester) async {
      await pumpApp(tester, env);
      await openEditor(tester);
      await tester.tap(find.byTooltip('Volver a Reglas'));
      await tester.pumpAndSettle();
      expect(find.text('Nueva regla'), findsOneWidget);
      expect(find.text('Patrón'), findsNothing);
    });

    testWidgets('leaving the editor with changes asks before discarding', (tester) async {
      final container = await pumpApp(tester, env);
      await openEditor(tester);
      await tester.enterText(find.byType(TextField).first, 'Cambio');
      await tester.pump();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('¿Descartar cambios?'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Patrón'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      expect(find.text('Patrón'), findsNothing);
      expect(container.read(rulesProvider).any((rule) => rule.name == 'Cambio'), isFalse);
    });

    testWidgets('an unknown rule id shows a message and a way back', (tester) async {
      final container = await pumpApp(tester, env);
      unawaited(container.read(routerProvider).push('/rules/no-existe'));
      await tester.pumpAndSettle();
      expect(find.text('Esta regla ya no existe'), findsOneWidget);
      await tester.tap(find.text('Volver a Reglas'));
      await tester.pumpAndSettle();
      expect(find.text('Esta regla ya no existe'), findsNothing);
    });

    testWidgets('an unknown location goes home', (tester) async {
      final container = await pumpApp(tester, env);
      container.read(routerProvider).go('/nada/por/aqui');
      await tester.pumpAndSettle();
      expect(find.text('URL del archivo'), findsOneWidget);
    });
  });

  group('rules list', () {
    testWidgets('lists the rules by name, without a way to reorder them', (tester) async {
      await pumpApp(tester, env);
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Reglas')));
      await tester.pumpAndSettle();

      final names = ['Facturas', 'Fecha + nombre', 'Limpio', 'Original'];
      final positions = [for (final name in names) tester.getTopLeft(find.text(name)).dy];
      expect([...positions]..sort(), positions);
      expect(find.byIcon(Icons.drag_indicator), findsNothing);
      expect(find.textContaining('Arrastra'), findsNothing);
    });

    testWidgets('each card shows name, tokens, example, options and folder, aligned to one edge', (tester) async {
      await pumpApp(tester, env);
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Reglas')));
      await tester.pumpAndSettle();

      // "Limpio": lowercase, no (2) suffix, spaces replaced, clean name; saved in Documents/Nombra.
      expect(find.text('{name}'), findsWidgets);
      expect(find.text('minúsculas'), findsOneWidget);
      expect(find.text('Sin sufijo (2)'), findsOneWidget);
      expect(find.text('Espacios → -'), findsOneWidget);
      expect(find.text('Nombre limpio'), findsOneWidget);
      expect(find.text('/Documents/Nombra'), findsOneWidget);
      // Every rule says what happens when the file exists, and where it is saved.
      expect(find.textContaining('Si existe:'), findsNWidgets(4));
      expect(find.byIcon(Icons.folder_outlined), findsNWidgets(4));

      // The pattern, example, options and folder of a card start at the same left edge.
      final card = find.ancestor(of: find.text('/Documents/Nombra'), matching: find.byType(AppCard)).first;
      final edge = tester.getTopLeft(find.descendant(of: card, matching: find.text('/Documents/Nombra'))).dx;
      // A tag is a pill: compare the left edge of the pill, not of its text.
      final tag = find
          .ancestor(
            of: find.descendant(of: card, matching: find.text('Nombre limpio')),
            matching: find.byType(Container),
          )
          .first;
      expect(tester.getTopLeft(tag).dx, edge);
      expect(tester.getTopLeft(find.descendant(of: card, matching: find.text('{name}'))).dx, edge);
    });

    testWidgets('tapping a card opens the rule', (tester) async {
      await pumpApp(tester, env);
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Reglas')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Limpio'));
      await tester.pumpAndSettle();
      expect(find.text('Editar regla'), findsOneWidget);
    });
  });

  group('standard layout', () {
    testWidgets('every tab starts with the same header: position, size and style', (tester) async {
      await pumpApp(tester, env);
      final seen = <(Offset, double?)>[];
      for (final tab in ['Descargar', 'Reglas', 'Ajustes']) {
        await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(tab)));
        await tester.pumpAndSettle();
        final title = find.descendant(of: find.byType(ScreenHeader), matching: find.byType(Text)).first;
        seen.add((tester.getTopLeft(title), tester.widget<Text>(title).style?.fontSize));
      }
      expect(seen.toSet(), hasLength(1), reason: 'headers differ: $seen');
    });

    testWidgets('cards share the radius and padding, buttons the height and shape', (tester) async {
      await pumpApp(tester, env);
      final card = tester.widget<Material>(
        find.descendant(of: find.byType(AppCard), matching: find.byType(Material)).first,
      );
      expect(card.borderRadius, BorderRadius.circular(AppLayout.cardRadius));

      final button = tester.getSize(find.widgetWithText(FilledButton, 'Descargar'));
      expect(button.height, AppSize.button);
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Ajustes')));
      await tester.pumpAndSettle();
      final settingsCard = tester.getTopLeft(find.byType(AppCard).first);
      expect(settingsCard.dx, AppLayout.gutter);
    });
  });

  group('rule editor header', () {
    testWidgets('the back icon is flush with the content and the title sits next to it, same style', (tester) async {
      await pumpApp(tester, env);
      await tester.tap(find.text('Reglas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nueva regla'));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.byIcon(Icons.arrow_back)).dx, 16);
      final back = tester.getCenter(find.byIcon(Icons.arrow_back));
      final title = tester.getCenter(find.text('Nueva regla'));
      expect(title.dy, closeTo(back.dy, 1), reason: 'the title is in the same row as the back icon');
      expect(tester.getTopLeft(find.text('Nueva regla')).dx, greaterThan(back.dx));
      expect(tester.widget<Text>(find.text('Nueva regla')).style?.fontSize, 22);
    });

    testWidgets('Guardar is a full-width button at the bottom, below the example', (tester) async {
      await pumpApp(tester, env);
      await tester.tap(find.text('Reglas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nueva regla'));
      await tester.pumpAndSettle();

      final save = find.widgetWithText(FilledButton, 'Guardar');
      expect(save, findsOneWidget);
      expect(find.descendant(of: find.byType(ScreenHeader), matching: find.text('Guardar')), findsNothing);
      expect(tester.getTopLeft(save).dy, greaterThan(tester.getBottomLeft(find.textContaining('Ejemplo ·')).dy));
      expect(tester.getSize(save).width, greaterThan(300));
    });
  });

  group('pattern builder', () {
    Future<ProviderContainer> openQuick(WidgetTester tester) async {
      final container = await pumpApp(tester, env);
      await tester.tap(find.text('Personalizado'));
      await tester.pumpAndSettle();
      return container;
    }

    List<String> quickTokens(ProviderContainer container) => container.read(settingsProvider).quickTokens;

    testWidgets('the tokens, the .ext and the delete button share one center line', (tester) async {
      await openQuick(tester);
      final backspace = find.byIcon(Icons.backspace_outlined);
      final tokenCenter = tester.getCenter(find.text('{name}').first).dy;
      expect(tokenCenter, closeTo(tester.getCenter(backspace).dy, 1));

      await tester.tap(backspace);
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.text('.ext')).dy, closeTo(tester.getCenter(backspace).dy, 1));
    });

    testWidgets('a blank space can be added, and shows as a visible mark', (tester) async {
      final container = await openQuick(tester);
      await tester.tap(find.bySemanticsLabel('Espacio'));
      await tester.pumpAndSettle();
      expect(quickTokens(container), ['{name}', ' ']);
      expect(find.text('␣'), findsWidgets);
    });

    testWidgets('a pattern has no limit of tokens', (tester) async {
      final container = await openQuick(tester);
      for (var i = 0; i < 9; i++) {
        // The palette comes after the tokens already in the pattern.
        await tester.tap(find.text('_').last);
        await tester.pumpAndSettle();
      }
      expect(quickTokens(container), hasLength(10)); // {name} + 9 separators, more than the old limit of 5
      expect(find.textContaining('Máximo'), findsNothing);
      expect(find.text('Toca para insertar'), findsOneWidget);
    });

    testWidgets('a token leaves the palette once it is used; separators and text stay', (tester) async {
      final container = await openQuick(tester);
      // {name} is already in the quick pattern, so it is not offered again.
      expect(find.text('{name}'), findsOneWidget); // only the token inside the pattern
      expect(find.text('{date}'), findsOneWidget); // only the palette item

      await tester.tap(find.text('{date}'));
      await tester.pumpAndSettle();
      expect(find.text('{date}'), findsOneWidget); // now only the token inside the pattern
      expect(quickTokens(container), ['{name}', '{date}']);

      // Separators and free text can be used as many times as needed.
      await tester.tap(find.text('_').last);
      await tester.pumpAndSettle();
      expect(find.text('_'), findsNWidgets(2));
      expect(find.text('-'), findsOneWidget);
      expect(find.text('Texto…'), findsOneWidget);
      expect(find.bySemanticsLabel('Espacio'), findsOneWidget);

      // Deleting the token puts it back in the palette.
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byIcon(Icons.backspace_outlined));
        await tester.pumpAndSettle();
      }
      expect(quickTokens(container), ['{name}']);
      expect(find.text('{date}'), findsOneWidget);
    });

    testWidgets('the number is offered once, whatever its digits', (tester) async {
      await openQuick(tester);
      await addCounter(tester);
      expect(find.text('{n}'), findsNothing);
      expect(find.text('{n:3}'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pumpAndSettle();
      expect(find.text('{n}'), findsOneWidget);
    });

    testWidgets('text and number inputs open in a sheet at the bottom, not in a centered dialog', (tester) async {
      await openQuick(tester);
      final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;

      await tester.tap(find.text('Texto…'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.getBottomLeft(find.byType(BottomSheet)).dy, closeTo(screenHeight, 1));
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);

      await tester.tap(find.text('{n}'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.getBottomLeft(find.byType(BottomSheet)).dy, closeTo(screenHeight, 1));
    });

    testWidgets('a text token is changed by tapping it', (tester) async {
      final container = await openQuick(tester);
      await tester.tap(find.text('Texto…'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Doc_');
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();
      expect(quickTokens(container), ['{name}', 'Doc_']);

      await tester.tap(find.text('Doc_'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byType(TextField).last).controller!.text, 'Doc_');
      await tester.enterText(find.byType(TextField).last, 'Fac_');
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();
      expect(quickTokens(container), ['{name}', 'Fac_']);
    });

    testWidgets('the number token asks for its digits, and they can be changed later', (tester) async {
      final container = await openQuick(tester);
      await tester.tap(find.text('{n}'));
      await tester.pumpAndSettle();
      expect(find.text('3 dígitos'), findsOneWidget);
      expect(find.text('Ejemplo: 007'), findsOneWidget);

      await tester.tap(find.byTooltip('Más dígitos'));
      await tester.tap(find.byTooltip('Más dígitos'));
      await tester.pumpAndSettle();
      expect(find.text('Ejemplo: 00007'), findsOneWidget);
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();
      expect(quickTokens(container), ['{name}', '{n:5}']);

      await tester.tap(find.text('{n:5}'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Menos dígitos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();
      expect(quickTokens(container), ['{name}', '{n:4}']);
    });

    testWidgets('cancelling the digits does not add the token', (tester) async {
      final container = await openQuick(tester);
      await tester.tap(find.text('{n}'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(quickTokens(container), ['{name}']);
    });

    testWidgets('replacing spaces uses the same toggle as the letter case', (tester) async {
      await pumpApp(tester, env);
      await openEditor(tester);
      await tester.tap(find.text('Reemplazar espacios'));
      await tester.pumpAndSettle();
      expect(find.text('- guion'), findsOneWidget);
      expect(find.byType(SegmentedToggle<String>), findsOneWidget);
      expect(find.byType(SegmentedToggle<CaseMode>), findsOneWidget);
    });
  });

  group('rule editor example', () {
    testWidgets('is pinned below the form, outside the scrolling list, and follows the pattern', (tester) async {
      await pumpApp(tester, env);
      await openEditor(tester);

      final example = find.textContaining('Ejemplo ·');
      expect(example, findsOneWidget);
      expect(find.descendant(of: find.byType(ListView), matching: example), findsNothing);
      // It sits at the bottom of the screen, below the form.
      expect(tester.getBottomLeft(example).dy, greaterThan(tester.getTopLeft(find.text('Patrón')).dy));

      expect(find.textContaining('Informe Q3 FINAL (2).pdf'), findsWidgets);
      await addCounter(tester);
      await tester.pumpAndSettle();
      expect(
        find.text('${DateTime.now().toIso8601String().substring(0, 10)}_Informe Q3 FINAL (2)001.pdf'),
        findsOneWidget,
      );
    });
  });

  group('validation', () {
    testWidgets('a rule name that already exists is rejected', (tester) async {
      final container = await pumpApp(tester, env);
      await openEditor(tester);
      await tester.enterText(find.byType(TextField).first, ' facturas ');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Ya existe una regla con ese nombre'), findsOneWidget);
      expect(container.read(rulesProvider), hasLength(4));
    });

    testWidgets('an empty pattern cannot be saved', (tester) async {
      final container = await pumpApp(tester, env);
      await openEditor(tester);
      await tester.enterText(find.byType(TextField).first, 'Vacía');
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byTooltip('Borrar último elemento'));
        await tester.pump();
      }
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Agrega al menos un elemento al patrón'), findsOneWidget);
      expect(container.read(rulesProvider), hasLength(4));
    });

    testWidgets('an empty quick pattern shows an error and blocks the download', (tester) async {
      await pumpApp(tester, env);
      await tester.tap(find.text('Personalizado'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, _url);
      await tester.tap(find.byTooltip('Borrar último elemento'));
      await tester.pumpAndSettle();
      expect(find.text('Agrega al menos un elemento al patrón'), findsWidgets);
      await tapDownload(tester);
      await tester.pumpAndSettle();
      expect(env.engine.enqueued, isEmpty);
    });
  });
}
