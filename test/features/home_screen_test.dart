import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nombra/app/app.dart';

void main() {
  testWidgets('shows the home greeting in the device language', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('es')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const ProviderScope(child: NombraApp()));
    await tester.pumpAndSettle();

    expect(find.text('Hola'), findsOneWidget);
    expect(find.text('Esta es la app Nombra'), findsOneWidget);
  });
}
