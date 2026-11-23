import 'package:intl/intl.dart';

/// `48,2 MB` with the decimal separator of [locale].
String formatBytes(num bytes, String locale) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final format = NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: unit == 0 ? 0 : 1);
  return '${format.format(value)} ${units[unit]}';
}

/// `3,1 MB/s`; [megabytesPerSecond] is how the downloader reports speed.
String formatSpeed(double megabytesPerSecond, String locale) {
  final format = NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 1);
  return '${format.format(megabytesPerSecond)} MB/s';
}
