import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'lyricschanger_base.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database

  String lyricTable = 'lyric_table';
  String colId = 'id';
  String colInput = 'input';
  String colFavourite = 'fav';
  String colLevel = 'levelnr';
  String colExtraletters = 'extraletters';
  String colExtrawords = 'extrawords';
  String colScramble = 'scramble';
  String colSeeend = 'seeend';
  String colSeestart = 'seestart';
  String colCategory = 'category';
  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}lyrics.db';

    // Open/create the database at a given path
    var lyricsDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return lyricsDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $lyricTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colInput TEXT,$colFavourite INTEGER, $colLevel INTEGER,$colExtraletters INTEGER,$colExtrawords INTEGER,$colScramble INTEGER,$colSeeend INTEGER,$colSeestart INTEGER,$colCategory TEXT)');
  }

  // Fetch Operation: Get all lyric objects from database
  Future<List<Map<String, dynamic>>> getlyricMapList() async {
    Database db = await database;

//		var result = await db.rawQuery('SELECT * FROM $lyricTable order by $colInput ASC');
    var result = await db.query(lyricTable, orderBy: '$colInput ASC');
    return result;
  }

  // Insert Operation: Insert a lyric object to database
  Future<int> insertlyric(LyricsTransformer lyric) async {
    Database db = await database;
    int result;
    result = await db.insert(
      lyricTable,
      lyric.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Use the REPLACE conflict algorithm
    );
    //var qr = await db
    //    .rawQuery('SELECT * FROM $lyricTable WHERE $colInput="$linput"');
    // qr.isEmpty
    //    ? result = await db.insert(lyricTable, lyric.toMap())
    //   : result = 2;
    if (kDebugMode) {
      print('insertlyrics:$result');
    }
    var b = await getCount();
    if (kDebugMode) {
      print(b);
    }
    return result;
  }

  // Update Operation: Update a lyric object and save it to database
  Future<int> updatelyric(LyricsTransformer lyric) async {
    var db = await database;
    var result = await db.update(lyricTable, lyric.toMap(),
        where: '$colId = ?', whereArgs: [lyric.id]);
    if (kDebugMode) {
      print('updatelyrics:');
    }
    //var b = await getCount();
    if (kDebugMode) {
      print("inupdate lyrics:$result");
    }
    return result;
  }

  Future<int> updatelyricCompleted(LyricsTransformer lyric) async {
    var db = await database;
    var result = await db.update(lyricTable, lyric.toMap(),
        where: '$colId = ?', whereArgs: [lyric.id]);
    return result;
  }

  // Delete Operation: Delete a lyric object from database
  Future<int> deletelyric(int id) async {
    var db = await database;
    int result =
        await db.rawDelete('DELETE FROM $lyricTable WHERE $colId = $id');
    return result;
  }

  // Get number of lyric objects in database
  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $lyricTable');
    int result = Sqflite.firstIntValue(x) as int;
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'lyric List' [ List<lyric> ]
  Future<List<LyricsTransformer>> getlyricList() async {
    var lyricMapList = await getlyricMapList(); // Get 'Map List' from database
    return lyricMapList
        .map((lyricMap) => LyricsTransformer.fromMapObject(lyricMap))
        .toList();
  }

  void renameCategory(String oldName, String newName) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE $lyricTable SET $colCategory = ? WHERE $colCategory = ?',
      [newName, oldName],
    );
  }

  void removeCategoryFromLyrics(String categoryName) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE $lyricTable SET $colCategory = NULL WHERE $colCategory = ?',
      [categoryName],
    );
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'lyric List' [ List<lyric> ]
  Future<List<Map<String, dynamic>>> getlyricMapListByCategory(
      String category) async {
    Database db = await database;
    var result = await db.rawQuery(
        'SELECT * FROM $lyricTable WHERE $colCategory="$category" order by $colInput ASC');
    return result;
  }

/*   Future<List<LyricsTransformer>> getlyricList() async {
    var lyricMapList = await getlyricMapList(); // Get 'Map List' from database
    int count =
        lyricMapList.length; // Count the number of map entries in db table

    List<LyricsTransformer> lyricList = [];
    // For loop to create a 'lyric List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      lyricList.add(LyricsTransformer.fromMapObject(lyricMapList[i]));
    }

    return lyricList;
  } */

  Future<LyricsTransformer?> getLyric(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(lyricTable,
        columns: [
          colId,
          colInput,
          colLevel,
          colFavourite,
          colExtraletters,
          colExtrawords,
          colScramble,
          colSeeend,
          colSeestart,
          colCategory
        ],
        where: '$colId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return LyricsTransformer.fromMapObject(maps.first);
    }
    return null;
  }
}
