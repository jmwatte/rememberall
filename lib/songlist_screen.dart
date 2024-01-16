//import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
// ignore_for_file: unnecessary_new
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diacritic/diacritic.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rememberall/song_screen.dart';
import 'package:rememberall/songs.dart';
import 'package:sqflite/sqflite.dart';
import 'databasehelper.dart';
import 'saver_screen.dart';
import 'atozscrollwithsearch.dart';
import 'editorscreen.dart';
import 'lyricschanger_base.dart';
import 'categorylist_screen.dart';
//import 'main.dart';

class MySongList extends StatefulWidget {
  const MySongList({
    Key? key,
  }) : super(key: key);

  @override
  _MySongListState createState() => _MySongListState();
}

class _MySongListState extends State<MySongList> {
//test
  List<String> categories = [];
  //List<String> categoryNames = ['all'];
  Map<String, Widget> categoryWidgets = {};
  String selectedCategory = 'all';

//endtest
  String openingszin = 'No songs yet';
  String openingszinb = 'Select a category';
  String appBarTitle = "Songlist"; // Add this line
  List<LyricsTransformer> songpieces = [];
  List<LyricsTransformer> firstrunsongpieces = [];
  //List<LyricsTransformer> songsfromdatabase = [];
  late int count;
  List<Widget> favoritesList = [];
  List<Widget> normalList = [];
  List<String> titelList = [];
  TextEditingController searchController = TextEditingController();
  DatabaseHelper databaseHelper = DatabaseHelper();
  @override
  void initState() {
    /*  filterList();
    searchController.addListener(() {
      filterList();
    }); */
    loadSongs();
    // _openCategory(context, songpieces);

    super.initState();
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<LyricsTransformer>> todoListFuture =
          databaseHelper.getlyricList();
      todoListFuture.then((databaseLyricsResult) {
        setState(() {
          songpieces = databaseLyricsResult;
          count = databaseLyricsResult.length;
          categories = databaseLyricsResult
                  .where((LyricsTransformer e) =>
                      e.category.isNotEmpty) // filter out empty categories
                  .map((e) => e.category)
                  .toSet()
                  .toList()
              // .cast<String>()
              ;
          //categoryNames = songs.map((song) => song.category).toSet().toList();
          categories.insert(0, 'all'); // Ensure 'all' is the first category
          categoryWidgets = {};
          for (var category in categories) {
            if (category == 'all') {
              categoryWidgets[category] =
                  createCategoryWidget(databaseLyricsResult, category);
            } else {
              categoryWidgets[category] = createCategoryWidget(
                  databaseLyricsResult
                      .where((lyricResult) => lyricResult.category == category)
                      .toList(),
                  category);
            }
          }
        });
      });
    });
  }

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
  void changeFavoriteStatus(LyricsTransformer lyric) {
    setState(() {
      lyric.favourite = !lyric.favourite;
    });
  }

  void loadSongs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      firstrunsongpieces.addAll(catchSong
          .allMatches(songslist)
          .map((e) => LyricsTransformer()..input = e.group(0)!));
      firstrunsongpieces.sort((a, b) => a.title().compareTo(b.title()));

      await databaseHelper.initializeDatabase();
      for (var lyric in firstrunsongpieces) {
        setState(() {
          openingszin = lyric.title();
          openingszinb = lyric.title();
        });
        await databaseHelper.insertlyric(lyric);
      }
      await prefs.setBool('isFirstRun', false);
      updateListView();
    }
    //on first run populate the database

    updateListView();
  }
  //final items = List<String>.generate(10000, (i) => "Item $i");

  //  List<String> getList() {
  //   //var f = File(r'assets/songsheets.txt');
  //   //var songs = f.readAsStringSync();
  //   return catchSong.allMatches(songslist).map((element) {
  //     LyricsTransformer()..input = element.group(0);
  //   }).toList();
  //}
  final _saver = Saver();
  Future<void> choiceAction(String choice) async {
    if (choice == Constants.exportAllToTxtFile) {
      var archive = songpieces.map((e) => e.input.trim()).join('\n\n');
      _saver.save('test.txt', archive);
      // _navigateAndDisplaySelection(context);
      if (kDebugMode) {
        print('save');
      }
    } else if (choice == Constants.openTxtForNewLyric) {
      openLoader();
      if (kDebugMode) {
        print(_paths);
      }
    } else if (choice == Constants.toArchive) {
      //  _openeditor(context, widget.ltf);
      if (kDebugMode) {
        print('archiveren');
      }
    } else if (choice == Constants.aNewLyric) {
      _openeditor(
        context,
        new LyricsTransformer()..input = '',
      );
    } else if (choice == Constants.reset) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstRun', true);
    } else if (choice == Constants.category) {
      _openCategory(context, songpieces);
    }
  }

  void onRenameCategory(String oldName, String newName) {
    setState(() {
      int index = categories.indexOf(oldName);
      if (index != -1) {
        categories[index] = newName;
      }
    });
    databaseHelper.renameCategory(oldName, newName);
    updateListView();
  }
  // final categoriesNotifier = ValueNotifier<List<String>>([]);

  void onDeleteCategory(String name) {
    categories.remove(name);
    //  categoriesNotifier.value = categories;

    databaseHelper.removeCategoryFromLyrics(name);
    updateListView();
  }

  _openCategory(
      BuildContext context, List<LyricsTransformer> songpieces) async {
    // var categories = songpieces
    //         .where((LyricsTransformer e) =>
    //             e.category.isNotEmpty) // filter out empty categories
    //         .map((e) => e.category)
    //         .toSet()
    //         .toList()
    //     // .cast<String>()
    //     ;
    // categories.add('all');
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryListScreen(
            categories: categories,
            onRenameCategory: onRenameCategory,
            onDeleteCategory: onDeleteCategory,
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
      updateListView();
      //endtest

      /*  if (result == 'all') {
      newSongPieces = songpieces;
    } else {
      newSongPieces =
          songpieces.where((element) => element.category == result).toList();
    } */
      setState(() {
        //test
        if (kDebugMode) {
          print("before $selectedCategory");
        }
        if (result != null) {
          selectedCategory = result;
          appBarTitle = result;
        }
        if (kDebugMode) {
          print("after $selectedCategory");
        }
      });
    });
  }

  _openeditor(BuildContext context, LyricsTransformer input) async {
    final result = await Navigator.pushNamed(context, EditorScreen.routeName,
        arguments: input);
    //aaaprint('resukltaat:' + result.toString());
    if (result is String) {
      setState(() {
        if (result.toString().isNotEmpty) {
          songpieces.add(LyricsTransformer()..input = result);
          //save the result to the database
          databaseHelper.insertlyric(LyricsTransformer()..input = result);
          // filterList();
        }
        // widget.ltf.input = result;
      });
    }
  }

//test
  void onSongCategoryChanged(LyricsTransformer song) {
    databaseHelper.updatelyric(song);
    updateListView();
  }

  Widget createCategoryWidget(
      List<LyricsTransformer> CategorySongs, String category) {
    return CategorySongs.isNotEmpty
        ? Container(
            key: Key(category),
            child:
                // Replace with the widget you want to use when CategorySongs has less than 10 items
                AtoZSlider(
                    CategorySongs,
                    (i) => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MyHomePage(
                                title: CategorySongs[i].title(),
                                ltf: CategorySongs[i],
                              ),
                            ),
                          ),
                        },
                    (word) => {debugPrint("SearchWord: $word")}, (i) {
              debugPrint("starclicked on $i");

              setState(() {
                var itemToUpdate =
                    CategorySongs.firstWhere((element) => element.id == i);
                // Toggle the 'favourite' property of the item
                // itemToUpdate.favourite = i.favourite;
                itemToUpdate.favourite = !itemToUpdate.favourite;
                // Update the item in the database
                // Update the item in the database
                databaseHelper.updatelyric(itemToUpdate).then((_) {
                  // After the item is updated, fetch the updated songpieces from the database
                  databaseHelper.getlyricList().then((updatedSongPieces) {
                    setState(() {
                      CategorySongs = updatedSongPieces;
                      updateListView();
                    });
                  });
                });
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
              databaseHelper.updatelyric(CategorySongs[i]).then((_) {
                // After the item is updated, fetch the updated songpieces from the database
                // databaseHelper.getlyricList().then((updatedSongPieces) {
                // setState(() {
                updateListView();
                // CategorySongs = updatedSongPieces;
                // }
                // );
              });

              debugPrint("moreclickedInSonglist on$i");
            }, (i) {
              setState(() {
                var element =
                    CategorySongs.firstWhere((element) => element.id == i.id);
                element.levelnr = i.levelnr;

                // Update the item in the database
                databaseHelper.updatelyric(element).then((_) {
                  // After the item is updated, fetch the updated songpieces from the database
                  databaseHelper.getlyricList().then((updatedSongPieces) {
                    setState(() {
                      CategorySongs = updatedSongPieces;
                      updateListView();
                    });
                  });
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
                      CategorySongs = updatedSongPieces;
                    });
                  });
                });
              });
            }, (i) {
              onSongCategoryChanged(i);
            })
            // ... other callbacks ...
            )
        : Center(child: Text(openingszin));
  }
//endtest

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
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
      body: categoryWidgets[selectedCategory] ??
          Center(child: Text(openingszinb)),

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

  late List<FilePickerResult> _paths;
  void openLoader() async {
    _paths = (await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'])) as List<FilePickerResult>;
  }
}
