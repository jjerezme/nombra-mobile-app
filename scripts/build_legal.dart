// Writes the legal web pages (terms and privacy policy, in Spanish and English) into `web/`, from the same text the app
// shows (`lib/features/legal/domain/`). Run it after changing that text:
//
//   dart run scripts/build_legal.dart
//
// Then publish with `firebase deploy --only hosting --project nombra-prod`. `web/style.css` and `web/logo.png` are
// written by hand and are not touched.
import 'dart:io';

import 'package:nombra/features/legal/domain/legal_html.dart';

void main() {
  final root = Directory('web');
  for (final entry in renderLegalSite().entries) {
    final file = File('${root.path}/${entry.key}');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value);
    stdout.writeln('web: ${entry.key}');
  }
}
