import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EditorFaultyInputScreen extends StatelessWidget {
  static const routeName = '/editFaultyInputTextScreen';
  final contr = TextEditingController();

  EditorFaultyInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String poem = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
        appBar: AppBar(
          title: const Text('edit'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, poem),
            //Navigator.pop(context,ltf)
          ),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.check_circle),
                onPressed: () {
                  poem = contr.text.trimLeft();
                  //put the first line of contr.txt in all UpperCase

                  poem = contr.text.replaceFirstMapped(
                      RegExp(r'^.*$', multiLine: true), (Match match) {
                    if (kDebugMode) {
                      print("match0= ${match[0]!}");
                    }

                    return match[0]!.toUpperCase();
                  });

                  if (kDebugMode) {
                    print("in editor+ $poem");
                  }
                })
          ],
          automaticallyImplyLeading: true,
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
                decoration: const InputDecoration(
                    helperText: 'put a ******** above the title(s)'),
                controller: contr..text = poem,
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: null)));
  }
}
