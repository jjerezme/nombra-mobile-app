/// Replaces every link in [text] with `<url>`: a download link can carry a token or a signature, so it never goes to a
/// crash report.
String redactUrls(String text) => text.replaceAll(RegExp(r'\b[a-zA-Z][a-zA-Z0-9+.-]*://[^\s<>"]+'), '<url>');

/// An error as it is reported: same type name, message without links.
class RedactedError implements Exception {
  RedactedError(Object error) : type = error.runtimeType.toString(), message = redactUrls(error.toString());

  final String type;
  final String message;

  @override
  String toString() => message.startsWith(type) ? message : '$type: $message';
}
