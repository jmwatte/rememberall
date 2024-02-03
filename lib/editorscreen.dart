import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'poem_model.dart';

class EditorScreen extends StatelessWidget {
  static const routeName = '/editorscreen';
  final contr = TextEditingController();

  EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Poem poem = ModalRoute.of(context)!.settings.arguments as Poem;
    return Scaffold(
        appBar: AppBar(
          title: const Text('edit'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, poem.theText),
            //Navigator.pop(context,ltf)
          ),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.check_circle),
                onPressed: () {
                  poem.theText = contr.text;
                  if (kDebugMode) {
                    print("in editor)+ ${poem.theText}");
                  }
                })
          ],
          automaticallyImplyLeading: true,
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
                decoration: const InputDecoration(
                    helperText:
                        'title in ALLCAPS. Not in poem at the firstline'),
                controller: contr..text = poem.theText,
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: null)));
  }
}
