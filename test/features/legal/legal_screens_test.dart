import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nombra/app/app.dart';
import 'package:nombra/core/l10n/current_l10n.dart';
import 'package:nombra/features/legal/domain/legal_content.dart';
import 'package:nombra/features/legal/domain/legal_models.dart';
import 'package:nombra/features/settings/settings_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../helpers/account_fakes.dart';
import '../../helpers/fakes.dart';

Future<void> pumpSettings(WidgetTester tester, TestEnvironment env, {String locale = 'es'}) async {
  tester.view
    ..physicalSize = const Size(1170, 4000)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  tester.platformDispatcher
    ..localeTestValue = Locale(locale)
    ..localesTestValue = [Locale(locale)];
  addTearDown(tester.platformDispatcher.clearLocaleTestValue);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  addTearDown(() => languageOverride = null);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...env.overrides,
        ...accountOverrides(FakeAuthGateway(), FakeBackupGateway()),
        packageInfoProvider.overrideWith(
          (ref) async => PackageInfo(appName: 'Nombra', packageName: 'x', version: '1.0.0', buildNumber: '1'),
        ),
      ],
      child: const NombraApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(locale == 'es' ? 'Ajustes' : 'Settings'));
  await tester.pumpAndSettle();
}

Future<void> openFromLegalRow(WidgetTester tester, String label) async {
  final row = find.widgetWithText(ListTile, label);
  await tester.ensureVisible(row);
  await tester.pumpAndSettle();
  await tester.tap(row);
  await tester.pumpAndSettle();
}

void main() {
  late TestEnvironment env;

  setUp(() async => env = await TestEnvironment.create());

  testWidgets('Settings has a Legal section that opens the terms and the privacy policy', (tester) async {
    await pumpSettings(tester, env);
    final terms = legalDocument(LegalKind.terms, 'es');
    final privacy = legalDocument(LegalKind.privacy, 'es');

    await openFromLegalRow(tester, 'Términos y condiciones');
    expect(find.text(terms.title), findsOneWidget);
    expect(find.text(terms.updatedLabel), findsOneWidget);
    expect(find.text(terms.sections.first.title), findsOneWidget);

    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    await openFromLegalRow(tester, 'Política de privacidad');
    expect(find.text(privacy.title), findsOneWidget);
    expect(find.text(privacy.sections.first.title), findsOneWidget);
  });

  testWidgets('the text follows the language of the app', (tester) async {
    await pumpSettings(tester, env, locale: 'en');
    await openFromLegalRow(tester, 'Privacy policy');
    expect(find.text(legalDocument(LegalKind.privacy, 'en').intro), findsOneWidget);
  });

  testWidgets('the section titles are headings for a screen reader', (tester) async {
    await pumpSettings(tester, env);
    await openFromLegalRow(tester, 'Términos y condiciones');
    final handle = tester.ensureSemantics();
    final title = legalDocument(LegalKind.terms, 'es').sections.first.title;
    expect(tester.getSemantics(find.text(title)).flagsCollection.isHeader, isTrue);
    handle.dispose();
  });

  testWidgets('signing in says the terms and the policy are accepted and links to them', (tester) async {
    await pumpSettings(tester, env);
    expect(find.text('Al continuar aceptas los términos y la política de privacidad.'), findsOneWidget);
    final link = find.widgetWithText(TextButton, 'Política de privacidad');
    await tester.ensureVisible(link);
    await tester.pumpAndSettle();
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(find.text(legalDocument(LegalKind.privacy, 'es').title), findsOneWidget);
  });
}
