import 'package:flutter/material.dart';

class BlokkerScreen extends StatelessWidget {
  final blokkerchoicesConsonants = 'xX*#¤_¤•□■▄▬○●=^.'.split('');
  final blokkerchoicesVowels = '|'.split('');

  BlokkerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick an option'),
      ),
      body: PageView(
        children: <Widget>[
          buildPage(blokkerchoicesConsonants, context),
          buildPage(blokkerchoicesVowels, context),
        ],
      ),
    );
  }

  Widget buildPage(List<String> blokkerchoices, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: blokkerchoices.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Center(child: Text(blokkerchoices[index] * 11)),
          onTap: () {
            Navigator.pop(context, {
              'consonant': blokkerchoicesConsonants[index],
              'vowel': blokkerchoicesVowels[index],
            });
          },
        );
      },
    );
  }
}
