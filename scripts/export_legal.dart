// Writes the terms and the privacy policy the app shows (`lib/features/legal/domain/`) into `web/legal/{en,es}.json`,
// where the website generator reads them. After changing a legal text run both:
//
//   dart run scripts/export_legal.dart
//   npx --yes -p git+https://github.com/jjerezme/mobile-tools.git#v0.6.0 build-web
//
// Then publish with `firebase deploy --only hosting --project nombra-prod`, only when asked.
import 'dart:io';

import 'package:nombra/features/legal/domain/legal_export.dart';

void main() {
  for (final code in ['en', 'es']) {
    final file = File('web/legal/$code.json');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(exportLegalJson(code));
    stdout.writeln('web/legal/$code.json');
  }
}
