import 'dart:core';
import 'dart:math';
import 'package:flutter/material.dart';

class Constants {
  static const String add = 'Add';
  static const String blokker = 'Blokker';
  static const String prefs = 'Prefs';
  static const List<String> choices = <String>[
    blokker,
    font,
    edit,
    delete,
    add,
    prefs
  ];
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String font = 'Font';
  static const Color geel = Colors.yellow;
  static const Color groen = Colors.green;
  static const Color lichtgroen = Colors.lightGreen;
  static const Color orange = Colors.orange;
  static const Color rood = Colors.red;
  static final List<Color> levelkleur = <Color>[
    Colors.green,
    Colors.lightGreen,
    Colors.yellow,
    Colors.orange,
    Colors.red
    // groen,
    // lichtgroen,
    //geel,
    //orange,
    //rood
  ];
  static const List<String> listChoices = <String>[
    openTxtForNewPoem,
    aNewPoem,
    exportAllToTxtFile,
    toArchive,
    reset,
    category,
    usePrefs,
  ];
  static const String aNewPoem = 'New';
  static const String openTxtForNewPoem = 'Import';
  static const String exportAllToTxtFile = 'ExportAll';
  static const String toArchive = 'Archiveren';
  static const String reset = 'Reset';
  static const String category = 'Category';
  static const String usePrefs = 'UsePrefs';
}

//import 'dart:async'show Future;
//import 'package:flutter/services.dart'show rootBundle;
class CutUpPoemSheet {
//Future<List> loadSongs() async{
//return await rootBundle.loadString('assets/songsheets.txt').then((value) => value.split(catchSong));
//}
//List<String> getsongs(){
  // List<String> songlist;
//var songs=loadSongs();
//songs.then((value) =>songlist= value.split(catchSong));
//return songlist;
}

var catchPoem = RegExp(
    r'''^[^\s][^.][^a-z\n]*\n+((\n|.)*?)(?=^[^\s][^.][^a-z\n]*\n+)''',
    multiLine: true);

/* RegExp catchSong = RegExp(
    r'''(?<=(\n\s*\n\s*))^[A-Z0-9(][^a-z]{2}.+((?:\n|.)*?)(?=($(?![\r\n]))|(\n\s*\n\s*)[A-Z0-9(][^a-z]{2}(.|\n+))''',
    multiLine: true);
 */ //RegExp catchSong=RegExp( r'^[a-z]+[a-z\s][a-z\s]+[\s\s]+?(?=^[a-z]+[a-z\s][a-z\s])',multiLine: true);
enum Linetransform { first, last }

enum Scramblemethod {
  xForAll,
  xForVowels,
  xForConsonants,
}

class Poem {
  int? id;
  String theText = "";
  int levelnr = 1;
  bool favourite = false;
  int extraVisibleLetters = 1;
  int extraVisibleWordsStart = 1;
  int extraVisibleWordsEnd = 1;
  Scramblemethod scramble =
      Scramblemethod.xForAll; // Assuming Scramble is an enum
  bool seeEnd = false;
  bool seeStart = false;
  String blokker = 'x';
  String category = '';

  // Constructor
  Poem({
    this.id,
    this.theText = "",
    this.levelnr = 1,
    this.favourite = false,
    this.extraVisibleLetters = 1,
    this.extraVisibleWordsStart = 1,
    this.extraVisibleWordsEnd = 1,
    this.scramble = Scramblemethod.xForAll,
    this.seeEnd = false,
    this.seeStart = false,
    this.blokker = 'x',
    this.category = '',
  });

//a method copywith that takesa LyriscTransFormer and a field and a value and returns a new LyricsTransformer with the field set to the value
  Poem copyWith({
    int? id,
    String? input,
    int? levelnr,
    bool? favourite,
    int? extraVisibleLetters,
    int? extraVisibleWordsStart,
    int? extraVisibleWordsEnd,
    Scramblemethod? scramble,
    bool? seeEnd,
    bool? seeStart,
    String? category,
    String? blokker,
  }) {
    return Poem(
      id: id ?? this.id,
      theText: input ?? this.theText,
      levelnr: levelnr ?? this.levelnr,
      favourite: favourite ?? this.favourite,
      extraVisibleLetters: extraVisibleLetters ?? this.extraVisibleLetters,
      extraVisibleWordsStart:
          extraVisibleWordsStart ?? this.extraVisibleWordsStart,
      extraVisibleWordsEnd: extraVisibleWordsEnd ?? this.extraVisibleWordsEnd,
      scramble: scramble ?? this.scramble,
      seeEnd: seeEnd ?? this.seeEnd,
      seeStart: seeStart ?? this.seeStart,
      category: category ?? this.category,
      blokker: blokker ?? this.blokker,
    );
  }

// Convert a Poem object into a Map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['input'] = theText;
    map['levelnr'] = levelnr;
    map['fav'] = favourite ? 1 : 0;
    map['extraletters'] = extraVisibleLetters;
    map['extrawordsStart'] = extraVisibleWordsStart;
    map['extrawordsEnd'] = extraVisibleWordsEnd;
    map['scramble'] = scramble.index;
    map['seeend'] = seeEnd ? 1 : 0;
    map['seestart'] = seeStart ? 1 : 0;
    map['category'] = category;
    map['blokker'] = blokker;
    return map;
  }

  // Extract a poem object from a Map object
  Poem.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    theText = map['input'];
    favourite = map['fav'] == 1 ? true : false;
    levelnr = map['levelnr'];
    extraVisibleLetters = map['extraletters'];
    extraVisibleWordsStart = map['extrawordsStart'];
    extraVisibleWordsEnd = map['extrawordsEnd'];
    scramble = Scramblemethod.values[map['scramble']];
    seeEnd = map['seeend'] == 1 ? true : false;
    seeStart = map['seestart'] == 1 ? true : false;
    category = map['category'] ?? '';
    blokker = map['blokker'] ?? 'x';
  }
  //String blokker = '▒'; // '█'▒;
  //int extraVisibleLetters = 0;
  //nt extraVisibleWords = 0;
  //bool favourite = false;
  //String input;
  //int id;
  late int key;
  //int levelnr;
  Color level() {
    return Constants.levelkleur[levelnr];
  }

  var regExpForAll = RegExp('[a-zA-Z0-9]');
  var regExpForConsonants =
      RegExp('[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]'); //'^.'

  var regExpForXesForVowels = RegExp('[aeiuo]');
  //scramblemethod scramble = scramblemethod.xForAll;
  var scrambler = RegExp('[a-zA-Z0-9]');
  //bool seeEnd = false;
  //bool seeStart = false;
  String poemTitle() {
    return theText.split('\n')[0];
  }

  String poemText() {
    return theText.split('\n').sublist(1).join('\n');
  }

  //linetransform changeline;

  String transformed() {
    switch (scramble) {
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
        if (i < 0 + extraVisibleWordsStart && seeStart == true ||
            i > theWords.length - extraVisibleWordsEnd - 1 && seeEnd == true) {
          res = '$res${theWords[i]} ';
        } else {
          res =
              '$res${theWords[i].substring(0, min(extraVisibleLetters, theWords[i].length))}${theWords[i].substring(min(extraVisibleLetters, theWords[i].length)).replaceAll(scrambler, blokker)} ';
          // ' ';
        }
      }
      res = '$res\n';
    }
    return (res);
  }
}

String testPoem =
    '''ACCENTUATE THE POSITIVE
You’ve got to accentuate the positive,
eliminate the negative.
Latch on to the affirmative,
don’t mess with Mr. In Between.
You’ve got to spread joy up to the maximum,
bring gloom down to the minimum.
Have faith or pandemonium
liable to walk upon the scene.
	To illustrate my last remark,
	Jonah in the whale, Noah in the ark
	What did they do,
	after everything looked so dark, looked so dark, Man, they said:
You’ve got to accentuate the positive,
eliminate the negative.
Latch on to the affirmative,
don’t mess with Mr. In Between, no,
Don’t mess with Mr. In Between, no, don’t mess with Mr. In Between.''';
