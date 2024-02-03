import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rememberall2/poem_model.dart';
import 'package:rememberall2/poems_screen_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/watch_it.dart';

class PoemScreenLogic extends ChangeNotifier {
  final List<Color> cycleColors = [
    Colors.red,
    Colors.orange,
    Colors.green,
  ];
  final toggleStart = ValueNotifier<bool>(false);
  final counterStart = ValueNotifier<int>(0);
  final toggleEnd = ValueNotifier<bool>(false);
  final counterEnd = ValueNotifier<int>(0);
  final toggleVisibilityFirstLetter = ValueNotifier<bool>(false);
  final cycler = ValueNotifier<int>(0);
  final cycleColor = ValueNotifier<Color>(Colors.black);
  final blokker = ValueNotifier<String>('x');
  final blokkerVowel = ValueNotifier<String>('x');
  final poemId = ValueNotifier<int>(0);
  final scrambleMethod = ValueNotifier<Scramblemethod>(Scramblemethod.xForAll);
  bool _useSharedPrefs = false;
  bool get useSharedPrefs => _useSharedPrefs;
  set useSharedPrefs(bool value) {
    _useSharedPrefs = value;
    if (value) {
      initSharedPrefs();
    } else {
      usePoemsPrefs(di.get<PoemsScreenLogic>().selectedPoem.value);
    }
    notifyListeners();
  }

  final connectionStatus =
      ValueNotifier<ConnectivityResult>(ConnectivityResult.none);
  PoemScreenLogic() {
    _initConnectivity();
    Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);

    if (di.get<PoemsScreenLogic>().useSharedPrefs.value) {
      initSharedPrefs();
    } else {
      usePoemsPrefs(di.get<PoemsScreenLogic>().selectedPoem.value);
    }
  }
  Future<void> _initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    try {
      result = await (Connectivity().checkConnectivity());
    } catch (e) {
      if (kDebugMode) {
        print("in _initConnectivity() Error: $e");
      }
    }
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    connectionStatus.value = result;
  }

  void initSharedPrefs() {
    var prefs = SharedPreferences.getInstance();
    prefs.then((value) {
      toggleStart.value = value.getBool('toggleStart') ?? false;
      toggleEnd.value = value.getBool('toggleEnd') ?? false;
      toggleVisibilityFirstLetter.value =
          value.getBool('toggleVisibilityFirstLetter') ?? false;
      counterStart.value = value.getInt('counterStart') ?? 0;
      counterEnd.value = value.getInt('counterEnd') ?? 0;
      blokker.value = value.getString('blokker') ?? 'x';
      blokkerVowel.value = value.getString('blokkerVowel') ?? 'x';
      cycleColor.value = cycleColors[value.getInt('scrambleMethod') ?? 0];
      scrambleMethod.value =
          Scramblemethod.values[value.getInt('scrambleMethod') ?? 0];
    });
  }

  void saveSharedPrefs() {
    var prefs = SharedPreferences.getInstance();
    prefs.then((value) {
      value.setBool('toggleStart', toggleStart.value);
      value.setBool('toggleEnd', toggleEnd.value);
      value.setBool(
          'toggleVisibilityFirstLetter', toggleVisibilityFirstLetter.value);
      value.setInt('counterStart', counterStart.value);
      value.setInt('counterEnd', counterEnd.value);
      value.setString('blokker', blokker.value);
      value.setString('blokkerVowel', blokkerVowel.value);
      value.setInt('scrambleMethod', scrambleMethod.value.index);
    });
    if (useSharedPrefs) {
      // initSharedPrefs();
    }
  }

  void savePoemsPrefs() {
    var prefs = di.get<PoemsScreenLogic>().selectedPoem.value;
    prefs = prefs.copyWith(
      seeStart: toggleStart.value,
      seeEnd: toggleEnd.value,
      extraVisibleLetters: toggleVisibilityFirstLetter.value ? 0 : 1,
      extraVisibleWordsStart: counterStart.value,
      extraVisibleWordsEnd: counterEnd.value,
      scramble: scrambleMethod.value,
      blokker: blokker.value,
      blokkerVowel: blokkerVowel.value,
    );
  }

  void usePoemsPrefs(Poem value) {
    toggleStart.value = value.seeStart;
    toggleEnd.value = value.seeEnd;
    toggleVisibilityFirstLetter.value = value.extraVisibleLetters > 0;
    counterStart.value = value.extraVisibleWordsStart;
    counterEnd.value = value.extraVisibleWordsEnd;
    // cycler.value = value.levelnr;
    cycleColor.value = cycleColors[value.scramble.index];
    blokker.value = value.blokker;
    blokkerVowel.value = value.blokkerVowel;
    scrambleMethod.value = value.scramble;
  }

  var regExpForAll = RegExp('[a-zA-Z0-9]');
  var regExpForConsonants =
      RegExp('[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]'); //'^.'

  var regExpForXesForVowels = RegExp('[aeiuo]');
  //scramblemethod scramble = scramblemethod.xForAll;
  var scrambler = RegExp('[a-zA-Z0-9]');
  String title() {
    return di.get<PoemsScreenLogic>().selectedPoem.value.theText.split('\n')[0];
  }

  String poemText() {
    return di
        .get<PoemsScreenLogic>()
        .selectedPoem
        .value
        .theText
        .split('\n')
        .sublist(1)
        .join('\n');
  }

  String transformed() {
    switch (scrambleMethod.value) {
      case Scramblemethod.xForAll:
        scrambler = regExpForAll;
        break;
      case Scramblemethod.xForConsonants:
        scrambler = regExpForConsonants;
        break;
      case Scramblemethod.xForVowels:
        scrambler = regExpForXesForVowels;
        break;
      default:
        scrambler = regExpForAll;
    }
    var theLines = poemText().split('\n');
    var res = '';
    for (var y = 0; y < theLines.length; y++) {
      var theWords = theLines[y].split(' ');
      for (var i = 0; i < theWords.length; i++) {
        if (i < 0 + counterStart.value && toggleStart.value == true ||
            i > theWords.length - counterEnd.value - 1 &&
                toggleEnd.value == true) {
          res = '$res${theWords[i]} ';
        } else {
          res =
              '$res${theWords[i].substring(0, min(toggleVisibilityFirstLetter.value ? 0 : 1, theWords[i].length))}${theWords[i].substring(min(toggleVisibilityFirstLetter.value ? 0 : 1, theWords[i].length)).replaceAllMapped(scrambler, (match) {
            if ('aeiouAEIOU'.contains(match[0]!)) {
              return blokkerVowel.value;
            } else {
              return blokker.value;
            }
          })} ';

          //  res =
          //     '$res${theWords[i].substring(0, min(toggleVisibilityFirstLetter.value ? 0 : 1, theWords[i].length))}${theWords[i].substring(min(toggleVisibilityFirstLetter.value ? 0 : 1, theWords[i].length)).replaceAll(scrambler, blokker.value)} ';
          // ' ';
        }
      }
      res = '$res\n';
    }
    return (res);
  }

  void pickTheScrambleMethod() {
    cycler.value++;
    if (cycler.value > 2) {
      cycler.value = 0;
    }
    switch (cycler.value) {
      case 0:
        scrambleMethod.value = Scramblemethod.xForAll;

        cycleColor.value = cycleColors[cycler.value];
        break;
      case 1:
        scrambleMethod.value = Scramblemethod.xForConsonants;
        cycleColor.value = cycleColors[cycler.value];

        break;
      case 2:
        scrambleMethod.value = Scramblemethod.xForVowels;
        cycleColor.value = cycleColors[cycler.value];
        break;
      default:
        scrambleMethod.value = Scramblemethod.xForAll;
        cycleColor.value = cycleColors[0];
    }
  }
}
  // SongScreenLogic() {
  //   updateConnectivityStatus();
  // }

  // void updateConnectivityStatus() {
  //   Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
  //     connectionStatus.value = result;
  //   });
  // }

