import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/flashcard.dart';
import '../models/lesson.dart';

class Db {
  Db._();
  static final Db instance = Db._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return openDatabase('lingocode.db',
          version: 1, onCreate: _onCreate);
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'lingocode.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE flashcards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        front TEXT NOT NULL,
        back TEXT NOT NULL,
        example TEXT,
        hint TEXT,
        audio_text TEXT,
        topic TEXT NOT NULL,
        ease REAL NOT NULL DEFAULT 2.5,
        interval_days INTEGER NOT NULL DEFAULT 0,
        repetitions INTEGER NOT NULL DEFAULT 0,
        next_review TEXT NOT NULL,
        lapses INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE lesson_progress (
        lesson_id TEXT PRIMARY KEY,
        completed_exercises INTEGER NOT NULL DEFAULT 0,
        total_exercises INTEGER NOT NULL,
        completed_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE app_stats (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_cards_next ON flashcards(next_review)');
    await db.execute('CREATE INDEX idx_cards_type ON flashcards(type)');
  }

  Future<int> insertCard(Flashcard c) async {
    final db = await database;
    return db.insert('flashcards', c.toMap()..remove('id'));
  }

  Future<void> upsertCardsIfEmpty(List<Flashcard> cards) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM flashcards')) ??
        0;
    if (count > 0) return;
    final batch = db.batch();
    for (final c in cards) {
      batch.insert('flashcards', c.toMap()..remove('id'));
    }
    await batch.commit(noResult: true);
  }

  Future<void> updateCard(Flashcard c) async {
    final db = await database;
    await db.update('flashcards', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<List<Flashcard>> dueCards({CardType? type, int limit = 30}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final rows = await db.query(
      'flashcards',
      where: type == null
          ? 'next_review <= ?'
          : 'next_review <= ? AND type = ?',
      whereArgs: type == null ? [now] : [now, type.name],
      orderBy: 'next_review ASC',
      limit: limit,
    );
    return rows.map(Flashcard.fromMap).toList();
  }

  Future<int> countDue({CardType? type}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final result = await db.rawQuery(
      type == null
          ? 'SELECT COUNT(*) FROM flashcards WHERE next_review <= ?'
          : 'SELECT COUNT(*) FROM flashcards WHERE next_review <= ? AND type = ?',
      type == null ? [now] : [now, type.name],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countTotal({CardType? type}) async {
    final db = await database;
    final result = await db.rawQuery(
      type == null
          ? 'SELECT COUNT(*) FROM flashcards'
          : 'SELECT COUNT(*) FROM flashcards WHERE type = ?',
      type == null ? [] : [type.name],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countLearned({CardType? type}) async {
    final db = await database;
    final result = await db.rawQuery(
      type == null
          ? 'SELECT COUNT(*) FROM flashcards WHERE repetitions > 0'
          : 'SELECT COUNT(*) FROM flashcards WHERE repetitions > 0 AND type = ?',
      type == null ? [] : [type.name],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<LessonProgress?> lessonProgress(String lessonId) async {
    final db = await database;
    final rows = await db.query('lesson_progress',
        where: 'lesson_id = ?', whereArgs: [lessonId], limit: 1);
    if (rows.isEmpty) return null;
    return LessonProgress.fromMap(rows.first);
  }

  Future<void> saveLessonProgress(LessonProgress p) async {
    final db = await database;
    await db.insert('lesson_progress', p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<LessonProgress>> allLessonProgress() async {
    final db = await database;
    final rows = await db.query('lesson_progress');
    return rows.map(LessonProgress.fromMap).toList();
  }

  Future<String?> getStat(String key) async {
    final db = await database;
    final rows = await db.query('app_stats',
        where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setStat(String key, String value) async {
    final db = await database;
    await db.insert('app_stats', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
