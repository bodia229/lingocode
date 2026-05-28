enum CardType { english, python }

class Flashcard {
  final int? id;
  final CardType type;
  final String front;
  final String back;
  final String? example;
  final String? hint;
  final String? audioText;
  final String topic;

  double ease;
  int intervalDays;
  int repetitions;
  DateTime nextReview;
  int lapses;

  Flashcard({
    this.id,
    required this.type,
    required this.front,
    required this.back,
    this.example,
    this.hint,
    this.audioText,
    required this.topic,
    this.ease = 2.5,
    this.intervalDays = 0,
    this.repetitions = 0,
    DateTime? nextReview,
    this.lapses = 0,
  }) : nextReview = nextReview ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'front': front,
        'back': back,
        'example': example,
        'hint': hint,
        'audio_text': audioText,
        'topic': topic,
        'ease': ease,
        'interval_days': intervalDays,
        'repetitions': repetitions,
        'next_review': nextReview.toIso8601String(),
        'lapses': lapses,
      };

  factory Flashcard.fromMap(Map<String, dynamic> m) => Flashcard(
        id: m['id'] as int?,
        type: CardType.values.firstWhere((e) => e.name == m['type']),
        front: m['front'] as String,
        back: m['back'] as String,
        example: m['example'] as String?,
        hint: m['hint'] as String?,
        audioText: m['audio_text'] as String?,
        topic: m['topic'] as String,
        ease: (m['ease'] as num).toDouble(),
        intervalDays: m['interval_days'] as int,
        repetitions: m['repetitions'] as int,
        nextReview: DateTime.parse(m['next_review'] as String),
        lapses: m['lapses'] as int,
      );

  bool get isDue => DateTime.now().isAfter(nextReview);
}
