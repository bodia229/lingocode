import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/flashcard.dart';
import '../models/lesson.dart';
import '../services/database.dart';
import '../services/lesson_repo.dart';
import '../services/streak.dart';
import 'review_screen.dart';
import 'lesson_list_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _lessonRepo = LessonRepository();

  int _due = 0;
  int _total = 0;
  int _learned = 0;
  int _streak = 0;
  int _xp = 0;
  List<Lesson> _lessons = const [];
  List<LessonProgress> _progress = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final due = await Db.instance.countDue(type: CardType.english);
    final total = await Db.instance.countTotal(type: CardType.english);
    final learned = await Db.instance.countLearned(type: CardType.english);
    final streak = await StreakService.streak();
    final xp = await StreakService.xp();
    final lessons = await _lessonRepo.all();
    final progress = await Db.instance.allLessonProgress();
    if (!mounted) return;
    setState(() {
      _due = due;
      _total = total;
      _learned = learned;
      _streak = streak;
      _xp = xp;
      _lessons = lessons;
      _progress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final completedLessons = _progress.where((p) => p.isComplete).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('app_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: context.tr('stats'),
            onPressed: () async {
              await Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const StatsScreen()));
              _load();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: context.tr('settings'),
            onPressed: () async {
              await Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                _statTile(
                    icon: Icons.local_fire_department,
                    label: context.tr('streak'),
                    value: '$_streak',
                    color: Colors.orange),
                const SizedBox(width: 12),
                _statTile(
                    icon: Icons.bolt,
                    label: context.tr('xp'),
                    value: '$_xp',
                    color: cs.primary),
              ],
            ),
            const SizedBox(height: 24),
            Text(context.tr('english_flashcards'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              color: cs.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('cards_due_now', {'n': _due}),
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: cs.onPrimaryContainer)),
                    const SizedBox(height: 4),
                    Text(context.tr('learned_x_of_y', {'a': _learned, 'b': _total}),
                        style: TextStyle(color: cs.onPrimaryContainer.withOpacity(.8))),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: Text(_due > 0
                          ? context.tr('start_review')
                          : context.tr('review_anyway')),
                      onPressed: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ReviewScreen()));
                        _load();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.tr('python_lessons'),
                    style: Theme.of(context).textTheme.titleLarge),
                Text('$completedLessons / ${_lessons.length}',
                    style: TextStyle(color: cs.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('lessons_subtitle'), style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.code),
                      label: Text(context.tr('open_lessons')),
                      onPressed: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LessonListScreen()));
                        _load();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(context.tr('tip_title'), style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              context.tr('tip_body'),
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
