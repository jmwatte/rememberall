import 'package:flutter/foundation.dart';
import 'package:rememberall2/poem_model.dart';

List<Poem> getPoemsFromString(String poemsString, bool favourite) {
  var result = <Poem>[];
  var catchPoem = RegExp(
      r'''^[^\s][^.][^a-z\n]*\n+((\n|.)*?)(?=(^[^\s][^.][^a-z\n]*\n+))''',
      multiLine: true);
  poemsString += '\nXXXXXXXXXXXX\n';

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
