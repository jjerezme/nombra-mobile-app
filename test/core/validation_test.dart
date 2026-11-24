import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/core/validation.dart';

void main() {
  group('validateRuleName', () {
    test('requires a non-blank name', () {
      expect(validateRuleName('   '), InputError.required);
      expect(validateRuleName('Facturas'), isNull);
    });

    test('limits the length', () {
      expect(validateRuleName('a' * maxRuleNameLength), isNull);
      expect(validateRuleName('a' * (maxRuleNameLength + 1)), InputError.tooLong);
    });

    test('rejects a name used by another rule, ignoring case and spaces', () {
      expect(validateRuleName(' facturas ', otherNames: const ['Facturas']), InputError.duplicate);
      expect(validateRuleName('Fotos', otherNames: const ['Facturas']), isNull);
    });
  });

  group('file names', () {
    test('validatePatternText has the same character rules', () {
      expect(validatePatternText(' '), InputError.required);
      expect(validatePatternText('a*b'), InputError.invalidChars);
      expect(validatePatternText('Factura_'), isNull);
    });
  });

  group('validateSubfolder', () {
    test('accepts empty and nested folders', () {
      expect(validateSubfolder(''), isNull);
      expect(validateSubfolder('Nombra/Facturas'), isNull);
    });

    test('rejects parent references and invalid characters', () {
      expect(validateSubfolder('../etc'), InputError.invalidPath);
      expect(validateSubfolder(r'a\..\b'), InputError.invalidPath);
      expect(validateSubfolder('a:b'), InputError.invalidChars);
    });
  });

  test('patternHasContent needs at least one non-blank item', () {
    expect(patternHasContent(const []), isFalse);
    expect(patternHasContent(const [' ']), isFalse);
    expect(patternHasContent(const ['{name}']), isTrue);
  });
}
