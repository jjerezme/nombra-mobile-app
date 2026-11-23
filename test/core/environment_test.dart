import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/core/environment.dart';

void main() {
  group('AppEnvironment.fromFlavor', () {
    test('prod resolves to production', () {
      expect(AppEnvironment.fromFlavor('prod'), AppEnvironment.production);
    });

    test('dev, unknown and null resolve to development', () {
      expect(AppEnvironment.fromFlavor('dev'), AppEnvironment.development);
      expect(AppEnvironment.fromFlavor('staging'), AppEnvironment.development);
      expect(AppEnvironment.fromFlavor(null), AppEnvironment.development);
    });
  });

  test('application ids match the Android flavors', () {
    expect(AppEnvironment.production.applicationId, 'com.jujeme.nombra');
    expect(AppEnvironment.development.applicationId, 'com.jujeme.nombra.dev');
  });
}
