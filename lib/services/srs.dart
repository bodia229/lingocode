import '../models/flashcard.dart';

/// Quality grades for SM-2 algorithm.
enum Grade {
  again, // total blackout (0)
  hard, // recalled with serious difficulty (3)
  good, // recalled correctly (4)
  easy, // perfect recall (5)
}

/// SM-2 spaced repetition algorithm, adapted from SuperMemo 2.
/// Reference: https://www.supermemo.com/en/blog/application-of-a-computer-to-improve-the-results-obtained-in-working-with-the-supermemo-method
class Srs {
  static Flashcard schedule(Flashcard card, Grade grade) {
    final q = switch (grade) {
      Grade.again => 0,
      Grade.hard => 3,
      Grade.good => 4,
      Grade.easy => 5,
    };

    double newEase = card.ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    if (newEase < 1.3) newEase = 1.3;

    int newReps = card.repetitions;
    int newInterval;
    int newLapses = card.lapses;

    if (q < 3) {
      newReps = 0;
      newInterval = 1;
      newLapses = card.lapses + 1;
    } else {
      newReps = card.repetitions + 1;
      if (newReps == 1) {
        newInterval = 1;
      } else if (newReps == 2) {
        newInterval = 6;
      } else {
        newInterval = (card.intervalDays * newEase).round();
      }
    }

    card.ease = double.parse(newEase.toStringAsFixed(2));
    card.repetitions = newReps;
    card.intervalDays = newInterval;
    card.lapses = newLapses;
    card.nextReview = DateTime.now().add(Duration(days: newInterval));
    return card;
  }

  /// Preview the next interval without mutating the card.
  static int previewInterval(Flashcard card, Grade grade) {
    final clone = Flashcard(
      id: card.id,
      type: card.type,
      front: card.front,
      back: card.back,
      topic: card.topic,
      ease: card.ease,
      intervalDays: card.intervalDays,
      repetitions: card.repetitions,
      nextReview: card.nextReview,
      lapses: card.lapses,
    );
    return schedule(clone, grade).intervalDays;
  }
}
