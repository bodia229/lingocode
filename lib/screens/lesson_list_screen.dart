import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../services/database.dart';
import '../services/lesson_repo.dart';
import 'lesson_screen.dart';

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({super.key});
  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  final _repo = LessonRepository();
  List<Lesson> _lessons = const [];
  Map<String, LessonProgress> _progress = const {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lessons = await _repo.all();
    final list = await Db.instance.allLessonProgress();
    final map = {for (final p in list) p.lessonId: p};
    if (!mounted) return;
    setState(() {
      _lessons = lessons;
      _progress = map;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Python lessons')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _lessons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final l = _lessons[i];
                final p = _progress[l.id];
                final done = p?.isComplete ?? false;
                return Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor:
                          done ? cs.primary : cs.surfaceContainerHighest,
                      foregroundColor: done ? cs.onPrimary : cs.onSurface,
                      child: done
                          ? const Icon(Icons.check)
                          : Text('${l.order}'),
                    ),
                    title: Text(l.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(l.description),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: p?.progress ?? 0,
                          backgroundColor: cs.surfaceContainerHighest,
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LessonScreen(lesson: l)));
                      _load();
                    },
                  ),
                );
              },
            ),
    );
  }
}
