// ignore_for_file: avoid_print

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note_model.dart';

class NoteDatabase {
  static final NoteDatabase instance = NoteDatabase._init();
  static Database? _database;

  NoteDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT,
        color TEXT,
        category TEXT DEFAULT 'General',
        date_created TEXT NOT NULL,
        date_updated TEXT NOT NULL,
        date_deleted TEXT,
        is_deleted BOOLEAN NOT NULL DEFAULT 0
      )
    ''');
  }

  // Insert a new note
  Future<int> insertNote(Note note) async {
    final db = await instance.database;
    return await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all notes (excluding deleted ones)
  Future<List<Note>> getNotes() async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'is_deleted = ?',
      whereArgs: [0],
    );

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Fetch a single note by ID
  Future<Note?> getNoteById(int id) async {
    final db = await instance.database;
    final result = await db.query('notes', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return Note.fromMap(result.first);
    }
    return null;
  }

  // Update a note
  Future<int> updateNote({
    required int id,
    required String title,
    required String content,
    required String color,
    required String category,
  }) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      {
        'title': title,
        'content': content,
        'color': color,
        'category': category,
        'date_updated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Soft delete a note
  Future<int> softDeleteNote(int id) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      {'is_deleted': 1, 'date_deleted': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Restore a soft-deleted note
  Future<int> restoreNote(int id) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      {'is_deleted': 0, 'date_deleted': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Permanently delete a note
  Future<int> deleteNotePermanently(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Close database
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
