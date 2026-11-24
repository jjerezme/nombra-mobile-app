import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nombra/app/app.dart';
import 'package:nombra/app/router.dart';
import 'package:nombra/core/constants/tokens.dart';
import 'package:nombra/core/widgets/app_card.dart';
import 'package:nombra/core/widgets/screen_header.dart';
import 'package:nombra/core/widgets/segmented_toggle.dart';
import 'package:nombra/features/rules/domain/rename_rule.dart';
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

  setUp(() async => env = await TestEnvironment.create(preferences: storedRules(sampleRules())));

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

  testWidgets('quick mode builds the name with tokens, like a rule', (tester) async {
    final container = await pumpApp(tester, env);
    await tester.tap(find.text('Rápida'));
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
    await tester.tap(find.text('Rápida'));
    await tester.pumpAndSettle();
    await addCounter(tester);
    await tester.pumpAndSettle();
    expect(container.read(rulesProvider), hasLength(4));
    expect(env.preferences.getString('settings'), contains('"quickTokens":["{name}","{n:3}"]'));
  });

  testWidgets('the sequential number can be set by hand and starts again when the pattern changes', (tester) async {
    final container = await pumpApp(tester, env);
    await tester.tap(find.text('Rápida'));
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
      expect(find.text('No hay reglas activas. Crea o activa una en Reglas.'), findsOneWidget);
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
    testWidgets('the back icon is flush with the content and the title lines up with the other screens', (
      tester,
    ) async {
      await pumpApp(tester, env);
      await tester.tap(find.text('Ajustes'));
      await tester.pumpAndSettle();
      final settingsTitle = tester.getTopLeft(find.text('Ajustes').first).dx;

      await tester.tap(find.text('Reglas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nueva regla'));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.byIcon(Icons.arrow_back)).dx, 16);
      expect(tester.getTopLeft(find.text('Nueva regla')).dx, settingsTitle);
      expect(tester.widget<Text>(find.text('Nueva regla')).style?.fontSize, 22);
    });
  });

  group('pattern builder', () {
    Future<ProviderContainer> openQuick(WidgetTester tester) async {
      final container = await pumpApp(tester, env);
      await tester.tap(find.text('Rápida'));
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

    testWidgets('a pattern takes at most 5 tokens', (tester) async {
      final container = await openQuick(tester);
      for (var i = 0; i < 4; i++) {
        // The palette comes after the tokens already in the pattern.
        await tester.tap(find.text('_').last);
        await tester.pumpAndSettle();
      }
      expect(quickTokens(container), hasLength(5));
      expect(find.text('Máximo 5 elementos'), findsOneWidget);

      await tester.tap(find.text('-'));
      await tester.pumpAndSettle();
      expect(quickTokens(container), hasLength(5));

      // Deleting one makes room again.
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Máximo 5 elementos'), findsNothing);
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
      await tester.tap(find.text('Rápida'));
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
