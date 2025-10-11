import 'dart:convert';

import 'package:kyros/models/note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE notes (
  id $idType,
  title $textType,
  content $textType,
  createdTime $textType,
  labels $textType,
  isArchived $boolType,
  isDeleted $boolType,
  imageUrls $textType,
  audioUrls $textType
)
''');
  }

  Future<Note> create(Note note) async {
    final db = await instance.database;
    final id = await db.insert('notes', {
      'title': note.title,
      'content': note.content,
      'createdTime': note.createdTime.toIso8601String(),
      'labels': jsonEncode(note.labels),
      'isArchived': note.isArchived ? 1 : 0,
      'isDeleted': note.isDeleted ? 1 : 0,
      'imageUrls': jsonEncode(note.imageUrls),
      'audioUrls': jsonEncode(note.audioUrls),
    });
    return note.copy(id: id);
  }

  Future<Note> readNote(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      'notes',
      columns: [
        'id',
        'title',
        'content',
        'createdTime',
        'labels',
        'isArchived',
        'isDeleted',
        'imageUrls',
        'audioUrls'
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return Note(
        id: map['id'] as int?,
        title: map['title'] as String,
        content: map['content'] as String,
        createdTime: DateTime.parse(map['createdTime'] as String),
        labels: jsonDecode(map['labels'] as String).cast<String>(),
        isArchived: map['isArchived'] == 1,
        isDeleted: map['isDeleted'] == 1,
        imageUrls: jsonDecode(map['imageUrls'] as String).cast<String>(),
        audioUrls: jsonDecode(map['audioUrls'] as String).cast<String>(),
      );
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes');
    return result.map((map) {
      return Note(
        id: map['id'] as int?,
        title: map['title'] as String,
        content: map['content'] as String,
        createdTime: DateTime.parse(map['createdTime'] as String),
        labels: jsonDecode(map['labels'] as String).cast<String>(),
        isArchived: map['isArchived'] == 1,
        isDeleted: map['isDeleted'] == 1,
        imageUrls: jsonDecode(map['imageUrls'] as String).cast<String>(),
        audioUrls: jsonDecode(map['audioUrls'] as String).cast<String>(),
      );
    }).toList();
  }

  Future<int> update(Note note) async {
    final db = await instance.database;

    return db.update(
      'notes',
      {
        'title': note.title,
        'content': note.content,
        'createdTime': note.createdTime.toIso8601String(),
        'labels': jsonEncode(note.labels),
        'isArchived': note.isArchived ? 1 : 0,
        'isDeleted': note.isDeleted ? 1 : 0,
        'imageUrls': jsonEncode(note.imageUrls),
        'audioUrls': jsonEncode(note.audioUrls),
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
