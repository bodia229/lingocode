import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../models/lesson.dart';
import '../services/database.dart';
import '../services/lesson_repo.dart';
import '../services/streak.dart';
import 'review_screen.dart';
import 'lesson_list_screen.dart';
import 'stats_screen.dart';

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
        title: const Text('LingoCode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Stats',
            onPressed: () async {
              await Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const StatsScreen()));
              _load();
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
                    label: 'Streak',
                    value: '$_streak',
                    color: Colors.orange),
                const SizedBox(width: 12),
                _statTile(
                    icon: Icons.bolt,
                    label: 'XP',
                    value: '$_xp',
                    color: cs.primary),
              ],
            ),
            const SizedBox(height: 24),
            Text('English flashcards', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              color: cs.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$_due cards due now',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: cs.onPrimaryContainer)),
                    const SizedBox(height: 4),
                    Text('Learned $_learned of $_total',
                        style: TextStyle(color: cs.onPrimaryContainer.withOpacity(.8))),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: Text(_due > 0 ? 'Start review' : 'Review anyway'),
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
                Text('Python lessons',
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
                    const Text('Interactive exercises with instant feedback.',
                        style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.code),
                      label: const Text('Open lessons'),
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
            Text('Tip', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Daily reviews protect your streak. Even 5 cards a day keeps long-term retention up.',
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
