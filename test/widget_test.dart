import 'package:flutter_test/flutter_test.dart';

import 'package:lingocode/services/srs.dart';
import 'package:lingocode/models/flashcard.dart';

void main() {
  group('SRS algorithm', () {
    Flashcard newCard() => Flashcard(
          type: CardType.english,
          front: 'function',
          back: 'функція',
          topic: 'test',
        );

    test('first correct review schedules in 1 day', () {
      final c = newCard();
      Srs.schedule(c, Grade.good);
      expect(c.repetitions, 1);
      expect(c.intervalDays, 1);
    });

    test('second correct review schedules in 6 days', () {
      final c = newCard();
      Srs.schedule(c, Grade.good);
      Srs.schedule(c, Grade.good);
      expect(c.repetitions, 2);
      expect(c.intervalDays, 6);
    });

    test('Again resets repetitions and bumps lapses', () {
      final c = newCard();
      Srs.schedule(c, Grade.good);
      Srs.schedule(c, Grade.good);
      Srs.schedule(c, Grade.again);
      expect(c.repetitions, 0);
      expect(c.intervalDays, 1);
      expect(c.lapses, 1);
    });

    test('Ease floor of 1.3', () {
      final c = newCard();
      for (var i = 0; i < 20; i++) {
        Srs.schedule(c, Grade.again);
      }
      expect(c.ease, greaterThanOrEqualTo(1.3));
    });
  });
}
