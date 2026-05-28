import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/flashcard.dart';
import 'database.dart';

class Seeder {
  /// Merge JSON-defined cards into the local DB, preserving SRS progress
  /// of any card already present (matched by type+front).
  static Future<SeedReport> syncContent() async {
    final raw = await rootBundle.loadString('assets/data/english_cards.json');
    final fromAssets = (jsonDecode(raw) as List)
        .map((j) => _cardFromJson(j as Map<String, dynamic>))
        .toList();

    final db = await Db.instance.database;
    final rows = await db.query('flashcards',
        columns: ['front', 'type'], where: 'type = ?', whereArgs: [CardType.english.name]);
    final existing = rows
        .map((r) => '${r['type']}|${r['front']}')
        .toSet();

    int added = 0;
    final batch = db.batch();
    for (final c in fromAssets) {
      final key = '${c.type.name}|${c.front}';
      if (existing.contains(key)) continue;
      batch.insert('flashcards', c.toMap()..remove('id'));
      added += 1;
    }
    if (added > 0) {
      await batch.commit(noResult: true);
    }
    return SeedReport(totalInAssets: fromAssets.length, newlyAdded: added);
  }

  static Flashcard _cardFromJson(Map<String, dynamic> j) => Flashcard(
        type: CardType.english,
        front: j['front'] as String,
        back: j['back'] as String,
        example: j['example'] as String?,
        hint: j['hint'] as String?,
        audioText: j['audio_text'] as String? ?? j['front'] as String,
        topic: j['topic'] as String? ?? 'general',
      );
}

class SeedReport {
  final int totalInAssets;
  final int newlyAdded;
  const SeedReport({required this.totalInAssets, required this.newlyAdded});
}
