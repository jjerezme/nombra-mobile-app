import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/rename_rule.dart';

const String _rulesKey = 'rules';

class RulesNotifier extends Notifier<List<RenameRule>> {
  @override
  List<RenameRule> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getString(_rulesKey);
    if (raw != null) {
      try {
        return (jsonDecode(raw) as List<dynamic>)
            .map((json) => RenameRule.fromJson(json as Map<String, dynamic>))
            .toList();
      } on Object {
        // A corrupted value falls back to no rules: the user starts from a clean list.
      }
    }
    return const [];
  }

  void _update(List<RenameRule> next) {
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

  void setEnabled(String id, {required bool isEnabled}) {
    _update([for (final rule in state) rule.id == id ? rule.copyWith(isEnabled: isEnabled) : rule]);
  }

  /// [newIndex] is the position after the item at [oldIndex] has been removed (as in `onReorderItem`).
  void reorder(int oldIndex, int newIndex) {
    final next = [...state];
    final moved = next.removeAt(oldIndex);
    next.insert(newIndex, moved);
    _update(next);
  }

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
