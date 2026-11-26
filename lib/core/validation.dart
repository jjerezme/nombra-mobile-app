import '../l10n/app_localizations.dart';

/// Why a text field is not valid; [InputErrorText.message] turns it into the user-facing text.
enum InputError { required, tooLong, invalidChars, duplicate, invalidPath, invalidNumber }

const int maxRuleNameLength = 40;
const int maxFileBaseLength = 120;
const int maxSubfolderLength = 100;

/// Largest sequential number accepted in quick mode.
const int maxSequenceNumber = 999999999;

final RegExp _invalidFileChars = RegExp(r'[/\\:*?"<>|\x00-\x1F]');
final RegExp _invalidFolderChars = RegExp(r'[:*?"<>|\x00-\x1F]');

/// Rule name: required, at most [maxRuleNameLength] characters and different from the other rules' names.
InputError? validateRuleName(String value, {Iterable<String> otherNames = const []}) {
  final name = value.trim();
  if (name.isEmpty) return InputError.required;
  if (name.length > maxRuleNameLength) return InputError.tooLong;
  final lower = name.toLowerCase();
  if (otherNames.any((other) => other.trim().toLowerCase() == lower)) return InputError.duplicate;
  return null;
}

/// Free text inside a pattern: it ends up in a file name, so it cannot hold characters Android rejects.
InputError? validatePatternText(String value) {
  if (value.trim().isEmpty) return InputError.required;
  if (_invalidFileChars.hasMatch(value)) return InputError.invalidChars;
  if (value.length > maxFileBaseLength) return InputError.tooLong;
  return null;
}

/// Subfolder under a public folder; may be empty. Rejects `..` and characters Android does not allow.
InputError? validateSubfolder(String value) {
  if (_invalidFolderChars.hasMatch(value)) return InputError.invalidChars;
  if (value.length > maxSubfolderLength) return InputError.tooLong;
  final parts = value.replaceAll(r'\', '/').split('/').map((part) => part.trim());
  if (parts.any((part) => part == '..')) return InputError.invalidPath;
  return null;
}

/// The next sequential number typed by hand: a whole number from 1 to [maxSequenceNumber].
InputError? validateSequenceNumber(String value) {
  final number = int.tryParse(value.trim());
  if (number == null || number < 1 || number > maxSequenceNumber) return InputError.invalidNumber;
  return null;
}

/// Whether a pattern can produce a name: it needs at least one token or some text.
bool patternHasContent(List<String> tokens) => tokens.any((token) => token.trim().isNotEmpty);

extension InputErrorText on InputError {
  String message(AppLocalizations l10n, {int? max}) => switch (this) {
    InputError.required => l10n.errRequired,
    InputError.tooLong => l10n.errTooLong(max ?? maxFileBaseLength),
    InputError.invalidChars => l10n.errInvalidChars,
    InputError.duplicate => l10n.errDuplicateName,
    InputError.invalidPath => l10n.errSubfolderInvalid,
    InputError.invalidNumber => l10n.errInvalidNumber,
  };
}
