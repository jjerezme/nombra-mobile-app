import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/features/rules/data/rules_notifier.dart';
import 'package:nombra/features/rules/domain/rename_rule.dart';

import '../../helpers/fakes.dart';

void main() {
  late TestEnvironment env;

  setUp(() async => env = await TestEnvironment.create(preferences: storedRules(sampleRules())));

  test('a fresh install has no rules', () async {
    final clean = await TestEnvironment.create();
    expect(clean.container().read(rulesProvider), isEmpty);
    expect(clean.preferences.getString('rules'), isNull);
  });

  test('a corrupted stored value falls back to no rules', () async {
    final broken = await TestEnvironment.create(preferences: {'rules': '{not json'});
    expect(broken.container().read(rulesProvider), isEmpty);
  });

  test('rules are persisted across containers', () {
    env.container().read(rulesProvider.notifier).upsert(RenameRule(id: 'x', name: 'X', tokens: const ['{name}']));
    expect(env.container().read(rulesProvider).last.id, 'x');
  });

  test('reorder moves a rule to its new position', () {
    final container = env.container();
    container.read(rulesProvider.notifier).reorder(3, 0);
    expect(container.read(rulesProvider).first.id, 'invoices');
  });

  test('setEnabled toggles a rule', () {
    final container = env.container();
    container.read(rulesProvider.notifier).setEnabled('clean', isEnabled: false);
    expect(container.read(rulesProvider).firstWhere((rule) => rule.id == 'clean').isEnabled, isFalse);
  });

  test('the default rule cannot be removed; others can', () {
    final container = env.container();
    final notifier = container.read(rulesProvider.notifier);
    notifier.remove('date-name');
    notifier.remove('clean');
    final ids = container.read(rulesProvider).map((rule) => rule.id);
    expect(ids, contains('date-name'));
    expect(ids, isNot(contains('clean')));
  });

  test('takeCounter returns the current value and advances it', () {
    final container = env.container();
    final notifier = container.read(rulesProvider.notifier);
    expect(notifier.takeCounter('invoices'), 1);
    expect(notifier.takeCounter('invoices'), 2);
    expect(notifier.byId('invoices')!.counter, 3);
  });
}
