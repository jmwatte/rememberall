import 'dart:math';
import 'poem_model.dart';

final _regExpForAll = RegExp('[a-zA-Z0-9]');
final _regExpForConsonants =
    RegExp('[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]');
final _regExpForVowels = RegExp('[aeiuo]');

/// Scramble a single line of text using the given method and blocker characters.
/// If [hideFirstLetter] is true, the first letter of each word is also hidden.
String scrambleText(
  String text,
  Scramblemethod method, {
  String blokker = 'x',
  String blokkerVowel = '|',
  bool hideFirstLetter = false,
}) {
  RegExp scrambler;
  switch (method) {
    case Scramblemethod.xForAll:
      scrambler = _regExpForAll;
      break;
    case Scramblemethod.xForConsonants:
      scrambler = _regExpForConsonants;
      break;
    case Scramblemethod.xForVowels:
      scrambler = _regExpForVowels;
      break;
  }

  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    int keep = hideFirstLetter ? 0 : 1;
    int idx = min(keep, word.length);
    String visible = word.substring(0, idx);
    String hidden = word.substring(idx).replaceAllMapped(scrambler, (match) {
      if ('aeiouAEIOU'.contains(match[0]!)) {
        return blokkerVowel;
      } else {
        return blokker;
      }
    });
    return '$visible$hidden';
  }).join(' ');
}
