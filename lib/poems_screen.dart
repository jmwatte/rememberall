import 'package:rememberall2/loadingscreen.dart';
import 'package:rememberall2/poem_screen_logic.dart';
import 'package:rememberall2/poems_screen_logic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rememberall2/poem_screen.dart';
import 'package:rememberall2/atozscrollwithsearch.dart';
import 'package:rememberall2/editorscreen.dart';
import 'package:rememberall2/poem_model.dart';
import 'package:rememberall2/categorylist_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/watch_it.dart';
//import 'main.dart';

class MyPoems extends StatefulWidget with WatchItStatefulWidgetMixin {
  const MyPoems({
    super.key,
  });
  //
  @override
  MyPoemsState createState() => MyPoemsState();
}

class MyPoemsState extends State<MyPoems> {
  @override
  void initState() {
    di.get<PoemsScreenLogic>().loadPoems();

    super.initState();
  }

  void updateListView() {
    di.get<PoemsScreenLogic>().updateListView();
  }

  void changeFavoriteStatus() {
    di.get<PoemsScreenLogic>().changeFavoriteStatus();
  }

  void loadPoems() {
    di.get<PoemsScreenLogic>().loadPoems();
  }

  Future<void> choiceAction(String choice) async {
    if (choice == Constants.exportAllToTxtFile) {
      di.get<PoemsScreenLogic>().exportAllToTxtFile();
      if (kDebugMode) {
        print('in choiceAction exportAllToTxtFile');
      }
    } else if (choice == Constants.importNewPoem) {
      di.get<PoemsScreenLogic>().openImporter();
    } else if (choice == Constants.toArchive) {
      di.get<PoemsScreenLogic>().toArchive();
      //  _openeditor(context, widget.ltf);
      if (kDebugMode) {
        print('in choiceAction archiveren');
      }
    } else if (choice == Constants.aNewPoem) {
      _openeditor(
        context,
        Poem()..theText = '',
      );
    } else if (choice == Constants.reset) {
      di.get<PoemsScreenLogic>().resetToFirstRun();
    } else if (choice == Constants.category) {
      _openCategory(context);
    } else if (choice == Constants.usePrefs) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return FutureBuilder<bool>(
              future: SharedPreferences.getInstance()
                  .then((prefs) => prefs.getBool('usePrefs') ?? false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  bool usePrefs = snapshot.data!;
                  return AlertDialog(
                    title: const Text(
                        'Use the prefs from the song or the shared prefs?'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          ListTile(
                            leading: usePrefs ? null : const Icon(Icons.check),
                            title: const Text('Use the prefs from the song'),
                            onTap: () {
                              SharedPreferences.getInstance().then((prefs) {
                                prefs.setBool('usePrefs', false);
                                di.get<PoemScreenLogic>().useSharedPrefs =
                                    false;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                          ListTile(
                            leading: usePrefs ? const Icon(Icons.check) : null,
                            title: const Text('Use the shared prefs'),
                            onTap: () {
                              SharedPreferences.getInstance().then((prefs) {
                                prefs.setBool('usePrefs', true);
                                di.get<PoemScreenLogic>().useSharedPrefs = true;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            );
          });
    }
  }

  void onRenameCategory(String oldName, String newName) {
    di.get<PoemsScreenLogic>().onRenameCategory(oldName, newName);
  }

  void onDeleteCategory(String name) {
    di.get<PoemsScreenLogic>().onDeleteCategory(name);
  }

  _openCategory(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryListScreen(
            categories: di.get<PoemsScreenLogic>().categories.value,
            onRenameCategory: di.get<PoemsScreenLogic>().onRenameCategory,
            onDeleteCategory: di.get<PoemsScreenLogic>().onDeleteCategory,
            //   categoriesNotifier: categoriesNotifier,
          ),
        ),
      );

      // di.get<PoemsScreenLogic>().updateListView();
      //endtest

      if (result != null) {
        di.get<PoemsScreenLogic>().categoryHasChangedTo(result);
        di.get<PoemsScreenLogic>().appBarTitle.value = result;
      }
    });
  }

  _openeditor(BuildContext context, Poem input) async {
    final result = await Navigator.pushNamed(context, EditorScreen.routeName,
        arguments: input);
    if (result is String) {
      di.get<PoemsScreenLogic>().addNewPoem(result);
    }
  }

//test
  void onPoemCategoryChanged(Poem song) {
    di.get<PoemsScreenLogic>().onPoemCategoryChanged(song);
  }

  Widget createCategoryWidget() {
    var diLogic = di.get<PoemsScreenLogic>();
    watchValue((PoemsScreenLogic s) => s.selectedCategoryPoems);
    var tit = watchValue((PoemsScreenLogic s) => s.whatWeGot);
    return diLogic.selectedCategoryPoems.value.isNotEmpty
        ? Container(
            key: Key(diLogic.selectedCategory.value),
            child:
                // Replace with the widget you want to use when CategorySongs has less than 10 items
                ValueListenableBuilder<List<Poem>>(
                    valueListenable: diLogic.selectedCategoryPoems,
                    builder: (context, poems, child) {
                      return AtoZSlider(
                          // logic: di.get<PoemsScreenLogic>(),
                          // poems: diLogic.selectedCategoryPoems.value,
                          callbackitemclick: (i) => {
                                diLogic.selectedPoem.value =
                                    diLogic.selectedCategoryPoems.value[i],
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OnePoemSreen(
                                      title: diLogic
                                          .selectedCategoryPoems.value[i]
                                          .poemTitle(),
                                      poem: diLogic
                                          .selectedCategoryPoems.value[i],
                                    ),
                                  ),
                                ),
                              },
                          callbacksearchchange: (word) => {
                                debugPrint(
                                    "in callbackSearchchange Word: $word")
                              },
                          callbackstarclicked: (i) {
                            debugPrint("starclicked on $i");
                            //TODO is this not the selectedLyric?
                            var itemToUpdate = di
                                .get<PoemsScreenLogic>()
                                .selectedCategoryPoems
                                .value
                                .firstWhere((element) => element.id == i);
                            itemToUpdate.favourite = !itemToUpdate.favourite;

                            di.get<PoemsScreenLogic>().updatePoem(itemToUpdate);
                          },
                          callbackmoreclicked: (i) {
                            di.get<PoemsScreenLogic>().updatePoem(di
                                .get<PoemsScreenLogic>()
                                .selectedCategoryPoems
                                .value[i]);

                            debugPrint("moreclickedInSonglist on$i");
                          },
                          callbacklevelchanged: (i) {},
                          callbackDeleteItem: (i) {
                            di.get<PoemsScreenLogic>().onDeletePoem(i);
                          },
                          callbackcategorychanged: (i) {
                            onPoemCategoryChanged(i);
                          });
                    })
            // ... other callbacks ...
            )
        : Center(child: (LoadingScreen(tit)));
  }
//endtest

  @override
  Widget build(BuildContext context) {
    //  var selectedCategoryPoems =
    //    watchValue((PoemsScreenLogic s) => s.selectedCategoryPoems);
    var titleText = watchValue((PoemsScreenLogic s) => s.appBarTitle);
    return Scaffold(
        appBar: AppBar(
          title: Text(titleText),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: choiceAction,
              itemBuilder: (BuildContext context) {
                return Constants.listChoices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
        ),

        //test
        body: createCategoryWidget());
  }
}
