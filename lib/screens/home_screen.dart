import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/flashcard.dart';
import '../models/lesson.dart';
import '../services/database.dart';
import '../services/game_service.dart';
import '../services/lesson_repo.dart';
import '../services/streak.dart';
import 'achievements_screen.dart';
import 'deck_screen.dart';
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
  int _dailyCount = 0;
  int _dailyGoal = GameService.defaultDailyGoal;
  int _unlockedCount = 0;
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
    final dailyCount = await GameService.dailyReviewed();
    final dailyGoal = await GameService.dailyGoal();
    final unlocked = await GameService.unlockedIds();
    if (!mounted) return;
    setState(() {
      _due = due;
      _total = total;
      _learned = learned;
      _streak = streak;
      _xp = xp;
      _lessons = lessons;
      _progress = progress;
      _dailyCount = dailyCount;
      _dailyGoal = dailyGoal;
      _unlockedCount = unlocked.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final completedLessons = _progress.where((p) => p.isComplete).length;
    final level = GameService.levelFromXp(_xp);
    final levelProgress = GameService.levelProgress(_xp);
    final xpIntoLevel = GameService.xpIntoLevel(_xp);
    final dailyProgress = _dailyGoal == 0 ? 0.0 : (_dailyCount / _dailyGoal).clamp(0.0, 1.0);
    final dailyDone = _dailyCount >= _dailyGoal;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('app_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: context.tr('achievements'),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AchievementsScreen()));
              _load();
            },
          ),
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
            // Level card
            Card(
              color: cs.primary,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${context.tr('level')} $level',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: cs.onPrimary)),
                        Text('$xpIntoLevel / ${GameService.xpPerLevel} XP',
                            style: TextStyle(color: cs.onPrimary.withOpacity(.85))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: levelProgress,
                        minHeight: 10,
                        backgroundColor: cs.onPrimary.withOpacity(.25),
                        valueColor: AlwaysStoppedAnimation(cs.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statTile(
                    icon: Icons.local_fire_department,
                    label: context.tr('streak'),
                    value: '$_streak',
                    color: Colors.orange),
                const SizedBox(width: 12),
                _statTile(
                    icon: Icons.emoji_events,
                    label: context.tr('achievements'),
                    value: '$_unlockedCount',
                    color: Colors.amber),
              ],
            ),
            const SizedBox(height: 16),
            // Daily goal
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flag, color: cs.primary, size: 20),
                            const SizedBox(width: 6),
                            Text(context.tr('daily_goal'),
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        InkWell(
                          onTap: _showDailyGoalDialog,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            child: Text(
                              dailyDone
                                  ? '✓ ${context.tr('daily_goal_done')}'
                                  : '$_dailyCount / $_dailyGoal',
                              style: TextStyle(
                                color: dailyDone ? Colors.green : cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: dailyProgress,
                        minHeight: 8,
                        valueColor: AlwaysStoppedAnimation(
                            dailyDone ? Colors.green : cs.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(context.tr('english_flashcards'),
                style: Theme.of(context).textTheme.titleLarge),
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
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: Text(_due > 0
                                ? context.tr('start_review')
                                : context.tr('review_anyway')),
                            onPressed: () async {
                              await Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const ReviewScreen()));
                              _load();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.view_list),
                          label: Text(context.tr('deck')),
                          onPressed: () async {
                            await Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const DeckScreen()));
                            _load();
                          },
                        ),
                      ],
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
                    Text(context.tr('lessons_subtitle'),
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.code),
                      label: Text(context.tr('open_lessons')),
                      onPressed: () async {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const LessonListScreen()));
                        _load();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(context.tr('tip_title'),
                style: Theme.of(context).textTheme.titleSmall),
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

  Future<void> _showDailyGoalDialog() async {
    int selected = _dailyGoal;
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('set_daily_goal')),
        content: StatefulBuilder(
          builder: (ctx, setState) => Wrap(
            spacing: 8,
            children: [5, 10, 15, 20, 30, 50].map((n) {
              return ChoiceChip(
                label: Text('$n'),
                selected: selected == n,
                onSelected: (_) => setState(() => selected = n),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, selected),
              child: const Text('OK')),
        ],
      ),
    );
    if (result != null) {
      await GameService.setDailyGoal(result);
      _load();
    }
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
