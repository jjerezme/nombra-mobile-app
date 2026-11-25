import 'dart:convert';
import 'dart:math';

import '../../rules/domain/rename_rule.dart';

/// The list of rules as the JSON that is stored in the cloud.
String encodeRules(List<RenameRule> rules) => jsonEncode(rules.map((rule) => rule.toJson()).toList());

/// Reads what [encodeRules] wrote; null when [json] is not a valid list of rules.
List<RenameRule>? decodeRules(String json) {
  try {
    return (jsonDecode(json) as List<dynamic>)
        .map((item) => RenameRule.fromJson(item as Map<String, dynamic>))
        .toList();
  } on Object {
    return null;
  }
}

/// The first time a device meets the backup: every rule of both sides is kept. For a rule on both sides the cloud
/// version wins, except its `{n:3}` counter, which keeps the higher number so no file gets a number used before.
List<RenameRule> mergeRules(List<RenameRule> local, List<RenameRule> remote) {
  final byId = {for (final rule in local) rule.id: rule};
  for (final rule in remote) {
    final mine = byId[rule.id];
    byId[rule.id] = mine == null ? rule : rule.copyWith(counter: max(rule.counter, mine.counter));
  }
  return byId.values.toList();
}
