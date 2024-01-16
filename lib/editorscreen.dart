import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'lyricschanger_base.dart';

class EditorScreen extends StatelessWidget {
  static const routeName = '/editorscreen';
  final contr = TextEditingController();

  EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LyricsTransformer ltf =
        ModalRoute.of(context)!.settings.arguments as LyricsTransformer;
    return Scaffold(
        appBar: AppBar(
          title: const Text('edit'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, ltf.input),
            //Navigator.pop(context,ltf)
          ),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.check_circle),
                onPressed: () {
                  ltf.input = contr.text;
                  if (kDebugMode) {
                    print(ltf.input);
                  }
                })
          ],
          automaticallyImplyLeading: true,
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
                decoration: const InputDecoration(
                    helperText: 'title in ALLCAPS. Not in lyrics at the start'),
                controller: contr..text = ltf.input,
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: null)));
  }
}
