import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/flashcard.dart';
import 'database.dart';

class Seeder {
  static Future<void> seedIfEmpty() async {
    final raw = await rootBundle.loadString('assets/data/english_cards.json');
    final cards = (jsonDecode(raw) as List)
        .map((j) => Flashcard(
              type: CardType.english,
              front: j['front'] as String,
              back: j['back'] as String,
              example: j['example'] as String?,
              hint: j['hint'] as String?,
              audioText: j['audio_text'] as String? ?? j['front'] as String,
              topic: j['topic'] as String? ?? 'tech',
            ))
        .toList();
    await Db.instance.upsertCardsIfEmpty(cards);
  }
}
