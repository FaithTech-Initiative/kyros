import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:kyros/models/note.dart';

class NotesDatabaseHelper {
  static const _databaseName = "Notes.db";
  static const _databaseVersion = 1;

  static const table = 'notes';

  static const columnId = '_id';
  static const columnTitle = 'title';
  static const columnContent = 'content';
  static const columnCreatedTime = 'createdTime';
  static const columnIsArchived = 'isArchived';
  static const columnIsDeleted = 'isDeleted';

  NotesDatabaseHelper._privateConstructor();
  static final NotesDatabaseHelper instance = NotesDatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnTitle TEXT NOT NULL,
            $columnContent TEXT NOT NULL,
            $columnCreatedTime TEXT NOT NULL,
            $columnIsArchived INTEGER NOT NULL,
            $columnIsDeleted INTEGER NOT NULL
          )
          ''');
  }

  Future<Note> create(Note note) async {
    Database db = await instance.database;
    final id = await db.insert(table, note.toMap());
    return note.copy(id: id);
  }

  Future<Note> readNote(int id) async {
    Database db = await instance.database;
    final maps = await db.query(
      table,
      columns: [columnId, columnTitle, columnContent, columnCreatedTime, columnIsArchived, columnIsDeleted],
      where: '$columnId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Note>> readAllNotes() async {
    Database db = await instance.database;
    final result = await db.query(table);
    return result.map((json) => Note.fromMap(json)).toList();
  }

  Future<int> update(Note note) async {
    Database db = await instance.database;
    return await db.update(
      table,
      note.toMap(),
      where: '$columnId = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}
