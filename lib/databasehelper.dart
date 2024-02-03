import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'poem_model.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database

  String poemsTable = 'poems_table';
  String colId = 'id';
  String colInput = 'input';
  String colFavourite = 'fav';
  String colLevel = 'levelnr';
  String colExtraletters = 'extraletters';
  String colExtrawordsStart = 'extrawordsStart';
  String colExtrawordsEnd = 'extrawordsEnd';
  String colScramble = 'scramble';
  String colSeeend = 'seeend';
  String colSeestart = 'seestart';
  String colCategory = 'category';
  String colBlokker = 'blokker';
  String colBlokkerVowel = 'blokkerVowel';

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
    String path = '${directory.path}poems.db';

    // Open/create the database at a given path
    var poemsDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return poemsDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $poemsTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colInput TEXT,$colFavourite INTEGER, $colLevel INTEGER,$colExtraletters INTEGER,$colExtrawordsStart INTEGER,$colExtrawordsEnd INTEGER,$colScramble INTEGER,$colSeeend INTEGER,$colSeestart INTEGER,$colCategory TEXT, $colBlokker TEXT,$colBlokkerVowel TEXT)');
  }

  Future<List<String>> getDistinctCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT DISTINCT $colCategory FROM $poemsTable WHERE $colCategory != ""');
    return List.generate(maps.length, (i) => maps[i][colCategory]);
  }

  // Fetch Operation: Get all lyric objects from database
  Future<List<Map<String, dynamic>>> _getPoemsFromDataBase() async {
    Database db = await database;

//		var result = await db.rawQuery('SELECT * FROM $lyricTable order by $colInput ASC');
    var result = await db.query(poemsTable, orderBy: '$colInput ASC');
    return result;
  }

  Future<List<Poem>> getPoemsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      poemsTable,
      where: '$colCategory = ?',
      whereArgs: [category],
      orderBy: '$colInput ASC', // Sort by title in ascending order
    );
    return List.generate(maps.length, (i) => Poem.fromMap(maps[i]));
  }

  // Insert Operation: Insert a lyric object to database
  Future<int> insertPoem(Poem poem) async {
    Database db = await database;
    int result;
    result = await db.insert(
      poemsTable,
      poem.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Use the REPLACE conflict algorithm
    );

    if (kDebugMode) {
      print('insertPoem:$result');
    }
    var b = await getPoemsCount();
    if (kDebugMode) {
      print(" In insertPoems poemscount:$b");
    }
    return result;
  }

// Fetch Operation: Get a lyric object from database
  Future<Poem?> getPoemByID(int id) async {
    var db = await database;
    List<Map> maps =
        await db.query(poemsTable, where: '$colId = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Poem.fromMap(maps.first as Map<String, dynamic>);
    }
    return null;
  }

  // Update Operation: Update a lyric object and save it to database
  Future<int> updatePoem(Poem poem) async {
    var db = await database;
    if (kDebugMode) {
      print('inupdate poem:${poem.favourite}');
    }
    var result = await db.update(poemsTable, poem.toMap(),
        where: '$colId = ?', whereArgs: [poem.id]);
    if (kDebugMode) {
      Poem? a = await getPoemByID(poem.id!);
      print('afterupdate poem:${a?.favourite}');
    }
    //var b = await getCount();
    if (kDebugMode) {
      print("inupdate poem:$result");
    }
    return result;
  }

  // Delete Operation: Delete a lyric object from database
  Future<int> deletePoemByID(int id) async {
    var db = await database;
    int result =
        await db.rawDelete('DELETE FROM $poemsTable WHERE $colId = $id');
    return result;
  }

  // Get number of lyric objects in database
  Future<int> getPoemsCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $poemsTable');
    int result = Sqflite.firstIntValue(x) as int;
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'lyric List' [ List<lyric> ]
  Future<List<Poem>> getPoemsfromDB() async {
    var poemsMapList =
        await _getPoemsFromDataBase(); // Get 'Map List' from database
    return poemsMapList.map((poemMap) => Poem.fromMap(poemMap)).toList();
  }

  void renameCategory(String oldName, String newName) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE $poemsTable SET $colCategory = ? WHERE $colCategory = ?',
      [newName, oldName],
    );
  }

  void removeCategoryFromDataBase(String categoryName) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE $poemsTable SET $colCategory = NULL WHERE $colCategory = ?',
      [categoryName],
    );
  }
}
