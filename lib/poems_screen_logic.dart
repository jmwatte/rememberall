import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rememberall2/databasehelper.dart';
import 'package:rememberall2/helpers.dart';
import 'package:rememberall2/poem_model.dart';
import 'package:rememberall2/main.dart';
import 'package:rememberall2/saver_screen.dart';
import 'package:rememberall2/poems_collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PoemsScreenLogic {
  //List<String> categoryNames = ['all'];
  //Map<String, Widget> categoryWidgets = {};

//endtest
  final useSharedPrefs = ValueNotifier<bool>(false);
  final poemscache = ValueNotifier<List<Poem>>([]);
  final numOfFav = ValueNotifier<int>(0);
  final categories = ValueNotifier<List<String>>([]);
  final selectedCategory = ValueNotifier<String>('all');
  final appBarTitle = ValueNotifier<String>("Songlist"); // Add this line
  final whatWeGot = ValueNotifier<String>('No poems yet');
  final whatWeGotAlso = ValueNotifier<String>('Select a category');
  // final songpieces = ValueNotifier<List<LyricsTransformer>>([]);
  final selectedCategoryPoems = ValueNotifier<List<Poem>>([]);

  List<Poem> firstRunPoemsPieces = [];
  //List<LyricsTransformer> songsfromdatabase = [];
  // late int count;
  List<Widget> favoritesList = [];
  List<Widget> normalList = [];
  List<String> titelList = [];
  TextEditingController searchController = TextEditingController();
  DatabaseHelper databaseHelper = DatabaseHelper();
  final selectedPoem = ValueNotifier<Poem>(Poem());

  PoemsScreenLogic() {
    SharedPreferences.getInstance().then((prefs) {
      useSharedPrefs.value = prefs.getBool('useSharedPrefs') ?? false;
    });
  }
  void categoryHasChangedTo(String category) async {
    final stopwatch = Stopwatch()..start();

    await getPoemsFromCategory(category);
    setPoemsCache();
    selectedCategory.value = category;

    if (kDebugMode) {
      print('categoryHasChangedTo() executed in ${stopwatch.elapsed}');
    }
  }

  Future<void> getPoemsFromCategory(category) async {
    if (category == 'all') {
      List<Poem> poems = await databaseHelper.getPoemsfromDB();
      selectedCategoryPoems.value = List.from(poems);
    } else {
      List<Poem> poemsByCategory =
          await databaseHelper.getPoemsByCategory(category);
      selectedCategoryPoems.value = List.from(poemsByCategory);
    }
    //setPoemsCache();
  }

  void loadPoems() async {
    if (kDebugMode) {
      print('loadPoems() started');
    }
    final stopwatch = Stopwatch()..start();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      if (kDebugMode) {
        print("loadPoems()IsFirstRum = $isFirstRun started");
      }
      firstRunPoemsPieces.addAll(getPoemsFromString(poems, false));

      await databaseHelper.initializeDatabase();
      for (var poem in firstRunPoemsPieces) {
        whatWeGot.value = poem.poemTitle();
        whatWeGotAlso.value = poem.poemTitle();

        await databaseHelper.insertPoem(poem);
      }
      await prefs.setBool('isFirstRun', false);
      if (isDebugMode) {
        if (kDebugMode) {
          print('loadPoems() executed in ${stopwatch.elapsed}');
        }
      }
      if (isDebugMode) {
        if (kDebugMode) {
          print('loadPoems() finished first run');
        }
      }
      //updateListView();
      //categoryHasChangedTo('all');
    }
    if (isDebugMode) {
      if (kDebugMode) {
        print('loadPoems() finished no first run');
      }
    } //on first run populate the database

    updateListView();
    categoryHasChangedTo('all');
  }

  void updateListView() async {
    if (isDebugMode) {
      if (kDebugMode) {
        print('updateListView() started');
      }
    } // final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    final stopwatch = Stopwatch()..start();
    //var databasePoemsResult = await databaseHelper.getPoemsfromDB();
    var allCategories = await databaseHelper.getDistinctCategories();
    // count = databaseLyricsResult.length;
    allCategories.insert(0, 'all');
    categories.value = allCategories; // Ensure 'all' is the first category
    //selectedCategoryPoems.value = List.from(databasePoemsResult);
    // var categoryPoems = selectedCategory.value == 'all'
    //     ? databasePoemsResult
    //     : databasePoemsResult
    //         .where((poem) => poem.category == selectedCategory.value)
    //         .toList();
    // selectedCategoryPoems.value = categoryPoems;
    if (isDebugMode) {
      if (kDebugMode) {
        print('updateListView() executed in ${stopwatch.elapsed}');
      }
    }

    //setPoemsCache();
  }

  void changeFavoriteStatus() {
    selectedPoem.value =
        selectedPoem.value.copyWith(favourite: !selectedPoem.value.favourite);
//save it to database
  }

  final saver = Saver();
  void exportAllToTxtFile() async {
    var archive = await databaseHelper.getPoemsfromDB();
    var archiveInTextFormat = archive.map((e) => e.theText.trim()).join('\n\n');
    saver.save('test.txt', archiveInTextFormat);
  }

  String normalizeLineEndings(String text) {
    return text.replaceAll('\r\n', '\n');
  }

  void openImporter() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      allowMultiple: true,
    );

    if (result != null) {
      List<PlatformFile> files = result.files;

      for (var file in files) {
        if (file.path != null) {
          var fileContent = await File(file.path!).readAsString();
          fileContent = normalizeLineEndings(fileContent);
          var poemsToImport = getPoemsFromString(fileContent, true);

          if (kDebugMode) {
            for (var poem in poemsToImport) {
              print("in openImporter()");
              print(poem.theText);
            }
          }

          if (poemsToImport.isNotEmpty) {
            for (var poem in poemsToImport) {
              // Save the song to the database.
              await databaseHelper.insertPoem(poem);
            }
          }
        }
      }
      updateListView();
      categoryHasChangedTo('all');
    }
  }

  void toArchive() {}

  void addNewPoem(String poem) {
    if (poem.toString().isNotEmpty) {
      databaseHelper.insertPoem(Poem()..theText = poem);
      updateListView();
      categoryHasChangedTo(selectedCategory.value);
      //selectedCategoryPoems.value.add(Poem()..theText = poem);
      //save the result to the database
      // filterList();
    }
  }

  void resetToFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', true);
  }

  void onRenameCategory(String oldName, String newName) {
    int index = categories.value.indexOf(oldName);
    if (index != -1) {
      List<String> newCategories = List.from(categories.value);
      newCategories[index] = newName;
      categories.value = newCategories;
    }
    databaseHelper.renameCategory(oldName, newName);
    updateListView();
    categoryHasChangedTo(selectedCategory.value);
  }

  void onDeleteCategory(String name) {
    int index = categories.value.indexOf(name);

    if (index != -1) {
      List<String> newCategories = List.from(categories.value);
      newCategories.removeAt(index);
      categories.value = newCategories;
    }
    databaseHelper.removeCategoryFromDataBase(name);
    updateListView();
    categoryHasChangedTo(selectedCategory.value);
  }

  void onPoemCategoryChanged(Poem poem) {
    databaseHelper.updatePoem(poem);
    updateListView();
    categoryHasChangedTo(selectedCategory.value);
  }

  void updatePoem(Poem poem) async {
    await databaseHelper.updatePoem(poem);
    updateListView();
    categoryHasChangedTo(selectedCategory.value);
  }

  void onDeletePoem(Poem poem) async {
    await databaseHelper.deletePoemByID(poem.id!);
    updateListView();
    categoryHasChangedTo(selectedCategory.value);
  }

  void sortOriginalItems() {
    if (kDebugMode) {
      print('sortOriginalItems() started');
    }
    final stopwatch = Stopwatch()..start();
    // selectedCategorySongs.value.sort((a, b) =>
    //     removeDiacritics(a.title().toUpperCase())
    //         .compareTo(removeDiacritics(b.title().toUpperCase())));
    if (isDebugMode) {
      if (kDebugMode) {
        print(
            'sortOriginalItemsinscreenLogic() executed in ${stopwatch.elapsed}');
      }
    }
  }

  void setPoemsCache() {
    if (kDebugMode) {
      print('setPoemsCache() started');
    }

    final stopwatch = Stopwatch()..start();
    selectedCategoryPoems.value
        .sort((a, b) => a.poemTitle().compareTo(b.poemTitle()));

// Partition items into favorites and non-favorites
    var fav = <Poem>[];
    var notfav = <Poem>[];
    for (var poem in selectedCategoryPoems.value) {
      if (poem.favourite) {
        fav.add(poem);
      } else {
        notfav.add(poem);
      }
    }

    numOfFav.value = fav.length;
    var orderedList = fav.followedBy(notfav).toList();
    poemscache.value = orderedList;
    if (isDebugMode) {
      if (kDebugMode) {
        print('setPoemsCache() executed in ${stopwatch.elapsed}');
      }
    }
  }

  void onLevelChanged(Poem poem) {
    selectedCategoryPoems.value
        .firstWhere((element) => element.id == poem.id)
        .levelnr = poem.levelnr;

    databaseHelper.updatePoem(poem);
    updateListView();
  }

  void onStarItemClicked(Poem poem) {
    if (isDebugMode) {
      if (kDebugMode) {
        print('onStarItemClickedbefore() ${poem.favourite}');
      }
    }
    poem.favourite = !poem.favourite;
    selectedCategoryPoems.value
        .firstWhere((element) => element.id == poem.id)
        .favourite = poem.favourite;
    databaseHelper.updatePoem(poem);
    if (isDebugMode) {
      if (kDebugMode) {
        print('onStarItemClickedAfter() ${poem.favourite}');
      }
    }
    selectedCategoryPoems.value = List.from(selectedCategoryPoems.value);
  }
}

class CategoriesNotifier extends ValueNotifier<List<String>> {
  CategoriesNotifier() : super([]);
}
