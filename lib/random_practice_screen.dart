import 'package:flutter/material.dart';
import 'package:rememberall2/poem_model.dart';
import 'package:rememberall2/poem_screen.dart';
import 'package:rememberall2/poems_screen_logic.dart';
import 'package:rememberall2/random_practice_logic.dart';
import 'package:watch_it/watch_it.dart';

class RandomPracticeScreen extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const RandomPracticeScreen({super.key});

  @override
  State<RandomPracticeScreen> createState() => _RandomPracticeScreenState();
}

class _RandomPracticeScreenState extends State<RandomPracticeScreen> {
  @override
  Widget build(BuildContext context) {
    final logic = di.get<RandomPracticeLogic>();
    final poem = watchValue((RandomPracticeLogic l) => l.currentPoem);
    final remaining = watchValue((RandomPracticeLogic l) => l.remaining);

    return Scaffold(
      appBar: AppBar(
        title: Text('${logic.doneCount} / ${logic.totalCount.value}'),
      ),
      body: Center(
        child: poem == null
            ? const Text('All done!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      poem.poemTitle(),
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Practice this one'),
                      onPressed: () {
                        di.get<PoemsScreenLogic>().selectedPoem.value = poem;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OnePoemSreen(
                              title: poem.poemTitle(),
                              poem: poem,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: poem != null
          ? FloatingActionButton.extended(
              onPressed: () => logic.next(),
              label: Text('Next (${remaining.length} left)'),
              icon: const Icon(Icons.skip_next),
            )
          : FloatingActionButton.extended(
              onPressed: () => Navigator.pop(context),
              label: const Text('Done'),
              icon: const Icon(Icons.check),
            ),
    );
  }
}
