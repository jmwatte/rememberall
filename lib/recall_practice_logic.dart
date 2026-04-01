import 'package:flutter/material.dart';
import 'package:rememberall2/poem_model.dart';
import 'package:rememberall2/poems_screen_logic.dart';
import 'package:watch_it/watch_it.dart';

class RecallPracticeLogic {
  final remaining = ValueNotifier<List<Poem>>([]);
  final recalled = ValueNotifier<List<String>>([]);
  final recalledPoems = ValueNotifier<List<Poem>>([]);
  final totalCount = ValueNotifier<int>(0);
  final lastMatchResult = ValueNotifier<String>('');
  final finished = ValueNotifier<bool>(false);

  void start(List<Poem> poems) {
    remaining.value = List<Poem>.from(poems);
    recalled.value = [];
    recalledPoems.value = [];
    totalCount.value = poems.length;
    lastMatchResult.value = '';
    finished.value = false;
  }

  /// Try to match input against remaining titles.
  /// Returns the matched title if exactly one match, or null otherwise.
  String? tryMatch(String input) {
    if (input.trim().isEmpty) return null;

    final normalizedInput = _normalize(input);

    // Exact match always wins — accept one even if multiple share the title
    final exactMatches = remaining.value
        .where((p) => _normalize(p.poemTitle()) == normalizedInput)
        .toList();
    if (exactMatches.isNotEmpty) {
      _accept(exactMatches.first);
      return exactMatches.first.poemTitle();
    }

    // Collect all candidates: "contains" match + fuzzy match (>=0.7)
    final candidates = <Poem>{};

    // "starts with" candidates
    if (normalizedInput.length >= 3) {
      candidates.addAll(remaining.value.where(
          (p) => _normalize(p.poemTitle()).startsWith(normalizedInput)));
    }

    // "contains" candidates
    if (normalizedInput.length >= 3) {
      candidates.addAll(remaining.value
          .where((p) => _normalize(p.poemTitle()).contains(normalizedInput)));
    }

    // Fuzzy candidates
    for (var poem in remaining.value) {
      if (_similarity(normalizedInput, _normalize(poem.poemTitle())) >= 0.7) {
        candidates.add(poem);
      }
    }

    if (candidates.isEmpty) {
      lastMatchResult.value = 'No match found';
      return null;
    }

    if (candidates.length == 1) {
      _accept(candidates.first);
      return candidates.first.poemTitle();
    }

    // Multiple candidates — user needs to be more specific
    lastMatchResult.value = '${candidates.length} candidates — be more specific';
    return null;
  }

  void _accept(Poem poem) {
    var list = List<Poem>.from(remaining.value);
    list.remove(poem);
    remaining.value = list;

    var done = List<String>.from(recalled.value);
    done.add(poem.poemTitle());
    recalled.value = done;

    var donePoems = List<Poem>.from(recalledPoems.value);
    donePoems.add(poem);
    recalledPoems.value = donePoems;

    lastMatchResult.value = 'Matched: ${poem.poemTitle()}';
  }

  /// End the session: set recalled to green (0), missed to red (4), save to DB.
  void finish() {
    final logic = di.get<PoemsScreenLogic>();
    for (var poem in recalledPoems.value) {
      poem.levelnr = 0; // green
      logic.onLevelChanged(poem);
    }
    for (var poem in remaining.value) {
      poem.levelnr = 4; // red
      logic.onLevelChanged(poem);
    }
    finished.value = true;
  }

  /// Show all remaining titles (give up / peek)
  List<String> peek() {
    return remaining.value.map((p) => p.poemTitle()).toList();
  }

  bool get isDone => remaining.value.isEmpty;

  String _normalize(String s) {
    return s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Returns a similarity score between 0.0 and 1.0
  double _similarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    int distance = _levenshtein(a, b);
    int maxLen = a.length > b.length ? a.length : b.length;
    return 1.0 - (distance / maxLen);
  }

  int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<List<int>> matrix = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => 0),
    );

    for (int i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        int cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[a.length][b.length];
  }
}
