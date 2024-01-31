//import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
// ignore_for_file: unnecessary_new
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
  // PoemsScreenLogic logic = PoemsScreenLogic();

//test
//   List<String> categories = [];
//   //List<String> categoryNames = ['all'];
//   Map<String, Widget> categoryWidgets = {};
//   String selectedCategory = 'all';

// //endtest
//   String openingszin = 'No songs yet';
//   String openingszinb = 'Select a category';
//   String appBarTitle = "Songlist"; // Add this line
//   List<LyricsTransformer> songpieces = [];
//   List<LyricsTransformer> firstrunsongpieces = [];
//   //List<LyricsTransformer> songsfromdatabase = [];
//   late int count;
//   List<Widget> favoritesList = [];
//   List<Widget> normalList = [];
//   List<String> titelList = [];
//   TextEditingController searchController = TextEditingController();
//   DatabaseHelper databaseHelper = DatabaseHelper();
  @override
  void initState() {
    /*  filterList();
    searchController.addListener(() {
      filterList();
    }); */
    di.get<PoemsScreenLogic>().loadPoems();
    // _openCategory(context, songpieces);

    super.initState();
  }

  void updateListView() {
    di.get<PoemsScreenLogic>().updateListView();
  }

  //   final Future<Database> dbFuture = databaseHelper.initializeDatabase();
  //   dbFuture.then((database) {
  //     Future<List<LyricsTransformer>> todoListFuture =
  //         databaseHelper.getlyricList();
  //     todoListFuture.then((databaseLyricsResult) {
  //       setState(() {
  //         songpieces = databaseLyricsResult;
  //         count = databaseLyricsResult.length;
  //         categories = databaseLyricsResult
  //                 .where((LyricsTransformer e) =>
  //                     e.category.isNotEmpty) // filter out empty categories
  //                 .map((e) => e.category)
  //                 .toSet()
  //                 .toList()
  //             // .cast<String>()
  //             ;
  //         //categoryNames = songs.map((song) => song.category).toSet().toList();
  //         categories.insert(0, 'all'); // Ensure 'all' is the first category
  //         categoryWidgets = {};
  //         for (var category in categories) {
  //           if (category == 'all') {
  //             categoryWidgets[category] = createCategoryWidget(category);
  //           } else {
  //             categoryWidgets[category] = createCategoryWidget(
  //                 databaseLyricsResult
  //                     .where((lyricResult) => lyricResult.category == category)
  //                     .toList(),
  //                 category);
  //           }
  //         }
  //       });
  //     });
  //   });
  // }
  /*  filterList() {
    List<LyricsTransformer> lyrics = [];
    lyrics.addAll(songpieces);
    favoritesList = [];
    normalList = [];
    titelList = [];
    if (searchController.text.isNotEmpty) {
      lyrics.retainWhere((lyric) => lyric
          .title()
          .toLowerCase()
          .contains(searchController.text.toLowerCase()));
    }
    lyrics.forEach((lyric) {
      if (lyric.favourite) {
        favoritesList.add(
          Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            secondaryActions: <Widget>[
              IconSlideAction(
                iconWidget: Icon(Icons.star),
                onTap: () {},
              ),
              IconSlideAction(
                iconWidget: Icon(Icons.more_horiz),
                onTap: () {},
              ),
            ],
            child: ListTile(
              leading: Container(
                  height: 40,
                  width: 40,
                  child: Center(
                    child: Icon(
                      Icons.star,
                      color: Colors.yellow[100],
                    ),
                  )),
              title: Text(lyric.title()),
              subtitle: Text(
                lyric.lyrics(),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        );
      } else {
        normalList.add(
          Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            secondaryActions: <Widget>[
              IconSlideAction(
                iconWidget: Icon(Icons.star),
                onTap: () {
                  changeFavoriteStatus(lyric);
                },
              ),
              IconSlideAction(
                iconWidget: Icon(Icons.more_horiz),
                onTap: () {},
              ),
            ],
            child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MyHomePage(
                              title: lyric.title(),
                              ltf: lyric,
                            )));
              },
              title: Text(
                lyric.title(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                lyric.lyrics(),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        );
        titelList.add(removeDiacritics(lyric.title()));
      }
    });

    setState(() {
      titelList;
      favoritesList;
      normalList;
      titelList;
    });
  }
 */
  void changeFavoriteStatus() {
    di.get<PoemsScreenLogic>().changeFavoriteStatus();
  }

  // void changeFavoriteStatus(LyricsTransformer lyric) {
  //   setState(() {
  //     lyric.favourite = !lyric.favourite;
  //   });
  // }
  void loadPoems() {
    di.get<PoemsScreenLogic>().loadPoems();
  }
  // void loadSongs() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

  //   if (isFirstRun) {
  //     firstrunsongpieces.addAll(catchSong
  //         .allMatches(songslist)
  //         .map((e) => LyricsTransformer()..input = e.group(0)!));
  //     firstrunsongpieces.sort((a, b) => a.title().compareTo(b.title()));

  //     await databaseHelper.initializeDatabase();
  //     for (var lyric in firstrunsongpieces) {
  //       setState(() {
  //         openingszin = lyric.title();
  //         openingszinb = lyric.title();
  //       });
  //       await databaseHelper.insertlyric(lyric);
  //     }
  //     await prefs.setBool('isFirstRun', false);
  //     updateListView();
  //   }
  //   //on first run populate the database

  //   updateListView();
  // }
  //final items = List<String>.generate(10000, (i) => "Item $i");

  //  List<String> getList() {
  //   //var f = File(r'assets/songsheets.txt');
  //   //var songs = f.readAsStringSync();
  //   return catchSong.allMatches(songslist).map((element) {
  //     LyricsTransformer()..input = element.group(0);
  //   }).toList();
  //}
  //final _saver = Saver();
  Future<void> choiceAction(String choice) async {
    if (choice == Constants.exportAllToTxtFile) {
      // var archive = songpieces.map((e) => e.input.trim()).join('\n\n');
      // _saver.save('test.txt', archive);
      // _navigateAndDisplaySelection(context);
      di.get<PoemsScreenLogic>().exportAllToTxtFile();
      if (kDebugMode) {
        print('save');
      }
    } else if (choice == Constants.openTxtForNewPoem) {
      di.get<PoemsScreenLogic>().openLoader();
      // openLoader();
      // if (kDebugMode) {
      //   print(_paths);
      // }
    } else if (choice == Constants.toArchive) {
      di.get<PoemsScreenLogic>().toArchive();
      //  _openeditor(context, widget.ltf);
      if (kDebugMode) {
        print('archiveren');
      }
    } else if (choice == Constants.aNewPoem) {
      _openeditor(
        context,
        new Poem()..theText = '',
      );
    } else if (choice == Constants.reset) {
      di.get<PoemsScreenLogic>().resetToFirstRun();
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setBool('isFirstRun', true);
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
    //   setState(() {
    //     int index = categories.indexOf(oldName);
    //     if (index != -1) {
    //       categories[index] = newName;
    //     }
    //   });
    //   databaseHelper.renameCategory(oldName, newName);
    //   updateListView();
  }
  // final categoriesNotifier = ValueNotifier<List<String>>([]);

  void onDeleteCategory(String name) {
    di.get<PoemsScreenLogic>().onDeleteCategory(name);
    // categories.remove(name);
    // //  categoriesNotifier.value = categories;

    // databaseHelper.removeCategoryFromLyrics(name);
    // updateListView();
  }

  _openCategory(BuildContext context) async {
    // var categories = songpieces
    //         .where((LyricsTransformer e) =>
    //             e.category.isNotEmpty) // filter out empty categories
    //         .map((e) => e.category)
    //         .toSet()
    //         .toList()
    //     // .cast<String>()
    //     ;
    // categories.add('all');
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
      //test
      // if (result != null && result != 'all' && !categories.contains(result)) {
      //   categories.add(result);
      //   categoryWidgets[result] = createCategoryWidget(
      //       songpieces.where((element) => element.category == result).toList(),
      //       result);
      // }
      di.get<PoemsScreenLogic>().updateListView();
      //endtest

      /*  if (result == 'all') {
      newSongPieces = songpieces;
    } else {
      newSongPieces =
          songpieces.where((element) => element.category == result).toList();
    } */
      if (result != null) {
        di.get<PoemsScreenLogic>().categoryHasChangedTo(result);
        di.get<PoemsScreenLogic>().appBarTitle.value = result;
      }
      // setState(() {
      //   //test
      //   if (kDebugMode) {
      //     print("before $selectedCategory");
      //   }
      //   if (result != null) {
      //     logic.selectedCategory = result;
      //     appBarTitle = result;
      //   }
      //   if (kDebugMode) {
      //     print("after $selectedCategory");
      //   }
      // });
    });
  }

  _openeditor(BuildContext context, Poem input) async {
    final result = await Navigator.pushNamed(context, EditorScreen.routeName,
        arguments: input);
    //aaaprint('resukltaat:' + result.toString());
    if (result is String) {
      di.get<PoemsScreenLogic>().addNewPoem(result);
      // setState(() {
      //   if (result.toString().isNotEmpty) {
      //     songpieces.add(LyricsTransformer()..input = result);
      //     //save the result to the database
      //     databaseHelper.insertlyric(LyricsTransformer()..input = result);
      //     // filterList();
      //   }
      //   // widget.ltf.input = result;
      // });
    }
  }

//test
  void onPoemCategoryChanged(Poem song) {
    di.get<PoemsScreenLogic>().onPoemCategoryChanged(song);
    // databaseHelper.updatelyric(song);
    // updateListView();
  }

  Widget createCategoryWidget(List<Poem> poems) {
    var diLogic = di.get<PoemsScreenLogic>();
    return diLogic.selectedCategoryPoems.value.isNotEmpty
        ? Container(
            key: Key(diLogic.selectedCategory.value),
            child:
                // Replace with the widget you want to use when CategorySongs has less than 10 items
                ValueListenableBuilder<List<Poem>>(
                    valueListenable: diLogic.selectedCategoryPoems,
                    builder: (context, poems, child) {
                      return AtoZSlider(
                          logic: di.get<PoemsScreenLogic>(),
                          poems: diLogic.selectedCategoryPoems.value,
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
                          callbacksearchchange: (word) =>
                              {debugPrint("SearchWord: $word")},
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
                            // await databaseHelper.updatelyric(itemToUpdate);

                            // List updatedSongPieces = await databaseHelper.getlyricList();

                            // List<LyricsTransformer> updatedCategorySongs = updatedSongPieces
                            //     .map<LyricsTransformer>((item) => item as LyricsTransformer)
                            //     .toList();

                            // provider.updateCategorySongs(updatedCategorySongs);

                            // logic.updateListView();
                          },

                          //change the items favourite status
                          //and save it in the database

                          // songpieces
                          //   .where((element) => element.key == i)
                          //  .forEach((element) {
                          //  element.favourite = !element.favourite;
                          // });
                          //  songpieces[i].favourite = !songpieces[i].favourite;
                          callbackmoreclicked: (i) {
                            di.get<PoemsScreenLogic>().updatePoem(di
                                .get<PoemsScreenLogic>()
                                .selectedCategoryPoems
                                .value[i]);
                            // databaseHelper.updatelyric(provider.categorySongs[i]).then((_) {
                            // After the item is updated, fetch the updated songpieces from the database
                            // databaseHelper.getlyricList().then((updatedSongPieces) {
                            // setState(() {
                            // updateListView();
                            // CategorySongs = updatedSongPieces;
                            // }
                            // );

                            debugPrint("moreclickedInSonglist on$i");
                          },
                          callbacklevelchanged: (i) {
                            // var element = logic.selectedCategoryPoems.value
                            //     .firstWhere((element) => element.id == i.id);
                            // element.levelnr = i.levelnr;

                            // Update the item in the database
                            // databaseHelper.updatelyric(element).then((_) {
                            //   // After the item is updated, fetch the updated songpieces from the database
                            //   databaseHelper.getlyricList().then((updatedSongPieces) {
                            //     provider.updateCategorySongs(updatedSongPieces);
                            //     updateListView();
                            //   });
                            // }

                            // logic.updatePoem(element);
                          },
                          callbackDeleteItem: (i) {
                            di.get<PoemsScreenLogic>().onDeletePoem(i);
                            //delete item from database with databaseHelper and update the songpieces
                            //   databaseHelper.deletelyric(i.id).then((_) {
                            //changed key to id
                            // After the item is deleted, fetch the updated songpieces from the database
                            //   databaseHelper.getlyricList().then((updatedSongPieces) {
                            //   provider.updateCategorySongs(updatedSongPieces);
                            // updateListView();
                            //  });
                            // });
                            //);
                          },
                          callbackcategorychanged: (i) {
                            onPoemCategoryChanged(i);
                          });
                    })
            // ... other callbacks ...
            )
        : Center(
            child: ValueListenableBuilder<String>(
                valueListenable: di.get<PoemsScreenLogic>().whatWeGot,
                builder: (context, value, child) {
                  return Text(value);
                }));
  }
//endtest

  @override
  Widget build(BuildContext context) {
    var selectedCategoryPoems =
        watchValue((PoemsScreenLogic s) => s.selectedCategoryPoems);

    return Scaffold(
        appBar: AppBar(
          title: Text(di.get<PoemsScreenLogic>().appBarTitle.value),
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
        body: createCategoryWidget(selectedCategoryPoems)

        //??
        //  Center(child: Text(logic.openingszinb.value)),

        //endtest

        /* songpieces.isNotEmpty
          ? AtoZSlider(
              songpieces,
              (i) => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MyHomePage(
                                  title: songpieces[i].title(),
                                  ltf: songpieces[i],
                                )))
                  },
              (word) => {debugPrint("SearchWord: $word")}, (i) {
              debugPrint("starclicked on $i");

              setState(() {
                var itemToUpdate =
                    songpieces.firstWhere((element) => element.id == i);
                // Toggle the 'favourite' property of the item
                itemToUpdate.favourite = !itemToUpdate.favourite;
                // Update the item in the database
                databaseHelper.updatelyric(itemToUpdate);
              });
            },

              //change the items favourite status
              //and save it in the database

              // songpieces
              //   .where((element) => element.key == i)
              //  .forEach((element) {
              //  element.favourite = !element.favourite;
              // });
              //  songpieces[i].favourite = !songpieces[i].favourite;
              (i) {
              databaseHelper.updatelyric(songpieces[i]).then((_) {
                // After the item is updated, fetch the updated songpieces from the database
                databaseHelper.getlyricList().then((updatedSongPieces) {
                  setState(() {
                    songpieces = updatedSongPieces;
                  });
                });
              });

              debugPrint("moreclicked on$i");
            }, (i) {
              setState(() {
                songpieces
                    .where((element) => element.id == i.id) //changed key to id
                    .forEach((element) {
                  element.levelnr = i.levelnr;
                });
              });
            }, (i) {
              setState(() {
                //delete item from database with databaseHelper and update the songpieces
                databaseHelper.deletelyric(i.id).then((_) {
                  //changed key to id
                  // After the item is deleted, fetch the updated songpieces from the database
                  databaseHelper.getlyricList().then((updatedSongPieces) {
                    setState(() {
                      songpieces = updatedSongPieces;
                    });
                  });
                });
              });
            })
          : const Center(child: Text('No songs yet')), */
        );
  }

  // late List<FilePickerResult> _paths;
  // void openLoader() async {
  //   _paths = (await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['txt'])) as List<FilePickerResult>;
  // }
}
