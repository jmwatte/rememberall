import 'package:flutter/material.dart';

class SelectionScreen extends StatelessWidget {
  final blokkerchoices = 'xX*#¤_¤•□■▄▬○●=^.'.split('');

  SelectionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pick an option'),
        ),
        body: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: blokkerchoices.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  // color: Colors.amber[colorCodes[index]],
                  title: Center(child: Text(blokkerchoices[index] * 11)),
                  onTap: () {
                    Navigator.pop(context, blokkerchoices[index]);
                  });
            }));
  }
}
