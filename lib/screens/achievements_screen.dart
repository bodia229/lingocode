import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/achievement.dart';
import '../models/flashcard.dart';
import '../services/database.dart';
import '../services/game_service.dart';
import '../services/streak.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});
  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Set<String> _unlocked = const {};
  GameMetrics? _metrics;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unlocked = await GameService.unlockedIds();
    final reviewed = await GameService.reviewedTotal();
    final streak = await StreakService.streak();
    final xp = await StreakService.xp();
    final perfect = await GameService.perfectSessions();
    final combo = await GameService.comboBest();
    final learned = await Db.instance.countLearned(type: CardType.english);
    final progress = await Db.instance.allLessonProgress();
    final lessonsDone = progress.where((p) => p.isComplete).length;
    if (!mounted) return;
    setState(() {
      _unlocked = unlocked;
      _metrics = GameMetrics(
        cardsReviewed: reviewed,
        streakDays: streak,
        xpEarned: xp,
        lessonsCompleted: lessonsDone,
        cardsLearned: learned,
        perfectSessions: perfect,
        comboBest: combo,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_metrics == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('achievements'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final total = Achievements.all.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('achievements')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.tr('unlocked_x_of_y', {'a': _unlocked.length, 'b': total}),
                style: TextStyle(color: cs.onPrimary.withOpacity(.85)),
              ),
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: Achievements.all.length,
        itemBuilder: (_, i) {
          final a = Achievements.all[i];
          final unlocked = _unlocked.contains(a.id);
          final value = _metrics!.valueFor(a.metric);
          final progress = (value / a.threshold).clamp(0.0, 1.0);
          return Card(
            color: unlocked
                ? cs.primaryContainer
                : cs.surfaceContainerHighest.withOpacity(.5),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: unlocked ? 1 : 0.35,
                    child: Text(a.emoji, style: const TextStyle(fontSize: 36)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr(a.titleKey),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: unlocked
                          ? cs.onPrimaryContainer
                          : cs.onSurface.withOpacity(.85),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr(a.descKey),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: unlocked
                          ? cs.onPrimaryContainer.withOpacity(.85)
                          : cs.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: cs.surface.withOpacity(.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$value / ${a.threshold}',
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
