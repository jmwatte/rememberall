import 'package:flutter/material.dart';
import 'package:rememberall2/poem_screen_logic.dart';
import 'package:watch_it/watch_it.dart';

class BlokkerScreen extends StatefulWidget {
  const BlokkerScreen({Key? key}) : super(key: key);

  @override
  BlokkerScreenState createState() => BlokkerScreenState();
}

class BlokkerScreenState extends State<BlokkerScreen> {
  final blokkerchoicesConsonants = '|xXxX*#¤_¤•□■▄▬○●=^.∆ΘΞΠ°'.split('');
  final blokkerchoicesVowels = 'xX*#¤_¤•□■▄▬○●=^.∆ΘΞΠ°'.split('');
  int selectedConsonantIndex = 0;
  int selectedVowelIndex = 0;
  String selectedConsonant = di.get<PoemScreenLogic>().blokker.value;
  String selectedVowel = di.get<PoemScreenLogic>().blokkerVowel.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick an option'),
      ),
      body: PageView(
        children: <Widget>[
          buildPage(blokkerchoicesConsonants, context, true),
          buildPage(blokkerchoicesVowels, context, false),
        ],
      ),
    );
  }

  Widget buildPage(
      List<String> blokkerchoices, BuildContext context, bool isConsonant) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: blokkerchoices.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          tileColor:
              isConsonant && blokkerchoices[index] == selectedConsonant ||
                      !isConsonant && blokkerchoices[index] == selectedVowel
                  ? Colors.blue
                  : null,
          title: Center(child: Text(blokkerchoices[index] * 11)),
          onTap: () {
            setState(() {
              if (isConsonant) {
                selectedConsonantIndex = index;
              } else {
                selectedVowelIndex = index;
              }
            });
            Navigator.pop(context, {
              'consonant': blokkerchoicesConsonants[selectedConsonantIndex],
              'vowel': blokkerchoicesVowels[selectedVowelIndex],
            });
          },
        );
      },
    );
  }
}
