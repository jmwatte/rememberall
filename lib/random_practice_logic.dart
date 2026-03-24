import 'package:flutter/material.dart';
import 'package:rememberall2/poem_model.dart';

class RandomPracticeLogic {
  final remaining = ValueNotifier<List<Poem>>([]);
  final currentPoem = ValueNotifier<Poem?>(null);
  final totalCount = ValueNotifier<int>(0);

  void start(List<Poem> poems) {
    var shuffled = List<Poem>.from(poems)..shuffle();
    remaining.value = shuffled;
    totalCount.value = shuffled.length;
    _drawNext();
  }

  void next() => _drawNext();

  void _drawNext() {
    if (remaining.value.isEmpty) {
      currentPoem.value = null;
      return;
    }
    var list = List<Poem>.from(remaining.value);
    currentPoem.value = list.removeAt(0);
    remaining.value = list;
  }

  int get doneCount => totalCount.value - remaining.value.length;
}
