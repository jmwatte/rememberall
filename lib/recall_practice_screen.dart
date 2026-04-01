import 'package:flutter/material.dart';
import 'package:rememberall2/poem_model.dart';
import 'package:rememberall2/recall_practice_logic.dart';
import 'package:rememberall2/scramble_utils.dart';
import 'package:watch_it/watch_it.dart';

class RecallPracticeScreen extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const RecallPracticeScreen({super.key});

  @override
  State<RecallPracticeScreen> createState() => _RecallPracticeScreenState();
}

class _RecallPracticeScreenState extends State<RecallPracticeScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _lastMatch;
  String _feedbackMessage = '';
  bool _showRemaining = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final logic = di.get<RecallPracticeLogic>();
    final result = logic.tryMatch(_controller.text);
    setState(() {
      _lastMatch = result;
      _feedbackMessage = logic.lastMatchResult.value;
      _showRemaining = false;
    });
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _giveUp() {
    final logic = di.get<RecallPracticeLogic>();
    logic.finish();
  }

  @override
  Widget build(BuildContext context) {
    final logic = di.get<RecallPracticeLogic>();
    final remaining = watchValue((RecallPracticeLogic l) => l.remaining);
    final recalled = watchValue((RecallPracticeLogic l) => l.recalled);
    final total = watchValue((RecallPracticeLogic l) => l.totalCount);
    final isFinished = watchValue((RecallPracticeLogic l) => l.finished);

    final isDone = remaining.isEmpty;

    // Results screen (after give-up or all done)
    if (isFinished || isDone) {
      if (!isFinished && isDone) {
        // All recalled — auto-finish to save colors
        WidgetsBinding.instance.addPostFrameCallback((_) {
          logic.finish();
        });
      }
      return Scaffold(
        appBar: AppBar(
          title: Text('Results: ${recalled.length} / $total'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (isDone) ...[
                const Icon(Icons.emoji_events, size: 48, color: Colors.amber),
                const SizedBox(height: 8),
                const Text('All titles recalled!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ] else ...[
                Text('${recalled.length} recalled, ${remaining.length} missed',
                    style: const TextStyle(fontSize: 18)),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    if (recalled.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text('Recalled',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16)),
                      ),
                      ...recalled.map((title) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.check_circle,
                                color: Colors.green, size: 20),
                            title: Text(title),
                          )),
                    ],
                    if (remaining.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text('Missed — needs more work',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 16)),
                      ),
                      ...remaining.map((poem) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.cancel,
                                color: Colors.red, size: 20),
                            title: Text(poem.poemTitle()),
                          )),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to list'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }

    // Active practice screen
    return Scaffold(
      appBar: AppBar(
        title: Text('${recalled.length} / $total recalled'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Peek at remaining',
            onPressed: () {
              setState(() {
                _showRemaining = !_showRemaining;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.flag),
            tooltip: 'Give up & see results',
            onPressed: _giveUp,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input area
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: 'Type a title...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _submit,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Feedback
            if (_lastMatch != null)
              Card(
                color: Colors.green.shade50,
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(_lastMatch!),
                ),
              )
            else if (recalled.isEmpty && _feedbackMessage.isEmpty)
              const Text('Type the title of a poem you remember',
                  style: TextStyle(color: Colors.grey)),

            // No match / multiple candidates feedback
            if (_lastMatch == null && _feedbackMessage.isNotEmpty)
              Card(
                color: _feedbackMessage.contains('candidates')
                    ? Colors.orange.shade50
                    : Colors.red.shade50,
                child: ListTile(
                  leading: Icon(
                    _feedbackMessage.contains('candidates')
                        ? Icons.info_outline
                        : Icons.close,
                    color: _feedbackMessage.contains('candidates')
                        ? Colors.orange
                        : Colors.red,
                  ),
                  title: Text(_feedbackMessage),
                ),
              ),

            const SizedBox(height: 16),

            // Remaining titles (peek)
            if (_showRemaining) ...[
              const Divider(),
              Text('${remaining.length} remaining:',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: remaining.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.help_outline, size: 18),
                      title: Text(
                          scrambleText(
                            remaining[index].poemTitle(),
                            Scramblemethod.xForAll,
                          ),
                          style: const TextStyle(color: Colors.grey)),
                    );
                  },
                ),
              ),
            ],

            // Recalled titles
            if (!_showRemaining && recalled.isNotEmpty) ...[
              const Divider(),
              Text('${recalled.length} recalled:',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: recalled.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      leading:
                          const Icon(Icons.check, size: 18, color: Colors.green),
                      title: Text(recalled[index]),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
