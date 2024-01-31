import 'package:flutter/foundation.dart';
import 'package:rememberall2/poem_model.dart';

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
