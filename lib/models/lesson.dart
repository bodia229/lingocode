enum ExerciseKind { fillBlank, multipleChoice, writeOutput, orderLines }

class Exercise {
  final String id;
  final ExerciseKind kind;
  final String prompt;
  final String? codeTemplate;
  final List<String>? choices;
  final String expected;
  final String? explanation;
  final String? hint;

  Exercise({
    required this.id,
    required this.kind,
    required this.prompt,
    this.codeTemplate,
    this.choices,
    required this.expected,
    this.explanation,
    this.hint,
  });

  factory Exercise.fromJson(Map<String, dynamic> j) => Exercise(
        id: j['id'] as String,
        kind: ExerciseKind.values.firstWhere((e) => e.name == j['kind']),
        prompt: j['prompt'] as String,
        codeTemplate: j['code_template'] as String?,
        choices: (j['choices'] as List?)?.map((e) => e as String).toList(),
        expected: j['expected'] as String,
        explanation: j['explanation'] as String?,
        hint: j['hint'] as String?,
      );
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final String topic;
  final int order;
  final List<Exercise> exercises;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.topic,
    required this.order,
    required this.exercises,
  });

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        topic: j['topic'] as String,
        order: j['order'] as int,
        exercises: (j['exercises'] as List)
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class LessonProgress {
  final String lessonId;
  final int completedExercises;
  final int totalExercises;
  final DateTime? completedAt;

  LessonProgress({
    required this.lessonId,
    required this.completedExercises,
    required this.totalExercises,
    this.completedAt,
  });

  bool get isComplete => completedExercises >= totalExercises;
  double get progress => totalExercises == 0 ? 0 : completedExercises / totalExercises;

  Map<String, dynamic> toMap() => {
        'lesson_id': lessonId,
        'completed_exercises': completedExercises,
        'total_exercises': totalExercises,
        'completed_at': completedAt?.toIso8601String(),
      };

  factory LessonProgress.fromMap(Map<String, dynamic> m) => LessonProgress(
        lessonId: m['lesson_id'] as String,
        completedExercises: m['completed_exercises'] as int,
        totalExercises: m['total_exercises'] as int,
        completedAt: m['completed_at'] == null
            ? null
            : DateTime.parse(m['completed_at'] as String),
      );
}
