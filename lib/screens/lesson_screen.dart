import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/lesson.dart';
import '../services/checker.dart';
import '../services/database.dart';
import '../services/streak.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _index = 0;
  final _controller = TextEditingController();
  String? _feedback;
  bool _correct = false;
  int _completedCount = 0;

  Exercise get _exercise => widget.lesson.exercises[_index];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final p = await Db.instance.lessonProgress(widget.lesson.id);
    if (p != null && mounted) {
      setState(() => _completedCount = p.completedExercises);
    }
  }

  Future<void> _check() async {
    final user = _controller.text.trim();
    if (user.isEmpty) return;
    final ok = AnswerChecker.isCorrect(user, _exercise.expected);
    setState(() {
      _feedback = ok
          ? context.tr('correct')
          : context.tr('not_quite_expected', {'expected': _exercise.expected});
      _correct = ok;
    });
    if (ok) {
      await StreakService.addXp(5);
      await StreakService.bumpForReviewToday();
    }
  }

  Future<void> _choose(String value) async {
    final ok = AnswerChecker.isCorrect(value, _exercise.expected);
    setState(() {
      _feedback = ok
          ? context.tr('correct')
          : context.tr('wrong_expected', {'expected': _exercise.expected});
      _correct = ok;
    });
    if (ok) {
      await StreakService.addXp(5);
      await StreakService.bumpForReviewToday();
    }
  }

  Future<void> _next() async {
    if (_correct) {
      final newCompleted = _index + 1 > _completedCount ? _index + 1 : _completedCount;
      await Db.instance.saveLessonProgress(LessonProgress(
        lessonId: widget.lesson.id,
        completedExercises: newCompleted,
        totalExercises: widget.lesson.exercises.length,
        completedAt: newCompleted >= widget.lesson.exercises.length
            ? DateTime.now()
            : null,
      ));
    }
    if (_index + 1 >= widget.lesson.exercises.length) {
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }
    setState(() {
      _index += 1;
      _controller.clear();
      _feedback = null;
      _correct = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ex = _exercise;
    final progress = (_index + 1) / widget.lesson.exercises.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.tr('lesson_progress', {'i': _index + 1, 'n': widget.lesson.exercises.length}),
                  style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),
              _PromptBlock(prompt: ex.prompt),
              const SizedBox(height: 20),
              Expanded(child: _buildInput(ex)),
              if (_feedback != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _correct
                        ? Colors.green.withOpacity(.15)
                        : Colors.red.withOpacity(.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(_correct ? Icons.check_circle : Icons.cancel,
                          color: _correct ? Colors.green : Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_feedback!)),
                    ],
                  ),
                ),
                if (ex.explanation != null) ...[
                  const SizedBox(height: 8),
                  Text(ex.explanation!,
                      style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ],
              const SizedBox(height: 16),
              if (_feedback == null)
                FilledButton(
                  onPressed: ex.kind == ExerciseKind.multipleChoice ? null : _check,
                  child: Text(context.tr('check')),
                )
              else
                FilledButton(
                  onPressed: _next,
                  child: Text(_index + 1 >= widget.lesson.exercises.length
                      ? context.tr('finish')
                      : context.tr('next')),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(Exercise ex) {
    switch (ex.kind) {
      case ExerciseKind.multipleChoice:
        return ListView.separated(
          itemCount: ex.choices?.length ?? 0,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final c = ex.choices![i];
            return OutlinedButton(
              onPressed: _feedback == null ? () => _choose(c) : null,
              child: Align(alignment: Alignment.centerLeft, child: Text(c)),
            );
          },
        );
      case ExerciseKind.fillBlank:
      case ExerciseKind.writeOutput:
      case ExerciseKind.orderLines:
        return TextField(
          controller: _controller,
          maxLines: ex.kind == ExerciseKind.writeOutput ? 3 : 1,
          enabled: _feedback == null,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: context.tr('your_answer'),
          ),
        );
    }
  }
}

class _PromptBlock extends StatelessWidget {
  final String prompt;
  const _PromptBlock({required this.prompt});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        prompt,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
      ),
    );
  }
}
