import 'package:flutter/foundation.dart';
import 'package:rememberall2/poem_model.dart';
import 'package:rememberall2/main.dart';

class ScrollerLogic {
  final itemscache = ValueNotifier<List<Poem>>([]);
  final numOfFav = ValueNotifier<int>(0);

  setItemscache(List<Poem> originalHeap) {
    final stopwatch = Stopwatch()..start();
    originalHeap.sort((a, b) => a.poemTitle().compareTo(b.poemTitle()));
// Partition items into favorites and non-favorites
    var fav = <Poem>[];
    var notfav = <Poem>[];
    for (var poem in originalHeap) {
      if (poem.favourite) {
        fav.add(poem);
      } else {
        notfav.add(poem);
      }
      // }

      numOfFav.value = fav.length;
      itemscache.value = fav.followedBy(notfav).toList();
    }

    if (isDebugMode) {
      if (kDebugMode) {
        print('setItemscache() executed in ${stopwatch.elapsed}');
      }
    }
  }
}
