import 'package:flutter/material.dart';
import 'package:rememberall2/poem_screen_logic.dart';
import 'package:watch_it/watch_it.dart';

class BlokkerScreen extends StatefulWidget with WatchItStatefulWidgetMixin {
  const BlokkerScreen({super.key});

  @override
  BlokkerScreenState createState() => BlokkerScreenState();
}

class BlokkerScreenState extends State<BlokkerScreen> {
  final blokkerchoicesConsonants = '|xXxX*#¤_¤•□■▄▬○●=^.∆ΘΞΠ°'.split('');
  final blokkerchoicesVowels = 'xX*#¤_¤•□■▄▬○●=^.∆ΘΞΠ°'.split('');
  String selectedConsonant = di.get<PoemScreenLogic>().blokker.value;
  String selectedVowel = di.get<PoemScreenLogic>().blokkerVowel.value;
  int selectedConsonantIndex = 0;
  int selectedVowelIndex = 0;

  @override
  Widget build(BuildContext context) {
    selectedConsonantIndex = blokkerchoicesConsonants
        .indexOf(di.get<PoemScreenLogic>().blokker.value);
    selectedVowelIndex = blokkerchoicesVowels
        .indexOf(di.get<PoemScreenLogic>().blokkerVowel.value);
    // var consonantHider = watchValue((PoemScreenLogic logic) => logic.blokker);
    // var vowelHider = watchValue((PoemScreenLogic logic) => logic.blokkerVowel);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick an option'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, {
                'consonant': di.get<PoemScreenLogic>().blokker.value,
                'vowel': di.get<PoemScreenLogic>().blokkerVowel.value,
              });
            },
          ),
        ],
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            isConsonant ? 'Consonants' : 'Vowels',
            style: const TextStyle(fontSize: 24),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: blokkerchoices.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                tileColor: isConsonant && index == selectedConsonantIndex ||
                        !isConsonant && index == selectedVowelIndex
                    ? Colors.blue
                    : null,
                title: Center(child: Text(blokkerchoices[index] * 11)),
                onTap: () {
                  setState(() {
                    if (isConsonant) {
                      selectedConsonantIndex = index;
                      di.get<PoemScreenLogic>().blokker.value =
                          blokkerchoices[index];
                    } else {
                      selectedVowelIndex = index;
                      di.get<PoemScreenLogic>().blokkerVowel.value =
                          blokkerchoices[index];
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
