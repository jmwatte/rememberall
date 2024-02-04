import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rememberall2/poem_model.dart';
import 'package:rememberall2/poems_screen.dart';
import 'package:rememberall2/poems_screen_logic.dart';
import 'package:watch_it/watch_it.dart';

List<Poem> getPoemsFromString(String poemsString, bool favourite) {
  var result = <Poem>[];
  var catchPoem =
      RegExp(r'(?<=^\*+\n)(.*?)(?=\n^\*+)', multiLine: true, dotAll: true);
  // var catchPoem = RegExp(
  //     r'''^[^\s][^.][^a-z\n]*\n+((\n|.)*?)(?=(^[^\s][^.][^a-z\n]*\n+))''',
  //     multiLine: true);
  poemsString += '\n********\n';

  result = catchPoem.allMatches(poemsString).map((e) {
    var poem = Poem()..favourite = favourite;
    poem.theText =
        e.group(0)!; // Note the change here from group(0) to group(1)
    return poem;
  }).toList();
  return result;
}

class CategoryPoemsProvider extends ChangeNotifier {
  List<Poem> _categoryPoems = [];
  List<Poem> _databasePoemsResult = [];

  List<Poem> get databasePoemsResult => _databasePoemsResult;
  List<Poem> get categoryPoems => _categoryPoems;

  void updateDatabasePoemsResult(List<Poem> newDatabasePoemsResult) {
    _databasePoemsResult = newDatabasePoemsResult;
    notifyListeners();
  }

  void updateCategoryPoems(List<Poem> newPoems) {
    _categoryPoems = newPoems;
    notifyListeners();
  }
}

class FirstRunScreen extends StatelessWidget {
  const FirstRunScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double displayStringShort(String displayString) {
      var displayStringShort =
          displayString.substring(0, min(displayString.length, 40));
      return 300.0 - (displayStringShort.length * 2.0);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Database'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FittedBox(
            fit: BoxFit.fill,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              onPressed: () {
                // Execute logic to fill the database
                di<PoemsScreenLogic>().fillDatabase.value = true;
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const MyPoems()));
              },
              child: Text(
                textAlign: TextAlign.center,
                'Fill\n Database',
                style: TextStyle(
                  fontSize: displayStringShort('Fill the Database') == 0
                      ? 1
                      : displayStringShort('Fill the Database'),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FittedBox(
            fit: BoxFit.fill,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              onPressed: () {
                // Execute logic for a clean database
                di<PoemsScreenLogic>().fillDatabase.value = false;
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const MyPoems()));

                // Navigate to next screen or perform desired action
              },
              child: Text(
                textAlign: TextAlign.center,
                'Empty\n Database',
                style: TextStyle(
                  fontSize: displayStringShort('Clean Database') == 0
                      ? 1
                      : displayStringShort('Clean Database'),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
