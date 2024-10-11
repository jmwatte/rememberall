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
import 'package:flutter/services.dart' show rootBundle;

class PoemsScreenLogic {
  //List<String> categoryNames = ['all'];
  //Map<String, Widget> categoryWidgets = {};

//endtest
  final fillDatabase = ValueNotifier<bool>(false);

  final useSharedPrefs = ValueNotifier<bool>(false);
  final isFirstRun = ValueNotifier<bool>(true);
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
      useSharedPrefs.value = prefs.getBool('usePrefs') ?? false;
      isFirstRun.value = prefs.getBool('isFirstRun') ?? true;
      selectedCategory.value = prefs.getString('selectedCategory') ?? 'all';
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

  Future<String> loadPoemsFromAssets() async {
    return await rootBundle.loadString('assets/poems.txt');
  }

  void loadPoems() async {
    if (kDebugMode) {
      print('loadPoems() started');
    }
    final stopwatch = Stopwatch()..start();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun.value) {
      if (kDebugMode) {
        print("loadPoems()IsFirstRum = $isFirstRun started");
      }
      await databaseHelper.initializeDatabase();
      if (fillDatabase.value == true) {
        poems = await loadPoemsFromAssets();

        firstRunPoemsPieces.addAll(getPoemsFromString(poems, false));
        for (var poem in firstRunPoemsPieces) {
          whatWeGot.value = poem.poemTitle();
          whatWeGotAlso.value = poem.poemTitle();
          await databaseHelper.insertPoem(poem);
        }
      }
      SharedPreferences.getInstance()
          .then((prefs) => prefs.setBool('isFirstRun', false));
      // await prefs.setBool('isFirstRun', false);
      if (isDebugMode) {
        if (kDebugMode) {
          print('loadPoems() executed in ${stopwatch.elapsed}');
        }
      }
      if (isDebugMode) {
        if (kDebugMode) {
          print('loadPoems() finished first run IsFirstRum = $isFirstRun');
        }
      }
      updateListView();
      categoryHasChangedTo('all');
    }
    // if (isDebugMode) {
    //  if (kDebugMode) {
    //   print('loadPoems() finished no first run IsFirstRun = $isFirstRun');
    // }
    //} //on first run populate the database
    else {
      updateListView();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString('selectedCategory') != null) {
        categoryHasChangedTo(prefs.getString('selectedCategory')!);
      } else {
        categoryHasChangedTo('all');
      }
    }
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
  void exportAllToTxtFile(String fileName) async {
    var archive = await databaseHelper.getPoemsfromDB();
    var archiveInTextFormat = archive
        .map((e) => "****************\n${e.theText.trim()}")
        .join('\n\n');
    saver.save(fileName, archiveInTextFormat);
  }

  String normalizeLineEndings(String text) {
    return text
        .replaceAll(RegExp(r'[^\x00-\x7F]+'), '')
        .replaceAll('\r\n', '\n');
  }

  Future<String> openImporter() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      allowMultiple: true,
    );

    var poemsToImport = [];
    var fileContent = '';
    var noGoodFiles = '';
    if (result != null) {
      List<PlatformFile> files = result.files;
      for (var file in files) {
        if (file.path != null) {
          fileContent = await File(file.path!).readAsString();
          fileContent = normalizeLineEndings(fileContent);
          var poems = getPoemsFromString(fileContent, true);
          if (poems.isNotEmpty) {
            for (var poem in poems) {
              poemsToImport.add(poem);
            }
          } else {
            noGoodFiles += '$fileContent\n\n';
          }
        }
      }
    }

    if (poemsToImport.isNotEmpty) {
      for (var poem in poemsToImport) {
        // Save the song to the database.
        await databaseHelper.insertPoem(poem);
        updateListView();
        categoryHasChangedTo('all');
      }
    }
    if (kDebugMode) {
      for (var poem in poemsToImport) {
        print("in openImporter()");
        print(poem.theText);
      }
    }
    if (noGoodFiles.isNotEmpty) {
      return noGoodFiles;
    }

    return "";
  }

  void addNewPoem(String poem) {
    if (poem.toString().isNotEmpty) {
      //change thefirst line to allcaps

      databaseHelper.insertPoem(Poem()
        ..theText = poem
        ..favourite = true);
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

  void sortByColor(int a) {
    // Check if there are any poems with the specified color
    bool hasColorA =
        selectedCategoryPoems.value.any((poem) => poem.levelnr == a);
    if (!hasColorA) return; // If no poems have color a, do not sort

    // Sort poems by color and then by favorite status
    selectedCategoryPoems.value.sort((Poem x, Poem y) {
      // First sort by color 'a'
      if (x.levelnr == a && y.levelnr != a) {
        return -1;
      } else if (x.levelnr != a && y.levelnr == a) {
        return 1;
      } else if (x.levelnr == a && y.levelnr == a) {
        // If both have color 'a', sort by favorite status
        if (x.favourite && !y.favourite) {
          return -1;
        } else if (!x.favourite && y.favourite) {
          return 1;
        }
      }
      // If colors are the same and favorite status is the same, maintain original order
      return 0;
    });
    poemscache.value = List.from(selectedCategoryPoems.value);
    //setPoemsCache();
  }

  void toArchive() {}
}

class CategoriesNotifier extends ValueNotifier<List<String>> {
  CategoriesNotifier() : super([]);
}
