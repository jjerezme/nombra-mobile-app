import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Set<String> _keys(String path) {
  final json = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return json.keys.where((key) => !key.startsWith('@')).toSet();
}

void main() {
  test('es and en define the same keys', () {
    expect(_keys('lib/l10n/app_en.arb'), _keys('lib/l10n/app_es.arb'));
  });
}
