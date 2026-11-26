/// One line of the developer report. Technical labels stay in English on purpose: they are pasted into bug reports.
class InfoRow {
  const InfoRow(this.label, this.value);

  final String label;
  final String value;
}

/// A group of rows; [id] picks its translated title.
class InfoSection {
  const InfoSection(this.id, this.rows);

  final String id;
  final List<InfoRow> rows;
}

/// What a value that could not be read looks like.
const String unknownValue = '—';

/// The text of "copy report": each section with its rows, in order.
String formatReport(List<InfoSection> sections, String Function(String id) titleOf) => sections
    .map(
      (section) =>
          ['## ${titleOf(section.id)}', for (final row in section.rows) '${row.label}: ${row.value}'].join('\n'),
    )
    .join('\n\n');

/// The packages under `dependencies:` of a pubspec, with their version constraint (SDK packages are left out).
List<InfoRow> parseDependencies(String pubspec) {
  final rows = <InfoRow>[];
  var isInside = false;
  for (final line in pubspec.replaceAll('\r\n', '\n').split('\n')) {
    if (line.startsWith('dependencies:')) {
      isInside = true;
    } else if (isInside) {
      if (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('#')) break;
      final match = RegExp(r'^  ([a-z0-9_]+):[ \t]*(\S+)').firstMatch(line);
      if (match != null) rows.add(InfoRow(match[1]!, match[2]!));
    }
  }
  return rows;
}

/// Bytes as a short size: `1.5 GB`.
String formatBytes(num bytes) {
  if (bytes <= 0) return unknownValue;
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return '${value.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
}
