import '../l10n/app_localizations.dart';

/// "hace 2 min", "hace 3 h", "hace 2 d"; "ahora" under a minute.
String relativeTime(AppLocalizations l10n, DateTime then, DateTime now) {
  final difference = now.difference(then);
  if (difference.inMinutes < 1) return l10n.relativeNow;
  if (difference.inHours < 1) return l10n.relativeMinutes(difference.inMinutes);
  if (difference.inDays < 1) return l10n.relativeHours(difference.inHours);
  return l10n.relativeDays(difference.inDays);
}
