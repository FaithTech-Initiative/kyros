import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "Bible.db";
  static const _databaseVersion = 1;

  static const table = 'verses';

  static const columnId = '_id';
  static const columnBook = 'book';
  static const columnChapter = 'chapter';
  static const columnVerse = 'verse';
  static const columnText = 'text';
  static const columnTranslation = 'translation';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnBook TEXT NOT NULL,
            $columnChapter INTEGER NOT NULL,
            $columnVerse INTEGER NOT NULL,
            $columnText TEXT NOT NULL,
            $columnTranslation TEXT NOT NULL
          )
          ''');
    await _loadBibleData(db, 'KJV');
  }

  Future<void> _loadBibleData(Database db, String translation) async {
    String jsonString = await rootBundle.loadString('assets/translations/$translation.json');
    Map<String, dynamic> jsonResult = json.decode(jsonString);

    for (String book in jsonResult.keys) {
      Map<String, dynamic> chapters = jsonResult[book];
      for (String chapter in chapters.keys) {
        Map<String, dynamic> verses = chapters[chapter];
        for (String verse in verses.keys) {
          String text = verses[verse];
          await db.insert(table, {
            columnBook: book,
            columnChapter: int.parse(chapter),
            columnVerse: int.parse(verse),
            columnText: text,
            columnTranslation: translation,
          });
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getBooks(String translation) async {
    Database db = await instance.database;
    return await db.rawQuery('SELECT DISTINCT $columnBook FROM $table WHERE $columnTranslation = ?', [translation]);
  }

  Future<int> getChapterCount(String translation, String book) async {
    Database db = await instance.database;
    final result = await db.rawQuery(
        'SELECT COUNT(DISTINCT $columnChapter) as chapterCount FROM $table WHERE $columnTranslation = ? AND $columnBook = ?', [translation, book]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getVerses(String translation, String book, int chapter) async {
    Database db = await instance.database;
    return await db.query(table,
        where: '$columnTranslation = ? AND $columnBook = ? AND $columnChapter = ?',
        whereArgs: [translation, book, chapter]);
  }
}
