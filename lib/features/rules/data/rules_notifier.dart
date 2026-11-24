import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/rename_rule.dart';

const String _rulesKey = 'rules';

/// Rules in the order the app shows them everywhere: by name, ignoring case. There is no manual order.
List<RenameRule> sortedByName(Iterable<RenameRule> rules) =>
    [...rules]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

class RulesNotifier extends Notifier<List<RenameRule>> {
  @override
  List<RenameRule> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getString(_rulesKey);
    if (raw != null) {
      try {
        return sortedByName(
          (jsonDecode(raw) as List<dynamic>).map((json) => RenameRule.fromJson(json as Map<String, dynamic>)),
        );
      } on Object {
        // A corrupted value falls back to no rules: the user starts from a clean list.
      }
    }
    return const [];
  }

  void _update(List<RenameRule> changed) {
    final next = sortedByName(changed);
    state = next;
    ref.read(sharedPreferencesProvider).setString(_rulesKey, jsonEncode(next.map((rule) => rule.toJson()).toList()));
  }

  RenameRule? byId(String id) => state.where((rule) => rule.id == id).firstOrNull;

  String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Replaces the rule with the same id, or appends it.
  void upsert(RenameRule rule) {
    final index = state.indexWhere((existing) => existing.id == rule.id);
    if (index < 0) {
      _update([...state, rule]);
    } else {
      _update([...state]..[index] = rule);
    }
  }

  /// Deletes every rule, including the default one.
  void clear() => _update(const []);

  void remove(String id) => _update(state.where((rule) => rule.id != id || rule.isDefault).toList());

  /// Returns the current `{n:3}` value of the rule and advances it.
  int takeCounter(String id) {
    final rule = byId(id);
    if (rule == null) return 1;
    _update([
      for (final existing in state) existing.id == id ? existing.copyWith(counter: rule.counter + 1) : existing,
    ]);
    return rule.counter;
  }
}

final rulesProvider = NotifierProvider<RulesNotifier, List<RenameRule>>(RulesNotifier.new);
