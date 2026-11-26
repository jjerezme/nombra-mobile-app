import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/core/crash_reporting.dart';

void main() {
  test('redactUrls removes links with their tokens and keeps the rest', () {
    expect(
      redactUrls('Failed to download https://cdn.ejemplo.com/a.pdf?token=abc123 (403)'),
      'Failed to download <url> (403)',
    );
    expect(redactUrls('sin enlaces'), 'sin enlaces');
    expect(redactUrls('a http://x.com/y y b https://z.org'), 'a <url> y b <url>');
  });

  test('RedactedError keeps the type and hides the link', () {
    expect(RedactedError('bad https://a.com/x').toString(), 'String: bad <url>');
    final error = RedactedError(const FormatException('bad https://a.com/x?sig=1'));
    expect(error.toString(), 'FormatException: bad <url>');
  });
}
